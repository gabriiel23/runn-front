import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/ranking_data.dart';

// Grid visual de territorios del runner (6 celdas)
const _gridSize = 6;

class TerritoryRunnerProfilePage extends StatelessWidget {
  final String runnerId;

  const TerritoryRunnerProfilePage({super.key, required this.runnerId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final runner = territoryRankingMock.firstWhere(
      (r) => r.id == runnerId,
      orElse: () => territoryRankingMock.first,
    );
    final rank = territoryRankingMock.indexOf(runner) + 1;

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero AppBar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: c.card,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      runner.accentColor,
                      runner.accentColor.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage: runner.avatarUrl.isNotEmpty
                              ? NetworkImage(runner.avatarUrl)
                              : null,
                          child: runner.avatarUrl.isEmpty
                              ? const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 40,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        runner.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            runner.handle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'LVL. ${runner.level}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats rápidas ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '#$rank',
                          label: 'Ranking',
                          icon: Icons.leaderboard_rounded,
                          color: runner.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: '${runner.territoriesOwned}',
                          label: 'Territorios',
                          icon: Icons.flag_rounded,
                          color: runner.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: '${runner.totalKm}',
                          label: 'km totales',
                          icon: Icons.route_rounded,
                          color: runner.accentColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: runner.avgHoldTime,
                          label: 'Pos. promedio',
                          icon: Icons.hourglass_bottom_rounded,
                          color: runner.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: runner.location.split(',').first,
                          label: 'Ciudad',
                          icon: Icons.location_on_rounded,
                          color: runner.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: 'LVL ${runner.level}',
                          label: 'Nivel',
                          icon: Icons.emoji_events_rounded,
                          color: runner.accentColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Mapa visual de territorios ───────────────────────────
                  _SectionTitle(title: 'Mapa de Territorios', color: runner.accentColor),
                  const SizedBox(height: 14),
                  _TerritoryMiniMap(
                    runner: runner,
                  ),

                  const SizedBox(height: 28),

                  // ── Lista de territorios ─────────────────────────────────
                  _SectionTitle(
                    title: 'Zonas conquistadas (${runner.territories.length})',
                    color: runner.accentColor,
                  ),
                  const SizedBox(height: 14),

                  if (runner.territories.isEmpty)
                    _EmptyTerritories(color: runner.accentColor)
                  else
                    ...runner.territories.asMap().entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TerritoryRowCard(
                              territory: e.value,
                              accentColor: runner.accentColor,
                            ),
                          ),
                        ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets internos ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: c.textHint, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _TerritoryMiniMap extends StatelessWidget {
  final RankedRunner runner;

  const _TerritoryMiniMap({required this.runner});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final owned = runner.territories.where((t) => t.status == 'owned').length;
    final contested = runner.territories.where((t) => t.status == 'contested').length;
    final empty = _gridSize - owned - contested;

    // Build a simple visual grid
    final cells = <String>[];
    for (var i = 0; i < owned; i++) { cells.add('owned'); }
    for (var i = 0; i < contested; i++) { cells.add('contested'); }
    for (var i = 0; i < (empty < 0 ? 0 : empty); i++) { cells.add('empty'); }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: runner.accentColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Grid visual 3×2
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.6,
            children: cells.take(_gridSize).map((type) {
              Color cellColor;
              if (type == 'owned') {
                cellColor = runner.accentColor;
              } else if (type == 'contested') {
                cellColor = const Color(0xFFFFB84D);
              } else {
                cellColor = c.primaryDeepWithAlpha(0.06);
              }
              return Container(
                decoration: BoxDecoration(
                  color: type == 'empty'
                      ? cellColor
                      : cellColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: type == 'empty'
                        ? c.primaryDeepWithAlpha(0.08)
                        : cellColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: type != 'empty'
                    ? Icon(
                        type == 'owned'
                            ? Icons.flag_rounded
                            : Icons.bolt_rounded,
                        color: cellColor,
                        size: 18,
                      )
                    : null,
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MapLegend(color: runner.accentColor, label: 'DOMINADA'),
              const SizedBox(width: 16),
              _MapLegend(color: const Color(0xFFFFB84D), label: 'EN DISPUTA'),
              const SizedBox(width: 16),
              _MapLegend(color: c.primaryDeepWithAlpha(0.15), label: 'LIBRE'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _MapLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TerritoryRowCard extends StatelessWidget {
  final RunnerTerritory territory;
  final Color accentColor;

  const _TerritoryRowCard({required this.territory, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isContested = territory.status == 'contested';
    final statusColor = isContested ? const Color(0xFFFFB84D) : accentColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icono
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isContested ? Icons.bolt_rounded : Icons.flag_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      territory.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 11, color: c.textHint),
                        const SizedBox(width: 3),
                        Text(
                          'Desde ${territory.heldSince}',
                          style: TextStyle(
                            fontSize: 11,
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.route_rounded, size: 11, color: c.textHint),
                        const SizedBox(width: 3),
                        Text(
                          '${territory.km} km',
                          style: TextStyle(
                            fontSize: 11,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Badge estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isContested ? 'En disputa' : 'Dominada',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de dominio
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dominio',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: c.textHint,
                    ),
                  ),
                  Text(
                    '${territory.dominance}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: territory.dominance / 100,
                  minHeight: 6,
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyTerritories extends StatelessWidget {
  final Color color;

  const _EmptyTerritories({required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.primaryDeepWithAlpha(0.07)),
      ),
      child: Column(
        children: [
          Icon(Icons.flag_outlined, size: 36, color: c.textHint),
          const SizedBox(height: 10),
          Text(
            'Sin territorios detallados',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
