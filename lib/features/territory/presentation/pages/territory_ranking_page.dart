import 'package:flutter/material.dart';
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
          preferredSize: const Size.fromHeight(52),
          child: Column(
            children: [
              Container(color: c.primaryDeepWithAlpha(0.07), height: 1),
              Container(
                height: 44,
                color: c.card,
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: c.primaryDeepWithAlpha(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    padding: const EdgeInsets.all(3),
                    indicator: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: c.textSecondary,
                    labelStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
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
          const SizedBox(height: 16),
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
              _PodiumItem(runner: top3[1], rank: 2, height: 100),
              const SizedBox(width: 12),
              _PodiumItem(runner: top3[0], rank: 1, height: 130),
              const SizedBox(width: 12),
              _PodiumItem(runner: top3[2], rank: 3, height: 80),
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
              size: 56, color: c.textHint.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(texto,
              style: TextStyle(color: c.textSecondary, fontSize: 14)),
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

    return Column(
      children: [
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
                backgroundColor: c.primaryDeepWithAlpha(0.15),
                backgroundImage: runner.avatarUrl != null &&
                        runner.avatarUrl!.isNotEmpty
                    ? NetworkImage(runner.avatarUrl!)
                    : null,
                child:
                    runner.avatarUrl == null || runner.avatarUrl!.isEmpty
                        ? Icon(Icons.person_rounded,
                            color: c.primaryDeepWithAlpha(0.6),
                            size: rank == 1 ? 32 : 24)
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
        Text(
          runner.nombre.split(' ').first,
          style: TextStyle(
            fontSize: rank == 1 ? 14 : 12,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: medalColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${runner.totalTerritorios} zonas',
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.primaryDeepWithAlpha(0.07)),
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
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.textHint),
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: c.primaryDeepWithAlpha(0.12),
            backgroundImage:
                runner.avatarUrl != null && runner.avatarUrl!.isNotEmpty
                    ? NetworkImage(runner.avatarUrl!)
                    : null,
            child:
                runner.avatarUrl == null || runner.avatarUrl!.isEmpty
                    ? Icon(Icons.person_rounded,
                        color: c.primaryDeepWithAlpha(0.6), size: 20)
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  runner.nombre,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  runner.ciudad ?? 'Sin ciudad',
                  style:
                      TextStyle(fontSize: 11, color: c.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${runner.totalTerritorios}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: c.primaryDeep,
                  letterSpacing: -0.5,
                ),
              ),
              Text('territorios',
                  style: TextStyle(fontSize: 10, color: c.textHint)),
            ],
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, size: 18, color: c.textHint),
        ],
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: rank <= 3
                ? medalColor.withValues(alpha: 0.2)
                : c.primaryDeepWithAlpha(0.07)),
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? medalColor.withValues(alpha: 0.15)
                  : c.primaryDeepWithAlpha(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: rank <= 3 ? medalColor : c.textHint,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundColor: c.primaryDeepWithAlpha(0.12),
            backgroundImage: grupo.fotoUrl != null && grupo.fotoUrl!.isNotEmpty
                ? NetworkImage(grupo.fotoUrl!)
                : null,
            child: grupo.fotoUrl == null || grupo.fotoUrl!.isEmpty
                ? Icon(Icons.group_rounded,
                    color: c.primaryDeepWithAlpha(0.6), size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              grupo.nombre,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${grupo.totalTerritorios}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: rank <= 3 ? medalColor : c.primaryDeep,
                  letterSpacing: -0.5,
                ),
              ),
              Text('zonas',
                  style: TextStyle(fontSize: 10, color: c.textHint)),
            ],
          ),
        ],
      ),
    );
  }
}
