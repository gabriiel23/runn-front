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

const _pages = [
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
  // Slide 4: theme selector (special)
  _OnboardingPage(
    title: 'Elige tu estilo',
    description: 'Selecciona el tema visual que quieres usar en la app.',
    imageUrl: '',
    fallbackIcon: Icons.palette_rounded,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _timerController;

  static const _slideDuration = Duration(seconds: 5);
  // Index of the theme-picker slide (last one)
  static const _themeSlideIndex = 3;

  @override
  void initState() {
    super.initState();
    _timerController =
        AnimationController(vsync: this, duration: _slideDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _nextPage();
            }
          });
    _timerController.forward();
  }

  void _nextPage() {
    if (_currentPage >= _pages.length - 1) return; // stay on last
    final next = _currentPage + 1;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _timerController.reset();
    // Don't auto-advance from the theme selector slide
    if (index < _themeSlideIndex) {
      _timerController.forward();
    }
  }

  bool get _isThemeSlide => _currentPage == _themeSlideIndex;

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
            // ── Carousel ──────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  if (index == _themeSlideIndex) {
                    return _buildThemeSelectorSlide(context);
                  }
                  return _buildPage(_pages[index], colors);
                },
              ),
            ),

            // ── Bottom section ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: Column(
                children: [
                  // Progress dots
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final isActive = i == _currentPage;
                        return GestureDetector(
                          onTap: () => _goToPage(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 32 : 8,
                            height: 8,
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

                  // CTA button
                  GestureDetector(
                    onTap: () {
                      if (_isThemeSlide) {
                        context.go('/login');
                      } else {
                        _nextPage();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primaryWithAlpha(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isThemeSlide ? 'Comenzar' : 'Siguiente',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _isThemeSlide
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            color: colors.textPrimary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Standard info slide ────────────────────────────────────────────────────
  Widget _buildPage(_OnboardingPage page, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: 300,
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
                  Container(color: Colors.black.withValues(alpha: 0.04)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 72),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
              height: 1.6,
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
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colors.card.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primaryDeepWithAlpha(0.25),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Icon(page.fallbackIcon, color: colors.primaryDeep, size: 44),
          ),
        ),
      ],
    );
  }

  // ── Theme selector slide ───────────────────────────────────────────────────
  Widget _buildThemeSelectorSlide(BuildContext context) {
    final notifier = context.themeNotifier;
    final colors = context.colors;

    final themes = [
      _ThemeOption(
        label: 'Rosa Claro',
        emoji: '🌸',
        scheme: AppColorScheme.pink,
        brightness: AppBrightness.light,
        swatch: const Color(0xFFFFD3E0),
        swatchDeep: const Color(0xFFC4607A),
        isDarkCard: false,
      ),
      _ThemeOption(
        label: 'Rosa Oscuro',
        emoji: '🌙',
        scheme: AppColorScheme.pink,
        brightness: AppBrightness.dark,
        swatch: const Color(0xFFFFD3E0),
        swatchDeep: const Color(0xFFF08AAA),
        isDarkCard: true,
      ),
      _ThemeOption(
        label: 'Azul Claro',
        emoji: '🩵',
        scheme: AppColorScheme.blue,
        brightness: AppBrightness.light,
        swatch: const Color(0xFF84DEFA),
        swatchDeep: const Color(0xFF0A8FAD),
        isDarkCard: false,
      ),
      _ThemeOption(
        label: 'Azul Oscuro',
        emoji: '🌑',
        scheme: AppColorScheme.blue,
        brightness: AppBrightness.dark,
        swatch: const Color(0xFF84DEFA),
        swatchDeep: const Color(0xFF4DD4F2),
        isDarkCard: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Column(
        children: [
          Icon(Icons.palette_rounded, color: colors.primaryDeep, size: 56),
          const SizedBox(height: 20),
          Text(
            'Elige tu estilo',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Puedes cambiarlo después desde Perfil → Ajustes',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
          const SizedBox(height: 36),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.15,
              children: themes.map((opt) {
                final isSelected =
                    notifier.scheme == opt.scheme &&
                    notifier.brightness == opt.brightness;
                return GestureDetector(
                  onTap: () async {
                    await notifier.setTheme(opt.scheme, opt.brightness);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: opt.isDarkCard
                          ? const Color(0xFF1A1A2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected
                            ? opt.swatchDeep
                            : opt.swatch.withValues(alpha: 0.3),
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? opt.swatchDeep.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: isSelected ? 20 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Color preview circles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _colorDot(opt.swatch),
                            const SizedBox(width: 6),
                            _colorDot(opt.swatchDeep),
                            if (opt.isDarkCard) ...[
                              const SizedBox(width: 6),
                              _colorDot(const Color(0xFF1A1A1A)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(opt.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 8),
                        Text(
                          opt.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: opt.isDarkCard
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: opt.swatchDeep,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Text(
                              'Activo',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorDot(Color color) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 1.5),
    ),
  );
}

class _ThemeOption {
  final String label;
  final String emoji;
  final AppColorScheme scheme;
  final AppBrightness brightness;
  final Color swatch;
  final Color swatchDeep;
  final bool isDarkCard;

  const _ThemeOption({
    required this.label,
    required this.emoji,
    required this.scheme,
    required this.brightness,
    required this.swatch,
    required this.swatchDeep,
    required this.isDarkCard,
  });
}
