import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('Building ProfileScreen...');
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
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
                _buildSettingsMenu(context),
                const SizedBox(height: 40),
                _buildLogoutButton(context),
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
        color: Colors.white,
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
              _buildUserInfo(),
              const SizedBox(height: 28),
              _buildMainStatsSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE8698A).withValues(alpha: 0.15),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFFFF0F4),
            child: Icon(
              Icons.person_rounded,
              color: const Color(0xFFE8698A).withValues(alpha: 0.8),
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
              color: const Color(0xFFFFF0F4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: Color(0xFFE8698A),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alex Runner',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0A0A0A),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Corriendo por el mundo, un kilómetro a la vez. 🏃‍♂️💨',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
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
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
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
        border: Border.all(color: const Color(0xFFFFB84D).withValues(alpha: 0.25)),
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

  Widget _buildMainStatsSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8698A).withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryStat('47', 'Carreras', Icons.directions_run_rounded),
          _buildSummaryDivider(),
          _buildSummaryStat('352', 'km', Icons.location_on_rounded),
          _buildSummaryDivider(),
          _buildSummaryStat('12', 'Territorios', Icons.flag_rounded),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFE8698A).withValues(alpha: 0.7), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0A0A0A),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryDivider() {
    return Container(
      width: 1.5,
      height: 30,
      color: const Color(0xFFE8698A).withValues(alpha: 0.1),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return _buildNavigationCard(
      context,
      'Mis estadísticas',
      'Ver gráficas de km, velocidad y ritmo',
      Icons.analytics_rounded,
      const Color(0xFFE8698A),
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
        _buildSectionTitle('Actividad reciente'),
        const SizedBox(height: 20),
        _buildActivityItem('Carrera matutina', 'Hoy, 07:30 AM', '8.5 km', '42:15'),
        const SizedBox(height: 12),
        _buildActivityItem('Entrenamiento urbano', 'Ayer, 06:45 PM', '5.2 km', '28:10'),
      ],
    );
  }

  Widget _buildActivityItem(String title, String date, String dist, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.directions_run_rounded, color: Color(0xFFE8698A), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0A0A0A))),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(color: const Color(0xFF1A1A1A).withValues(alpha: 0.45), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(dist, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFFE8698A))),
              Text(time, style: TextStyle(color: const Color(0xFF1A1A1A).withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    return Column(
      children: [
        _buildMenuOption(context, 'Editar perfil', Icons.person_outline_rounded, 'profile_edit'),
        const SizedBox(height: 12),
        _buildMenuOption(context, 'Conectar wearable', Icons.watch_rounded, 'profile_wearables'),
      ],
    );
  }

  Widget _buildMenuOption(BuildContext context, String title, IconData icon, String routeName) {
    return ListTile(
      onTap: () => context.pushNamed(routeName),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFFE8698A).withValues(alpha: 0.05)),
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFFE8698A), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0A0A0A)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFE0E0E0)),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      onPressed: () => context.go('/login'),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, color: Color(0xffFF3B30), size: 20),
          SizedBox(width: 8),
          Text(
            'Cerrar sesión',
            style: TextStyle(color: Color(0xffFF3B30), fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
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
    return GestureDetector(
      onTap: () => context.pushNamed(routeName),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
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
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0A0A0A), letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: const Color(0xFF1A1A1A).withValues(alpha: 0.5), height: 1.2),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE8698A).withValues(alpha: 0.05)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0A0A0A),
        letterSpacing: -0.5,
      ),
    );
  }
}
