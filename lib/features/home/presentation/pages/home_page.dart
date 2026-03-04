import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _bgColor = Color(0xFFF6F3F5);
  static const _textPrimary = Color(0xFF2A2C3A);
  static const _textSecondary = Color(0xFF8A8EA3);
  static const _pinkSoft = Color(0xFFF2E7EC);
  static const _runButtonColor = Color(0xFFFFD3E0);

  late final PageController _newsPageController;
  late final PageController _quotesPageController;
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
      'quote': '"No importa que tan lento vayas, siempre y cuando no te detengas."',
      'author': 'CONFUCIO',
    },
    {
      'quote': '"Cada paso te acerca a tu mejor version."',
      'author': 'RUNN',
    },
    {
      'quote': '"La disciplina vence al talento cuando el talento no se disciplina."',
      'author': 'ANONIMO',
    },
  ];

  @override
  void initState() {
    super.initState();
    _newsPageController = PageController();
    _quotesPageController = PageController();
    _startAutoCarousels();
  }

  @override
  void dispose() {
    _newsTimer?.cancel();
    _quotesTimer?.cancel();
    _newsPageController.dispose();
    _quotesPageController.dispose();
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
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 22),
              _sectionTitle('Stats rapidas', actionText: 'Ver detalles'),
              const SizedBox(height: 12),
              _statsRow(),
              const SizedBox(height: 18),
              _startRunButton(context),
              const SizedBox(height: 18),
              _sectionTitle('Novedades'),
              const SizedBox(height: 12),
              _newsCarousel(),
              const SizedBox(height: 22),
              _weeklyStats(),
              const SizedBox(height: 16),
              _quotesCarousel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF0D7CC),
          ),
          child: const Icon(Icons.person, color: Color(0xFFB47F65), size: 20),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenido de nuevo!',
                style: TextStyle(
                  fontSize: 11,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '¡Hola, Runner!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary,
                  letterSpacing: -0.7,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFEDEFF4),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.notifications,
            size: 18,
            color: Color(0xFF5D6174),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, {String? actionText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: _textPrimary,
            letterSpacing: -0.6,
          ),
        ),
        if (actionText != null)
          Text(
            actionText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5E9BD8),
            ),
          ),
      ],
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.straighten_rounded,
            title: 'Distancia\ntotal',
            value: '12.5',
            unit: 'km',
            foot: '↑ 15% esta semana',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.map_rounded,
            title: 'Territorios\nnuevos',
            value: '3',
            unit: 'nuevos',
            foot: '↑ 2% vs ayer',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required String foot,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _pinkSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFD590AF)),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              height: 1.15,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary,
                  letterSpacing: -0.9,
                  height: 0.9,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textSecondary,
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
              color: Color(0xFF5AAA72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _startRunButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 66,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _runButtonColor,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB88998).withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextButton.icon(
          onPressed: () => context.go('/territories'),
          icon: const Icon(
            Icons.play_circle_fill_rounded,
            color: Color(0xFF2A4063),
            size: 24,
          ),
          label: const Text(
            'Iniciar Carrera',
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2A4063),
              letterSpacing: -0.8,
            ),
          ),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(34),
            ),
          ),
        ),
      ),
    );
  }

  Widget _newsCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 165,
          child: PageView.builder(
            controller: _newsPageController,
            itemCount: _newsItems.length,
            onPageChanged: (index) {
              setState(() => _newsCurrentPage = index);
            },
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

  Widget _weeklyStats() {
    final stats = [
      {
        'emoji': '📍',
        'label': 'Distancia',
        'value': '24.5',
        'unit': 'km',
        'progress': 0.72,
        'color': const Color(0xFFE09AB8),
        'bg': const Color(0xFFF8EDF2),
        'change': '+3.2 km vs semana ant.',
      },
      {
        'emoji': '⏱️',
        'label': 'Tiempo',
        'value': '3h 42',
        'unit': 'min',
        'progress': 0.62,
        'color': const Color(0xFF8EB8E8),
        'bg': const Color(0xFFEAF3FF),
        'change': '+25 min vs semana ant.',
      },
      {
        'emoji': '🔥',
        'label': 'Calorias',
        'value': '1,840',
        'unit': 'kcal',
        'progress': 0.84,
        'color': const Color(0xFFD5A46A),
        'bg': const Color(0xFFFFF3E6),
        'change': 'Meta casi alcanzada',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Resumen semanal'),
        const SizedBox(height: 12),
        _weekBarChart(),
        const SizedBox(height: 14),
        ...stats.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _weekStatRow(
              emoji: s['emoji'] as String,
              label: s['label'] as String,
              value: s['value'] as String,
              unit: s['unit'] as String,
              progress: s['progress'] as double,
              color: s['color'] as Color,
              bg: s['bg'] as Color,
              change: s['change'] as String,
            ),
          ),
        ),
      ],
    );
  }

  Widget _weekBarChart() {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    const values = [4.2, 0.0, 6.5, 5.1, 4.8, 3.9, 0.0];
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEE9EC),
        borderRadius: BorderRadius.circular(22),
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
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.55),
                ),
              ),
              const Text(
                '24.5 km totales',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8EB8E8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(days.length, (i) {
              final ratio = maxVal > 0 ? values[i] / maxVal : 0.0;
              final hasRun = values[i] > 0;
              final barHeight = hasRun ? (ratio * 52).clamp(8.0, 52.0) : 8.0;
              final isHighPerformance = hasRun && ratio >= 0.75;
              final Color barColor = !hasRun
                  ? const Color(0xFFDFDFDF)
                  : isHighPerformance
                  ? const Color(0xFFE09AB8)
                  : const Color(0xFFBFD8F3);
              final Color valueColor = !hasRun
                  ? const Color(0xFFB7B7B7)
                  : isHighPerformance
                  ? const Color(0xFFE09AB8)
                  : const Color(0xFF8EB8E8);
              final Color dayColor = !hasRun
                  ? const Color(0xFF9FA3B5)
                  : isHighPerformance
                  ? const Color(0xFFE09AB8)
                  : const Color(0xFF6F92BC);
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
                              color: valueColor,
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
                      fontWeight:
                          isHighPerformance ? FontWeight.w800 : FontWeight.w600,
                      color: dayColor,
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
    required String emoji,
    required String label,
    required String value,
    required String unit,
    required double progress,
    required Color color,
    required Color bg,
    required String change,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: progress,
                    backgroundColor: color.withValues(alpha: 0.16),
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

  Widget _quotesCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _quotesPageController,
            itemCount: _quotes.length,
            onPageChanged: (index) {
              setState(() => _quoteCurrentPage = index);
            },
            itemBuilder: (_, index) {
              final quote = _quotes[index];
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF0D2DF), Color(0xFFD5E9FF)],
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '”',
                      style: TextStyle(
                        fontSize: 44,
                        height: 0.9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE6A9C1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quote['quote']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.3,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF303448),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      quote['author']!,
                      style: const TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5C93D0),
                        fontSize: 11,
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

  Widget _dotIndicator(int length, int current) {
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
                ? const Color(0xFFE09AB8)
                : const Color(0xFFE09AB8).withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.15),
              Colors.black.withValues(alpha: 0.58),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
