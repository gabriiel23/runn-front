import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/territory_data.dart';
import 'territory_detail_page.dart';
import '../widgets/territory_map_tab.dart';
import '../widgets/my_territories_tab.dart';

class TerritoriesScreen extends StatefulWidget {
  const TerritoriesScreen({super.key});

  @override
  State<TerritoriesScreen> createState() => _TerritoriesScreenState();
}

class _TerritoriesScreenState extends State<TerritoriesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late Animation<double> _headerAnimation;

  TerritoryData _selected = territoriesMock.first;

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
    _animController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _openDetail(TerritoryData territory) {
    setState(() => _selected = territory);
    _tabController.animateTo(2);
  }

  void _backToList() {
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController.index == 2) {
      return TerritoryDetailView(territory: _selected, onBack: _backToList);
    }

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(child: _buildHeader(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            TerritoryMapTab(onOpenDetail: _openDetail),
            MyTerritoriesTab(onOpenDetail: _openDetail),
            const SizedBox.shrink(),
          ],
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
              top: 30,
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
              bottom: 20,
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
                    // Tab bar corregido
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: context.colors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.colors.primaryDeepWithAlpha(0.08),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        padding: const EdgeInsets.all(4),
                        indicatorPadding: EdgeInsets.zero,
                        indicator: BoxDecoration(
                          color: context.colors.textPrimary,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        labelColor: context.colors.bg,
                        unselectedLabelColor: context.colors.textSecondary,
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                        tabs: const [
                          Tab(text: 'Mapa'),
                          Tab(text: 'Mis territorios'),
                          Tab(text: 'Detalle'),
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
}
