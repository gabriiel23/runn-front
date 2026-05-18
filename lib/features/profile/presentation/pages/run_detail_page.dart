import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/core/theme/app_theme.dart';
import 'package:runn_front/core/utils/format_utils.dart';
import '../../../start_career/domain/actividad_model.dart';
import '../../../start_career/services/actividades_service.dart';

class RunDetailPage extends StatefulWidget {
  final String actividadId;

  const RunDetailPage({super.key, required this.actividadId});

  @override
  State<RunDetailPage> createState() => _RunDetailPageState();
}

class _RunDetailPageState extends State<RunDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _badgeCtrl;
  GoogleMapController? _mapController;
  ActividadHistorial? _actividad;
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _error;

  static const LatLng _centroLocalizacionGeneral = LatLng(-0.22985, -78.52495); // Quito, EC

  @override
  void initState() {
    super.initState();
    _badgeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fetchDetail();
  }

  @override
  void dispose() {
    _badgeCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    try {
      final data = await ActividadesService.obtenerDetalle(widget.actividadId);
      if (mounted) {
        setState(() {
          _actividad = data;
          _isLoading = false;
        });
        _badgeCtrl.forward();
        _fitMapBounds();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'No se pudo cargar el detalle';
        });
      }
    }
  }

  Future<void> _borrarActividad() async {
    final c = context.colors;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar actividad', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('¿Seguro quieres eliminar esta actividad permanentemente del historial?', style: TextStyle(color: c.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: TextStyle(color: c.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isDeleting = true);
    try {
      await ActividadesService.eliminarActividad(widget.actividadId);
      if (!mounted) return;
      // Retornar true para indicar que hubo cambios (y refescar listados)
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar'), backgroundColor: Color(0xFFFF3B30)),
      );
    }
  }

  void _fitMapBounds() {
    if (_mapController == null || _actividad?.puntosRuta == null || _actividad!.puntosRuta!.isEmpty) return;

    double minLat = _actividad!.puntosRuta![0]['lat']!;
    double maxLat = minLat;
    double minLng = _actividad!.puntosRuta![0]['lng']!;
    double maxLng = minLng;

    for (var point in _actividad!.puntosRuta!) {
      if (point['lat']! < minLat) minLat = point['lat']!;
      if (point['lat']! > maxLat) maxLat = point['lat']!;
      if (point['lng']! < minLng) minLng = point['lng']!;
      if (point['lng']! > maxLng) maxLng = point['lng']!;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)),
        40, // Padding
      ),
    );
  }

  String _fechaFmt(DateTime? d) {
    if (d == null) return '--/--/----';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _horaFmt(DateTime? d) {
    if (d == null) return '--:--';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: _isLoading || _isDeleting
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : _error != null
              ? _buildErrorView(c)
              : _buildContentView(c),
    );
  }

  Widget _buildErrorView(AppColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: c.textPrimary, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchDetail();
            },
            child: const Text('Reintentar'),
          )
        ],
      ),
    );
  }

  Widget _buildContentView(AppColors c) {
    final a = _actividad!;
    final isRunning = a.tipo == 'correr';
    final hasRoute = a.puntosRuta != null && a.puntosRuta!.length >= 2;
    List<LatLng> routePoints = [];
    if (hasRoute) {
      routePoints = a.puntosRuta!.map((p) => LatLng(p['lat']!, p['lng']!)).toList();
    }

    return CustomScrollView(
      slivers: [
        // ── MAPA Y CABECERA ──────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          expandedHeight: 280,
          backgroundColor: c.bg,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              onPressed: () => context.pop(),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                onPressed: _borrarActividad,
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: hasRoute ? routePoints.first : _centroLocalizacionGeneral, 
                zoom: hasRoute ? 14 : 12,
              ),
              onMapCreated: (ctrl) {
                _mapController = ctrl;
                if (hasRoute) _fitMapBounds();
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              polylines: {
                if (hasRoute)
                  Polyline(
                    polylineId: const PolylineId('ruta_actividad'),
                    points: routePoints,
                    color: c.primaryDeep,
                    width: 5,
                  ),
              },
            ),
          ),
        ),

        // ── CONTENIDO ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Puntos Ganados
                ScaleTransition(
                  scale: CurvedAnimation(parent: _badgeCtrl, curve: Curves.elasticOut),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isRunning 
                          ? [c.primaryDeep, c.primaryDeep.withValues(alpha: 0.7)]
                          : [const Color(0xFF34C759), const Color(0xFF34C759).withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isRunning ? c.primaryDeep : const Color(0xFF34C759)).withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          isRunning ? '✨ Carrera de Historial' : '✨ Senderismo Completo',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '+${a.puntosGanados} puntos',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Estadísticas principales ─────────────────────
                _sectionTitle(c, '🏃 Rendimiento principal'),
                const SizedBox(height: 10),
                Builder(builder: (_) {
                  final dist = formatDistancia(a.distanciaKm);
                  return Row(children: [
                    Expanded(child: _statCard(c, '📏', 'Distancia', '${dist.valor} ${dist.unidad}', c.primaryDeep)),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard(c, '⏱', 'Tiempo', a.duracionFormateada, c.primaryDeep)),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard(c, '⚡', 'Ritmo', '${a.ritmoPromedio.toStringAsFixed(1)} m/km', c.primaryDeep)),
                  ]);
                }),
                const SizedBox(height: 10),

                // ── Estadísticas secundarias ─────────────────────
                _sectionTitle(c, '📊 Detalles'),
                const SizedBox(height: 10),
                Row(children: [
                   Expanded(child: _statCard(c, '🔥', 'Calorías', '${a.calorias ?? '--'} kcal', const Color(0xFFFF6B35))),
                   const SizedBox(width: 10),
                   Expanded(child: _statCard(c, '💨', 'Vel. prom.', '${a.velocidadPromedio.toStringAsFixed(1)} km/h', const Color(0xFF34C759))),
                   const SizedBox(width: 10),
                   Expanded(child: _statCard(c, '🚀', 'Vel. máx.', '${a.velocidadMax?.toStringAsFixed(1) ?? '--'} km/h', const Color(0xFF5E5CE6))),
                ]),
                const SizedBox(height: 10),

                // ── Datos de la sesión ────────────────────────────
                _sectionTitle(c, '📅 Sesión'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.primaryDeep.withValues(alpha: 0.07)),
                  ),
                  child: Column(
                    children: [
                      _sessionRow(c, Icons.calendar_today_rounded, 'Fecha', _fechaFmt(a.fecha)),
                      const Divider(height: 20),
                      _sessionRow(c, Icons.play_circle_outline_rounded, 'Hora inicio', _horaFmt(a.horaInicio)),
                      const Divider(height: 20),
                      _sessionRow(c, Icons.stop_circle_outlined, 'Hora fin', _horaFmt(a.horaFin ?? a.fecha)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── SECCIÓN DE FOTO (SI TIENE) ──────────────────
                if (a.fotoUrl != null && a.fotoUrl!.isNotEmpty) ...[
                  _sectionTitle(c, '📸 Momento Capturado'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(a.fotoUrl!),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(AppColors c, String text) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 2),
    child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.textPrimary)),
  );

  Widget _statCard(AppColors c, String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: c.textHint, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c.textPrimary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _sessionRow(AppColors c, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: c.primaryDeep),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: c.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}
