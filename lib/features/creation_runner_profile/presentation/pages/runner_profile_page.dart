import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const kPink = Color(0xFFFFD3E0);
const kPinkDark = Color(0xFFE8A0B8);
const kPinkDeep = Color(0xFFC4607A);
const kPinkLight = Color(0xFFFFF0F5);
const kPinkMid = Color(0xFFFFB8CE);
const kBgLight = Color(0xFFF8F5F6);

class _Level {
  final String id;
  final String title;
  final String subtitle;

  const _Level({required this.id, required this.title, required this.subtitle});
}

const _levels = [
  _Level(
    id: 'beginner',
    title: 'Principiante',
    subtitle: 'Corro ocasionalmente',
  ),
  _Level(
    id: 'intermediate',
    title: 'Intermedio',
    subtitle: 'Corro 3 veces por semana',
  ),
  _Level(id: 'advanced', title: 'Avanzado', subtitle: 'Entreno para competir'),
];

class RunnerProfileScreen extends StatefulWidget {
  const RunnerProfileScreen({super.key});

  @override
  State<RunnerProfileScreen> createState() => _RunnerProfileScreenState();
}

class _RunnerProfileScreenState extends State<RunnerProfileScreen> {
  String _selectedLevel = 'beginner';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
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
                    onPressed: () => context.go('/physical_metrics'),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: const Color(0xFF1A1A1A),
                    iconSize: 24,
                  ),
                  const Expanded(
                    child: Text(
                      'Perfil de Corredor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Divider(),

            // ── Scrollable body ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Progress ──────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Paso 3 de 3',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          '100%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: LinearProgressIndicator(
                        value: 1.0,
                        minHeight: 10,
                        backgroundColor: kPink.withValues(alpha: 0.25),
                        valueColor: const AlwaysStoppedAnimation<Color>(kPink),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Experiencia de carrera',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Header ────────────────────────────────────────
                    const Text(
                      '¿Cuál es tu nivel?',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Personalizaremos tu plan de entrenamiento basado en tu experiencia actual.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[500],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Level cards ───────────────────────────────────
                    ..._levels.map((level) {
                      final isSelected = _selectedLevel == level.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedLevel = level.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kPink.withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? kPinkDeep
                                    : kPink.withValues(alpha: 0.35),
                                width: isSelected ? 2 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: kPink.withValues(alpha: 0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              children: [
                                // Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        level.title,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? kPinkDeep
                                              : const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        level.subtitle,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Radio indicator
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? kPinkDeep
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? kPinkDeep : kPinkMid,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ── Sticky footer button ──────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: kBgLight.withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(
                    color: kPink.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  width: double.infinity,
                  height: 56,
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Finalizar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF1A1A1A),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
