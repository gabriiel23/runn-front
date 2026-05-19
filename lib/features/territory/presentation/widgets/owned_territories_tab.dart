import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/territory_model.dart';
import '../../services/territory_service.dart';

/// Tab "Territorios" — muestra el listado global de todos los territorios
/// con indicación de su estado (libre, propio, rival).
class OwnedTerritoriesTab extends StatefulWidget {
  final bool isGrupal;
  const OwnedTerritoriesTab({super.key, this.isGrupal = false});

  @override
  State<OwnedTerritoriesTab> createState() => _OwnedTerritoriesTabState();
}

class _OwnedTerritoriesTabState extends State<OwnedTerritoriesTab> {
  List<TerritoryModel>? _territorios;
  String? _error;
  bool _loading = true;
  String? _miId;
  String _filtro = 'todos'; // todos | libres | propios | rivales

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(OwnedTerritoriesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGrupal != widget.isGrupal) {
      _cargar();
    }
  }

  Future<void> _cargar() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _miId = await ApiConfig.getCurrentUserId();
      final lista = await TerritorioService.getTerritorios(
        modalidad: widget.isGrupal ? 'grupal' : 'individual'
      );
      if (!mounted) return;
      setState(() {
        _territorios = lista;
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

  List<TerritoryModel> get _filtrados {
    final all = _territorios ?? [];
    final uid = _miId ?? '';
    switch (_filtro) {
      case 'libres':
        return all.where((t) => t.libre).toList();
      case 'propios':
        return all.where((t) => t.isOwned(uid)).toList();
      case 'rivales':
        return all.where((t) => !t.libre && !t.isOwned(uid)).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: c.textSecondary, size: 48),
            const SizedBox(height: 12),
            Text('Error al cargar', style: TextStyle(color: c.textSecondary)),
            const SizedBox(height: 8),
            TextButton(onPressed: _cargar, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    final lista = _filtrados;

    return RefreshIndicator(
      onRefresh: _cargar,
      color: c.primaryDeep,
      backgroundColor: c.surface,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Filtros
          SliverToBoxAdapter(
            child: _buildFiltros(context),
          ),

          if (lista.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag_outlined,
                          size: 56, color: c.textHint.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text('Sin territorios en esta categoría',
                          style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 90),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) {
                    final t = lista[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TerritoryGlobalCard(
                        territory: t,
                        userId: _miId ?? '',
                      ),
                    );
                  },
                  childCount: lista.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFiltros(BuildContext context) {
    final c = context.colors;
    final opciones = [
      ('todos', 'Todos'),
      ('libres', 'Libres'),
      ('propios', 'Míos'),
      ('rivales', 'Rivales'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: opciones.map((op) {
          final selected = _filtro == op.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filtro = op.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? c.primaryDeep
                      : c.primaryDeepWithAlpha(0.07),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  op.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : c.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── CARD GLOBAL ──────────────────────────────────────────────────────────────

class _TerritoryGlobalCard extends StatelessWidget {
  final TerritoryModel territory;
  final String userId;

  const _TerritoryGlobalCard({
    required this.territory,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final statusColor = territory.statusColor(context, userId);
    final libre = territory.libre;

    return GestureDetector(
      onTap: () => context.pushNamed(
        'territory_detail',
        pathParameters: {'id': territory.id},
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: statusColor.withValues(alpha: 0.2)),
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
            // ─ Icono con badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                libre
                    ? Icons.explore_rounded
                    : territory.isOwned(userId)
                        ? Icons.workspace_premium_rounded
                        : Icons.local_fire_department_rounded,
                color: statusColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // ─ Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          territory.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          territory.statusLabel(userId).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 12, color: c.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          territory.ownerDisplayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: c.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  if (territory.tiempoRecordFormateado != null &&
                      !territory.libre) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 12, color: c.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Récord: ${territory.tiempoRecordFormateado}',
                          style: TextStyle(
                            fontSize: 11,
                            color: c.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            Icon(Icons.chevron_right_rounded, size: 18, color: c.textHint),
          ],
        ),
      ),
    );
  }
}
