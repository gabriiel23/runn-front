import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/app_theme.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class _OnboardingPage {
  final String title;
  final String description;
  final String imageUrl;
  final IconData fallbackIcon;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.fallbackIcon,
  });
}

const _carouselPages = [
  _OnboardingPage(
    title: 'Conquista tu Ciudad',
    description:
        'Corre bucles cerrados para reclamar territorios y defenderlos de otros corredores.',
    imageUrl: 'assets/territorios.png',
    fallbackIcon: Icons.location_city_rounded,
  ),
  _OnboardingPage(
    title: 'Mejora tu Rendimiento',
    description:
        'Entrena con planes personalizados y supera tus marcas personales cada semana.',
    imageUrl: 'assets/rendimiento.jpg',
    fallbackIcon: Icons.directions_run_rounded,
  ),
  _OnboardingPage(
    title: 'Lleva tus Estadísticas',
    description:
        'Visualiza tu progreso, distancias, ritmo y calorías en tiempo real con cada carrera.',
    imageUrl: 'assets/estadisticas.jpg',
    fallbackIcon: Icons.bar_chart_rounded,
  ),
];

class _ThemeOption {
  final String label;
  final String label2;
  final String emoji;
  final AppColorScheme scheme;
  final AppBrightness brightness;
  final Color swatch;
  final Color swatchDeep;
  final bool isDarkCard;

  const _ThemeOption({
    required this.label,
    required this.label2,
    required this.emoji,
    required this.scheme,
    required this.brightness,
    required this.swatch,
    required this.swatchDeep,
    required this.isDarkCard,
  });
}

final _themes = [
  const _ThemeOption(
    label: 'Rosa',
    label2: 'Claro',
    emoji: '🌸',
    scheme: AppColorScheme.pink,
    brightness: AppBrightness.light,
    swatch: Color(0xFFFFD3E0),
    swatchDeep: Color(0xFFC4607A),
    isDarkCard: false,
  ),
  const _ThemeOption(
    label: 'Rosa',
    label2: 'Oscuro',
    emoji: '🌙',
    scheme: AppColorScheme.pink,
    brightness: AppBrightness.dark,
    swatch: Color(0xFFFFD3E0),
    swatchDeep: Color(0xFFF08AAA),
    isDarkCard: true,
  ),
  const _ThemeOption(
    label: 'Azul',
    label2: 'Claro',
    emoji: '🩵',
    scheme: AppColorScheme.blue,
    brightness: AppBrightness.light,
    swatch: Color(0xFF84DEFA),
    swatchDeep: Color(0xFF0A8FAD),
    isDarkCard: false,
  ),
  const _ThemeOption(
    label: 'Azul',
    label2: 'Oscuro',
    emoji: '🌑',
    scheme: AppColorScheme.blue,
    brightness: AppBrightness.dark,
    swatch: Color(0xFF84DEFA),
    swatchDeep: Color(0xFF4DD4F2),
    isDarkCard: true,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const int _virtualMultiplier = 1000;
  late final PageController _pageController;
  int _virtualPage = _carouselPages.length * _virtualMultiplier;
  late AnimationController _timerController;

  static const _slideDuration = Duration(seconds: 5);

  int get _realIndex => _virtualPage % _carouselPages.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _virtualPage);
    _timerController =
        AnimationController(vsync: this, duration: _slideDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) _nextPage();
          });
    _timerController.forward();
  }

  void _nextPage() {
    final next = _virtualPage + 1;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goToRealIndex(int index) {
    final offset = index - _realIndex;
    final targetVirtual = _virtualPage + offset;
    _pageController.animateToPage(
      targetVirtual,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int virtualIndex) {
    setState(() => _virtualPage = virtualIndex);
    _timerController.reset();
    _timerController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER: Selector de tema ───────────────────────────────────
            Expanded(
              flex: 20,
              child: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 0),
                child: _buildThemeHeader(context),
              ),
            ),

            // ── Divider separador ──────────────────────────────────────────
            Divider(
              height: 0,
              thickness: 2,
              indent: 20,
              endIndent: 20,
              color: colors.primaryDark,
            ),

            // ── MEDIO: Carrusel infinito ───────────────────────────────────
            Expanded(
              flex: 60,
              child: Padding(
                padding: const EdgeInsets.only(top:48, bottom: 48),
                child: _buildCarousel(colors),
              ),
            ),

            // ── BOTTOM: Botón ──────────────────────────────────────────────
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: _buildBottomButton(context, colors),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER: fila horizontal con chips de tema ──────────────────────────────
  Widget _buildThemeHeader(BuildContext context) {
    final notifier = context.themeNotifier;
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ELIGE TU ESTILO',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: _themes.map((opt) {
              final isSelected =
                  notifier.scheme == opt.scheme &&
                  notifier.brightness == opt.brightness;
              return Expanded(
                child: GestureDetector(
                  onTap: () => notifier.setTheme(opt.scheme, opt.brightness),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? opt.swatchDeep.withValues(alpha: 0.15)
                          : colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? opt.swatchDeep
                            : colors.primaryWithAlpha(0.15),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _colorDot(opt.swatch, 10),
                            const SizedBox(width: 3),
                            _colorDot(opt.swatchDeep, 10),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(opt.emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          opt.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? opt.swatchDeep
                                : colors.textSecondary,
                          ),
                        ),
                        Text(
                          opt.label2,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: isSelected
                                ? opt.swatchDeep.withValues(alpha: 0.8)
                                : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── CARRUSEL INFINITO ──────────────────────────────────────────────────────
  Widget _buildCarousel(AppColors colors) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, virtualIndex) {
              final realIndex = virtualIndex % _carouselPages.length;
              return _buildCarouselSlide(_carouselPages[realIndex], colors);
            },
          ),
        ),

        // Dots indicadores
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_carouselPages.length, (i) {
              final isActive = i == _realIndex;
              return GestureDetector(
                onTap: () => _goToRealIndex(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 28 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isActive
                        ? colors.primary
                        : colors.primaryWithAlpha(0.3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselSlide(_OnboardingPage page, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.primaryWithAlpha(0.25),
                          colors.primaryMidWithAlpha(0.45),
                        ],
                      ),
                    ),
                  ),
                  page.imageUrl.isNotEmpty
                      ? Image.asset(
                          page.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildFallback(page, colors),
                        )
                      : _buildFallback(page, colors),
                ],
              ),
            ),
          ),

          // Texto debajo de la imagen
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(_OnboardingPage page, AppColors colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemCount: 64,
          itemBuilder: (_, i) => Container(
            color: i % 3 == 0
                ? colors.primaryWithAlpha(0.18)
                : colors.primaryLight.withValues(alpha: 0.5),
          ),
        ),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.card.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: Icon(page.fallbackIcon, color: colors.primaryDeep, size: 36),
          ),
        ),
      ],
    );
  }

  // ── BOTÓN ──────────────────────────────────────────────────────────────────
  Widget _buildBottomButton(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: GestureDetector(
        onTap: () => context.go('/login'),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.primaryWithAlpha(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Comenzar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.rocket_launch_rounded,
                color: colors.textPrimary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorDot(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 1),
    ),
  );
}
