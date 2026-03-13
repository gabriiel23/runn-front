import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/ranking_data.dart';

class TerritoryRankingPage extends StatelessWidget {
  const TerritoryRankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final top3 = territoryRankingMock.take(3).toList();
    final rest = territoryRankingMock.skip(3).toList();

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
          'Ranking de Territorios',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: c.primaryDeepWithAlpha(0.07), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Podio TOP 3 ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: c.card,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                children: [
                  Text(
                    '🏆 Top Conquistadores',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 2do lugar
                      _PodiumItem(
                        runner: top3[1],
                        rank: 2,
                        height: 100,
                        medalColor: const Color(0xFFB0C4D8),
                        onTap: () => context.pushNamed(
                          'territory_runner_profile',
                          pathParameters: {'runnerId': top3[1].id},
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 1er lugar
                      _PodiumItem(
                        runner: top3[0],
                        rank: 1,
                        height: 130,
                        medalColor: const Color(0xFFFFB84D),
                        onTap: () => context.pushNamed(
                          'territory_runner_profile',
                          pathParameters: {'runnerId': top3[0].id},
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 3er lugar
                      _PodiumItem(
                        runner: top3[2],
                        rank: 3,
                        height: 80,
                        medalColor: const Color(0xFFCD7F32),
                        onTap: () => context.pushNamed(
                          'territory_runner_profile',
                          pathParameters: {'runnerId': top3[2].id},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Lista del puesto 4 en adelante ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: rest.asMap().entries.map((e) {
                  final rank = e.key + 4;
                  final runner = e.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RankingRow(
                      runner: runner,
                      rank: rank,
                      onTap: () => context.pushNamed(
                        'territory_runner_profile',
                        pathParameters: {'runnerId': runner.id},
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Podio ───────────────────────────────────────────────────────────────────

class _PodiumItem extends StatelessWidget {
  final RankedRunner runner;
  final int rank;
  final double height;
  final Color medalColor;
  final VoidCallback onTap;

  const _PodiumItem({
    required this.runner,
    required this.rank,
    required this.height,
    required this.medalColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: medalColor.withValues(alpha: 0.3),
                  border: Border.all(color: medalColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: rank == 1 ? 36 : 28,
                  backgroundColor: runner.accentColor.withValues(alpha: 0.15),
                  backgroundImage: runner.avatarUrl.isNotEmpty
                      ? NetworkImage(runner.avatarUrl)
                      : null,
                  child: runner.avatarUrl.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          color: runner.accentColor,
                          size: rank == 1 ? 32 : 24,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: -6,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: medalColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: medalColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Nombre
          Text(
            runner.name.split(' ').first,
            style: TextStyle(
              fontSize: rank == 1 ? 14 : 12,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          // Territorios
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: medalColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${runner.territoriesOwned} zonas',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: medalColor == const Color(0xFFB0C4D8)
                    ? Colors.blueGrey
                    : medalColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Base del podio
          Container(
            width: rank == 1 ? 96 : 80,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  medalColor.withValues(alpha: 0.7),
                  medalColor.withValues(alpha: 0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fila del ranking (4+) ───────────────────────────────────────────────────

class _RankingRow extends StatelessWidget {
  final RankedRunner runner;
  final int rank;
  final VoidCallback onTap;

  const _RankingRow({
    required this.runner,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: runner.accentColor.withValues(alpha: 0.1),
          ),
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
            // Posición
            SizedBox(
              width: 32,
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: c.textHint,
                ),
              ),
            ),
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: runner.accentColor.withValues(alpha: 0.15),
              backgroundImage: runner.avatarUrl.isNotEmpty
                  ? NetworkImage(runner.avatarUrl)
                  : null,
              child: runner.avatarUrl.isEmpty
                  ? Icon(
                      Icons.person_rounded,
                      color: runner.accentColor,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    runner.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    runner.location,
                    style: TextStyle(
                      fontSize: 11,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Zonas
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${runner.territoriesOwned}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: runner.accentColor,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'territorios',
                  style: TextStyle(fontSize: 10, color: c.textHint),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 18, color: c.textHint),
          ],
        ),
      ),
    );
  }
}
