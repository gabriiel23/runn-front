import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _newsPageController;
  late final PageController _quotesPageController;
  late AnimationController _animationController;
  late Animation<double> _contentAnimation;
  Timer? _newsTimer;
  Timer? _quotesTimer;

  int _newsCurrentPage = 0;
  int _quoteCurrentPage = 0;

  final List<Map<String, String>> _newsItems = const [
    {
      'title': 'Maraton de Primavera: Inscribete',
      'subtitle': 'Evento principal de esta semana',
      'image':
          'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Nueva ruta en parque central',
      'subtitle': 'Conquista 3 territorios hoy',
      'image':
          'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Reto nocturno disponible',
      'subtitle': 'Gana bonus de energia',
      'image':
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1000&q=80',
    },
  ];

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
    _animationController.forward();
    _startAutoCarousels();
  }

  @override
  void dispose() {
    _newsTimer?.cancel();
    _quotesTimer?.cancel();
    _newsPageController.dispose();
    _quotesPageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoCarousels() {
    _newsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(c), // 👈 ahora SI hace scroll

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _startRunButton(context),
                      const SizedBox(height: 28),

                      _buildSectionHeader(
                        'Novedades',
                        Icons.newspaper_rounded,
                        context,
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
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.primaryLight,
                          image: const DecorationImage(
                            image: AssetImage("assets/corredores.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Bienvenido de nuevo!',
                              style: TextStyle(
                                fontSize: 12,
                                color: c.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '¡Hola, Runner!',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: c.textPrimary,
                                letterSpacing: -0.6,
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
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    BuildContext context,
  ) {
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
        const Spacer(),
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
              children: const [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                SizedBox(width: 10),
                Text(
                  'Iniciar Carrera',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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

  Widget _newsCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 165,
          child: PageView.builder(
            controller: _newsPageController,
            itemCount: _newsItems.length,
            onPageChanged: (index) => setState(() => _newsCurrentPage = index),
            itemBuilder: (_, index) {
              final item = _newsItems[index];
              return _NewsCard(
                title: item['title']!,
                subtitle: item['subtitle']!,
                imageUrl: item['image']!,
              );
            },
          ),
        ),
        const SizedBox(height: 10),
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

// ── NEWS CARD ─────────────────────────────────────────────────────────────────

class _NewsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;

  const _NewsCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.10),
              Colors.black.withValues(alpha: 0.60),
            ],
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.4,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
