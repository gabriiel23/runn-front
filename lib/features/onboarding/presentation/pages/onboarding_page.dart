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
  
  int _currentStep = 0; // 0 = Seleccionar Tema, 1 = Ver Carrusel

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
    
    // Si iniciamos en step 1, correr el timer. Por ahora inicia en 0.
    // _timerController.forward();
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
    if (_currentStep == 0) return;
    final offset = index - _realIndex;
    final targetVirtual = _virtualPage + offset;
    _pageController.animateToPage(
      targetVirtual,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int virtualIndex) {
    if (_currentStep == 0) return;
    setState(() => _virtualPage = virtualIndex);
    _timerController.reset();
    _timerController.forward();
  }

  void _continuarAlCarrusel() {
    setState(() {
      _currentStep = 1;
    });
    // Al entrar al carrusel, empezamos el auto-slide
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _currentStep == 0
              ? _buildStep1(context, colors)
              : _buildStep2(context, colors),
        ),
      ),
    );
  }

  // ── STEP 1: Selección de Tema ──────────────────────────────────────────────
  Widget _buildStep1(BuildContext context, AppColors colors) {
    return LayoutBuilder(
      key: const ValueKey('step1'),
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Logo o ícono central
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colors.primaryDeep.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.palette_rounded,
                        size: 48,
                        color: colors.primaryDeep,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Personaliza tu Experiencia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.8,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Elige cómo prefieres que se vea tu aplicación.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildThemeSelector(context),
                    
                    const Spacer(),
                    const SizedBox(height: 16),
                    
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: _buildBottomButton(
                        context: context,
                        colors: colors,
                        text: 'Continuar',
                        icon: Icons.arrow_forward_rounded,
                        onTap: _continuarAlCarrusel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    // Tenemos 4 temas, los mostraremos en 2 filas de 2.
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildThemeCard(context, _themes[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildThemeCard(context, _themes[1])),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildThemeCard(context, _themes[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildThemeCard(context, _themes[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeCard(BuildContext context, _ThemeOption opt) {
    final notifier = context.themeNotifier;
    final colors = context.colors;
    final isSelected =
        notifier.scheme == opt.scheme && notifier.brightness == opt.brightness;

    return GestureDetector(
      onTap: () => notifier.setTheme(opt.scheme, opt.brightness),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? opt.swatchDeep.withValues(alpha: 0.15)
              : colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? opt.swatchDeep
                : colors.primaryWithAlpha(0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: opt.swatchDeep.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24, // 14 + 10 para superponer un poco
                  height: 14,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: _colorDot(opt.swatch, 14),
                      ),
                      Positioned(
                        left: 10,
                        child: _colorDot(opt.swatchDeep, 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(opt.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              opt.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isSelected ? opt.swatchDeep : colors.textSecondary,
              ),
            ),
            Text(
              opt.label2,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? opt.swatchDeep.withValues(alpha: 0.8)
                    : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 2: Carrusel Infinito ──────────────────────────────────────────────
  Widget _buildStep2(BuildContext context, AppColors colors) {
    return Column(
      key: const ValueKey('step2'),
      children: [
        // ── MEDIO: Carrusel infinito ───────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 48, bottom: 24),
            child: _buildCarousel(colors),
          ),
        ),

        // ── BOTTOM: Botón ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: _buildBottomButton(
            context: context,
            colors: colors,
            text: 'Comenzar',
            icon: Icons.rocket_launch_rounded,
            onTap: () => context.go('/login'),
          ),
        ),
      ],
    );
  }

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
          padding: const EdgeInsets.symmetric(vertical: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 24), // Ajustado a 24
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
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
          ),

          // Texto debajo de la imagen
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
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

  // ── BOTÓN REUTILIZABLE ──────────────────────────────────────────────────────
  Widget _buildBottomButton({
    required BuildContext context,
    required AppColors colors,
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
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
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              icon,
              color: colors.textPrimary,
              size: 20,
            ),
          ],
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
      border: Border.all(color: Colors.white, width: 1.5),
    ),
  );
}
