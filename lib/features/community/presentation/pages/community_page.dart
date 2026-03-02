import 'package:flutter/material.dart';

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

  // 0 = Comunidad, 1 = Retos
  int _selectedTab = 0;

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

  void _switchTab(int index) {
    if (_selectedTab != index) {
      setState(() => _selectedTab = index);
    }
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
                FadeTransition(
                  opacity: _contentAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(_contentAnimation),
                    child: _selectedTab == 0
                        ? _buildCommunityContent()
                        : _buildRetosContent(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HEADER CON TABS
  // ─────────────────────────────────────────────────────────────────────────

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
            // Decorative circles
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
                      const Color(0xFF6B8EFF).withValues(alpha: 0.05),
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
                      const Color(0xFF7ED957).withValues(alpha: 0.04),
                      const Color(0xFF7ED957).withValues(alpha: 0.01),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row
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
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: const Color(
                                    0xFF6B8EFF,
                                  ).withValues(alpha: 0.8),
                                  size: 22,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6B6B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Título dinámico
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        key: ValueKey(_selectedTab),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTab == 0 ? 'Comunidad' : 'Retos',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0A0A0A),
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedTab == 0
                                ? 'Conecta con runners cerca de ti'
                                : 'Supera tus límites cada día',
                            style: TextStyle(
                              fontSize: 15,
                              color: const Color(
                                0xFF1A1A1A,
                              ).withValues(alpha: 0.5),
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.2,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats rápidas dinámicas
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
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
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _selectedTab == 0
                            ? _buildCommunityStats()
                            : _buildRetosStats(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tab switcher
                    _buildTabSwitcher(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityStats() {
    return Row(
      key: const ValueKey('community-stats'),
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildHeaderStat('247', 'Grupos', Icons.groups_rounded),
        _buildHeaderDivider(),
        _buildHeaderStat('1.2k', 'Runners', Icons.directions_run_rounded),
        _buildHeaderDivider(),
        _buildHeaderStat('52', 'Eventos', Icons.event_rounded),
      ],
    );
  }

  Widget _buildRetosStats() {
    return Row(
      key: const ValueKey('retos-stats'),
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildHeaderStat('3', 'Activos', Icons.bolt_rounded),
        _buildHeaderDivider(),
        _buildHeaderStat('18.5', 'km hoy', Icons.location_on_rounded),
        _buildHeaderDivider(),
        _buildHeaderStat('4', 'Insignias', Icons.emoji_events_rounded),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTab(0, Icons.people_rounded, 'Comunidad'),
          _buildTab(1, Icons.bolt_rounded, 'Retos'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isActive
                    ? const Color(0xFF1E5BFF)
                    : const Color(0xFF6B6B6B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF1E5BFF)
                      : const Color(0xFF6B6B6B),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
      height: 40,
      color: const Color(0xFF6B8EFF).withValues(alpha: 0.1),
    );
  }

  BoxDecoration _cardDecoration({Color? accentColor}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: (accentColor ?? const Color(0xFF6B8EFF)).withValues(alpha: 0.10),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 0 — COMUNIDAD
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCommunityContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 28),
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 32),
          _buildNewsSection(),
          const SizedBox(height: 32),
          _buildPopularGroups(),
          const SizedBox(height: 32),
          _buildNearbyRunners(),
          const SizedBox(height: 40),
        ],
      ),
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
          hintText: 'Buscar grupos, runners...',
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
                  onPressed: () => setState(() => _searchController.clear()),
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

  Widget _buildNewsSection() {
    final newsList = [
      {
        'emoji': '🏆',
        'title': 'Runners Urbanos ganó el reto de marzo',
        'time': 'Hace 1h',
        'color': const Color(0xFFFFB84D),
      },
      {
        'emoji': '📍',
        'title': 'Nueva zona habilitada en el Centro Histórico',
        'time': 'Hace 3h',
        'color': const Color(0xFF6B8EFF),
      },
      {
        'emoji': '🔥',
        'title': 'Carlos M. está en racha — 7 días seguidos',
        'time': 'Hace 5h',
        'color': const Color(0xFFFF6B6B),
      },
    ];

    return Column(
      children: [
        _buildSectionHeader('Noticias', Icons.newspaper_rounded),
        const SizedBox(height: 16),
        ...newsList.map(
          (news) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildNewsItem(news),
          ),
        ),
      ],
    );
  }

  Widget _buildNewsItem(Map<String, dynamic> news) {
    final color = news['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(accentColor: color),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                news['emoji'] as String,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0A0A),
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  news['time'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.25),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPopularGroups() {
    final groups = [
      {
        'name': 'Runners Urbanos',
        'members': 247,
        'location': 'Centro Histórico',
        'level': 'Todos los niveles',
        'color': const Color(0xFF6B8EFF),
      },
      {
        'name': 'Trail Seekers',
        'members': 189,
        'location': 'Bosque de Chapultepec',
        'level': 'Intermedio',
        'color': const Color(0xFF7ED957),
      },
      {
        'name': 'Maratón Team',
        'members': 156,
        'location': 'Polanco',
        'level': 'Avanzado',
        'color': const Color(0xFFFFB84D),
      },
    ];

    return Column(
      children: [
        _buildSectionHeader('Grupos populares', Icons.groups_rounded),
        const SizedBox(height: 16),
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
      decoration: _cardDecoration(accentColor: color),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
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
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0A0A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group['members']} miembros  ·  ${group['level']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: color.withValues(alpha: 0.7),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      group['location'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Unirse',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyRunners() {
    final runners = [
      {
        'name': 'María González',
        'level': 12,
        'distance': '2.3 km',
        'avgPace': '5:15',
      },
      {
        'name': 'Carlos Ruiz',
        'level': 9,
        'distance': '1.8 km',
        'avgPace': '4:52',
      },
      {
        'name': 'Ana Martínez',
        'level': 15,
        'distance': '3.1 km',
        'avgPace': '5:30',
      },
    ];

    return Column(
      children: [
        _buildSectionHeader('Corredores cerca de ti', Icons.pin_drop_rounded),
        const SizedBox(height: 16),
        ...runners.map(
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
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 54,
                height: 54,
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
                  size: 26,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB84D), Color(0xFFFF9F1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    '${runner['level']}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
                  runner['name'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0A0A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: const Color(0xFF6B8EFF).withValues(alpha: 0.6),
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      runner['distance'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.trending_up_rounded,
                      color: const Color(0xFF7ED957).withValues(alpha: 0.7),
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${runner['avgPace']} min/km',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Seguir',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B8EFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 1 — RETOS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildRetosContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 28),
          _buildWeeklyChallenge(),
          const SizedBox(height: 32),
          _buildDailyChallenges(),
          const SizedBox(height: 32),
          _buildCommunityRaces(),
          const SizedBox(height: 32),
          _buildBadges(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWeeklyChallenge() {
    const progress = 18.5;
    const target = 30.0;
    const progressRatio = progress / target;

    return Column(
      children: [
        _buildSectionHeader('Reto de la semana', Icons.emoji_events_rounded),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E5BFF), Color(0xFF0D47D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E5BFF).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Corredor Imparable',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '3 días',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Corre 30 km esta semana',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${progress.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'de ${target.toStringAsFixed(0)} km',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏅', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        const Text(
                          'Insignia de Resistencia',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallenges() {
    final challenges = [
      {
        'icon': Icons.directions_run_rounded,
        'iconColor': const Color(0xFF6B8EFF),
        'iconBgColor': const Color(0xFFF5F7FF),
        'title': 'Carrera matutina',
        'description': 'Corre 5 km antes de las 9 AM',
        'reward': '+50 pts',
        'done': true,
      },
      {
        'icon': Icons.flag_rounded,
        'iconColor': const Color(0xFF7ED957),
        'iconBgColor': const Color(0xFFF4FDF0),
        'title': 'Conquista nueva zona',
        'description': 'Visita un territorio que no sea tuyo',
        'reward': '+80 pts',
        'done': false,
      },
      {
        'icon': Icons.people_rounded,
        'iconColor': const Color(0xFFFFB84D),
        'iconBgColor': const Color(0xFFFFF8F0),
        'title': 'Corre en grupo',
        'description': 'Completa una ruta con al menos 1 amigo',
        'reward': '+60 pts',
        'done': false,
      },
    ];

    return Column(
      children: [
        _buildSectionHeader('Desafíos diarios', Icons.bolt_rounded),
        const SizedBox(height: 16),
        ...challenges.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDailyChallengeItem(c),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallengeItem(Map<String, dynamic> c) {
    final isDone = c['done'] as bool;
    final iconColor = c['iconColor'] as Color;
    final iconBgColor = c['iconBgColor'] as Color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF4FDF0) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone
              ? const Color(0xFF7ED957).withValues(alpha: 0.3)
              : iconColor.withValues(alpha: 0.1),
          width: 1,
        ),
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF7ED957).withValues(alpha: 0.15)
                  : iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isDone ? Icons.check_rounded : c['icon'] as IconData,
              color: isDone ? const Color(0xFF7ED957) : iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['title'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDone
                        ? const Color(0xFF7ED957)
                        : const Color(0xFF0A0A0A),
                    letterSpacing: -0.2,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  c['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF7ED957).withValues(alpha: 0.1)
                  : iconColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isDone ? '✓' : c['reward'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDone ? const Color(0xFF7ED957) : iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityRaces() {
    final races = [
      {
        'name': '5K Matutino',
        'creator': 'Runners Urbanos',
        'date': '28 Nov',
        'participants': 42,
        'distance': 5,
        'color': const Color(0xFF6B8EFF),
      },
      {
        'name': 'Desafío 10K',
        'creator': 'Trail Seekers',
        'date': '2 Dic',
        'participants': 67,
        'distance': 10,
        'color': const Color(0xFF7ED957),
      },
      {
        'name': 'Media Maratón',
        'creator': 'Maratón Team',
        'date': '10 Dic',
        'participants': 128,
        'distance': 21,
        'color': const Color(0xFFFFB84D),
      },
    ];

    return Column(
      children: [
        _buildSectionHeader('Carreras de la comunidad', Icons.flag_rounded),
        const SizedBox(height: 16),
        ...races.map(
          (race) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRaceItem(race),
          ),
        ),
      ],
    );
  }

  Widget _buildRaceItem(Map<String, dynamic> race) {
    final color = race['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(accentColor: color),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '${race['distance']}K',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  race['name'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0A0A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Por ${race['creator']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      race['date'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.people_rounded,
                      size: 12,
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${race['participants']} inscritos',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Unirse',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    final badges = [
      {'name': 'Velocista', 'icon': '⚡', 'unlocked': true},
      {'name': 'Maratonista', 'icon': '🏃', 'unlocked': true},
      {'name': 'Conquistador', 'icon': '👑', 'unlocked': true},
      {'name': 'Resistencia', 'icon': '💪', 'unlocked': false},
      {'name': 'Nocturno', 'icon': '🌙', 'unlocked': false},
      {'name': 'Social', 'icon': '🤝', 'unlocked': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Mis insignias', Icons.workspace_premium_rounded),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: badges.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final badge = badges[index];
            final unlocked = badge['unlocked'] as bool;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: unlocked
                    ? const Color(0xFFFFD700).withValues(alpha: 0.12)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: unlocked
                      ? const Color(0xFFFFD700).withValues(alpha: 0.35)
                      : const Color(0xFFD1D1D1).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    badge['icon'] as String,
                    style: TextStyle(
                      fontSize: 30,
                      color: unlocked ? Colors.black : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    badge['name'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: unlocked
                          ? const Color(0xFF0A0A0A)
                          : const Color(0xFF1A1A1A).withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION HEADER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF6B8EFF).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF6B8EFF).withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0A0A),
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              Text(
                'Ver más',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B8EFF).withValues(alpha: 0.9),
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: const Color(0xFF6B8EFF).withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
