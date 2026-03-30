import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/home/data/models/novedad_model.dart';
import 'package:runn_front/features/home/services/novedades_service.dart';
import 'package:runn_front/features/home/presentation/widgets/news_bottom_sheet.dart';
import 'package:runn_front/features/profile/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final PageController _newsPageController;
  late final PageController _quotesPageController;
  late AnimationController _animationController;
  late AnimationController _skeletonController;
  late Animation<double> _contentAnimation;
  late Animation<double> _pulseAnimation;
  Timer? _newsTimer;
  Timer? _quotesTimer;

  int _newsCurrentPage = 0;
  int _quoteCurrentPage = 0;

  bool _isAdmin = false;
  String _userName = 'Runner';
  bool _isLoadingNews = true;
  bool _isRefreshing = false;
  List<NovedadModel> _newsItems = [];

  final List<Map<String, String>> _quotes = const [
    {
      'quote':
          '"No importa que tan lento vayas, siempre y cuando no te detengas."',
      'author': 'CONFUCIO',
    },
    {'quote': '"Cada paso te acerca a tu mejor version."', 'author': 'RUNN'},
    {
      'quote':
          '"La disciplina vence al talento cuando el talento no se disciplina."',
      'author': 'ANONIMO',
    },
  ];

  @override
  void initState() {
    super.initState();
    _newsPageController = PageController();
    _quotesPageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _contentAnimation = CurvedAnimation(
      parent: _animationController,
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
    _animationController.forward();
    _initData();
  }

  Future<void> _initData() async {
    await _loadUserData();
    await _checkRole();
    await _loadNews();
    _startAutoCarousels();
  }

  Future<void> _handleRefresh() async {
    if (mounted) setState(() => _isRefreshing = true);
    await _initData();
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _loadUserData() async {
    final data = await ProfileService.getLocalProfile();
    final fullNombre = data['nombre'] as String? ?? '';
    // Extraer el primer nombre
    final primerNombre = fullNombre.trim().split(' ').first;

    if (mounted) {
      setState(() {
        _userName = primerNombre.isNotEmpty ? primerNombre : 'Runner';
      });
    }
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isAdmin = prefs.getString(ApiConfig.userRolKey) == 'admin';
      });
    }
  }

  @override
  void dispose() {
    _newsTimer?.cancel();
    _quotesTimer?.cancel();
    _newsPageController.dispose();
    _quotesPageController.dispose();
    _animationController.dispose();
    _skeletonController.dispose();
    super.dispose();
  }

  void _startAutoCarousels() {
    _newsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _newsItems.isEmpty) return;
      final next = (_newsCurrentPage + 1) % _newsItems.length;
      _newsPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });

    _quotesTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_quoteCurrentPage + 1) % _quotes.length;
      _quotesPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: FadeTransition(
        opacity: _contentAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(_contentAnimation),
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: c.primaryDeep,
            backgroundColor: c.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(c),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
                    child: _isRefreshing 
                      ? _buildHomeSkeleton(context)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _startRunButton(context),
                      const SizedBox(height: 28),

                      _buildSectionHeader(
                        'Novedades',
                        Icons.newspaper_rounded,
                        context,
                        trailing: _isAdmin
                            ? IconButton(
                                onPressed: () async {
                                  final refresh = await context.push(
                                    '/news/new/edit',
                                  );
                                  if (refresh == true) {
                                    _loadNews();
                                  }
                                },
                                icon: Icon(
                                  Icons.add_circle,
                                  color: context.colors.primaryDeep,
                                  size: 28,
                                ),
                                tooltip: 'Nueva Novedad',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _newsCarousel(),

                      const SizedBox(height: 28),

                      _buildSectionHeader(
                        'Stats rápidas',
                        Icons.bolt_rounded,
                        context,
                      ),
                      const SizedBox(height: 16),
                      _statsRow(),

                      const SizedBox(height: 28),
                      _weeklyStats(),

                            const SizedBox(height: 20),
                            _quotesCarousel(),
                          ],
                        ),
                  ),
                ],
              ),
            ),
          ),
      ),
    ),
  );
}

  // ── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader(dynamic c) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surface,
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
            top: 20,
            right: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFB84D).withValues(alpha: 0.06),
                    const Color(0xFFFFB84D).withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    c.primaryDeepWithAlpha(0.05),
                    c.primaryDeepWithAlpha(0.01),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Columna 1: textos ──────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          '¡Hola, $_userName!',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '¡Bienvenido de nuevo!',
                          style: TextStyle(
                            fontSize: 16,
                            color: c.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Columna 2: iconos ──────────────────────────────────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 10),
                      _HeaderIconButton(
                        icon: Icons.notifications_outlined,
                        color: c,
                        onTap: () => context.push('/notifications'),
                      ),
                      const SizedBox(width: 8),
                      _HeaderIconButton(
                        icon: Icons.settings_outlined,
                        color: c,
                        onTap: () => context.pushNamed('profile_settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    BuildContext context, {
    Widget? trailing,
  }) {
    final c = context.colors;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: c.primaryDeepWithAlpha(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: c.primaryDeepWithAlpha(0.8)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing] else const Spacer(),
      ],
    );
  }

  // ── START RUN BUTTON ──────────────────────────────────────────────────────

  Widget _startRunButton(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.primaryDeep, c.primaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: c.primaryDeepWithAlpha(0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/start_career'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: c.primaryLight,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  'Iniciar Carrera',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: c.primaryLight,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── NEWS CAROUSEL ─────────────────────────────────────────────────────────

  Future<void> _loadNews() async {
    try {
      final items = _isAdmin
          ? await NovedadesService.getAdminNovedades()
          : await NovedadesService.getNovedades();
      if (mounted) {
        setState(() {
          _newsItems = items;
          _isLoadingNews = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingNews = false);
      }
    }
  }

  Widget _newsCarousel() {
    if (_isLoadingNews) {
      return const SizedBox(
        height: 165,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_newsItems.isEmpty) {
      return Container(
        height: 165,
        decoration: BoxDecoration(
          color: context.colors.primaryDeepWithAlpha(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          'Pronto habrán novedades...',
          style: TextStyle(
            color: context.colors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _newsPageController,
            itemCount: _newsItems.length,
            onPageChanged: (index) => setState(() => _newsCurrentPage = index),
            itemBuilder: (_, index) {
              final item = _newsItems[index];
              return _NewsCard(
                novedad: item,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => NewsDetailBottomSheet(
                      novedad: item,
                      isAdmin: _isAdmin,
                      onRefreshRequested: _loadNews,
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _dotIndicator(_newsItems.length, _newsCurrentPage),
      ],
    );
  }

  // ── STATS ROW ─────────────────────────────────────────────────────────────

  Widget _statsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _statCard(
            icon: Icons.straighten_rounded,
            title: 'Distancia\ntotal',
            value: '12.5',
            unit: 'km',
            foot: '↑ 15% esta semana',
          ),
          const SizedBox(width: 12),
          _statCard(
            icon: Icons.map_rounded,
            title: 'Territorios\nnuevos',
            value: '3',
            unit: 'nuevos',
            foot: '↑ 2% vs ayer',
          ),
          const SizedBox(width: 12),
          _statCard(
            icon: Icons.timer_rounded,
            title: 'Tiempo\ntotal',
            value: '3.5',
            unit: 'horas',
            foot: '↑ 10% vs ayer',
          ),
          const SizedBox(width: 12),
          _statCard(
            icon: Icons.favorite_rounded,
            title: 'Ritmo\ncardiaco',
            value: '120',
            unit: 'bpm',
            foot: 'Promedio',
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required String foot,
  }) {
    final c = context.colors;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c.primaryDeepWithAlpha(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: c.primaryDeepWithAlpha(0.8)),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              height: 1.2,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.w900,
                      color: c.textPrimary,
                      letterSpacing: -0.9,
                      height: 0.95,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            foot,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7ED957),
            ),
          ),
        ],
      ),
    );
  }

  // ── WEEKLY STATS ──────────────────────────────────────────────────────────

  Widget _weeklyStats() {
    final c = context.colors;
    final stats = [
      {
        'icon': Icons.timer_rounded,
        'iconColor': c.primaryDeep,
        'label': 'Tiempo',
        'value': '3h 42',
        'unit': 'min',
        'progress': 0.62,
        'color': c.primaryDeep,
        'change': '+25 min vs semana ant.',
      },
      {
        'icon': Icons.local_fire_department_rounded,
        'iconColor': const Color(0xFFFFB84D),
        'label': 'Calorias',
        'value': '1,840',
        'unit': 'kcal',
        'progress': 0.84,
        'color': const Color(0xFFFFB84D),
        'change': 'Meta casi alcanzada',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Resumen semanal',
          Icons.bar_chart_rounded,
          context,
        ),
        const SizedBox(height: 16),
        _weekBarChart(),
        const SizedBox(height: 12),
        ...stats.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _weekStatRow(
              icon: s['icon'] as IconData,
              iconColor: s['iconColor'] as Color,
              label: s['label'] as String,
              value: s['value'] as String,
              unit: s['unit'] as String,
              progress: s['progress'] as double,
              color: s['color'] as Color,
              change: s['change'] as String,
            ),
          ),
        ),
      ],
    );
  }

  Widget _weekBarChart() {
    final c = context.colors;
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    const values = [0.1, 2.0, 4.0, 6.0, 4.0, 2.0, 1.0];
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actividad diaria',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: c.primaryDeepWithAlpha(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '24.5 km totales',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.primaryDeepWithAlpha(0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(days.length, (i) {
              final ratio = maxVal > 0 ? values[i] / maxVal : 0.0;
              final hasRun = values[i] > 0;
              final barHeight = hasRun ? (ratio * 52).clamp(8.0, 52.0) : 8.0;
              final isHigh = hasRun && ratio >= 0.75;
              final barColor = !hasRun
                  ? c.primaryDeepWithAlpha(0.08)
                  : isHigh
                  ? const Color(0xFFE8698A)
                  : c.primaryDeepWithAlpha(0.30);
              final labelColor = !hasRun
                  ? c.textSecondary
                  : isHigh
                  ? const Color(0xFFE8698A)
                  : c.primaryDeepWithAlpha(0.6);

              return Column(
                children: [
                  SizedBox(
                    height: 14,
                    child: hasRun
                        ? Text(
                            '${values[i]}',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: labelColor,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 22,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isHigh ? FontWeight.w800 : FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── SKELETON ──────────────────────────────────────────────────────────────

  Widget _buildHomeSkeleton(BuildContext context) {
    final c = context.colors;
    return FadeTransition(
      opacity: _pulseAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón principal skeleton
          Container(
            width: double.infinity,
            height: 65,
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 28),
          
          // Novedades Title Skeleton
          _skeletonRow(120, 20),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Stats Title Skeleton
          _skeletonRow(140, 20),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 150,
                  height: 130,
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              )),
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Weekly Stats Skeleton
          _skeletonRow(160, 20),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
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

  Widget _weekStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
    required double progress,
    required Color color,
    required String change,
  }) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: c.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    value: progress,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── QUOTES CAROUSEL ───────────────────────────────────────────────────────

  Widget _quotesCarousel() {
    final c = context.colors;
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _quotesPageController,
            itemCount: _quotes.length,
            onPageChanged: (index) => setState(() => _quoteCurrentPage = index),
            itemBuilder: (_, index) {
              final quote = _quotes[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c.primaryDeep, c.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: c.primaryDeepWithAlpha(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"',
                      style: TextStyle(
                        fontSize: 44,
                        height: 0.9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        quote['quote']!,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.35,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.95),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        quote['author']!,
                        style: const TextStyle(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _dotIndicator(_quotes.length, _quoteCurrentPage),
      ],
    );
  }

  // ── DOT INDICATOR ─────────────────────────────────────────────────────────

  Widget _dotIndicator(int length, int current) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == current ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: i == current
                ? c.primaryDeepWithAlpha(0.8)
                : c.primaryDeepWithAlpha(0.20),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// ── Icono circular reutilizable para el header ────────────────────────────

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final dynamic color;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color;
    return Material(
      color: c.primaryDeepWithAlpha(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 22, color: c.textPrimary),
        ),
      ),
    );
  }
}

// ── NEWS CARD ─────────────────────────────────────────────────────────────────

class _NewsCard extends StatelessWidget {
  final NovedadModel novedad;
  final VoidCallback onTap;

  const _NewsCard({required this.novedad, required this.onTap});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} de ${months[date.month - 1]}. ${date.year}';
  }

  String _capitalize(String s) {
    if (s.isEmpty) return '';
    return s[0].toUpperCase() +
        s.substring(1).toLowerCase().replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasImage = novedad.fotoUrl != null && novedad.fotoUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: c.primaryDeep,
          image: hasImage
              ? DecorationImage(
                  image: NetworkImage(novedad.fotoUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.10),
                Colors.black.withValues(alpha: 0.75),
              ],
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Stack(
            children: [
              if (novedad.destacada)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB84D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Destacado',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: c.primaryDeep,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _capitalize(novedad.tipo),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    novedad.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.4,
                      color: Colors.white,
                    ),
                  ),
                  if (novedad.publicadoEn != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(novedad.publicadoEn),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
