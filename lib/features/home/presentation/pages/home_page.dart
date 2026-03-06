import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;

  // News carousel
  late PageController _newsPageController;
  int _newsCurrentPage = 0;
  Timer? _newsTimer;

  // Motivational carousel
  late PageController _motiPageController;
  int _motiCurrentPage = 0;
  Timer? _motiTimer;

  static const List<Map<String, String>> _newsItems = [
    {
      'title': 'Nueva Ruta: Parque Central',
      'desc': 'Descubre el nuevo trazado de 5km con desafíos exclusivos.',
      'emoji': '🏞️',
      'tag': 'NUEVO',
    },
    {
      'title': 'Evento Comunidad',
      'desc': 'Únete a la carrera grupal este domingo a las 8:00 AM.',
      'emoji': '🏃‍♂️',
      'tag': 'EVENTO',
    },
    {
      'title': 'Actualización v1.2',
      'desc': 'Mejoras en el seguimiento GPS y nuevos logros añadidos.',
      'emoji': '🚀',
      'tag': 'NOVEDAD',
    },
  ];

  static const List<Map<String, String>> _quotes = [
    {
      'quote':
          '"No te detengas cuando estés cansado. Detente cuando hayas terminado."',
      'author': 'David Goggins',
    },
    {
      'quote': '"El dolor que sientes hoy será la fuerza que sentirás mañana."',
      'author': 'Arnold Schwarzenegger',
    },
    {
      'quote': '"Cada kilómetro que corres te acerca a quien quieres ser."',
      'author': 'Anónimo',
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _animationController.forward();

    _newsPageController = PageController(viewportFraction: 0.88);
    _motiPageController = PageController();

    // Auto-advance news every 4 seconds
    _newsTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_newsCurrentPage + 1) % _newsItems.length;
      _newsPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });

    // Auto-advance motivational quotes every 5 seconds
    _motiTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_motiCurrentPage + 1) % _quotes.length;
      _motiPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _newsTimer?.cancel();
    _motiTimer?.cancel();
    _newsPageController.dispose();
    _motiPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildCreativeHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _contentAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_contentAnimation),
                      child: Column(
                        children: [
                          const SizedBox(height: 28),
                          _buildStartRunButton(),
                          const SizedBox(height: 32),
                          _buildNewsCarousel(),
                          const SizedBox(height: 32),
                          _buildWeeklyStats(),
                          const SizedBox(height: 28),
                          _buildMotivationalCarousel(),
                          const SizedBox(height: 32),
                          _buildTerritories(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String get _greetingEmoji {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 18) return '🌤️';
    return '🌙';
  }

  Widget _buildCreativeHeader() {
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFFFD3E0).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD3E0).withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: avatar + right actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFD3E0),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFFC04070),
                                size: 24,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_greetingEmoji $_greeting',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(
                                  0xFF1A1A1A,
                                ).withValues(alpha: 0.5),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'Runner',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0A0A0A),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD3E0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Text('⭐', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 4),
                              Text(
                                'Nv. 7',
                                style: TextStyle(
                                  color: Color(0xFFC04070),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFD3E0)),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: Color(0xFFC04070),
                                  size: 20,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6B6B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Headline
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (context, v, _) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, 14 * (1 - v)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Listo para correr,',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(
                                0xFF1A1A1A,
                              ).withValues(alpha: 0.45),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'conquista ',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0A0A0A),
                                    letterSpacing: -0.8,
                                    height: 1.1,
                                  ),
                                ),
                                TextSpan(
                                  text: 'el mundo',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFE8698A),
                                    letterSpacing: -0.8,
                                    height: 1.1,
                                  ),
                                ),
                                TextSpan(
                                  text: ' 🏆',
                                  style: TextStyle(fontSize: 24, height: 1.1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick stat chips — solid #FFD3E0
                Row(
                  children: [
                    _buildStatChip('🏃', '5', 'carreras'),
                    const SizedBox(width: 10),
                    _buildStatChip('📍', '42', 'zonas'),
                    const SizedBox(width: 10),
                    _buildStatChip('⭐', '127', 'pts'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD3E0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF8B1A4A),
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF8B1A4A).withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Start Run Button ────────────────────────────────────────────────────────

  Widget _buildStartRunButton() {
    return GestureDetector(
      onTap: () => context.go('/start_career'),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8698A), Color(0xFFFF85A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8698A).withValues(alpha: 0.38),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go('/start_career'),
            borderRadius: BorderRadius.circular(22),
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
                  SizedBox(width: 12),
                  Text(
                    'Iniciar carrera',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
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

  // ─── News Carousel ───────────────────────────────────────────────────────────

  Widget _buildNewsCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Novedades',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A0A0A),
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(
          height: 158,
          child: PageView.builder(
            controller: _newsPageController,
            itemCount: _newsItems.length,
            onPageChanged: (i) => setState(() => _newsCurrentPage = i),
            itemBuilder: (context, index) {
              final item = _newsItems[index];
              final isActive = index == _newsCurrentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                margin: EdgeInsets.only(
                  right: 12,
                  top: isActive ? 0 : 8,
                  bottom: isActive ? 0 : 8,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFE8698A).withValues(alpha: 0.25)
                        : const Color(0xFFE8698A).withValues(alpha: 0.08),
                    width: isActive ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isActive
                          ? const Color(0xFFE8698A).withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F4),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          item['emoji']!,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE8698A,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['tag']!,
                              style: const TextStyle(
                                color: Color(0xFFE8698A),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0A0A0A),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['desc']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(
                                0xFF1A1A1A,
                              ).withValues(alpha: 0.5),
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _newsItems.length,
            (i) => _buildDot(i, _newsCurrentPage, const Color(0xFFE8698A)),
          ),
        ),
      ],
    );
  }

  // ─── Weekly Stats ────────────────────────────────────────────────────────────

  Widget _buildWeeklyStats() {
    final stats = [
      {
        'emoji': '📍',
        'label': 'Distancia',
        'value': '24.5',
        'unit': 'km',
        'progress': 0.72,
        'color': const Color(0xFFE8698A),
        'bg': const Color(0xFFFFF0F4),
        'change': '+3.2 km vs semana ant.',
      },
      {
        'emoji': '⏱️',
        'label': 'Tiempo',
        'value': '3h 42',
        'unit': 'min',
        'progress': 0.62,
        'color': const Color(0xFF7ED957),
        'bg': const Color(0xFFF4FDF0),
        'change': '+25 min vs semana ant.',
      },
      {
        'emoji': '🔥',
        'label': 'Calorías',
        'value': '1,840',
        'unit': 'kcal',
        'progress': 0.84,
        'color': const Color(0xFFFFB84D),
        'bg': const Color(0xFFFFF8F0),
        'change': 'Meta casi alcanzada',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resumen semanal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0A0A),
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: Color(0xFFE8698A),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Esta semana',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE8698A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Day-of-week mini bar chart
        _buildWeekBarChart(),
        const SizedBox(height: 16),

        // Stat cards
        ...stats.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildWeekStatRow(
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

  Widget _buildWeekBarChart() {
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final values = [4.2, 0.0, 6.5, 5.1, 4.8, 3.9, 0.0];
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    const todayIndex = 6;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD3E0).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                ),
              ),
              const Text(
                '24.5 km totales',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8698A),
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
              final isToday = i == todayIndex;
              final hasRun = values[i] > 0;
              final barH = hasRun ? (ratio * 40).clamp(6.0, 40.0) : 6.0;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // km label — only shown if has run
                  SizedBox(
                    height: 14,
                    child: hasRun
                        ? Text(
                            '${values[i]}',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: isToday
                                  ? const Color(0xFFE8698A)
                                  : const Color(
                                      0xFF1A1A1A,
                                    ).withValues(alpha: 0.35),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 26,
                    height: barH,
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFFE8698A)
                          : hasRun
                          ? const Color(0xFFFFD3E0)
                          : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                      color: isToday
                          ? const Color(0xFFE8698A)
                          : const Color(0xFF1A1A1A).withValues(alpha: 0.4),
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

  Widget _buildWeekStatRow({
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0A0A0A),
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: color.withValues(alpha: 0.1),
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

  // ─── Motivational Carousel ───────────────────────────────────────────────────

  Widget _buildMotivationalCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Inspiración',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A0A0A),
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _motiPageController,
            itemCount: _quotes.length,
            onPageChanged: (i) => setState(() => _motiCurrentPage = i),
            itemBuilder: (context, index) {
              final q = _quotes[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFE8698A,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFFE8698A,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'TIP DEL DÍA',
                            style: TextStyle(
                              color: Color(0xFFE8698A),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.electric_bolt_rounded,
                          color: Color(0xFF7ED957),
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Text(
                        q['quote']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -0.4,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8698A),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          q['author']!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _quotes.length,
            (i) => _buildDot(i, _motiCurrentPage, const Color(0xFFE8698A)),
          ),
        ),
      ],
    );
  }

  // ─── Shared dot indicator ────────────────────────────────────────────────────

  Widget _buildDot(int index, int currentIndex, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: index == currentIndex ? 22 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: index == currentIndex ? color : color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ─── Territories ─────────────────────────────────────────────────────────────

  Widget _buildTerritories() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Territorios',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0A0A),
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/territories'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Ver todos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE8698A).withValues(alpha: 0.9),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: const Color(0xFFE8698A).withValues(alpha: 0.9),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE8698A).withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE8698A).withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zonas conquistadas',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(
                              0xFF1A1A1A,
                            ).withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '12/45',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A0A0A),
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF0F4), Color(0xFFFFE4EC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: const Color(0xFFE8698A).withValues(alpha: 0.8),
                      size: 36,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF1A1A1A).withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const Text(
                        '27%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A0A0A),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.27,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFFFF0F4),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFFE8698A).withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFE8698A).withValues(alpha: 0.12),
                        const Color(0xFFE8698A).withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.go('/territories'),
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Text(
                          'Explorar territorios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(
                              0xFFE8698A,
                            ).withValues(alpha: 0.95),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
