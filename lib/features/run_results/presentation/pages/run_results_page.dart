import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/core/theme/app_theme.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/core/utils/format_utils.dart';
import 'package:runn_front/features/challenges/data/models/reto_models.dart';
import '../../../start_career/services/actividades_service.dart';
import '../../../start_career/domain/actividad_model.dart';

class RunResultsPage extends StatefulWidget {
  final ActividadResumen resumen;
  final List<Map<String, double>> puntos;

  const RunResultsPage({
    super.key,
    required this.resumen,
    required this.puntos,
  });

  @override
  State<RunResultsPage> createState() => _RunResultsPageState();
}

class _RunResultsPageState extends State<RunResultsPage>
    with SingleTickerProviderStateMixin {
  AppColors get c => context.colors;

  GoogleMapController? _mapController;
  late AnimationController _badgeCtrl;
  bool _compartiendo = false;
  bool _compartida = false;
  bool _subiendoFoto = false;
  File? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _badgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Animación de entrada del badge de puntos
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _badgeCtrl.forward();
    });
    // Mostrar logros si los hay
    final logros = widget.resumen.logros;
    if (logros != null && logros.tieneLogros) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) _mostrarLogrosSheet(logros);
      });
    }
  }

  @override
  void dispose() {
    _badgeCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _mostrarLogrosSheet(LogrosCarrera logros) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogrosSheet(logros: logros, c: c),
    );
  }

  Future<bool> _subirFotoSiExiste() async {
    if (_selectedPhoto == null) return true;
    setState(() => _subiendoFoto = true);
    try {
      await ActividadesService.agregarFoto(widget.resumen.actividadId, _selectedPhoto!);
      return true;
    } on ApiException catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir foto: ${e.message}'), backgroundColor: const Color(0xFFFF3B30)),
      );
      return false; // Continues flowing but denotes failure
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Optimize for faster upload
      );
      if (image != null && mounted) {
        setState(() {
          _selectedPhoto = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al acceder a la galería.')),
      );
    }
  }

  Future<void> _guardarYVolver() async {
    setState(() => _compartiendo = true); // Usar el mismo flag visual
    await _subirFotoSiExiste();
    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _descartarYVolver() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Descartar actividad', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de descartar esta actividad? No se guardará en tu historial.', style: TextStyle(color: context.colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: TextStyle(color: context.colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Descartar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _compartiendo = true);
    try {
      await ActividadesService.eliminarActividad(widget.resumen.actividadId);
      if (!mounted) return;
      context.go('/home');
    } catch (_) {
       if (!mounted) return;
       setState(() => _compartiendo = false);
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Error al descartar la actividad'), backgroundColor: Color(0xFFFF3B30)),
       );
    }
  }

  Future<void> _compartir() async {
    setState(() => _compartiendo = true);
    await _subirFotoSiExiste();
    try {
      await ActividadesService.compartirActividad(widget.resumen.actividadId);
      if (!mounted) return;
      setState(() { _compartida = true; });
      final dist = formatDistancia(widget.resumen.distanciaKm);
      await Share.share(
        'Acabo de recorrer ${dist.valor} ${dist.unidad} '
        'en ${widget.resumen.duracionFormateada} con RUNN 🏃‍♂️\n'
        '¡Únete a la comunidad de corredores!',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFFF3B30)),
      );
    } finally {
      if (mounted) setState(() => _compartiendo = false);
    }
  }

  List<LatLng> get _latLngPuntos => widget.puntos
      .map((p) => LatLng(p['lat']!, p['lng']!))
      .toList();

  LatLng get _centroMapa {
    if (widget.puntos.isEmpty) return const LatLng(-0.22985, -78.52495);
    double sumLat = 0, sumLng = 0;
    for (final p in widget.puntos) {
      sumLat += p['lat']!;
      sumLng += p['lng']!;
    }
    return LatLng(sumLat / widget.puntos.length, sumLng / widget.puntos.length);
  }

  String _fechaFmt(DateTime dt) {
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${dt.day} de ${meses[dt.month - 1]} de ${dt.year}';
  }

  String _horaFmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = widget.resumen;

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          // ── APPBAR CON MAPA ────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            backgroundColor: c.bg,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => context.go('/home'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: widget.puntos.length >= 2
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(target: _centroMapa, zoom: 14),
                      onMapCreated: (ctrl) => _mapController = ctrl,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('ruta_final'),
                          points: _latLngPuntos,
                          color: c.primaryDeep,
                          width: 5,
                        ),
                      },
                      markers: {
                        if (widget.puntos.isNotEmpty)
                          Marker(
                            markerId: const MarkerId('inicio'),
                            position: _latLngPuntos.first,
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                          ),
                        if (widget.puntos.length > 1)
                          Marker(
                            markerId: const MarkerId('fin'),
                            position: _latLngPuntos.last,
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                          ),
                      },
                    )
                  : Container(
                      color: c.primaryDeep.withValues(alpha: 0.15),
                      child: Center(
                        child: Icon(Icons.map_outlined, size: 64, color: c.primaryDeep.withValues(alpha: 0.4)),
                      ),
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
                  // Badge puntos ganados
                  ScaleTransition(
                    scale: CurvedAnimation(parent: _badgeCtrl, curve: Curves.elasticOut),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [c.primaryDeep, c.primaryDeep.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: c.primaryDeep.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('✨ ¡Carrera completada!',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                            '+${r.puntosGanados} puntos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            'ganados en esta carrera',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
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
                    final dist = formatDistancia(r.distanciaKm);
                    return Row(children: [
                      Expanded(child: _statCard(c, '📏', 'Distancia', '${dist.valor} ${dist.unidad}', c.primaryDeep)),
                      const SizedBox(width: 10),
                      Expanded(child: _statCard(c, '⏱', 'Tiempo', r.duracionFormateada, c.primaryDeep)),
                      const SizedBox(width: 10),
                      Expanded(child: _statCard(c, '⚡', 'Ritmo', '${r.ritmoPromedio.toStringAsFixed(1)} m/km', c.primaryDeep)),
                    ]);
                  }),
                  const SizedBox(height: 10),

                  // ── Estadísticas secundarias ─────────────────────
                  _sectionTitle(c, '📊 Detalles'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _statCard(c, '🔥', 'Calorías', '${r.calorias} kcal', const Color(0xFFFF6B35))),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard(c, '💨', 'Vel. prom.', '${r.velocidadPromedio.toStringAsFixed(1)} km/h', const Color(0xFF34C759))),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard(c, '🚀', 'Vel. máx.', '${r.velocidadMax.toStringAsFixed(1)} km/h', const Color(0xFF5E5CE6))),
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
                        _sessionRow(c, Icons.calendar_today_rounded, 'Fecha', _fechaFmt(r.horaInicio)),
                        const Divider(height: 20),
                        _sessionRow(c, Icons.play_circle_outline_rounded, 'Hora inicio', _horaFmt(r.horaInicio)),
                        const Divider(height: 20),
                        _sessionRow(c, Icons.stop_circle_outlined, 'Hora fin', _horaFmt(r.horaFin)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── SECCIÓN DE FOTO (OPCIONAL) ──────────────────
                  _sectionTitle(c, '📸 Momentos'),
                  const SizedBox(height: 10),
                  _buildPhotoSection(c),
                  const SizedBox(height: 24),

                  // ── Botones de acción ─────────────────────────────
                  Row(children: [
                    Expanded(
                      child: _actionBtn(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                        label: 'Descartar',
                        color: const Color(0xFFFF3B30),
                        onTap: _compartiendo ? null : _descartarYVolver,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionBtn(
                        icon: _compartiendo && !_compartida
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                        label: _selectedPhoto != null ? 'Guardar foto' : 'Guardar',
                        color: c.primaryDeep,
                        onTap: _compartiendo ? null : _guardarYVolver,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _actionBtn(
                      icon: _compartiendo
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Icon(_compartida ? Icons.check_rounded : Icons.share_rounded, color: Colors.white, size: 20),
                      label: _compartida ? '¡Compartida exitosamente!' : 'Compartir actividad',
                      color: _compartida ? const Color(0xFF34C759) : const Color(0xFF636366),
                      onTap: (_compartiendo || _compartida) ? null : _compartir,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _actionBtn({required Widget icon, required String label, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: onTap == null ? color.withValues(alpha: 0.5) : color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(AppColors c) {
    if (_selectedPhoto != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.primaryDeep.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _selectedPhoto!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Foto lista', style: TextStyle(color: c.primaryDeep, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Text(
                          'Cambiar',
                          style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.underline),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => setState(() => _selectedPhoto = null),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_subiendoFoto)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.primaryDeep.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: c.primaryDeep.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.primaryDeep.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_a_photo_rounded, color: c.primaryDeep, size: 28),
            ),
            const SizedBox(height: 12),
            Text('Agregar foto (opcional)', style: TextStyle(color: c.primaryDeep, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Comparte tu experiencia con la comunidad.', style: TextStyle(color: c.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ─── LOGROS SHEET ─────────────────────────────────────────────────────────────

class _LogrosSheet extends StatefulWidget {
  final LogrosCarrera logros;
  final dynamic c;

  const _LogrosSheet({required this.logros, required this.c});

  @override
  State<_LogrosSheet> createState() => _LogrosSheetState();
}

class _LogrosSheetState extends State<_LogrosSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const Map<String, String> _nivelEmoji = {
    'sin_nivel': '🏅',
    'normal': '🏅',
    'oro': '🥇',
    'diamante': '💎',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final logros = widget.logros;
    final totalPts = logros.totalPuntosLogros;

    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        top: 8,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: c.primaryDeepWithAlpha(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [c.primaryDeep, c.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.primaryDeepWithAlpha(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(child: Text('🏆', style: TextStyle(fontSize: 32))),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Logros desbloqueados!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.textPrimary, letterSpacing: -0.4),
            ),
            const SizedBox(height: 6),
            Text('Increíble carrera 💪', style: TextStyle(fontSize: 14, color: c.textSecondary)),
            const SizedBox(height: 24),

            // Nuevas insignias
            ...logros.nuevasInsignias.map((ins) => _logroTile(
              c,
              emoji: _nivelEmoji[ins.nivel] ?? '🏅',
              titulo: ins.nombre,
              subtitulo: ins.descripcion ?? 'Nueva insignia desbloqueada',
              color: const Color(0xFFFFD700),
            )),

            // Reto diario
            if (logros.retoDiario.completado)
              _logroTile(c,
                emoji: '✅',
                titulo: 'Reto diario completado',
                subtitulo: logros.retoDiario.titulo,
                puntos: logros.retoDiario.puntosRecompensa,
                color: const Color(0xFF7ED957),
              ),

            // Reto semanal
            if (logros.retoSemanal.completado)
              _logroTile(c,
                emoji: '🗓',
                titulo: 'Reto semanal completado',
                subtitulo: logros.retoSemanal.titulo,
                puntos: logros.retoSemanal.puntosRecompensa,
                color: const Color(0xFF3B82F6),
              ),

            const SizedBox(height: 8),

            if (totalPts > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.primaryDeep.withValues(alpha: 0.15), c.primaryDeep.withValues(alpha: 0.05)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.primaryDeepWithAlpha(0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_rounded, color: c.primaryDeep, size: 22),
                    const SizedBox(width: 8),
                    Text('+$totalPts puntos totales ganados',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.primaryDeep)),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primaryDeep,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('¡Genial!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logroTile(dynamic c, {
    required String emoji,
    required String titulo,
    required String subtitulo,
    int? puntos,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary)),
                if (subtitulo.isNotEmpty)
                  Text(subtitulo, style: TextStyle(fontSize: 12, color: c.textSecondary)),
              ],
            ),
          ),
          if (puntos != null && puntos > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('+$puntos pts',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
            ),
        ],
      ),
    );
  }
}

