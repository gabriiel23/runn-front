import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/territory_model.dart';
import '../../services/territory_service.dart';
import '../../../community/services/grupos_service.dart';
import '../../../community/domain/models/grupo_model.dart';
import '../../../start_career/services/actividades_service.dart';
import 'territory_conquest_run_page.dart';

class TerritoryDetailView extends StatefulWidget {
  final String territoryId;
  final VoidCallback onBack;

  const TerritoryDetailView({
    super.key,
    required this.territoryId,
    required this.onBack,
  });

  @override
  State<TerritoryDetailView> createState() => _TerritoryDetailViewState();
}

class _TerritoryDetailViewState extends State<TerritoryDetailView> {
  TerritoryModel? _territory;
  bool _loading = true;
  bool _isActing = false;
  String? _error;
  String? _miId;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _miId = await ApiConfig.getCurrentUserId();
      final t = await TerritorioService.getTerritorioDetalle(widget.territoryId);
      if (!mounted) return;
      setState(() {
        _territory = t;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _shareTerritory() async {
    final t = _territory;
    if (t == null) return;
    await Share.share(
      'Territorio: ${t.nombre}\n'
      'Dueño: ${t.ownerDisplayName}\n'
      'Récord: ${t.tiempoRecordFormateado ?? "--"}\n'
      'Veces disputado: ${t.vecesDisputado}',
      subject: 'Territorio: ${t.nombre}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_loading) {
      return Scaffold(
        backgroundColor: c.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _territory == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, color: c.textSecondary, size: 48),
              const SizedBox(height: 12),
              Text('No se pudo cargar el territorio',
                  style: TextStyle(color: c.textSecondary)),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
                ),
              const SizedBox(height: 8),
              TextButton(onPressed: _cargar, child: const Text('Reintentar')),
              const SizedBox(height: 4),
              TextButton(
                  onPressed: widget.onBack,
                  child: Text('Volver',
                      style: TextStyle(color: c.textSecondary))),
            ],
          ),
        ),
      );
    }

    final t = _territory!;
    final uid = _miId ?? '';
    final esPropio = t.isOwned(uid);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargar,
          color: c.primaryDeep,
          backgroundColor: c.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── TOP BAR ─────────────────────────────────────────────────
                Row(
                  children: [
                    _HeaderActionButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: widget.onBack,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _HeaderActionButton(
                      icon: Icons.share_outlined,
                      onTap: _shareTerritory,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── MAPA Y DESCRIPCIÓN INTEGRADOS ────────────────────────────
                _buildMapAndDescription(context, t),

                const SizedBox(height: 20),

                // ── ESTADO / CHIP ────────────────────────────────────────────
                Row(
                  children: [
                    _StatusChip(territory: t, userId: uid),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: c.primaryDeepWithAlpha(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded,
                              size: 13,
                              color: c.primaryDeepWithAlpha(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            t.modalidad.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: c.primaryDeepWithAlpha(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── ESTADÍSTICAS CLAVE ───────────────────────────────────────
                _buildSectionHeader(
                    'Estadísticas', Icons.bar_chart_rounded, context),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(context),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        _buildStatCell(
                          context,
                          Icons.timer_rounded,
                          t.tiempoRecordFormateado ?? '--:--:--',
                          'Récord',
                          const Color(0xFF7ED957),
                        ),
                        _buildVerticalDivider(context),
                        _buildStatCell(
                          context,
                          Icons.flag_rounded,
                          '${t.vecesDisputado}',
                          'Disputas',
                          c.primaryDeep,
                        ),
                        _buildVerticalDivider(context),
                        _buildStatCell(
                          context,
                          Icons.shield_rounded,
                          '${t.totalDefensas}',
                          'Defensas',
                          const Color(0xFFFFB84D),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── PROPIETARIO ──────────────────────────────────────────────
                _buildSectionHeader(
                    'Propietario actual', Icons.person_rounded, context),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(context),
                  child: t.libre
                      ? Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: c.primaryDeepWithAlpha(0.07),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.flag_outlined,
                                  color: c.textHint, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Territorio libre',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: c.textPrimary,
                                  ),
                                ),
                                Text(
                                  '¡Sé el primero en conquistarlo!',
                                  style: TextStyle(
                                      fontSize: 12, color: c.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        )
                      : _PropietarioRow(territory: t),
                ),

                const SizedBox(height: 20),

                // ── HISTORIAL ────────────────────────────────────────────────
                if (t.historial.isNotEmpty) ...[
                  _buildSectionHeader(
                      'Historial reciente', Icons.history_rounded, context),
                  const SizedBox(height: 12),
                  ...t.historial.map(
                    (h) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HistorialCard(entry: h),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],


                // ── CTA BUTTON ───────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [c.primaryDeep, c.primaryDark],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: c.primaryDeepWithAlpha(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isActing ? null : _verificarProximidadYConquistar,
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isActing)
                              const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            else
                              Icon(
                                esPropio
                                    ? Icons.shield_rounded
                                    : Icons.bolt_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              esPropio
                                  ? '¡Defender mi territorio!'
                                  : t.libre
                                      ? '¡Conquistar territorio!'
                                      : '¡Disputar territorio!',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── VERIFICACIÓN DE PROXIMIDAD ────────────────────────────────────────────────────

  Future<void> _verificarProximidadYConquistar() async {
    setState(() => _isActing = true);
    final c = context.colors;
    try {
      // 1. Obtener permiso y ubicación actual
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _isActing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se necesita permiso de ubicación para conquistar.'), backgroundColor: Colors.orange),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // 2. Preguntar al backend si estamos cerca
      final resultado = await TerritorioService.verificarProximidad(
        territorioId: widget.territoryId,
        lat: pos.latitude,
        lng: pos.longitude,
      );

      if (!mounted) return;
      final cerca = resultado['cerca'] as bool? ?? false;

      if (!cerca) {
        setState(() => _isActing = false);
        final distanciaM = resultado['distancia_m'] as int? ?? 0;
        // Mostrar diálogo explicativo
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: c.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.location_off_rounded, color: Colors.orange, size: 28),
                const SizedBox(width: 10),
                Text('Demasiado lejos', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estás a ${distanciaM}m del territorio.',
                  style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Para conquistar este territorio necesitas estar a menos de 500 metros de su périmetro. ¡Ahí es donde la carrera comienza!',
                  style: TextStyle(color: c.textSecondary, height: 1.5),
                ),
              ],
            ),
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: c.primaryDeep, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
        return;
      }

      // 3. Está cerca: continuar con la conquista normal
      setState(() => _isActing = false);
      if (_territory!.modalidad == 'grupal') {
        _iniciarConquistaGrupal(modalidadActiva: 'grupal');
      } else {
        _conquistarTerritorio(modalidadActiva: 'individual');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isActing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al verificar ubicación: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── LÓGICA DE CONQUISTA ────────────────────────────────────────────────────

  Future<void> _iniciarConquistaGrupal({required String modalidadActiva}) async {
    setState(() => _isActing = true);
    try {
      final grupos = await GruposService.getMisGrupos();
      if (!mounted) return;
      setState(() => _isActing = false);

      if (grupos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No perteneces a ningún grupo para disputar de manera grupal.'), backgroundColor: Colors.red),
        );
        return;
      }
      _showGroupSelectionSheet(grupos, modalidadActiva);
    } catch (e) {
      if (mounted) {
        setState(() => _isActing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar grupos: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showGroupSelectionSheet(List<GrupoListItem> grupos, String modalidadActiva) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: c.primaryDeepWithAlpha(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Selecciona tu Grupo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '¿A qué grupo vas a representar en esta conquista?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: c.textSecondary),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: grupos.length,
                itemBuilder: (ctx, i) {
                  final g = grupos[i];
                  return Card(
                    color: c.card,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: c.primaryDeepWithAlpha(0.08)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: c.primaryDeepWithAlpha(0.1),
                        backgroundImage: g.fotoUrl != null ? NetworkImage(g.fotoUrl!) : null,
                        child: g.fotoUrl == null ? Icon(Icons.groups, color: c.primaryDeep) : null,
                      ),
                      title: Text(g.nombre, style: TextStyle(fontWeight: FontWeight.bold, color: c.textPrimary)),
                      subtitle: Text('${g.totalMiembros} miembros', style: TextStyle(color: c.textSecondary, fontSize: 13)),
                      trailing: Icon(Icons.chevron_right_rounded, color: c.primaryDeep),
                      onTap: () {
                        Navigator.pop(ctx);
                        _conquistarTerritorio(grupoId: g.id, modalidadActiva: modalidadActiva);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Inicia una actividad real y navega a la pantalla de carrera de conquista.
  Future<void> _conquistarTerritorio({String? grupoId, required String modalidadActiva}) async {
    setState(() => _isActing = true);
    try {
      // Obtener posición actual para el inicio del mapa
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      } catch (_) {}

      // Iniciar actividad en el backend
      final actividad = await ActividadesService.iniciarActividad(
        tipo: 'correr',
        modalidad: modalidadActiva,
      );

      if (!mounted) return;
      setState(() => _isActing = false);

      // Navegar a la pantalla de carrera de conquista (sobreponiendo todo)
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => TerritoryConquestRunPage(
            territory: _territory!,
            actividadId: actividad.id,
            horaInicio: actividad.horaInicio.toIso8601String(),
            latInicio: pos?.latitude,
            lngInicio: pos?.longitude,
            modalidad: modalidadActiva,
            grupoId: grupoId,
          ),
        ),
      );

      // Al regresar, recargar el detalle del territorio
      await _cargar();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isActing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isActing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar carrera: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── WIDGET DE MAPA + DESCRIPCIÓN ──────────────────────────────────────────

  Widget _buildMapAndDescription(BuildContext context, TerritoryModel t) {
    final c = context.colors;
    
    // Parsear el polígono
    List<LatLng>? points;
    if (t.poligono != null) {
      try {
        final geo = t.poligono is String ? jsonDecode(t.poligono) : t.poligono;
        if (geo != null && geo['type'] == 'Polygon') {
          final coords = (geo['coordinates'] as List).first as List;
          points = coords.map((coord) {
            final arr = coord as List;
            return LatLng((arr[1] as num).toDouble(), (arr[0] as num).toDouble());
          }).toList();
        }
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      decoration: _cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (points != null && points.isNotEmpty)
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: _getCameraPosForPolygon(points),
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    polygons: {
                      Polygon(
                        polygonId: PolygonId(t.id),
                        points: points,
                        fillColor: Colors.orange.withValues(alpha: 0.2),
                        strokeColor: Colors.orange,
                        strokeWidth: 2,
                      ),
                    },
                  ),
                  // Gradiente inferior para integrar con el texto
                  const Positioned(
                    bottom: 0, left: 0, right: 0,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black12],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          if (t.descripcion != null && t.descripcion!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                t.descripcion!,
                style: TextStyle(
                  fontSize: 14,
                  color: c.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            
          // Pequeño padding extra si no hay descripción pero sí mapa
          if ((t.descripcion == null || t.descripcion!.isEmpty) && points != null)
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  CameraPosition _getCameraPosForPolygon(List<LatLng> points) {
    if (points.isEmpty) return const CameraPosition(target: LatLng(0, 0), zoom: 15);
    final lats = points.map((p) => p.latitude);
    final lngs = points.map((p) => p.longitude);
    final minLat = lats.reduce(min);
    final maxLat = lats.reduce(max);
    final minLng = lngs.reduce(min);
    final maxLng = lngs.reduce(max);
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    return CameraPosition(target: LatLng(centerLat, centerLng), zoom: 15.5);
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration(BuildContext context) {
    final c = context.colors;
    return BoxDecoration(
      color: c.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: c.primaryDeepWithAlpha(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: c.primaryDeepWithAlpha(0.8)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCell(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final c = context.colors;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 60,
      color: context.colors.primaryDeepWithAlpha(0.07),
    );
  }
}

// ── PROPIETARIO ROW ───────────────────────────────────────────────────────────

class _PropietarioRow extends StatelessWidget {
  final TerritoryModel territory;
  const _PropietarioRow({required this.territory});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final propietario = territory.propietario;
    final grupo = territory.grupoPropietario;

    final nombre = propietario?.nombre ?? grupo?.nombre ?? 'Desconocido';
    final avatarUrl = propietario?.avatarUrl ?? grupo?.fotoUrl;
    final subtitulo = propietario?.ciudad ?? 'Sin ubicación';

    return GestureDetector(
      onTap: () {
        if (propietario != null && propietario.id.isNotEmpty) {
          context.pushNamed(
            'territory_runner_profile',
            pathParameters: {'runnerId': propietario.id},
          );
        }
      },
      child: Row(
        children: [
          CircleAvatar(
          radius: 24,
          backgroundColor: c.primaryDeepWithAlpha(0.12),
          backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Icon(Icons.person_rounded,
                  color: c.primaryDeepWithAlpha(0.6), size: 24)
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              if (propietario != null)
                Text(
                  subtitulo,
                  style: TextStyle(fontSize: 12, color: c.textSecondary),
                ),
            ],
          ),
        ),
        if (territory.conquistadoEn != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Conquistado',
                style: TextStyle(fontSize: 10, color: c.textHint),
              ),
              Text(
                _formatDate(territory.conquistadoEn!),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 30) return 'Hace ${diff.inDays} días';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── STATUS CHIP ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final TerritoryModel territory;
  final String userId;
  const _StatusChip({required this.territory, required this.userId});

  @override
  Widget build(BuildContext context) {
    final color = territory.statusColor(context, userId);
    final label = territory.libre
        ? 'LIBRE'
        : territory.isOwned(userId)
            ? 'MÍO'
            : 'RIVAL';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── HISTORIAL CARD ────────────────────────────────────────────────────────────

class _HistorialCard extends StatelessWidget {
  final TerritorialHistorialEntry entry;
  const _HistorialCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final gano = entry.resultado == 'ganado';
    final color = gano ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    final nombreActor =
        entry.usuario?.nombre ?? entry.grupo?.nombre ?? 'Desconocido';
    final avatarUrl = entry.usuario?.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: c.primaryDeepWithAlpha(0.10),
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Icon(Icons.person_rounded,
                    color: c.primaryDeepWithAlpha(0.5), size: 18)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreActor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  '${entry.tipo == 'conquista' ? 'Conquista' : 'Disputa'} · ${entry.tiempoFormateado}',
                  style: TextStyle(fontSize: 12, color: c.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              gano ? '✅ Ganado' : '❌ Perdido',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          ],
        ),
    );
  }
}

// ── HEADER ACTION BUTTON ──────────────────────────────────────────────────────

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
        ),
        child: Icon(icon, color: c.textSecondary, size: 22),
      ),
    );
  }
}
