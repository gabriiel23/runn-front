import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/core/theme/app_theme.dart';
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/core/utils/format_utils.dart';
import '../../services/actividades_service.dart';
import '../../services/tracking_service.dart';
import '../../domain/actividad_model.dart';

class RunActivePage extends StatefulWidget {
  final String actividadId;
  final String horaInicio;
  final double? latInicio;
  final double? lngInicio;

  const RunActivePage({
    super.key,
    required this.actividadId,
    required this.horaInicio,
    this.latInicio,
    this.lngInicio,
  });

  @override
  State<RunActivePage> createState() => _RunActivePageState();
}

class _RunActivePageState extends State<RunActivePage>
    with TickerProviderStateMixin {
  AppColors get c => context.colors;

  // Cronometro (lo mantiene el isolate del servicio, UI lo refleja)
  int _duracionSegs = 0;
  bool _corriendo = true;

  // Metricas (actualizadas desde el isolate)
  List<LatLng> _puntos = [];
  double _distanciaKm = 0;
  double _velocidadMaxKmh = 0;
  double _velocidadActualKmh = 0;
  double _pesoKg = 70;

  // GPS
  // (el GPS lo maneja el foreground service; aquí solo recibimos datos)

  // Mapa
  GoogleMapController? _mapController;
  late AnimationController _pulseCtrl;

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

    if (widget.latInicio != null && widget.lngInicio != null) {
      _puntos = [LatLng(widget.latInicio!, widget.lngInicio!)];
    }

    _cargarPeso();
    _iniciarServicio();
  }

  @override
  void dispose() {
    TrackingService.removeDataCallback(_onDataFromIsolate);
    _pulseCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _cargarPeso() async {
    final prefs = await SharedPreferences.getInstance();
    final peso = prefs.getDouble(ApiConfig.userPesoKey);
    if (peso != null && mounted) setState(() => _pesoKg = peso);
  }

  // ─── FOREGROUND SERVICE ────────────────────────────────────────────────────

  Future<void> _iniciarServicio() async {
    // Pedir permiso de notificación si no lo tiene
    final bgStatus = await FlutterForegroundTask.checkNotificationPermission();
    if (bgStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    // Registrar el callback ANTES de arrancar el servicio
    TrackingService.addDataCallback(_onDataFromIsolate);

    await TrackingService.start();
  }

  void _onDataFromIsolate(dynamic data) {
    if (!mounted || data is! Map) return;

    final lat = data['lat'] as double?;
    final lng = data['lng'] as double?;
    final speed = data['speed'] as double?; // m/s
    final distancia = data['distanciaKm'] as double?;
    final duracion = data['duracionSegs'] as int?;

    setState(() {
      if (distancia != null) _distanciaKm = distancia;
      if (duracion != null) _duracionSegs = duracion;
      if (speed != null) {
        _velocidadActualKmh = speed * 3.6;
        if (_velocidadActualKmh > _velocidadMaxKmh) {
          _velocidadMaxKmh = _velocidadActualKmh;
        }
      }
      if (lat != null && lng != null) {
        final nuevo = LatLng(lat, lng);
        _puntos = [..._puntos, nuevo];
        _mapController?.animateCamera(CameraUpdate.newLatLng(nuevo));
      }
    });
  }

  void _pausarReanudar() {
    if (_corriendo) {
      FlutterForegroundTask.stopService();
      TrackingService.removeDataCallback(_onDataFromIsolate);
    } else {
      TrackingService.addDataCallback(_onDataFromIsolate);
      TrackingService.start();
      TrackingService.syncState(
        distanciaKm: _distanciaKm,
        duracionSegs: _duracionSegs,
      );
    }
    setState(() => _corriendo = !_corriendo);
  }

  // ─── MÉTRICAS DERIVADAS ────────────────────────────────────────────────────

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Finalizar carrera?',
              style: TextStyle(
                  color: tc.textPrimary, fontWeight: FontWeight.bold)),
          content: Text(
            'Se guardara un resumen con los datos actuales.',
            style: TextStyle(color: tc.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Continuar corriendo',
                  style: TextStyle(color: tc.textHint)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: tc.primaryDeep,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Finalizar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    await _finalizarCarrera();
  }

  Future<void> _confirmarCancelar() async {
    final tc = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: tc.bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('¿Cancelar carrera?',
              style: TextStyle(
                  color: tc.textPrimary, fontWeight: FontWeight.bold)),
          content: Text(
            'Esta actividad se eliminará y no se guardará en tu historial.',
            style: TextStyle(color: tc.textSecondary),
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
    await TrackingService.stop();
    TrackingService.removeDataCallback(_onDataFromIsolate);
    try {
      // Intentamos borrar la actividad del servidor ya que no se va a guardar
      await ActividadesService.eliminarActividad(widget.actividadId);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) context.go('/home');
    }
  }

  Future<void> _finalizarCarrera() async {
    await TrackingService.stop();
    TrackingService.removeDataCallback(_onDataFromIsolate);
    setState(() {
      _finalizando = true;
      _errorFinalizar = null;
    });

    String? rutaJson;
    if (_puntos.length >= 2) {
      final coords = _puntos.map((p) => [p.longitude, p.latitude]).toList();
      rutaJson = jsonEncode({'type': 'LineString', 'coordinates': coords});
    }

    try {
      final data = await ActividadesService.finalizarActividad(
        widget.actividadId,
        distanciaKm: double.parse(_distanciaKm.toStringAsFixed(3)),
        duracionSegs: _duracionSegs,
        velocidadPromedio:
            double.parse(_velocidadPromedioKmh.toStringAsFixed(2)),
        velocidadMax: double.parse(_velocidadMaxKmh.toStringAsFixed(2)),
        ritmoPromedio: double.parse(_ritmoMinkm.toStringAsFixed(2)),
        calorias: _calorias,
        ruta: rutaJson,
      );

      if (!mounted) return;

      final resumen = data['resumen'] as Map<String, dynamic>? ?? {};
      final actividad = data['actividad'] as Map<String, dynamic>? ?? {};
      final puntosGanados = (data['puntos_ganados'] as num?)?.toInt() ?? 0;
      final logros = data['logros'] as Map<String, dynamic>?;

      final actResumen = ActividadResumen.fromApiResponse(
        actividadId: widget.actividadId,
        resumen: resumen,
        actividad: actividad,
        puntosGanados: puntosGanados,
        logros: logros,
      );

      context.goNamed(
        'run_results',
        extra: {
          'resumen': actResumen,
          'puntos': _puntos
              .map((p) => {'lat': p.latitude, 'lng': p.longitude})
              .toList(),
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final tc = context.colors;
    final posActual = _puntos.isNotEmpty ? _puntos.last : null;

    return Scaffold(
      backgroundColor: tc.bg,
      body: Column(
        children: [
          // MAPA (mitad superior expandible libremente)
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: posActual ??
                        (widget.latInicio != null
                            ? LatLng(widget.latInicio!, widget.lngInicio!)
                            : const LatLng(-0.22985, -78.52495)),
                    zoom: 17,
                  ),
                  onMapCreated: (ctrl) => _mapController = ctrl,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  polylines: _puntos.length >= 2
                      ? {
                          Polyline(
                            polylineId: const PolylineId('ruta'),
                            points: _puntos,
                            color: tc.primaryDeep,
                            width: 5,
                          ),
                        }
                      : {},
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

                // TOP BAR (Badge y Cancelar alineados a los extremos)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón Cancelar (Inicio)
                      GestureDetector(
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

                      // Badge de estado (Final)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: tc.card.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8)
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, __) => Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _corriendo
                                      ? Color.lerp(
                                          tc.primaryDeep,
                                          tc.primaryDeep.withValues(alpha: 0.4),
                                          _pulseCtrl.value)!
                                      : Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _corriendo ? 'En progreso' : 'Pausado',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: tc.textPrimary,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // METRICAS (mitad inferior) - Ajustable a su contenido
          Container(
            padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 8 : 28),
            decoration: BoxDecoration(
              color: tc.bg,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Esto hace que crezca solo lo necesario
              children: [
                // Cronometro Central
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
                            child: Builder(builder: (_) {
                              final dist = formatDistancia(_distanciaKm);
                              return _metricCard(
                                  tc,
                                  Icons.straighten_rounded,
                                  tc.primaryDeep,
                                  'Distancia',
                                  dist.valor,
                                  dist.unidad);
                            }),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _metricCard(
                                tc,
                                Icons.speed_rounded,
                                tc.primaryDeep,
                                'Ritmo',
                                _ritmoMinkm > 0
                                    ? _ritmoMinkm.toStringAsFixed(1)
                                    : '--',
                                'min/km'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _metricCard(
                                tc,
                                Icons.local_fire_department_rounded,
                                const Color(0xFFFF6B35),
                                'Calorías',
                                '$_calorias',
                                'kcal'),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _metricCard(
                                tc,
                                Icons.trending_up_rounded,
                                const Color(0xFF34C759),
                                'Velocidad',
                                _velocidadActualKmh.toStringAsFixed(1),
                                'km/h'),
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
                              onTap: _finalizarCarrera,
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
                                  size: 20,
                                ),
                                label: Text(
                                  _corriendo ? 'PAUSAR' : 'REANUDAR',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _corriendo ? tc.primaryDeep : const Color(0xFF34C759),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Botón Finalizar
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _confirmarFinalizar,
                                icon: const Icon(Icons.stop_rounded, color: Colors.white, size: 18),
                                label: const Text('PARAR',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF3B30),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
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

  Widget _metricCard(AppColors tc, IconData icon, Color color, String label,
      String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tc.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 13),
              ),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: tc.textHint,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: tc.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: TextStyle(
                  color: tc.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
