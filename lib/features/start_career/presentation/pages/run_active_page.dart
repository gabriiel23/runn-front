import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/core/theme/app_theme.dart';
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/services/http_client.dart';
import '../../services/actividades_service.dart';
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

  // Cronometro
  int _duracionSegs = 0;
  bool _corriendo = true;
  Timer? _timer;

  // Metricas
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
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(nuevo));
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
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

  Future<void> _finalizarCarrera() async {
    _timer?.cancel();
    _gpsSub?.cancel();
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
          // MAPA (mitad superior)
          Expanded(
            flex: 5,
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

                // Badge de estado
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
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
                  ),
                ),
              ],
            ),
          ),

          // METRICAS (mitad inferior)
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                color: tc.bg,
                child: Column(
                  children: [
                    // Cronometro
                    Text('Tiempo',
                        style: TextStyle(
                            color: tc.textHint,
                            fontSize: 12,
                            letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(
                      _fmt(_duracionSegs),
                      style: TextStyle(
                        color: tc.textPrimary,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Distancia + Ritmo
                    Row(
                      children: [
                        Expanded(
                            child: _metricCard(
                                tc,
                                Icons.straighten_rounded,
                                tc.primaryDeep,
                                'Distancia',
                                _distanciaKm.toStringAsFixed(2),
                                'km')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _metricCard(
                                tc,
                                Icons.speed_rounded,
                                tc.primaryDeep,
                                'Ritmo',
                                _ritmoMinkm > 0
                                    ? _ritmoMinkm.toStringAsFixed(1)
                                    : '--',
                                'min/km')),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Calorias + Velocidad
                    Row(
                      children: [
                        Expanded(
                            child: _metricCard(
                                tc,
                                Icons.local_fire_department_rounded,
                                const Color(0xFFFF6B35),
                                'Calorias',
                                '$_calorias',
                                'kcal')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _metricCard(
                                tc,
                                Icons.trending_up_rounded,
                                const Color(0xFF34C759),
                                'Velocidad',
                                _velocidadPromedioKmh.toStringAsFixed(1),
                                'km/h')),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Error de finalizar
                    if (_errorFinalizar != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFF3B30).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFFF3B30)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_rounded,
                                color: Color(0xFFFF3B30), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorFinalizar!,
                                style: const TextStyle(
                                    color: Color(0xFFFF3B30), fontSize: 13),
                              ),
                            ),
                            TextButton(
                              onPressed: _finalizarCarrera,
                              child: const Text('Reintentar',
                                  style: TextStyle(
                                      color: Color(0xFFFF3B30),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Botones
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _finalizando ? null : _pausarReanudar,
                              icon: Icon(
                                _corriendo
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                              ),
                              label: Text(
                                _corriendo ? 'Pausar' : 'Reanudar',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _corriendo
                                    ? tc.primaryDeep
                                    : const Color(0xFF34C759),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 52,
                            child: _finalizando
                                ? Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: tc.card,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
                                  )
                                : OutlinedButton(
                                    onPressed: _confirmarFinalizar,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFFFF3B30),
                                          width: 1.5),
                                      foregroundColor:
                                          const Color(0xFFFF3B30),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                    ),
                                    child: const Text('Finalizar',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15)),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(AppColors tc, IconData icon, Color color, String label,
      String value, String unit) {
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
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color: tc.textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: TextStyle(
                      color: tc.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1)),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit,
                    style: TextStyle(
                        color: tc.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
