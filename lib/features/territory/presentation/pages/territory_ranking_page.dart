import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/ranking_model.dart';
import '../../services/territory_service.dart';

class TerritoryRankingPage extends StatefulWidget {
  const TerritoryRankingPage({super.key});

  @override
  State<TerritoryRankingPage> createState() => _TerritoryRankingPageState();
}

class _TerritoryRankingPageState extends State<TerritoryRankingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<RankingUsuarioModel>? _rankingIndividual;
  List<RankingGrupoModel>? _rankingGrupal;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        TerritorioService.getRankingGrupal(),
      ]);
      if (!mounted) return;
      setState(() {
        _rankingIndividual = results[0] as List<RankingUsuarioModel>;
        _rankingGrupal = results[1] as List<RankingGrupoModel>;
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

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
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
          preferredSize: const Size.fromHeight(56),
          child: Column(
            children: [
              Container(color: c.primaryDeepWithAlpha(0.07), height: 1),
              Container(
                height: 52,
                color: c.card,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: c.primaryDeepWithAlpha(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    padding: const EdgeInsets.all(4),
                    indicatorPadding: EdgeInsets.zero,
                    indicator: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    labelColor: c.card,
                    unselectedLabelColor: c.textSecondary,
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                    tabs: const [
                      Tab(text: 'Individual'),
                      Tab(text: 'Grupal'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_rounded,
                          color: context.colors.textSecondary, size: 48),
                      const SizedBox(height: 12),
                      Text('Error al cargar el ranking'),
                      const SizedBox(height: 8),
                      TextButton(
                          onPressed: _cargar, child: const Text('Reintentar')),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildIndividualRanking(context),
                    _buildGrupalRanking(context),
                  ],
                ),
    );
  }

  // ─── RANKING INDIVIDUAL ───────────────────────────────────────────────────

  Widget _buildIndividualRanking(BuildContext context) {
    final lista = _rankingIndividual ?? [];
    if (lista.isEmpty) {
      return _buildEmpty(context, 'Aún no hay corredores en el ranking');
    }
    final top3 = lista.take(3).toList();
    final rest = lista.skip(3).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildPodio(context, top3),
          const SizedBox(height: 24),
          if (rest.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: rest.asMap().entries.map((e) {
                  final rank = e.key + 4;
                  final runner = e.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _UsuarioRankingRow(runner: runner, rank: rank),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPodio(BuildContext context, List<RankingUsuarioModel> top3) {
    final c = context.colors;
    // Asegurar mínimo 3 elementos para el pódio
    while (top3.length < 3) {
      top3.add(RankingUsuarioModel(
        id: '',
        nombre: '—',
        totalTerritorios: 0,
        puntos: 0,
        posicion: top3.length + 1,
      ));
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.workspace_premium_rounded, color: const Color(0xFFFFB84D), size: 22),
              const SizedBox(width: 8),
              Text(
                'Top Conquistadores',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PodiumItem(runner: top3[1], rank: 2, height: 110),
              const SizedBox(width: 12),
              _PodiumItem(runner: top3[0], rank: 1, height: 140),
              const SizedBox(width: 12),
              _PodiumItem(runner: top3[2], rank: 3, height: 90),
            ],
          ),
        ],
      ),
    );
  }

  // ─── RANKING GRUPAL ───────────────────────────────────────────────────────

  Widget _buildGrupalRanking(BuildContext context) {
    final lista = _rankingGrupal ?? [];
    if (lista.isEmpty) {
      return _buildEmpty(context, 'Aún no hay grupos en el ranking');
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        children: lista.asMap().entries.map((e) {
          final rank = e.key + 1;
          final grupo = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _GrupoRankingRow(grupo: grupo, rank: rank),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String texto) {
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.leaderboard_outlined,
              size: 64, color: c.textHint.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(texto,
              style: TextStyle(color: c.textSecondary, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── PODIUM ITEM ──────────────────────────────────────────────────────────────

class _PodiumItem extends StatelessWidget {
  final RankingUsuarioModel runner;
  final int rank;
  final double height;

  const _PodiumItem({
    required this.runner,
    required this.rank,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final medalColor = runner.medalColor;
    final isFirst = rank == 1;

    return GestureDetector(
      onTap: () {
        if (runner.id.isNotEmpty) {
          context.pushNamed(
            'territory_runner_profile',
            pathParameters: {'runnerId': runner.id},
          );
        }
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (isFirst)
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: medalColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              Container(
                padding: EdgeInsets.all(isFirst ? 4 : 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: medalColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: medalColor.withValues(alpha: isFirst ? 0.8 : 0.5),
                    width: isFirst ? 3 : 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: isFirst ? 34 : 26,
                  backgroundColor: c.primaryDeepWithAlpha(0.2),
                  backgroundImage: runner.avatarUrl != null && runner.avatarUrl!.isNotEmpty
                      ? NetworkImage(runner.avatarUrl!)
                      : null,
                  child: runner.avatarUrl == null || runner.avatarUrl!.isEmpty
                      ? Icon(Icons.person_rounded,
                          color: c.primaryDeepWithAlpha(0.6),
                          size: isFirst ? 32 : 24)
                      : null,
                ),
              ),
              if (isFirst)
                Positioned(
                  top: -22,
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: medalColor,
                    size: 34,
                    shadows: [
                      Shadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                ),
              Positioned(
                bottom: -8,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: medalColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.card, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: medalColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            runner.nombre.split(' ').first,
            style: TextStyle(
              fontSize: isFirst ? 15 : 13,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flag_rounded,
                size: 12,
                color: medalColor == const Color(0xFFB0C4D8) ? Colors.blueGrey : medalColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${runner.totalTerritorios}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: medalColor == const Color(0xFFB0C4D8) ? Colors.blueGrey : medalColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: isFirst ? 104 : 86,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  medalColor.withValues(alpha: 0.8),
                  medalColor.withValues(alpha: 0.2),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: medalColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: -1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FILA USUARIO ─────────────────────────────────────────────────────────────

class _UsuarioRankingRow extends StatelessWidget {
  final RankingUsuarioModel runner;
  final int rank;

  const _UsuarioRankingRow({required this.runner, required this.rank});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isTop10 = rank <= 10;
    final medalColor = runner.medalColor;

    return Container(
      decoration: BoxDecoration(
        color: isTop10 ? medalColor.withValues(alpha: 0.03) : c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTop10 ? medalColor.withValues(alpha: 0.2) : c.primaryDeepWithAlpha(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (runner.id.isNotEmpty) {
              context.pushNamed(
                'territory_runner_profile',
                pathParameters: {'runnerId': runner.id},
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: isTop10 ? medalColor : c.textHint,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isTop10 ? medalColor.withValues(alpha: 0.5) : c.primaryDeepWithAlpha(0.1),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: c.primaryDeepWithAlpha(0.1),
                    backgroundImage: runner.avatarUrl != null && runner.avatarUrl!.isNotEmpty
                        ? NetworkImage(runner.avatarUrl!)
                        : null,
                    child: runner.avatarUrl == null || runner.avatarUrl!.isEmpty
                        ? Icon(Icons.person_rounded, color: c.primaryDeepWithAlpha(0.5), size: 20)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        runner.nombre,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: c.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (runner.ciudad != null && runner.ciudad!.isNotEmpty)
                        Text(
                          runner.ciudad!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: c.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: medalColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: medalColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag_rounded, size: 14, color: medalColor),
                      const SizedBox(width: 6),
                      Text(
                        '${runner.totalTerritorios}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: medalColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, size: 20, color: c.textHint.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── FILA GRUPO ───────────────────────────────────────────────────────────────

class _GrupoRankingRow extends StatelessWidget {
  final RankingGrupoModel grupo;
  final int rank;

  const _GrupoRankingRow({required this.grupo, required this.rank});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final medalColor = grupo.medalColor;
    final isTop10 = rank <= 10;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTop10 ? medalColor.withValues(alpha: 0.03) : c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTop10 ? medalColor.withValues(alpha: 0.2) : c.primaryDeepWithAlpha(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: isTop10 ? medalColor : c.textHint,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isTop10 ? medalColor.withValues(alpha: 0.5) : c.primaryDeepWithAlpha(0.1),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: c.primaryDeepWithAlpha(0.1),
              backgroundImage: grupo.fotoUrl != null && grupo.fotoUrl!.isNotEmpty
                  ? NetworkImage(grupo.fotoUrl!)
                  : null,
              child: grupo.fotoUrl == null || grupo.fotoUrl!.isEmpty
                  ? Icon(Icons.group_rounded, color: c.primaryDeepWithAlpha(0.5), size: 20)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              grupo.nombre,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: medalColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: medalColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag_rounded, size: 14, color: medalColor),
                const SizedBox(width: 6),
                Text(
                  '${grupo.totalTerritorios}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: medalColor,
                    letterSpacing: -0.5,
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
