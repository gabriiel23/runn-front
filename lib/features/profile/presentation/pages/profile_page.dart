import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('Building ProfileScreen...');
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 28),
                _buildBadgesSection(context),
                const SizedBox(height: 28),
                _buildStatisticsSection(context),
                const SizedBox(height: 28),
                _buildMultimediaSection(context),
                const SizedBox(height: 28),
                _buildSettingsMenu(context),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HEADER (foto + nombre + descripción + ubicación + círculos de stats)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final c = context.colors;
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
            // ── Barra superior ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => context.pushNamed('profile_edit'),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: c.primaryLight,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: c.primaryDeep,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Foto de perfil con borde de nivel ──────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Foto
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFB84D),
                        const Color(0xFFFFB84D).withValues(alpha: 0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: c.primaryLight,
                    child: Icon(
                      Icons.person_rounded,
                      color: c.primaryDeepWithAlpha(0.7),
                      size: 46,
                    ),
                  ),
                ),
                // Badge de nivel
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
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB84D).withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'LVL. 10',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Nombre ─────────────────────────────────────────────────────
            Text(
              'Alex Runner',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 8),

            // ── Descripción ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Corriendo por el mundo, un kilómetro a la vez. 🏃‍♂️💨',
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

            // ── Ubicación ──────────────────────────────────────────────────
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
                  'Loja, EC',
                  style: TextStyle(
                    fontSize: 13,
                    color: c.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Tres círculos de stats ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCircle(
                    context,
                    '12',
                    'Territorios',
                    Icons.flag_rounded,
                    const Color(0xFFE8698A),
                  ),
                  _buildStatCircle(
                    context,
                    '352',
                    'KM Totales',
                    Icons.directions_run_rounded,
                    c.primaryDeep,
                  ),
                  _buildStatCircle(
                    context,
                    '#8',
                    'Rango',
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
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 2,
            ),
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

  // ──────────────────────────────────────────────────────────────────────────
  // INSIGNIAS (preview + Ver más)
  // ──────────────────────────────────────────────────────────────────────────

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

  // ──────────────────────────────────────────────────────────────────────────
  // ESTADÍSTICAS (preview + Ver más)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildStatisticsSection(BuildContext context) {
    final c = context.colors;
    final previewStats = [
      {
        'label': 'Total km',
        'value': '352.4',
        'unit': 'km',
        'icon': Icons.route_rounded,
        'color': c.primaryDeep,
      },
      {
        'label': 'Velocidad máx.',
        'value': '18.2',
        'unit': 'km/h',
        'icon': Icons.speed_rounded,
        'color': const Color(0xFFE8698A),
      },
      {
        'label': 'Ritmo promedio',
        'value': '5:12',
        'unit': 'min/km',
        'icon': Icons.timer_rounded,
        'color': const Color(0xFF7ED957),
      },
      {
        'label': 'Carreras',
        'value': '47',
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
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.4,
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
                        ),
                        Text(
                          s['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: c.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
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

  // ──────────────────────────────────────────────────────────────────────────
  // MULTIMEDIA
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildMultimediaSection(BuildContext context) {
    final c = context.colors;
    final mockImages = [
      'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=500&auto=format&fit=crop',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Multimedia',
          'Ver todo',
          () => context.pushNamed('profile_multimedia'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: mockImages.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    mockImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: c.primaryDeepWithAlpha(0.1),
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: c.textHint,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // MENÚ DE OPCIONES FINALES
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildSettingsMenu(BuildContext context) {
    return Column(
      children: [
        _buildMenuOption(
          context,
          'Editar perfil',
          Icons.person_outline_rounded,
          'profile_edit',
        ),
        const SizedBox(height: 12),
        _buildMenuOption(
          context,
          'Conectar wearable',
          Icons.watch_rounded,
          'profile_wearables',
        ),
        const SizedBox(height: 12),
        _buildMenuOption(
          context,
          'Configuración',
          Icons.settings_outlined,
          'profile_settings',
        ),
      ],
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    String title,
    IconData icon,
    String routeName,
  ) {
    final c = context.colors;
    return ListTile(
      onTap: () => context.pushNamed(routeName),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      tileColor: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: c.primaryDeepWithAlpha(0.05)),
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: c.primaryDeep, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: c.textHint.withValues(alpha: 0.5),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────────────────────

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
}
