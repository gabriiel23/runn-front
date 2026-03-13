import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/challenge_data.dart';

class PastWeeklyChallengesPage extends StatelessWidget {
  const PastWeeklyChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

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
          'Retos anteriores',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen superior
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: c.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryStat(
                    value:
                        '${pastWeeklyChallenges.where((ch) => ch.completed).length}',
                    label: 'Completados',
                    icon: Icons.emoji_events_rounded,
                    c: c,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: c.primaryDeepWithAlpha(0.1),
                  ),
                  _SummaryStat(
                    value: '${pastWeeklyChallenges.length}',
                    label: 'Total retos',
                    icon: Icons.bolt_rounded,
                    c: c,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: c.primaryDeepWithAlpha(0.1),
                  ),
                  _SummaryStat(
                    value:
                        '${pastWeeklyChallenges.where((ch) => ch.completed).length * 100 ~/ pastWeeklyChallenges.length}%',
                    label: 'Tasa éxito',
                    icon: Icons.trending_up_rounded,
                    c: c,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: Text(
              'Historial de retos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),

          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              itemCount: pastWeeklyChallenges.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ch = pastWeeklyChallenges[index];
                return _PastChallengeCard(challenge: ch, c: c);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PastChallengeCard extends StatelessWidget {
  final WeeklyChallenge challenge;
  final dynamic c;

  const _PastChallengeCard({required this.challenge, required this.c});

  @override
  Widget build(BuildContext context) {
    final statusColor = challengeStatusColor(challenge);
    final statusLabel = challengeStatusLabel(challenge);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Badge emoji
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    challenge.badgeEmoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.period,
                      style: TextStyle(
                        fontSize: 12,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de progreso
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: challenge.progress,
                    minHeight: 7,
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${challenge.currentKm.toStringAsFixed(1)} / ${challenge.targetKm.toStringAsFixed(0)} km',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
          if (challenge.completed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.military_tech_rounded,
                  size: 14,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  challenge.badge,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final dynamic c;

  const _SummaryStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: c.primaryDeepWithAlpha(0.7), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: c.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
