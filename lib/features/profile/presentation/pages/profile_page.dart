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
                _buildStatsCard(context),
                const SizedBox(height: 28),
                _buildBadgesSection(context),
                const SizedBox(height: 28),
                _buildRecentActivity(context),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 24),
              _buildUserInfo(context),
              const SizedBox(height: 28),
              _buildMainStatsSummary(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.primaryDeepWithAlpha(0.15), width: 2),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: c.primaryLight,
            child: Icon(
              Icons.person_rounded,
              color: c.primaryDeepWithAlpha(0.8),
              size: 24,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => context.pushNamed('profile_settings'),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.settings_outlined,
              color: c.primaryDeep,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alex Runner',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Corriendo por el mundo, un kilómetro a la vez. 🏃‍♂️💨',
          style: TextStyle(
            fontSize: 14,
            color: c.textSecondary,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildNivelBadge(),
            const SizedBox(width: 12),
            Text(
              'runner@mail.com',
              style: TextStyle(
                fontSize: 13,
                color: c.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNivelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB84D).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFB84D).withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB84D), size: 14),
          SizedBox(width: 4),
          Text(
            'Nivel 8',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFB84D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatsSummary(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: c.primaryLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.primaryDeep.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryStat(
            context,
            '47',
            'Carreras',
            Icons.directions_run_rounded,
          ),
          _buildSummaryDivider(context),
          _buildSummaryStat(context, '352', 'km', Icons.location_on_rounded),
          _buildSummaryDivider(context),
          _buildSummaryStat(context, '12', 'Territorios', Icons.flag_rounded),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final c = context.colors;
    return Column(
      children: [
        Icon(icon, color: c.primaryDeepWithAlpha(0.7), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: c.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryDivider(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 1.5,
      height: 30,
      color: c.primaryDeepWithAlpha(0.1),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final c = context.colors;
    return _buildNavigationCard(
      context,
      'Mis estadísticas',
      'Ver gráficas de km, velocidad y ritmo',
      Icons.analytics_rounded,
      c.primaryDeep,
      'profile_stats',
    );
  }

  Widget _buildBadgesSection(BuildContext context) {
    return _buildNavigationCard(
      context,
      'Mis insignias',
      'Colección de logros y medallas',
      Icons.workspace_premium_rounded,
      const Color(0xFFFFB84D),
      'profile_badges',
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Actividad reciente'),
        const SizedBox(height: 20),
        _buildActivityItem(
          context,
          'Carrera matutina',
          'Hoy, 07:30 AM',
          '8.5 km',
          '42:15',
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          context,
          'Entrenamiento urbano',
          'Ayer, 06:45 PM',
          '5.2 km',
          '28:10',
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String date,
    String dist,
    String time,
  ) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.directions_run_rounded,
              color: c.primaryDeep,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: c.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dist,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: c.primaryDeep,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: c.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultimediaSection(BuildContext context) {
    final c = context.colors;
    final mockImages = [
      'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=500&auto=format&fit=crop',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, 'Multimedia'),
            GestureDetector(
              onTap: () {
                context.pushNamed('profile_multimedia');
              },
              child: Row(
                children: [
                  Text(
                    'Ver todo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.primaryDeep,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: c.primaryDeep,
                  ),
                ],
              ),
            ),
          ],
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
                      child: Icon(Icons.broken_image_rounded, color: c.textHint),
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

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String routeName,
  ) {
    final c = context.colors;
    return GestureDetector(
      onTap: () => context.pushNamed(routeName),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(context),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: c.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: color.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final c = context.colors;
    return BoxDecoration(
      color: c.card,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: c.primaryDeepWithAlpha(0.05)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final c = context.colors;
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: c.textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }
}
