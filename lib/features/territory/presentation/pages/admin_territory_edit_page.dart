import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/territory_service.dart';
import '../../data/models/territory_model.dart';

/// Página de creación / edición de un territorio.
/// Solo accesible para admins.
class AdminTerritoryEditPage extends StatefulWidget {
  /// Si no es null, estamos en modo edición.
  final TerritoryModel? territory;

  const AdminTerritoryEditPage({super.key, this.territory});

  @override
  State<AdminTerritoryEditPage> createState() =>
      _AdminTerritoryEditPageState();
}

class _AdminTerritoryEditPageState
    extends State<AdminTerritoryEditPage> {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  String _modalidad = 'individual';

  // ── Map / Polygon ─────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  final List<LatLng> _points = [];
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isSaving = false;
  bool _isFullscreenMap = false;

  // ── Centros iniciales ─────────────────────────────────────────────────────
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(-0.22985, -78.52495), // Quito por defecto
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    final t = widget.territory;
    _nameCtrl = TextEditingController(text: t?.nombre ?? '');
    _descCtrl = TextEditingController(text: t?.descripcion ?? '');
    _modalidad = t?.modalidad ?? 'individual';

    // Si editamos, cargamos el polígono existente
    if (t?.poligono != null) {
      _loadPolygonFromGeoJson(t!.poligono);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Lógica del polígono ───────────────────────────────────────────────────

  void _loadPolygonFromGeoJson(dynamic geo) {
    if (geo == null) return;
    try {
      List<dynamic>? coords;
      if (geo is Map<String, dynamic>) {
        if (geo['type'] == 'Polygon') {
          coords = (geo['coordinates'] as List).first as List;
        } else if (geo['type'] == 'Feature') {
          final geometry = geo['geometry'] as Map<String, dynamic>;
          coords = (geometry['coordinates'] as List).first as List;
        }
      } else if (geo is List) {
        coords = geo;
      }

      if (coords == null || coords.isEmpty) return;

      final points = coords.map<LatLng>((c) {
        final pair = c as List;
        return LatLng(pair[1].toDouble(), pair[0].toDouble());
      }).toList();

      _points.clear();
      _points.addAll(points);
      _rebuildPolygon();
    } catch (_) {
      // Polígono inválido — ignorar silenciosamente
    }
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _points.add(point);
      _rebuildPolygon();
    });
  }

  void _undoLastPoint() {
    if (_points.isEmpty) return;
    setState(() {
      _points.removeLast();
      _rebuildPolygon();
    });
  }

  void _clearPolygon() {
    setState(() {
      _points.clear();
      _polygons = {};
      _markers = {};
    });
  }

  Future<void> _centerOnUser() async {
    if (_mapController == null) return;
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      if (perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16),
      );
    } catch (_) {}
  }

  void _rebuildPolygon() {
    _markers = _points.asMap().entries.map((e) {
      final index = e.key;
      return Marker(
        markerId: MarkerId('pt_$index'),
        position: e.value,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: 'Punto ${index + 1}'),
        draggable: true,
        onDragEnd: (newPos) {
          setState(() {
            _points[index] = newPos;
            _rebuildPolygon();
          });
        },
      );
    }).toSet();

    if (_points.length >= 3) {
      _polygons = {
        Polygon(
          polygonId: const PolygonId('territory'),
          points: _points,
          strokeColor: const Color(0xFF3B82F6),
          strokeWidth: 2,
          fillColor: const Color(0xFF3B82F6).withValues(alpha: 0.25),
        ),
      };
    } else {
      _polygons = {};
    }
  }

  // ── Serialización a GeoJSON ───────────────────────────────────────────────

  Map<String, dynamic> _buildGeoJson() {
    final coords = _points
        .map((p) => [p.longitude, p.latitude])
        .toList();
    // Cerrar el polígono (primer punto == último)
    if (coords.isNotEmpty && coords.first != coords.last) {
      coords.add(coords.first);
    }
    return {
      'type': 'Polygon',
      'coordinates': [coords],
    };
  }

  // ── Guardar ───────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_points.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dibuja al menos 3 puntos en el mapa para definir el territorio.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final geoJson = _buildGeoJson();
      final poligonoString = jsonEncode(geoJson);

      if (widget.territory == null) {
        // Crear nuevo
        await TerritorioService.createTerritorio(
          nombre: _nameCtrl.text.trim(),
          descripcion: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          poligono: poligonoString,
          modalidad: _modalidad,
        );
      } else {
        // Actualizar
        await TerritorioService.updateTerritorio(
          id: widget.territory!.id,
          nombre: _nameCtrl.text.trim(),
          descripcion: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          poligono: poligonoString,
          modalidad: _modalidad,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.territory == null
              ? '¡Territorio creado correctamente! ✅'
              : '¡Territorio actualizado! ✅'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // true = recarga la lista
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isEdit = widget.territory != null;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          isEdit ? 'Editar Territorio' : 'Nuevo Territorio',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.check_rounded, color: c.primaryDeep, size: 26),
              tooltip: 'Guardar',
              onPressed: _save,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Formulario ─────────────────────────────────────────────
              _SectionLabel(label: 'INFORMACIÓN'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameCtrl,
                decoration: _inputDecoration(c, 'Nombre del territorio', Icons.place_rounded),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: _inputDecoration(c, 'Descripción (opcional)', Icons.notes_rounded),
              ),
              const SizedBox(height: 12),

              // Modalidad
              Container(
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.primaryDeepWithAlpha(0.12)),
                ),
                child: Column(
                  children: [
                    _ModalidadOption(
                      value: 'individual',
                      groupValue: _modalidad,
                      label: 'Individual',
                      icon: Icons.person_rounded,
                      onTap: () => setState(() => _modalidad = 'individual'),
                      colors: c,
                    ),
                    Divider(height: 1, color: c.primaryDeepWithAlpha(0.08)),
                    _ModalidadOption(
                      value: 'grupal',
                      groupValue: _modalidad,
                      label: 'Grupal',
                      icon: Icons.group_rounded,
                      onTap: () => setState(() => _modalidad = 'grupal'),
                      colors: c,
                    ),
                    Divider(height: 1, color: c.primaryDeepWithAlpha(0.08)),
                    _ModalidadOption(
                      value: 'ambas',
                      groupValue: _modalidad,
                      label: 'Ambas (Ind. y Grupal)',
                      icon: Icons.public_rounded,
                      onTap: () => setState(() => _modalidad = 'ambas'),
                      colors: c,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Mapa ───────────────────────────────────────────────────
              _SectionLabel(label: 'DIBUJAR POLÍGONO (${_points.length} puntos)'),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.primaryDeepWithAlpha(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.primaryDeepWithAlpha(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_rounded, color: c.primaryDeep, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Muévete libremente por el mapa. Toca zonas para soltar puntos y dibujar el contorno del territorio. Puedes arrastrar los puntos existentes para ajustarlos. ¡Se necesitan al menos 3 puntos!',
                        style: TextStyle(fontSize: 13, color: c.textPrimary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Botones de control del mapa
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _MapControlButton(
                      icon: Icons.undo_rounded,
                      label: 'Deshacer',
                      onTap: _undoLastPoint,
                      colors: c,
                    ),
                    const SizedBox(width: 8),
                    _MapControlButton(
                      icon: Icons.delete_outline_rounded,
                      label: 'Limpiar',
                      onTap: _clearPolygon,
                      colors: c,
                      isDestructive: true,
                    ),
                    const SizedBox(width: 8),
                    _MapControlButton(
                      icon: Icons.my_location_rounded,
                      label: 'Centrar',
                      onTap: _centerOnUser,
                      colors: c,
                    ),
                    const SizedBox(width: 8),
                    _MapControlButton(
                      icon: _isFullscreenMap ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                      label: _isFullscreenMap ? 'Minimizar' : 'Expandir',
                      onTap: () => setState(() => _isFullscreenMap = !_isFullscreenMap),
                      colors: c,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Mapa interactivo
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _isFullscreenMap ? MediaQuery.of(context).size.height * 0.7 : 380,
                  child: GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                    },
                    initialCameraPosition: _initialCamera,
                    onMapCreated: (ctrl) => _mapController = ctrl,
                    onTap: _onMapTap,
                    polygons: _polygons,
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: true,
                    buildingsEnabled: false,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Botón final ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: c.primaryDeep,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEdit ? 'Actualizar Territorio' : 'Crear Territorio',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(dynamic c, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: c.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: c.textSecondary, size: 20),
      filled: true,
      fillColor: c.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.primaryDeepWithAlpha(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.primaryDeepWithAlpha(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.primaryDeep, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: context.colors.textSecondary,
      ),
    );
  }
}

class _ModalidadOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final dynamic colors;

  const _ModalidadOption({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Indicador circular manual — sin Radio deprecado
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colors.primaryDeep : colors.textSecondary,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primaryDeep,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Icon(
              icon,
              size: 18,
              color: isSelected ? colors.primaryDeep : colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colors.textPrimary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final dynamic colors;
  final bool isDestructive;

  const _MapControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colors,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : colors.primaryDeep;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
