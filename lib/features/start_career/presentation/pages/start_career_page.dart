import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/core/theme/app_theme.dart';

class StartCareerScreen extends StatefulWidget {
  const StartCareerScreen({super.key});

  @override
  State<StartCareerScreen> createState() => _StartCareerScreenState();
}

class _StartCareerScreenState extends State<StartCareerScreen>
    with TickerProviderStateMixin {
  AppColors get c => context.colors;

  bool _isStarted = false;
  bool _isRunning = false;
  int _time = 0;
  double _distance = 0;
  Timer? _timer;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _time += 1;
        _distance += 0.0028;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _currentPace => _distance > 0 ? (_time / 60) / _distance : 0;

  void _handleStart() {
    setState(() {
      _isStarted = true;
      _isRunning = true;
    });
    _startTimer();
  }

  void _handlePauseResume() {
    setState(() {
      _isRunning = !_isRunning;
    });
    if (_isRunning) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _handleFinish() {
    _stopTimer();
    setState(() => _isRunning = false);
    context.go('/run_results');
  }

  void _handleBack() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isStarted) return _buildPreStartScreen();
    return _buildRunningScreen();
  }

  // ─── PRE-START SCREEN ────────────────────────────────────────────────────────

  Widget _buildPreStartScreen() {
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: c.surface,
              boxShadow: [
                BoxShadow(
                  color: c.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: _handleBack,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Iniciar carrera',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Map Preview
          Expanded(
            child: Container(
              color: c.primaryLight,
              child: Stack(
                children: [
                  // Grid pattern
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                        ),
                    itemCount: 96,
                    itemBuilder: (_, i) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: i % 3 == 0
                              ? [
                                  const Color(0xFFFFF0F5),
                                  const Color(0xFFFFD3E0),
                                ]
                              : [
                                  const Color(0xFFFFF8FB),
                                  const Color(0xFFFFF0F5),
                                ],
                        ),
                      ),
                    ),
                  ),

                  // Location marker
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 64 + (_pulseController.value * 16),
                            height: 64 + (_pulseController.value * 16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.primaryDeep.withValues(
                                alpha: 0.15 - _pulseController.value * 0.1,
                              ),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.primaryDeep,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: c.primaryDeep.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Location card
                  Positioned(
                    top: 24,
                    left: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: c.primaryDeep.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: c.primaryDeep,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ubicación actual',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: c.textPrimary,
                                ),
                              ),
                              Text(
                                'GPS listo • Señal fuerte',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: c.textSecondary,
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
            ),
          ),

          // Bottom controls
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            color: c.surface,
            child: Column(
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        c.primary.withValues(alpha: 0.6),
                        c.primary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: c.primaryMid.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c.primaryDeep,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Esta función registrará tu ruta, distancia, tiempo y calorías en tiempo real. Presiona Iniciar cuando estés listo.',
                          style: TextStyle(
                            fontSize: 14,
                            color: c.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Start Button
                GestureDetector(
                  onTap: _handleStart,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [c.primaryDeep, c.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: c.primary.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Iniciar carrera',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Cancel Button
                GestureDetector(
                  onTap: _handleBack,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c.primaryMid, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── RUNNING SCREEN ──────────────────────────────────────────────────────────

  Widget _buildRunningScreen() {
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // Map area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    c.primaryDeep.withValues(alpha: 0.3),
                    c.primaryDark.withValues(alpha: 0.2),
                    c.bg,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Grid overlay
                  Opacity(
                    opacity: 0.25,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 1,
                          ),
                      itemCount: 96,
                      itemBuilder: (_, i) => Container(
                        color: i % 3 == 0
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.white.withValues(alpha: 0.02),
                      ),
                    ),
                  ),

                  // Route SVG
                  CustomPaint(
                    size: Size.infinite,
                    painter: _RoutePainter(color: c.primaryMid),
                  ),

                  // Start pin
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.18,
                    left: MediaQuery.of(context).size.width * 0.25,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: c.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.surface, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: c.primary.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Current location
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.25,
                    left: MediaQuery.of(context).size.width * 0.65,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 48 + (_pulseController.value * 12),
                            height: 48 + (_pulseController.value * 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.primaryDeep.withValues(
                                alpha: 0.2 - _pulseController.value * 0.1,
                              ),
                            ),
                          ),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.primaryDeep,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: c.primaryDeep.withValues(alpha: 0.6),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Status badge
                  Positioned(
                    top: 56,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isRunning
                              ? c.primaryDeep.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (_, __) => Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isRunning
                                      ? c.primary.withValues(
                                          alpha:
                                              0.6 +
                                              _pulseController.value * 0.4,
                                        )
                                      : c.textPrimary.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isRunning ? 'En progreso' : 'Pausado',
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Back button
                  Positioned(
                    top: 48,
                    left: 24,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('¿Cancelar carrera?'),
                            content: const Text(
                              'Se perderán los datos de esta carrera.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: _handleBack,
                                child: const Text('Sí'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.surface.withValues(alpha: 0.12),
                          border: Border.all(
                            color: c.textPrimary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: c.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats Panel
          Container(
            color: c.bg,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              children: [
                // Timer
                Column(
                  children: [
                    Text(
                      'Tiempo',
                      style: TextStyle(color: c.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(_time),
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Distance & Pace
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.location_on,
                        iconColor: c.primaryMid,
                        label: 'Distancia',
                        value: _distance.toStringAsFixed(2),
                        unit: 'km',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.trending_up,
                        iconColor: c.primary,
                        label: 'Ritmo',
                        value: _currentPace > 0
                            ? _currentPace.toStringAsFixed(1)
                            : '0.0',
                        unit: 'min/km',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Calories & BPM
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: c.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: c.textPrimary.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat(
                        icon: Icons.local_fire_department,
                        iconColor: c.primaryDark,
                        label: 'Calorías',
                        value: '${(_distance * 60).round()}',
                      ),
                      Container(
                        width: 1,
                        height: 48,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      _buildMiniStat(
                        icon: Icons.favorite,
                        iconColor: c.primaryDeep,
                        label: 'BPM',
                        value: '142',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _handlePauseResume,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isRunning
                                  ? [c.primaryDark, c.primaryMid]
                                  : [c.primaryDeep, c.primaryDark],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_isRunning ? c.primaryMid : c.primaryDeep)
                                        .withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isRunning
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isRunning ? 'Pausar' : 'Reanudar',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _handleFinish,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: c.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: c.textPrimary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          'Finalizar',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.textPrimary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: c.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(unit, style: TextStyle(color: c.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: c.textSecondary, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// Route painter
class _RoutePainter extends CustomPainter {
  final Color color;
  const _RoutePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.55);
    path.quadraticBezierTo(
      size.width * 0.38,
      size.height * 0.42,
      size.width * 0.50,
      size.height * 0.50,
    );
    path.quadraticBezierTo(
      size.width * 0.62,
      size.height * 0.58,
      size.width * 0.70,
      size.height * 0.52,
    );

    canvas.drawPath(
      path,
      paint
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..color = color.withValues(alpha: 0.5),
    );
    canvas.drawPath(
      path,
      paint
        ..maskFilter = null
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RoutePainter old) => old.color != color;
}
