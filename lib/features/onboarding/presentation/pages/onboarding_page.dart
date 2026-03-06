import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const kPink = Color(0xFFFFD3E0);
const kPinkDark = Color(0xFFE8A0B8);
const kPinkDeep = Color(0xFFC4607A);
const kPinkLight = Color(0xFFFFF0F5);
const kPinkMid = Color(0xFFFFB8CE);
const kBgLight = Color(0xFFFCF8F9);

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

  // ============================================================
  // TIEMPO DE CAMBIO AUTOMÁTICO DE DIAPOSITIVA
  // Cambia este valor para ajustar cuántos segundos dura cada slide.
  // Ejemplo: Duration(seconds: 3) para 3 segundos,
  //          Duration(seconds: 8) para 8 segundos.
  // ============================================================
  static const _slideDuration = Duration(seconds: 5);

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
    final next = (_currentPage + 1) % _pages.length;
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
    return Scaffold(
      backgroundColor: kBgLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Carousel ─────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),

            // ── Bottom section ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: Column(
                children: [
                  // Page indicators
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
                                  ? kPink
                                  : kPink.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Button
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: kPink,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: kPink.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Comenzar'
                                : 'Siguiente',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == _pages.length - 1
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            color: const Color(0xFF1A1A1A),
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

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image — tamaño fijo, no ocupa toda la pantalla
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
                          kPink.withValues(alpha: 0.25),
                          kPinkMid.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                  page.imageUrl.isNotEmpty
                      ? Image.network(
                          page.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallback(page),
                        )
                      : _buildFallback(page),
                  Container(color: Colors.black.withValues(alpha: 0.04)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 72),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 14),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(_OnboardingPage page) {
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
                ? kPink.withValues(alpha: 0.18)
                : kPinkLight.withValues(alpha: 0.5),
          ),
        ),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPinkDeep.withValues(alpha: 0.25),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Icon(page.fallbackIcon, color: kPinkDeep, size: 44),
          ),
        ),
      ],
    );
  }
}
