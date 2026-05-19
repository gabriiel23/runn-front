import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/ranking_model.dart';
import '../../services/territory_service.dart';
import '../../data/models/territory_model.dart';

const _gridSize = 6;

class TerritoryRunnerProfilePage extends StatefulWidget {
  final String runnerId;

  const TerritoryRunnerProfilePage({super.key, required this.runnerId});

  @override
  State<TerritoryRunnerProfilePage> createState() =>
      _TerritoryRunnerProfilePageState();
}

class _TerritoryRunnerProfilePageState
    extends State<TerritoryRunnerProfilePage> {
  RankingUsuarioModel? _runner;
  List<TerritoryModel> _territorios = [];
  int _rank = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        TerritorioService.getRankingIndividual(),
        TerritorioService.getTerritorios(modalidad: 'individual'),
      ]);
      
      final listaRanking = results[0] as List<RankingUsuarioModel>;
      final listaTerritorios = results[1] as List<TerritoryModel>;
      
      final idx = listaRanking.indexWhere((r) => r.id == widget.runnerId);
      final ownedTerritories = listaTerritorios.where((t) => t.propietario?.id == widget.runnerId).toList();

      if (!mounted) return;
      setState(() {
        _runner =
            idx >= 0 ? listaRanking[idx] : (listaRanking.isNotEmpty ? listaRanking.first : null);
        _rank = idx >= 0 ? idx + 1 : 1;
        _territorios = ownedTerritories;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_loading) {
      return Scaffold(
        backgroundColor: c.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _runner == null) {
      return Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(
          backgroundColor: c.card,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_off_outlined,
                  size: 48, color: c.textSecondary),
              const SizedBox(height: 12),
              Text('Corredor no encontrado',
                  style: TextStyle(color: c.textSecondary)),
              const SizedBox(height: 8),
              TextButton(
                  onPressed: _cargar, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    final runner = _runner!;
    final accentColor = runner.accentColor;

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero AppBar ────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
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
                      accentColor,
                      accentColor.withValues(alpha: 0.5),
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
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.2),
                          backgroundImage: runner.avatarUrl != null &&
                                  runner.avatarUrl!.isNotEmpty
                              ? NetworkImage(runner.avatarUrl!)
                              : null,
                          child:
                              runner.avatarUrl == null || runner.avatarUrl!.isEmpty
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
                        runner.nombre,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (runner.ciudad != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            runner.ciudad!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Contenido ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats rápidas
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '#$_rank',
                          label: 'Ranking',
                          icon: Icons.leaderboard_rounded,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: '${runner.totalTerritorios}',
                          label: 'Territorios',
                          icon: Icons.flag_rounded,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: '${runner.puntos}',
                          label: 'Puntos',
                          icon: Icons.stars_rounded,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Mini mapa visual (grid estático decorativo)
                  _SectionTitle(
                      title: 'Resumen Conquistas', color: accentColor),
                  const SizedBox(height: 14),
                  _TerritoryMiniGrid(
                    count: runner.totalTerritorios,
                    color: accentColor,
                  ),

                  const SizedBox(height: 32),

                  _SectionTitle(
                      title: 'Territorios Dominados', color: accentColor),
                  const SizedBox(height: 14),
                  if (_territorios.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: c.primaryDeepWithAlpha(0.05)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.flag_outlined, size: 40, color: c.textHint),
                          const SizedBox(height: 12),
                          Text(
                            'Aún no domina territorios',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._territorios.map((t) => _buildTerritoryCard(t, context, accentColor)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerritoryCard(TerritoryModel territory, BuildContext context, Color accentColor) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.flag_rounded,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  territory.nombre,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 14, color: c.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Récord: ${territory.tiempoRecordFormateado ?? "00:00:00"}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Defensas',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
              Text(
                '${territory.totalDefensas}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── STAT CARD ────────────────────────────────────────────────────────────────

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
            style:
                TextStyle(fontSize: 9, color: c.textHint, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── SECTION TITLE ────────────────────────────────────────────────────────────

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

// ─── MINI GRID ────────────────────────────────────────────────────────────────

class _TerritoryMiniGrid extends StatelessWidget {
  final int count;
  final Color color;

  const _TerritoryMiniGrid({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cells = List.generate(_gridSize, (i) => i < count ? 'owned' : 'empty');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.6,
            children: cells.take(_gridSize).map((type) {
              final isOwned = type == 'owned';
              final cellColor =
                  isOwned ? color : c.primaryDeepWithAlpha(0.06);
              return Container(
                decoration: BoxDecoration(
                  color: isOwned
                      ? cellColor.withValues(alpha: 0.25)
                      : cellColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isOwned
                        ? cellColor.withValues(alpha: 0.5)
                        : c.primaryDeepWithAlpha(0.08),
                    width: 1.5,
                  ),
                ),
                child: isOwned
                    ? Icon(Icons.flag_rounded, color: cellColor, size: 18)
                    : null,
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MapLegend(color: color, label: 'CONQUISTADO'),
              const SizedBox(width: 16),
              _MapLegend(
                  color: c.primaryDeepWithAlpha(0.15), label: 'LIBRE'),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── MAP LEGEND ───────────────────────────────────────────────────────────────

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
