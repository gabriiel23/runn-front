import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class PhysicalMetricsScreen extends StatefulWidget {
  const PhysicalMetricsScreen({super.key});

  @override
  State<PhysicalMetricsScreen> createState() => _PhysicalMetricsScreenState();
}

class _PhysicalMetricsScreenState extends State<PhysicalMetricsScreen> {
  double _height = 175;
  double _weight = 68.5;

  final double _minHeight = 140;
  final double _maxHeight = 230;
  final double _minWeight = 40;
  final double _maxWeight = 150;

  double get _bmi {
    final hm = _height / 100;
    return _weight / (hm * hm);
  }

  String get _bmiLabel {
    final b = _bmi;
    if (b < 18.5) return 'Bajo peso';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          // ── Decorative gradient bottom ─────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    c.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 16,
                    bottom: 0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/profile_setup'),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: c.textPrimary,
                        iconSize: 24,
                      ),
                      Expanded(
                        child: Text(
                          'Métricas físicas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Divider(),

                // ── Scrollable body ───────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Progress ────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progreso del perfil',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: c.textSecondary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: c.primary.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                'Paso 2 de 3',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: c.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: LinearProgressIndicator(
                            value: 2 / 3,
                            minHeight: 10,
                            backgroundColor: c.primary.withValues(alpha: 0.25),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              c.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Header ──────────────────────────────────
                        Text(
                          'Configura tu perfil',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Estos datos nos ayudan a calcular tu ritmo y quema de calorías de forma precisa.',
                          style: TextStyle(
                            fontSize: 15,
                            color: c.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // ── Height slider ────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.height_rounded,
                                  color: c.primaryDeep,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Altura',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: c.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${_height.round()}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: c.primaryDeep,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' cm',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: c.primary,
                            inactiveTrackColor: c.primary.withValues(
                              alpha: 0.25,
                            ),
                            thumbColor: c.card,
                            overlayColor: c.primary.withValues(alpha: 0.2),
                            thumbShape: _ThumbShape(
                              borderColor: c.primaryDeep,
                              fillColor: c.surface,
                            ),
                            trackHeight: 6,
                          ),
                          child: Slider(
                            value: _height,
                            min: _minHeight,
                            max: _maxHeight,
                            onChanged: (v) => setState(() => _height = v),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: ['140 cm', '170 cm', '200 cm', '230 cm']
                                .map(
                                  (t) => Text(
                                    t,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // ── Weight ruler ──────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.monitor_weight_outlined,
                                  color: c.primaryDeep,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Peso',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: c.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: _weight.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: c.primaryDeep,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' kg',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Weight ruler widget
                        _WeightRuler(
                          value: _weight,
                          min: _minWeight,
                          max: _maxWeight,
                          onChanged: (v) => setState(() => _weight = v),
                          primaryDeep: c.primaryDeep,
                        ),
                        const SizedBox(height: 36),

                        // ── BMI card ──────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: c.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: c.primaryMid.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: c.primaryMid,
                                    width: 2,
                                  ),
                                  color: c.card,
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCeRRqBMfVGrGInTt07y6XxbAj04AFw48L39NrwyUyOTO5MPPrCUgKqa__QUNp41Rt2PMOYHMxkb_2wxY8I0PIzhS1wqaD-_lkAaAbPayiotHMXVrWNQSqhiIRPPbjXgYd-JuWZS59maMRtQuaC6XAmU3PRxuc4YsyRDzY0ZuGl4CYlFvBaO1-yX88PNNIcQjIrBNXOCOpLE8_xBK1kwuLtCN7_hMBKaVp7_6poVbvmJN-8XA7FkF7vj0-eolGBZwzWpXO3vtNzVgdF',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.person_rounded,
                                      color: c.primaryDeep,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Casi listo, Elena',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: c.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tu IMC estimado: ${_bmi.toStringAsFixed(1)} ($_bmiLabel)',
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
                        const SizedBox(height: 32),

                        // ── Next button ───────────────────────────────
                        GestureDetector(
                          onTap: () => context.go('/runner_profile'),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: c.primary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: c.primary.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Siguiente paso',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: c.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: c.textPrimary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Skip button ───────────────────────────────
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: Center(
                              child: Text(
                                'Omitir por ahora',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: c.textSecondary,
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}

// ── Custom thumb para el Slider ───────────────────────────────────────────────

class _ThumbShape extends SliderComponentShape {
  final Color borderColor;
  final Color fillColor;
  const _ThumbShape({required this.borderColor, required this.fillColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Shadow
    canvas.drawCircle(
      center + const Offset(0, 2),
      12,
      Paint()
        ..color = borderColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Fill
    canvas.drawCircle(center, 12, Paint()..color = fillColor);

    // Border
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}

// ── Weight ruler widget ───────────────────────────────────────────────────────

class _WeightRuler extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color primaryDeep;

  const _WeightRuler({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.primaryDeep,
  });

  @override
  State<_WeightRuler> createState() => _WeightRulerState();
}

class _WeightRulerState extends State<_WeightRuler> {
  late ScrollController _scrollController;
  final double _tickWidth = 20;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToValue(widget.value);
    });
  }

  void _jumpToValue(double v) {
    final offset = (v - widget.min) * _tickWidth;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
      );
    }
  }

  @override
  void didUpdateWidget(_WeightRuler old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value &&
        !_scrollController.position.isScrollingNotifier.value) {
      _jumpToValue(widget.value);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalTicks = ((widget.max - widget.min) * 2).round() + 1;
    final deep = widget.primaryDeep;
    final c = context.colors;

    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Scrollable ruler
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollUpdateNotification) {
                final v = (n.metrics.pixels / _tickWidth) + widget.min;
                widget.onChanged(v.clamp(widget.min, widget.max));
              }
              return true;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: totalTicks,
              itemExtent: _tickWidth,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 2 - 24,
              ),
              itemBuilder: (_, i) {
                final tickVal = widget.min + i * 0.5;
                final isWhole = tickVal == tickVal.roundToDouble();
                final isCurrent = (tickVal - widget.value).abs() < 0.26;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isWhole && tickVal % 5 == 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${tickVal.round()}',
                          style: TextStyle(
                            fontSize: 9,
                            color: isCurrent ? deep : c.textHint,
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 17),
                    Container(
                      width: isCurrent ? 3 : 1.5,
                      height: isWhole ? 32 : 20,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? deep
                            : c.textHint.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),

          // Center indicator line
          Positioned(
            bottom: 8,
            child: Container(
              width: 3,
              height: 44,
              decoration: BoxDecoration(
                color: deep,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: deep, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
