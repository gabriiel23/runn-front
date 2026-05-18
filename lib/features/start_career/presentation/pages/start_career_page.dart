import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/core/theme/app_theme.dart';
import 'package:runn_front/core/services/http_client.dart';
import '../../services/actividades_service.dart';

class PreCarreraPage extends StatefulWidget {
  const PreCarreraPage({super.key});

  @override
  State<PreCarreraPage> createState() => _PreCarreraPageState();
}

class _PreCarreraPageState extends State<PreCarreraPage>
    with TickerProviderStateMixin {
  AppColors get c => context.colors;

  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _loadingLocation = true;
  bool _starting = false;
  String? _locationError;

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadLocation();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'El GPS está desactivado en tu dispositivo.';
          _loadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _locationError =
              'Permiso de ubicación denegado. Actívalo en Ajustes.';
          _loadingLocation = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _currentPosition = pos;
        _loadingLocation = false;
      });
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(pos.latitude, pos.longitude),
            zoom: 16,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = 'No se pudo obtener la ubicación.';
        _loadingLocation = false;
      });
    }
  }

  Future<void> _iniciarCarrera() async {
    if (_starting) return;
    setState(() => _starting = true);

    try {
      // Crear el registro de actividad en el servidor
      final actividad = await ActividadesService.iniciarActividad();
      if (!mounted) return;

      context.pushNamed(
        'run_active',
        extra: {
          'actividad_id': actividad.id,
          'hora_inicio': actividad.horaInicio.toIso8601String(),
          'lat_inicio': _currentPosition?.latitude,
          'lng_inicio': _currentPosition?.longitude,
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error inesperado al iniciar la actividad.'),
          backgroundColor: Color(0xFFFF3B30),
        ),
      );
    } finally {

      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pos = _currentPosition;

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          // ── MAPA ──────────────────────────────────────────────────
          Positioned.fill(
            child: _locationError != null
                ? _buildLocationError(c)
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: pos != null
                          ? LatLng(pos.latitude, pos.longitude)
                          : const LatLng(-0.22985, -78.52495),
                      zoom: 16,
                    ),
                    onMapCreated: (ctrl) => _mapController = ctrl,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    markers: pos != null
                        ? {
                            Marker(
                              markerId: const MarkerId('current'),
                              position: LatLng(pos.latitude, pos.longitude),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueAzure,
                              ),
                            ),
                          }
                        : {},
                  ),
          ),

          // ── INDICADOR DE CARGA GPS ────────────────────────────────
          if (_loadingLocation)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            ),

          // ── BARRA SUPERIOR ────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _circleBtn(c, Icons.arrow_back_rounded, () => context.go('/home')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: c.card.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: _locationError != null
                                    ? const Color(0xFFFF3B30)
                                    : _loadingLocation
                                        ? Colors.orange
                                        : const Color(0xFF34C759),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _locationError != null
                                  ? 'Error de GPS'
                                  : _loadingLocation
                                      ? 'Obteniendo ubicación…'
                                      : 'GPS listo · Señal fuerte',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: c.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── CONTROLES INFERIORES ──────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: BoxDecoration(
                color: c.bg.withValues(alpha: 0.97),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dragger
                  Container(
                    width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: c.primaryDeep.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          c.primaryDeep.withValues(alpha: 0.12),
                          c.primaryDeep.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.primaryDeep.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: c.primaryDeep,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.directions_run_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Se registrará tu ruta, distancia, tiempo y calorías en tiempo real. Asegúrate de estar al aire libre para mejor señal GPS.',
                            style: TextStyle(
                              fontSize: 13,
                              color: c.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón Iniciar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: (_loadingLocation || _locationError != null || _starting)
                          ? null
                          : _iniciarCarrera,
                      icon: _starting
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                      label: Text(
                        _starting ? 'Iniciando…' : 'Iniciar carrera',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primaryDeep,
                        disabledBackgroundColor: c.primaryDeep.withValues(alpha: 0.4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Botón Cancelar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => context.go('/home'),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationError(AppColors c) {
    return Container(
      color: c.bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off_rounded, size: 64, color: c.textHint),
              const SizedBox(height: 16),
              Text(
                _locationError ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.textSecondary, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _locationError = null;
                    _loadingLocation = true;
                  });
                  _loadLocation();
                },
                style: ElevatedButton.styleFrom(backgroundColor: c.primaryDeep, foregroundColor: Colors.white),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleBtn(AppColors c, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: c.card.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
        ),
        child: Icon(icon, color: c.textPrimary, size: 22),
      ),
    );
  }
}
