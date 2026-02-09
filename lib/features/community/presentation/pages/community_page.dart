import 'package:flutter/material.dart';
import 'dart:math' as math;

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _animationController.forward();

    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _contentAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_contentAnimation),
                      child: Column(
                        children: [
                          const SizedBox(height: 28),
                          _buildSearchBar(),
                          const SizedBox(height: 24),
                          _buildQuickActions(),
                          const SizedBox(height: 32),
                          _buildPopularGroups(),
                          const SizedBox(height: 32),
                          _buildNearbyRunners(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
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
            // Decorative elements
            Positioned(
              top: 30,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6B8EFF).withValues(alpha: 0.04),
                      const Color(0xFF6B8EFF).withValues(alpha: 0.01),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7ED957).withValues(alpha: 0.03),
                      const Color(0xFF7ED957).withValues(alpha: 0.01),
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.menu_rounded,
                            color: const Color(
                              0xFF6B8EFF,
                            ).withValues(alpha: 0.8),
                            size: 22,
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: const Color(
                              0xFF6B8EFF,
                            ).withValues(alpha: 0.8),
                            size: 22,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Comunidad',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A),
                        letterSpacing: -0.8,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Conecta con otros corredores cerca de ti',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.2,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Community stats
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(
                            0xFF6B8EFF,
                          ).withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildHeaderStat(
                            '247',
                            'Grupos',
                            Icons.groups_rounded,
                          ),
                          _buildHeaderDivider(),
                          _buildHeaderStat(
                            '1.2k',
                            'Runners',
                            Icons.directions_run_rounded,
                          ),
                          _buildHeaderDivider(),
                          _buildHeaderStat(
                            '52',
                            'Eventos',
                            Icons.event_rounded,
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
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF6B8EFF).withValues(alpha: 0.7),
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0A0A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
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
      height: 45,
      color: const Color(0xFF6B8EFF).withValues(alpha: 0.1),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSearchFocused
              ? const Color(0xFF6B8EFF).withValues(alpha: 0.3)
              : const Color(0xFF6B8EFF).withValues(alpha: 0.08),
          width: _isSearchFocused ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isSearchFocused
                ? const Color(0xFF6B8EFF).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: _isSearchFocused ? 16 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar grupos o corredores...',
          hintStyle: TextStyle(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isSearchFocused
                ? const Color(0xFF6B8EFF).withValues(alpha: 0.8)
                : const Color(0xFF1A1A1A).withValues(alpha: 0.4),
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _searchController.clear());
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.group_add_rounded,
            iconColor: const Color(0xFF6B8EFF),
            iconBgColor: const Color(0xFFF5F7FF),
            label: 'Crear Grupo',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.person_add_rounded,
            iconColor: const Color(0xFF7ED957),
            iconBgColor: const Color(0xFFF4FDF0),
            label: 'Invitar Amigos',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: iconColor.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
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
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0A0A0A),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularGroups() {
    final groups = [
      {
        'id': 1,
        'name': 'Runners Urbanos',
        'members': 247,
        'location': 'Centro Histórico',
        'level': 'Todos los niveles',
        'color': const Color(0xFF6B8EFF),
      },
      {
        'id': 2,
        'name': 'Trail Seekers',
        'members': 189,
        'location': 'Bosque de Chapultepec',
        'level': 'Intermedio',
        'color': const Color(0xFF7ED957),
      },
      {
        'id': 3,
        'name': 'Maratón Team',
        'members': 156,
        'location': 'Polanco',
        'level': 'Avanzado',
        'color': const Color(0xFFFFB84D),
      },
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grupos populares',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0A0A),
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Ver todos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B8EFF).withValues(alpha: 0.9),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: const Color(0xFF6B8EFF).withValues(alpha: 0.9),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...groups.map(
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildGroupItem(group),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupItem(Map<String, dynamic> group) {
    final color = group['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.groups_rounded,
              color: color.withValues(alpha: 0.8),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0A0A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${group['members']} miembros',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      group['level'],
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: color.withValues(alpha: 0.7),
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      group['location'],
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.3),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyRunners() {
    final nearbyRunners = [
      {
        'id': 1,
        'name': 'María González',
        'level': 12,
        'distance': '2.3 km',
        'avgPace': '5:15',
      },
      {
        'id': 2,
        'name': 'Carlos Ruiz',
        'level': 9,
        'distance': '1.8 km',
        'avgPace': '4:52',
      },
      {
        'id': 3,
        'name': 'Ana Martínez',
        'level': 15,
        'distance': '3.1 km',
        'avgPace': '5:30',
      },
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Corredores cerca de ti',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0A0A),
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Ver más',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B8EFF).withValues(alpha: 0.9),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: const Color(0xFF6B8EFF).withValues(alpha: 0.9),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...nearbyRunners.map(
          (runner) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRunnerItem(runner),
          ),
        ),
      ],
    );
  }

  Widget _buildRunnerItem(Map<String, dynamic> runner) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF6B8EFF).withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6B8EFF).withValues(alpha: 0.15),
                      const Color(0xFF6B8EFF).withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: const Color(0xFF6B8EFF).withValues(alpha: 0.7),
                  size: 28,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB84D), Color(0xFFFF9F1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '${runner['level']}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  runner['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0A0A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      runner['distance'],
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.speed_rounded,
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${runner['avgPace']} min/km',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6B8EFF).withValues(alpha: 0.15),
                  const Color(0xFF6B8EFF).withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_add_rounded,
              color: const Color(0xFF6B8EFF).withValues(alpha: 0.9),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
