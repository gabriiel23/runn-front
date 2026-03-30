import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/profile_service.dart';
import '../../../start_career/services/actividades_service.dart';
import '../../../start_career/domain/actividad_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _skeletonController;
  late Animation<double> _pulseAnimation;
  Map<String, dynamic> _userData = {};
  // Lista de fotos multimedia del backend ({id, url})
  List<Map<String, String>> _mediaItems = [];
  ActividadEstadisticas? _estadisticas;
  List<ActividadHistorial>? _actividadesRecientes;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _skeletonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _skeletonController, curve: Curves.easeInOut),
    );
    _skeletonController.repeat(reverse: true);
    _loadProfile();
  }

  @override
  void dispose() {
    _skeletonController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (mounted) setState(() => _isRefreshing = true);
    await _loadProfile();
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _loadProfile() async {
    // 1. Carga instantánea desde caché local
    final local = await ProfileService.getLocalProfile();
    if (mounted) {
      setState(() {
        _userData = local;
        _isLoading = false;
      });
    }

    // 2. Refresco en segundo plano: perfil y multimedia desde el servidor
    try {
      final remoto = await ProfileService.getMyProfile();
      if (mounted) {
        setState(() {
          _userData = {
            'id': remoto.id,
            'nombre': remoto.nombre,
            'correo': remoto.correo,
            'nivel': remoto.nivel,
            'puntos': remoto.puntos,
            'biografia': remoto.biografia,
            'avatar_url': remoto.avatarUrl,
            'ciudad': remoto.ciudad,
            'pais': remoto.pais,
            'peso_kg': remoto.pesoKg,
            'altura_cm': remoto.alturaCm,
          };
        });
      }
    } catch (_) {
      // Se mantienen los datos del caché si falla la red
    }

    // Cargar multimedia desde el backend
    try {
      final items = await ProfileService.getMedia();
      if (mounted) setState(() => _mediaItems = items);
    } catch (_) {
      // Fallback silencioso
    }

    // Cargar estadísticas
    try {
      debugPrint('[Perfil] Cargando estadísticas...');
      final stats = await ActividadesService.obtenerEstadisticas();
      debugPrint('[Perfil] Stats OK: totalCarreras=${stats.totalCarreras}, distancia=${stats.distanciaTotalKm}');
      if (mounted) setState(() => _estadisticas = stats);
    } catch (e) {
      debugPrint('[Perfil] ERROR estadísticas: $e');
    }

    // Cargar historial reciente (últimas 2)
    try {
      debugPrint('[Perfil] Cargando historial...');
      final historyMap = await ActividadesService.obtenerHistorial(limite: 2, pagina: 1);
      final lista = historyMap['historial'] as List<ActividadHistorial>;
      debugPrint('[Perfil] Historial OK: ${lista.length} carreras');
      if (mounted) setState(() => _actividadesRecientes = lista);
    } catch (e) {
      debugPrint('[Perfil] ERROR historial: $e');
      // Asignar lista vacía para que la UI no se quede en "Cargando..."
      if (mounted) setState(() => _actividadesRecientes ??= []);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building ProfileScreen...');
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: c.primaryDeep,
        backgroundColor: c.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            _isRefreshing
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildProfileSkeletonBody(context),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 28),
                        _buildBadgesSection(context),
                        const SizedBox(height: 28),
                        _buildStatisticsSection(context),
                        const SizedBox(height: 28),
                        _buildHistorialSection(context),
                        const SizedBox(height: 28),
                        _buildMultimediaSection(context),
                        const SizedBox(height: 60),
                      ]),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HEADER
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final c = context.colors;
    final nombre = _userData['nombre'] as String? ?? '';
    final biografia = _userData['biografia'] as String?;
    final ciudad = _userData['ciudad'] as String?;
    final pais = _userData['pais'] as String?;
    final avatarUrl = _userData['avatar_url'] as String?;
    final nivel = _userData['nivel'] as String?;
    final puntos = (_userData['puntos'] as num?)?.toInt() ?? 0;

    final ubicacion = [
      ciudad,
      pais,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Barra superior ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await context.pushNamed('profile_settings');
                      // Refrescar datos al volver por si se ha modificado el perfil desde Configuración
                      if (mounted) _loadProfile();
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: c.primaryLight,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.menu_rounded,
                        color: c.primaryDeep,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Foto de perfil ────────────────────────────────────────────────
            SizedBox(
              width: 160, // 🔥 control total aquí
              height: 160,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Container(
                      width: 160, // 🔥 tamaño del avatar
                      height: 160,
                      padding: const EdgeInsets.all(4), // 🔥 borde
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFB84D),
                            const Color(0xFFFFB84D).withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                      child: ClipOval(
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? Image.network(
                                avatarUrl,
                                fit: BoxFit.cover, // 🔥 clave
                              )
                            : Container(
                                color: c.primaryLight,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: c.primaryDeepWithAlpha(0.7),
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Badge
                  Positioned(
                    bottom: -6,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB84D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          nivel ?? 'PRINCIPIANTE',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Nombre ───────────────────────────────────────────────────────
            _isLoading && nombre.isEmpty
                ? Container(
                    width: 140,
                    height: 24,
                    decoration: BoxDecoration(
                      color: c.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  )
                : Text(
                    nombre.isNotEmpty ? nombre : 'Mi perfil',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),
            const SizedBox(height: 8),

            // ── Biografía ────────────────────────────────────────────────────
            if (biografia != null && biografia.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  biografia,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: c.textSecondary,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            const SizedBox(height: 10),

            // ── Ubicación ────────────────────────────────────────────────────
            if (ubicacion.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: c.primaryDeepWithAlpha(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ubicacion,
                    style: TextStyle(
                      fontSize: 13,
                      color: c.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 28),

            // ── Círculos de stats ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCircle(
                    context,
                    '–',
                    'Territorios',
                    Icons.flag_rounded,
                    const Color(0xFFE8698A),
                  ),
                  _buildStatCircle(
                    context,
                    '–',
                    'KM Totales',
                    Icons.directions_run_rounded,
                    c.primaryDeep,
                  ),
                  _buildStatCircle(
                    context,
                    '$puntos',
                    'Puntos',
                    Icons.leaderboard_rounded,
                    const Color(0xFFFFB84D),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCircle(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final c = context.colors;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.08),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: c.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // INSIGNIAS
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildBadgesSection(BuildContext context) {
    final c = context.colors;
    const previewBadges = [
      {
        'icon': Icons.directions_run_rounded,
        'color': Color(0xFFE8698A),
        'title': 'Primer paso',
      },
      {
        'icon': Icons.emoji_events_rounded,
        'color': Color(0xFFFFB84D),
        'title': 'Conquistador',
      },
      {
        'icon': Icons.bolt_rounded,
        'color': Color(0xFF7ED957),
        'title': 'Velocista',
      },
      {
        'icon': Icons.explore_rounded,
        'color': Color(0xFF56CCF2),
        'title': 'Explorador',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Mis Insignias',
          'Ver más',
          () => context.pushNamed('profile_badges'),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: previewBadges.map((b) {
            final color = b['color'] as Color;
            final icon = b['icon'] as IconData;
            final title = b['title'] as String;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HISTORIAL DE CARRERAS
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildHistorialSection(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Historial de Carreras',
          'Ver todo',
          () => context.pushNamed('run_history'),
        ),
        const SizedBox(height: 16),

        // Estado: cargando
        if (_actividadesRecientes == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.primaryDeep.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: c.primaryDeep),
                ),
                const SizedBox(height: 10),
                Text(
                  'Cargando historial...',
                  style: TextStyle(fontSize: 13, color: c.textHint, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )

        // Estado: sin carreras
        else if (_actividadesRecientes!.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.primaryDeep.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: c.primaryDeep.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.directions_run_rounded, size: 28, color: c.primaryDeep.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 14),
                Text(
                  'Aún no tienes carreras',
                  style: TextStyle(
                    fontSize: 15,
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completa tu primera carrera para verla aquí',
                  style: TextStyle(fontSize: 12, color: c.textHint),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )

        // Estado: con datos
        else
          Column(
            children: _actividadesRecientes!.map((a) {
              final isRunning = a.tipo == 'correr';
              final color = isRunning ? c.primaryDeep : const Color(0xFF34C759);
              final icon = isRunning ? Icons.directions_run_rounded : Icons.terrain_rounded;
              final label = isRunning ? 'Carrera' : 'Senderismo';

              // Formatear fecha
              final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
              final fechaStr = '${a.fecha.day} ${meses[a.fecha.month - 1]}. ${a.fecha.year}';

              return GestureDetector(
                onTap: () => context.pushNamed('run_detail', extra: {'actividad_id': a.id}),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: color.withValues(alpha: 0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Ícono / Foto
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: a.fotoUrl != null && a.fotoUrl!.isNotEmpty
                            ? Image.network(a.fotoUrl!, fit: BoxFit.cover)
                            : Icon(icon, color: color, size: 28),
                      ),
                      const SizedBox(width: 14),

                      // Info central
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: c.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (a.compartida)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: c.primaryDeep.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      'Compartida',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: c.primaryDeep,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${a.distanciaKm.toStringAsFixed(2)} km  •  ${a.duracionFormateada}',
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              fechaStr,
                              style: TextStyle(
                                fontSize: 11,
                                color: c.textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Puntos
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFB84D), size: 18),
                          const SizedBox(height: 2),
                          Text(
                            '+${a.puntosGanados}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'pts',
                            style: TextStyle(
                              fontSize: 9,
                              color: c.textHint,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, color: c.textHint, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ESTADÍSTICAS
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildStatisticsSection(BuildContext context) {
    if (_estadisticas == null) return const SizedBox.shrink();

    final c = context.colors;
    final stats = _estadisticas!;
    
    final previewStats = [
      {
        'label': 'Total km',
        'value': stats.distanciaTotalKm.toStringAsFixed(1),
        'unit': 'km',
        'icon': Icons.route_rounded,
        'color': c.primaryDeep,
      },
      {
        'label': 'Velocidad prom.',
        'value': stats.velocidadPromedioGeneral.toStringAsFixed(1),
        'unit': 'km/h',
        'icon': Icons.speed_rounded,
        'color': const Color(0xFFE8698A),
      },
      {
        'label': 'Ritmo prom.',
        'value': stats.ritmoPromedioGeneral.toStringAsFixed(1),
        'unit': 'min/km',
        'icon': Icons.timer_rounded,
        'color': const Color(0xFF7ED957),
      },
      {
        'label': 'Carreras',
        'value': '${stats.totalCarreras}',
        'unit': 'total',
        'icon': Icons.flag_rounded,
        'color': const Color(0xFFFFB84D),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Mis Estadísticas',
          'Ver más',
          () => context.pushNamed('profile_stats'),
        ),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 74,
          ),
          children: previewStats.map((s) {
            final color = s['color'] as Color;
            final icon = s['icon'] as IconData;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${s['value']} ${s['unit']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          s['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: c.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // MULTIMEDIA
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildMultimediaSection(BuildContext context) {
    final c = context.colors;
    // Mostrar máximo 3 thumbnails
    final preview = _mediaItems.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Multimedia', 'Ver todo', () async {
          await context.pushNamed('profile_multimedia');
          // Recargar multimedia cuando se regresa
          if (mounted) {
            final items = await ProfileService.getMedia();
            if (mounted) setState(() => _mediaItems = items);
          }
        }),
        const SizedBox(height: 16),
        if (preview.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Sin fotos',
                style: TextStyle(color: c.textHint, fontSize: 13),
              ),
            ),
          )
        else
          SizedBox(
            height: 110,
            child: Row(
              children: [
                for (int i = 0; i < preview.length; i++) ...[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        preview[i]['url']!,
                        fit: BoxFit.cover,
                        height: 110,
                        errorBuilder: (_, __, ___) => Container(
                          color: c.primaryDeepWithAlpha(0.1),
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: c.textHint,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (i < preview.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────

  // ────────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String actionLabel,
    VoidCallback onTap,
  ) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.primaryDeepWithAlpha(0.9),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: c.primaryDeepWithAlpha(0.9),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // SKELETON
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildProfileSkeletonBody(BuildContext context) {
    final c = context.colors;
    return FadeTransition(
      opacity: _pulseAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          
          // Badges Section
          _skeletonRow(140, 20),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(4, (i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )),
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Statistics Section
          _skeletonRow(120, 20),
          const SizedBox(height: 16),
          Column(
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            )),
          ),
          
          const SizedBox(height: 28),
          
          // Multimedia Section
          _skeletonRow(150, 20),
          const SizedBox(height: 16),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(14),
                ),
              );
            },
          ),
          
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _skeletonRow(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
