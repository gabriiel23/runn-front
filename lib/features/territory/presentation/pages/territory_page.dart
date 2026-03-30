import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../widgets/territory_map_tab.dart';
import '../widgets/my_territories_tab.dart';
import '../widgets/owned_territories_tab.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

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
    // Simular carga ya que es mockup por ahora
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _isRefreshing = false);
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
                  TerritoryMapTab(),
                  MyTerritoriesTab(),
                  OwnedTerritoriesTab(),
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
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: context.colors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: context.colors.primaryDeepWithAlpha(0.8),
                            size: 22,
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
                          Tab(text: 'Mis Territorios'),
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
