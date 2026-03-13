import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/challenge_data.dart';

class ChallengeItemDetailPage extends StatelessWidget {
  final String challengeId;

  const ChallengeItemDetailPage({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ch = weeklyChallengeItems.firstWhere(
      (e) => e.id == challengeId,
      orElse: () => weeklyChallengeItems.first,
    );
    final doneColor = const Color(0xFF7ED957);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detalle del desafío',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: c.primaryDeepWithAlpha(0.1), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: ch.done ? const Color(0xFFF4FDF0) : c.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: ch.done
                      ? doneColor.withValues(alpha: 0.3)
                      : ch.iconColor.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: ch.done
                              ? doneColor.withValues(alpha: 0.15)
                              : ch.iconBgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          ch.done ? Icons.check_circle_rounded : ch.icon,
                          color: ch.done ? doneColor : ch.iconColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ch.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: ch.done ? doneColor : c.textPrimary,
                                letterSpacing: -0.4,
                                decoration: ch.done
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ch.description,
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _InfoChip(
                        label: ch.difficulty,
                        icon: Icons.bolt_rounded,
                        color: ch.iconColor,
                      ),
                      const SizedBox(width: 10),
                      _InfoChip(
                        label: ch.estimatedTime,
                        icon: Icons.timer_rounded,
                        color: ch.iconColor,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: ch.done
                              ? doneColor.withValues(alpha: 0.12)
                              : ch.iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ch.done ? '✓ Ganaste' : ch.reward,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: ch.done ? doneColor : ch.iconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Descripción completa ────────────────────────────
            Text(
              'Acerca del desafío',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: c.primaryDeepWithAlpha(0.07)),
              ),
              child: Text(
                ch.fullDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: c.textSecondary,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Tips ───────────────────────────────────────────
            Text(
              'Consejos',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: c.primaryDeepWithAlpha(0.07)),
              ),
              child: Column(
                children: ch.tips
                    .asMap()
                    .entries
                    .map(
                      (e) => Padding(
                        padding: EdgeInsets.only(
                          bottom: e.key < ch.tips.length - 1 ? 14 : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: ch.iconColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${e.key + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: ch.iconColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: c.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 32),

            // ── CTA ────────────────────────────────────────────
            if (!ch.done)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/start_career'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ch.iconColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Aceptar desafío',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            if (ch.done)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: doneColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: doneColor.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    '✓ Desafío completado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: doneColor,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
