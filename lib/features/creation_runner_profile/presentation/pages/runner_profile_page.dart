import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../../login/register/services/auth_service.dart';
import 'package:runn_front/core/services/http_client.dart';

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
  final Map<String, dynamic> metricas;

  const RunnerProfileScreen({super.key, required this.metricas});

  @override
  State<RunnerProfileScreen> createState() => _RunnerProfileScreenState();
}

class _RunnerProfileScreenState extends State<RunnerProfileScreen> {
  String _selectedLevel = 'beginner';
  bool _isLoading = false;

  Future<void> _handleFinish() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.updateMetricas(
        genero: widget.metricas['genero'],
        fechaNacimiento: widget.metricas['fecha_nacimiento'],
        alturaCm: widget.metricas['altura_cm'].toDouble(),
        pesoKg: widget.metricas['peso_kg'].toDouble(),
        nivel: _selectedLevel,
        pais: widget.metricas['pais'],
        ciudad: widget.metricas['ciudad'],
      );

      if (mounted) {
        context.go('/home');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFFF3B30)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado al guardar datos'), backgroundColor: Color(0xFFFF3B30)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
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
                    color: c.textPrimary,
                    iconSize: 24,
                  ),
                  Expanded(
                    child: Text(
                      'Perfil de Corredor',
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
                        Text(
                          'Paso 3 de 3',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        ),
                        Text(
                          '100%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: c.textSecondary,
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
                        backgroundColor: c.primary.withValues(alpha: 0.25),
                        valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Experiencia de carrera',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Header ────────────────────────────────────────
                    Text(
                      '¿Cuál es tu nivel?',
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
                      'Personalizaremos tu plan de entrenamiento basado en tu experiencia actual.',
                      style: TextStyle(
                        fontSize: 15,
                        color: c.textSecondary,
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
                                  ? c.primary.withValues(alpha: 0.08)
                                  : c.card,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? c.primaryDeep
                                    : c.primary.withValues(alpha: 0.35),
                                width: isSelected ? 2 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: c.primary.withValues(alpha: 0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: c.textPrimary.withValues(
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
                                              ? c.primaryDeep
                                              : c.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        level.subtitle,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: c.textSecondary,
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
                                        ? c.primaryDeep
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? c.primaryDeep
                                          : c.primaryMid,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: c.card,
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
                color: c.bg.withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(
                    color: c.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: _isLoading ? null : _handleFinish,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isLoading ? c.primary.withValues(alpha: 0.5) : c.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isLoading ? [] : [
                      BoxShadow(
                        color: c.primary.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Finalizar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: c.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: c.textPrimary,
                                size: 22,
                              ),
                            ],
                          ),
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
