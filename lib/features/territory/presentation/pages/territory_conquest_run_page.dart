import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/core/theme/app_theme.dart';
import 'package:runn_front/core/services/http_client.dart';
import '../../../start_career/services/actividades_service.dart';
import '../../data/models/territory_model.dart';
import '../../services/territory_service.dart';

/// Pantalla de carrera activa para conquista/disputa de territorio.
/// Inicia una actividad nueva, muestra el polígono del territorio en el mapa,
/// y al finalizar envía el reclamo de conquista al backend.
class TerritoryConquestRunPage extends StatefulWidget {
  final TerritoryModel territory;
  final String actividadId;
  final String horaInicio;
  final double? latInicio;
  final double? lngInicio;
  final String modalidad;
  final String? grupoId;

  const TerritoryConquestRunPage({
    super.key,
    required this.territory,
    required this.actividadId,
    required this.horaInicio,
    this.latInicio,
    this.lngInicio,
    required this.modalidad,
    this.grupoId,
  });

  @override
  State<TerritoryConquestRunPage> createState() =>
      _TerritoryConquestRunPageState();
}

class _TerritoryConquestRunPageState extends State<TerritoryConquestRunPage>
    with TickerProviderStateMixin {
  AppColors get c => context.colors;

  // Cronómetro
  int _duracionSegs = 0;
  bool _corriendo = true;
  Timer? _timer;

  // Métricas GPS
  List<LatLng> _puntos = [];
  double _distanciaKm = 0;
  double _velocidadMaxKmh = 0;
  double _pesoKg = 70;

  // GPS
  StreamSubscription<Position>? _gpsSub;
  Position? _lastPosition;

  // Mapa
  GoogleMapController? _mapController;
  late AnimationController _pulseCtrl;
  Set<Polygon> _polygons = {};
  Set<Polyline> _polylines = {};

  // UI
  bool _finalizando = false;
  String? _errorFinalizar;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _cargarPeso();
    _startTimer();
    _startGps();
    _buildPolygonOverlay();

    if (widget.latInicio != null && widget.lngInicio != null) {
      _puntos = [LatLng(widget.latInicio!, widget.lngInicio!)];
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gpsSub?.cancel();
    _pulseCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _cargarPeso() async {
    final prefs = await SharedPreferences.getInstance();
    final peso = prefs.getDouble(ApiConfig.userPesoKey);
    if (peso != null && mounted) setState(() => _pesoKg = peso);
  }

  /// Construye el polígono del territorio para mostrarlo en el mapa.
  void _buildPolygonOverlay() {
    try {
      final poligono = widget.territory.poligono;
      if (poligono == null) return;

      final geom = poligono is String ? jsonDecode(poligono) : poligono;
      if (geom == null || geom['type'] != 'Polygon') return;

      final coords = geom['coordinates'] as List<dynamic>;
      final ring = coords[0] as List<dynamic>;

      final points = ring
          .map<LatLng>((c) => LatLng(
                (c[1] as num).toDouble(),
                (c[0] as num).toDouble(),
              ))
          .toList();

      setState(() {
        _polygons = {
          Polygon(
            polygonId: const PolygonId('territorio'),
            points: points,
            fillColor: Colors.orange.withValues(alpha: 0.15),
            strokeColor: Colors.orange,
            strokeWidth: 3,
          ),
        };
      });

      // Centrar el mapa en el polígono
      if (points.isNotEmpty) {
        final lats = points.map((p) => p.latitude);
        final lngs = points.map((p) => p.longitude);
        final centroLat = (lats.reduce(min) + lats.reduce(max)) / 2;
        final centroLng = (lngs.reduce(min) + lngs.reduce(max)) / 2;
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(centroLat, centroLng), zoom: 16),
          ),
        );
      }
    } catch (_) {}
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _duracionSegs++);
    });
  }

  void _pausarReanudar() {
    if (_corriendo) {
      _timer?.cancel();
      _gpsSub?.cancel();
    } else {
      _startTimer();
      _startGps();
    }
    setState(() => _corriendo = !_corriendo);
  }

  void _startGps() {
    _gpsSub?.cancel();
    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(_onNewPosition, onError: (_) {});
  }

  void _onNewPosition(Position pos) {
    if (!mounted) return;
    final nuevo = LatLng(pos.latitude, pos.longitude);

    double delta = 0;
    if (_lastPosition != null) {
      delta = _haversineKm(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );
    }

    if (pos.speed > 0) {
      final velKmh = pos.speed * 3.6;
      if (velKmh > _velocidadMaxKmh) _velocidadMaxKmh = velKmh;
    }

    setState(() {
      _puntos = [..._puntos, nuevo];
      _distanciaKm += delta;
      _lastPosition = pos;
      _polylines = _puntos.length >= 2
          ? {
              Polyline(
                polylineId: const PolylineId('ruta_conquista'),
                points: _puntos,
                color: c.primaryDeep,
                width: 6,
              ),
            }
          : {};
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(nuevo));
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  double get _ritmoMinkm =>
      _distanciaKm > 0 ? (_duracionSegs / 60) / _distanciaKm : 0;

  double get _velocidadPromedioKmh =>
      _duracionSegs > 0 ? _distanciaKm / (_duracionSegs / 3600) : 0;

  int get _calorias => (_distanciaKm * _pesoKg * 0.72).round();

  String _fmt(int segs) {
    final h = segs ~/ 3600;
    final m = (segs % 3600) ~/ 60;
    final s = segs % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmarFinalizar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final tc = ctx.colors;
        return AlertDialog(
          backgroundColor: tc.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            '¿Finalizar conquista?',
            style: TextStyle(color: tc.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Se analizará tu ruta y se enviará el reclamo de conquista. El backend verificará que hayas rodeado el territorio.',
            style: TextStyle(color: tc.textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Seguir corriendo', style: TextStyle(color: tc.textHint)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: tc.primaryDeep,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('¡Conquistar!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    await _finalizarYConquistar();
  }

  Future<void> _confirmarCancelar() async {
    final tc = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: tc.bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Color(0xFFFF3B30)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('¿Cancelar conquista?',
                    style: TextStyle(
                        color: tc.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
          content: Text(
            'Esta actividad se eliminará y tu intento de conquista se descartará por completo.',
            style: TextStyle(color: tc.textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:
                  Text('Seguir corriendo', style: TextStyle(color: tc.textHint)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancelar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    await _cancelarCarrera();
  }

  Future<void> _cancelarCarrera() async {
    _timer?.cancel();
    _gpsSub?.cancel();
    try {
      await ActividadesService.eliminarActividad(widget.actividadId);
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  Future<void> _finalizarYConquistar() async {
    _timer?.cancel();
    _gpsSub?.cancel();
    setState(() {
      _finalizando = true;
      _errorFinalizar = null;
    });

    // 1. Construir GeoJSON de la ruta
    String? rutaJson;
    if (_puntos.length >= 2) {
      final coords = _puntos.map((p) => [p.longitude, p.latitude]).toList();
      rutaJson = jsonEncode({'type': 'LineString', 'coordinates': coords});
    }

    try {
      // 2. Finalizar la actividad en el backend (guarda la ruta GPS)
      await ActividadesService.finalizarActividad(
        widget.actividadId,
        distanciaKm: double.parse(_distanciaKm.toStringAsFixed(3)),
        duracionSegs: _duracionSegs,
        velocidadPromedio: double.parse(_velocidadPromedioKmh.toStringAsFixed(2)),
        velocidadMax: double.parse(_velocidadMaxKmh.toStringAsFixed(2)),
        ritmoPromedio: double.parse(_ritmoMinkm.toStringAsFixed(2)),
        calorias: _calorias,
        ruta: rutaJson,
      );

      // 3. Enviar el reclamo de conquista → backend valida ruta vs polígono
      final resultado = await TerritorioService.conquistar(
        territorioId: widget.territory.id,
        actividadId: widget.actividadId,
        tiempoSegs: _duracionSegs,
        modalidad: widget.modalidad,
        grupoId: widget.grupoId,
      );

      if (!mounted) return;

      // 4. Mostrar resultado de la conquista
      _mostrarResultadoConquista(resultado);
    } on ApiException catch (e) {
      if (!mounted) return;
      // Puede ser una ruta inválida (422) u otro error → mostrar claro
      setState(() {
        _errorFinalizar = e.message;
        _finalizando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorFinalizar = 'Error inesperado. Intenta de nuevo.';
        _finalizando = false;
      });
    }
  }

  void _mostrarResultadoConquista(Map<String, dynamic> resultado) {
    final tc = context.colors;
    final ganado = resultado['resultado'] == 'ganado' ||
        resultado['resultado'] == 'aporte_registrado';
    final mensaje = resultado['mensaje'] as String? ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: tc.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              ganado ? Icons.emoji_events_rounded : Icons.close_rounded,
              color: ganado ? Colors.amber : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ganado ? '¡Territorio conquistado!' : 'Intento fallido',
                style: TextStyle(
                  color: tc.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mensaje, style: TextStyle(color: tc.textSecondary, height: 1.5)),
            const SizedBox(height: 12),
            _resumenStat(tc, Icons.timer_rounded, 'Tiempo', _fmt(_duracionSegs)),
            _resumenStat(tc, Icons.straighten_rounded, 'Distancia', '${_distanciaKm.toStringAsFixed(2)} km'),
            if (resultado['puntos_ganados'] != null)
              _resumenStat(tc, Icons.star_rounded, 'Puntos', '+${resultado['puntos_ganados']}'),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: tc.primaryDeep,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // vuelve al detalle del territorio
            },
            child: const Text('Ver territorio'),
          ),
        ],
      ),
    );
  }

  Widget _resumenStat(AppColors tc, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: tc.primaryDeep),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: tc.textSecondary, fontSize: 14)),
          Text(value, style: TextStyle(color: tc.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = context.colors;
    final posActual = _puntos.isNotEmpty ? _puntos.last : null;

    return Scaffold(
      backgroundColor: tc.bg,
      body: Column(
        children: [
          // ── MAPA (mitad superior) ─────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: posActual ??
                        (widget.latInicio != null
                            ? LatLng(widget.latInicio!, widget.lngInicio!)
                            : const LatLng(-0.22985, -78.52495)),
                    zoom: 16,
                  ),
                  onMapCreated: (ctrl) {
                    _mapController = ctrl;
                    _buildPolygonOverlay();
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  polygons: _polygons,
                  polylines: _polylines,
                  markers: posActual != null
                      ? {
                          Marker(
                            markerId: const MarkerId('actual'),
                            position: posActual,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure,
                            ),
                          ),
                        }
                      : {},
                ),

                // Botón Cancelar
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: GestureDetector(
                    onTap: _confirmarCancelar,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),

                // Banner de modo conquista
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 64, // Movido a la derecha para dar espacio al botón de cerrar
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: tc.card.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12),
                      ],
                    ),
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) => Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _corriendo
                                  ? Color.lerp(Colors.orange, Colors.orange.withValues(alpha: 0.3), _pulseCtrl.value)!
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.territory.nombre,
                                style: TextStyle(fontWeight: FontWeight.w800, color: tc.textPrimary, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '¡Rodea el territorio naranja!',
                                style: TextStyle(color: tc.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.modalidad == 'grupal' ? '👥 Grupal' : '👤 Individual',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── MÉTRICAS + CONTROLES (mitad inferior) ─────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 8 : 28),
            decoration: BoxDecoration(
              color: tc.bg,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Crece solo lo necesario
              children: [
                // Cronómetro Central
                Column(
                  children: [
                    Text('TIEMPO TOTAL',
                        style: TextStyle(
                            color: tc.textHint,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 1),
                    Text(
                      _fmt(_duracionSegs),
                      style: TextStyle(
                        color: tc.textPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Cuadrícula de Métricas
                LayoutBuilder(builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 12) / 2;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _metricCard(tc, Icons.straighten_rounded, tc.primaryDeep, 'Distancia', _distanciaKm.toStringAsFixed(2), 'km'),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _metricCard(tc, Icons.speed_rounded, tc.primaryDeep, 'Ritmo', _ritmoMinkm > 0 ? _ritmoMinkm.toStringAsFixed(1) : '--', 'min/km'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _metricCard(tc, Icons.local_fire_department_rounded, const Color(0xFFFF6B35), 'Calorías', '$_calorias', 'kcal'),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _metricCard(tc, Icons.trending_up_rounded, const Color(0xFF34C759), 'Velocidad', _velocidadPromedioKmh.toStringAsFixed(1), 'km/h'),
                          ),
                        ],
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 16),

                // Botones de Acción y Errores
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Error de finalizar (si existe)
                    if (_errorFinalizar != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFF3B30).withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_rounded, color: Color(0xFFFF3B30), size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_errorFinalizar!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Color(0xFFFF3B30), fontSize: 11)),
                            ),
                            GestureDetector(
                              onTap: _finalizarYConquistar,
                              child: const Text('Reintentar',
                                  style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ],
                        ),
                      ),

                    if (_finalizando)
                      const Center(child: CircularProgressIndicator(strokeWidth: 3))
                    else
                      Row(
                        children: [
                          // Botón Pausar/Reanudar (Principal)
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _pausarReanudar,
                                icon: Icon(
                                  _corriendo ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  _corriendo ? 'Pausar' : 'Reanudar',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _corriendo ? tc.primaryDeep : const Color(0xFF34C759),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Botón Finalizar (Secundario)
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: _confirmarFinalizar,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.orange, width: 1.5),
                                  foregroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text('Finalizar',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(AppColors tc, IconData icon, Color color, String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tc.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: tc.textHint, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(value, style: TextStyle(color: tc.textPrimary, fontSize: 22, fontWeight: FontWeight.w800, height: 1)),
            const SizedBox(width: 3),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(unit, style: TextStyle(color: tc.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
        ],
      ),
    );
  }
}
