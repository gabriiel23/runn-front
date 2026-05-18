import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/core/theme/app_theme.dart';
import '../../../profile/domain/models/insignia_model.dart';
import '../../../profile/services/profile_service.dart';

class MyBadgesPage extends StatefulWidget {
  const MyBadgesPage({super.key});

  @override
  State<MyBadgesPage> createState() => _MyBadgesPageState();
}

class _MyBadgesPageState extends State<MyBadgesPage> {
  bool _isLoading = true;
  InsigniasResult? _insignias;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInsignias();
  }

  Future<void> _loadInsignias() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await ProfileService.getInsignias();
      if (mounted) setState(() { _insignias = result; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  /// Mapea el nombre/condición de la insignia a un ícono representativo.
  IconData _iconForBadge(InsigniaModel b) {
    // Insignias de distancia — ícono según km acumulados
    if (b.kmRequeridos != null) {
      final km = b.kmRequeridos!;
      if (km >= 5000) return Icons.diamond_rounded;
      if (km >= 2500) return Icons.military_tech_rounded;
      if (km >= 1000) return Icons.emoji_events_rounded;
      if (km >= 500)  return Icons.fitness_center_rounded;
      if (km >= 200)  return Icons.local_fire_department_rounded;
      if (km >= 100)  return Icons.shield_rounded;
      if (km >= 50)   return Icons.speed_rounded;
      if (km >= 25)   return Icons.explore_rounded;
      if (km >= 10)   return Icons.route_rounded;
      return Icons.flag_rounded; // 1 km
    }
    // Insignias generales
    final name = '${b.nombre} ${b.condicion ?? ''}'.toLowerCase();
    if (name.contains('primer') || name.contains('primera') || name.contains('inicio')) return Icons.directions_run_rounded;
    if (name.contains('territori') || name.contains('conquist')) return Icons.flag_rounded;
    if (name.contains('veloci') || name.contains('rapid')) return Icons.bolt_rounded;
    if (name.contains('explor') || name.contains('ciudad')) return Icons.explore_rounded;
    if (name.contains('maratonist')) return Icons.military_tech_rounded;
    if (name.contains('colina') || name.contains('elevac')) return Icons.terrain_rounded;
    if (name.contains('caloria') || name.contains('energia')) return Icons.local_fire_department_rounded;
    if (name.contains('racha') || name.contains('consistente')) return Icons.calendar_today_rounded;
    if (name.contains('grupo') || name.contains('social') || name.contains('equipo')) return Icons.group_rounded;
    if (name.contains('centuri') || name.contains('100')) return Icons.directions_run_rounded;
    if (name.contains('leyenda')) return Icons.workspace_premium_rounded;
    return Icons.emoji_events_rounded;
  }

  Color _colorForBadge(InsigniaModel b, int index) {
    // Insignias de distancia usan color según nivel
    if (b.kmRequeridos != null) {
      switch (b.nivel) {
        case 'diamante': return const Color(0xFF56CCF2);
        case 'oro':      return const Color(0xFFFFB84D);
        case 'plata':    return const Color(0xFFB0BEC5);
        default:         return const Color(0xFF7ED957); // normal
      }
    }
    // Insignias generales usan color por posición
    const colors = [
      Color(0xFFE8698A), Color(0xFFFFB84D), Color(0xFF7ED957),
      Color(0xFF56CCF2), Color(0xFF9B51E0), Color(0xFFFF6B35),
      Color(0xFF34C759), Color(0xFF69C2E8),
    ];
    return colors[index % colors.length];
  }


  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mis insignias',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : _error != null
              ? _buildError(c)
              : _buildContent(c),
    );
  }

  Widget _buildError(AppColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 60, color: c.textHint),
            const SizedBox(height: 16),
            Text(
              'No se pudieron cargar las insignias',
              style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadInsignias,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primaryDeep,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppColors c) {
    final todas = _insignias!.todas;
    final desbloqueadas = _insignias!.desbloqueadas;
    final bloqueadas = _insignias!.bloqueadas;

    if (todas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 72, color: c.textHint),
            const SizedBox(height: 16),
            Text(
              'Aún no hay insignias disponibles',
              style: TextStyle(color: c.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Completa carreras para desbloquearlas',
              style: TextStyle(color: c.textHint, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Asignar índice global para color consistente
    final Map<String, int> indexMap = {};
    for (int i = 0; i < todas.length; i++) {
      indexMap[todas[i].id] = i;
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (desbloqueadas.isNotEmpty) ...[
          _buildSectionHeader(c, '🏅 Desbloqueadas (${desbloqueadas.length})'),
          _buildGrid(c, desbloqueadas, indexMap),
        ],
        if (bloqueadas.isNotEmpty) ...[
          _buildSectionHeader(c, '🔒 Por desbloquear (${bloqueadas.length})'),
          _buildGrid(c, bloqueadas, indexMap),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 48)),
      ],
    );
  }

  Widget _buildSectionHeader(AppColors c, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(AppColors c, List<InsigniaModel> badges, Map<String, int> indexMap) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final badge = badges[index];
            final colorIndex = indexMap[badge.id] ?? index;
            final color = _colorForBadge(badge, colorIndex);
            final icon = _iconForBadge(badge);
            return GestureDetector(
              onTap: () => _showDetails(badge, color, icon),
              child: _buildItem(c, badge, color, icon),
            );
          },
          childCount: badges.length,
        ),
      ),
    );
  }

  Widget _buildItem(AppColors c, InsigniaModel badge, Color color, IconData icon) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badge.desbloqueada ? color.withValues(alpha: 0.1) : c.card,
              border: Border.all(
                color: badge.desbloqueada
                    ? color.withValues(alpha: 0.35)
                    : c.textHint.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: badge.desbloqueada
                  ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Center(
              child: Icon(
                icon,
                size: 30,
                color: badge.desbloqueada ? color : c.textHint.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          badge.nombre,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: badge.desbloqueada ? c.textPrimary : c.textHint,
            height: 1.3,
          ),
        ),
        if (badge.kmRequeridos != null && !badge.desbloqueada && badge.progreso != null) ...[
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: badge.progreso!,
              minHeight: 4,
              backgroundColor: c.primaryDeep.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ],
    );
  }

  void _showDetails(InsigniaModel badge, Color color, IconData icon) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.52,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.textHint.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Ícono grande
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
                border: Border.all(color: color.withValues(alpha: 0.35), width: 3),
                boxShadow: badge.desbloqueada
                    ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 16)]
                    : [],
              ),
              child: Icon(
                icon,
                size: 44,
                color: badge.desbloqueada ? color : c.textHint.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              badge.nombre,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              badge.desbloqueada ? '¡Logro desbloqueado!' : 'Logro bloqueado',
              style: TextStyle(
                color: badge.desbloqueada ? const Color(0xFF34C759) : const Color(0xFFE8698A),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.descripcion ?? badge.condicion ?? 'Completa el objetivo para desbloquear esta insignia.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: c.textSecondary, height: 1.5),
            ),
            const Spacer(),
            if (badge.desbloqueada && badge.ganadoEn != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✅ Conseguido el ${badge.fechaFormateada}',
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else if (!badge.desbloqueada && badge.progreso != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: badge.progreso!,
                  minHeight: 10,
                  backgroundColor: c.primaryDeep.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Progreso: ${(badge.progreso! * 100).toInt()}%'
                '${badge.kmRequeridos != null ? '  •  ${badge.kmRequeridos!.toStringAsFixed(0)} km requeridos' : ''}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
