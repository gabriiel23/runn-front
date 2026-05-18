import 'package:flutter/material.dart';
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../widgets/territory_map_tab.dart';
import '../widgets/owned_territories_tab.dart';
import 'admin_territory_list_page.dart';

class TerritoriesScreen extends StatefulWidget {
  const TerritoriesScreen({super.key});

  @override
  State<TerritoriesScreen> createState() => _TerritoriesScreenState();
}

class _TerritoriesScreenState extends State<TerritoriesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late AnimationController _skeletonController;
  late Animation<double> _headerAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isRefreshing = false;
  bool _isAdmin = false;
  bool _isGrupal = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadAdminStatus();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _skeletonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _skeletonController, curve: Curves.easeInOut),
    );
    _skeletonController.repeat(reverse: true);
    _animController.forward();
  }

  Future<void> _handleRefresh() async {
    if (mounted) setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _loadAdminStatus() async {
    final rol = await ApiConfig.getUserRol();
    if (mounted) setState(() => _isAdmin = rol == 'admin');
  }

  void _openAdminPanel() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminTerritoryListPage()),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    _skeletonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: context.colors.primaryDeep,
        backgroundColor: context.colors.surface,
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(child: _buildHeader(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],
          body: _isRefreshing 
            ? _buildTerritorySkeleton(context) 
            : TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  TerritoryMapTab(isGrupal: _isGrupal),
                  OwnedTerritoriesTab(isGrupal: _isGrupal),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
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
        child: Stack(
          children: [
            // Círculo decorativo superior derecho
            Positioned(
              top: -20,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      context.colors.primaryDeepWithAlpha(0.05),
                      context.colors.primaryDeepWithAlpha(0.01),
                    ],
                  ),
                ),
              ),
            ),
            // Círculo decorativo inferior izquierdo
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      context.colors.primaryDeepWithAlpha(0.04),
                      context.colors.primaryDeepWithAlpha(0.01),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila de íconos (apps + tune)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: context.colors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.apps_rounded,
                            color: context.colors.primaryDeepWithAlpha(0.8),
                            size: 22,
                          ),
                        ),
                        GestureDetector(
                          onTap: _isAdmin ? _openAdminPanel : null,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _isAdmin
                                  ? context.colors.primaryDeepWithAlpha(0.15)
                                  : context.colors.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _isAdmin
                                  ? Icons.edit
                                  : Icons.map_outlined,
                              color: _isAdmin
                                  ? context.colors.primaryDeep
                                  : context.colors.primaryDeepWithAlpha(0.8),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Título
                    Text(
                      'Territorios',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gestiona y explora tus zonas de cobertura',
                      style: TextStyle(
                        fontSize: 15,
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.2,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botón para seleccionar modalidad
                    InkWell(
                      onTap: _showModeSelectionSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isGrupal ? Icons.groups_rounded : Icons.person_rounded,
                              size: 18,
                              color: context.colors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Modalidad: ${_isGrupal ? "Grupal" : "Individual"}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: context.colors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: context.colors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tab bar
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: context.colors.primaryDeepWithAlpha(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        padding: const EdgeInsets.all(4),
                        indicatorPadding: EdgeInsets.zero,
                        indicator: BoxDecoration(
                          color: context.colors.primary,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        labelColor: context.colors.card, // White on both modes mostly
                        unselectedLabelColor: context.colors.textSecondary,
                        labelStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                        tabs: const [
                          Tab(text: 'Mapa'),
                          Tab(text: 'Territorios'),
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

  void _showModeSelectionSheet() {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.primaryDeepWithAlpha(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Elige cómo competir',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona la modalidad para ver el mapa y los rankings correspondientes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            _buildModeOption(
              icon: Icons.person_rounded,
              title: 'Individual',
              description: 'Batalla 1 vs 1. Supera el récord actual para conquistar el territorio de forma inmediata. Gana puntos personales.',
              isSelected: !_isGrupal,
              onTap: () {
                setState(() => _isGrupal = false);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            _buildModeOption(
              icon: Icons.groups_rounded,
              title: 'Grupal',
              description: 'Trabajo en equipo. Se inicia una disputa de 48h donde todos los miembros aportan. El promedio grupal decide la victoria.',
              isSelected: _isGrupal,
              onTap: () {
                setState(() => _isGrupal = true);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? c.primary.withValues(alpha: 0.08) : c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? c.primary : c.primaryDeepWithAlpha(0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? c.primary : c.primaryDeepWithAlpha(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : c.textSecondary,
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
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? c.primary : c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: c.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: c.primary, size: 20),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SKELETON
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildTerritorySkeleton(BuildContext context) {
    final c = context.colors;
    return FadeTransition(
      opacity: _pulseAnimation,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 90),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: c.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, width: 120, color: c.bg),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 80, color: c.bg),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 100, color: c.bg),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 45,
                  height: 30,
                  decoration: BoxDecoration(
                    color: c.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
