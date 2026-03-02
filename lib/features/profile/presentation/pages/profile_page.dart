import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  _buildProfileCard(),
                  const SizedBox(height: 28),
                  _buildAchievements(),
                  const SizedBox(height: 28),
                  _buildRecentRuns(),
                  const SizedBox(height: 28),
                  _buildMenuOptions(),
                  const SizedBox(height: 28),
                  _buildLogoutButton(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
      child: Stack(
        children: [
          Positioned(
            top: 40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8698A).withValues(alpha: 0.04),
                    const Color(0xFFE8698A).withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8698A).withValues(alpha: 0.03),
                    const Color(0xFFE8698A).withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFFE8698A,
                            ).withValues(alpha: 0.15),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFFFF0F4),
                          backgroundImage: const NetworkImage(
                            'https://images.unsplash.com/photo-1650452671134-28837b325586?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhdGhsZXRpYyUyMHBlcnNvbiUyMHJ1bm5pbmd8ZW58MXx8fHwxNzYzNjA1NjQzfDA&ixlib=rb-4.1.0&q=80&w=1080',
                          ),
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          color: const Color(0xFFE8698A).withValues(alpha: 0.8),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Alex Runner',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0A0A),
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFB84D,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(
                              0xFFFFB84D,
                            ).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              color: const Color(
                                0xFFFFB84D,
                              ).withValues(alpha: 0.9),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Nivel 8',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(
                                  0xFFFFB84D,
                                ).withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'runner@mail.com',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(
                            0xFF1A1A1A,
                          ).withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE8698A).withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderStat(
                          '47',
                          'Carreras',
                          Icons.directions_run_rounded,
                        ),
                        _buildHeaderDivider(),
                        _buildHeaderStat(
                          '352',
                          'Kilómetros',
                          Icons.location_on_rounded,
                        ),
                        _buildHeaderDivider(),
                        _buildHeaderStat(
                          '12',
                          'Territorios',
                          Icons.flag_outlined,
                        ),
                      ],
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

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFFE8698A).withValues(alpha: 0.7),
          size: 22,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0A0A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderDivider() {
    return Container(
      width: 1,
      height: 50,
      color: const Color(0xFFE8698A).withValues(alpha: 0.1),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progreso total',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A0A0A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Territorios conquistados',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                '12/45 · 27%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0A0A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.27,
              minHeight: 12,
              backgroundColor: const Color(0xFFFFF0F4),
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFE8698A).withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildSectionTitle('Logros recientes'),
          const SizedBox(height: 20),
          _buildAchievementItem(
            icon: Icons.emoji_events_rounded,
            iconColor: const Color(0xFFFFB84D),
            iconBgColor: const Color(0xFFFFF8F0),
            title: 'Conquistador',
            description: '10+ territorios dominados',
          ),
          const SizedBox(height: 12),
          _buildAchievementItem(
            icon: Icons.track_changes_rounded,
            iconColor: const Color(0xFF7ED957),
            iconBgColor: const Color(0xFFF4FDF0),
            title: 'Meta alcanzada',
            description: '100 km en un mes',
          ),
          const SizedBox(height: 12),
          _buildAchievementItem(
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFFE8698A),
            iconBgColor: const Color(0xFFFFF0F4),
            title: 'Mejor ritmo',
            description: '4:30 min/km alcanzado',
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0A0A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRuns() {
    final recentRuns = [
      {
        'date': '20 Nov 2024',
        'time': '07:30 AM',
        'distance': '8.5',
        'duration': '42:15',
        'pace': '4:58',
        'calories': 520,
      },
      {
        'date': '18 Nov 2024',
        'time': '06:45 AM',
        'distance': '10.2',
        'duration': '58:30',
        'pace': '5:44',
        'calories': 645,
      },
      {
        'date': '16 Nov 2024',
        'time': '07:15 AM',
        'distance': '5.8',
        'duration': '31:20',
        'pace': '5:24',
        'calories': 380,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildSectionTitle('Historial de carreras'),
          const SizedBox(height: 20),
          ...recentRuns.map(
            (run) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildRunItem(run),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunItem(Map<String, dynamic> run) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8698A).withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7ED957),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      run['date'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0A0A0A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      run['time'],
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB84D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFB84D).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: const Color(0xFFFFB84D).withValues(alpha: 0.9),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${run['calories']} kcal',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFB84D).withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildRunStat(
                Icons.location_on_rounded,
                'Distancia',
                run['distance'],
                'km',
                const Color(0xFFE8698A),
              ),
              _buildRunStat(
                Icons.access_time_rounded,
                'Tiempo',
                run['duration'],
                '',
                const Color(0xFF7ED957),
              ),
              _buildRunStat(
                Icons.trending_up_rounded,
                'Ritmo',
                run['pace'],
                'min/km',
                const Color(0xFFFFB84D),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunStat(
    IconData icon,
    String label,
    dynamic value,
    String unit,
    Color color,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color.withValues(alpha: 0.6), size: 13),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A0A0A),
              letterSpacing: -0.3,
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.watch_rounded,
            iconColor: const Color(0xFFE8698A),
            iconBgColor: const Color(0xFFFFF0F4),
            title: 'Dispositivos',
            subtitle: 'Sin dispositivo conectado',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.track_changes_rounded,
            iconColor: const Color(0xFFE8698A),
            iconBgColor: const Color(0xFFFFF0F4),
            title: 'Objetivos',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFF7ED957),
            iconBgColor: const Color(0xFFF4FDF0),
            title: 'Rutas favoritas',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            iconColor: const Color(0xFF1A1A1A),
            iconBgColor: const Color(0xFFF5F5F5),
            title: 'Configuración',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A0A0A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: const Color(0xFFE8698A).withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.85),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.85),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFE8698A).withValues(alpha: 0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0A0A0A),
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
