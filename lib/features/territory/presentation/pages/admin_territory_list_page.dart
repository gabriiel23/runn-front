import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/territory_model.dart';
import '../../services/territory_service.dart';
import 'admin_territory_edit_page.dart';

/// Lista de territorios para que el administrador gestione el CRUD.
class AdminTerritoryListPage extends StatefulWidget {
  const AdminTerritoryListPage({super.key});

  @override
  State<AdminTerritoryListPage> createState() => _AdminTerritoryListPageState();
}

class _AdminTerritoryListPageState extends State<AdminTerritoryListPage> {
  List<TerritoryModel>? _territories;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await TerritorioService.getTerritorios();
      if (!mounted) return;
      setState(() {
        _territories = list;
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

  Future<void> _openEdit({TerritoryModel? territory}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminTerritoryEditPage(territory: territory),
      ),
    );
    // Si el usuario guardó (result == true), recargamos la lista
    if (result == true) _load();
  }

  Future<void> _confirmDelete(TerritoryModel t) async {
    final c = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Eliminar territorio',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de eliminar "${t.nombre}"? Esta acción no se puede deshacer y afectará a las actividades vinculadas.',
          style: TextStyle(color: c.textSecondary, fontSize: 14, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: c.textHint, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await TerritorioService.deleteTerritorio(t.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Territorio eliminado: ${t.nombre}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(
          backgroundColor: c.card,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.primaryDeepWithAlpha(0.04),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: c.textPrimary, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: Text(
            'Gestión de Territorios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: c.primaryDeepWithAlpha(0.04),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: c.primaryDeep,
                  size: 20,
                ),
                onPressed: _load,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              height: 44,
              decoration: BoxDecoration(
                color: c.primaryDeepWithAlpha(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.all(4),
                indicatorPadding: EdgeInsets.zero,
                indicator: BoxDecoration(
                  color: c.primaryDeep,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: c.primaryDeep.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: c.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Individuales'),
                  Tab(text: 'Grupales'),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openEdit(),
          backgroundColor: c.primaryDeep,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Nuevo Territorio',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              fontSize: 13,
            ),
          ),
        ),
        body: TabBarView(
          children: [_buildBody(c, 'individual'), _buildBody(c, 'grupal')],
        ),
      ),
    );
  }

  Widget _buildBody(dynamic c, String modalidadFiltro) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(c.primaryDeep),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando territorios...',
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: Colors.red,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No se pudieron cargar los territorios',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: c.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Reintentar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primaryDeep,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final allTerritories = _territories ?? [];
    final territories = allTerritories
        .where((t) => t.modalidad == modalidadFiltro)
        .toList();

    if (territories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.primaryDeepWithAlpha(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.map_outlined, color: c.primaryDeep, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                'No hay territorios creados aún',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Usa el botón "Nuevo Territorio" en la esquina inferior para registrar tu primer territorio en la modalidad ${modalidadFiltro == 'grupal' ? 'Grupal' : 'Individual'}.',
                style: TextStyle(
                  fontSize: 13,
                  color: c.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: territories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final t = territories[index];
        return _TerritoryAdminCard(
          territory: t,
          onEdit: () => _openEdit(territory: t),
          onDelete: () => _confirmDelete(t),
        );
      },
    );
  }
}

// ── Card de la lista ──────────────────────────────────────────────────────────

class _TerritoryAdminCard extends StatelessWidget {
  final TerritoryModel territory;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TerritoryAdminCard({
    required this.territory,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = territory;

    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    if (t.libre) {
      statusColor = const Color(0xFF3B82F6);
      statusIcon = Icons.lock_open_rounded;
      statusLabel = 'Libre';
    } else if (t.propietario != null) {
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.person_rounded;
      statusLabel = 'Ocupado';
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.group_rounded;
      statusLabel = 'Ocupado';
    }

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.primaryDeepWithAlpha(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icono decorado de tipo/estado
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withValues(alpha: 0.16),
                          statusColor.withValues(alpha: 0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 16),

                  // Nombre + info del territorio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _InfoChip(label: statusLabel, color: statusColor),
                            _InfoChip(
                              label: t.modalidad == 'grupal'
                                  ? 'Grupal'
                                  : 'Individual',
                              color: c.textSecondary,
                            ),
                            if (t.vecesDisputado > 0)
                              _InfoChip(
                                label:
                                    '${t.vecesDisputado} ${t.vecesDisputado == 1 ? 'disputa' : 'disputas'}',
                                color: const Color(0xFFFF6B35),
                              ),
                          ],
                        ),
                        if (t.ownerDisplayName != 'Sin dueño') ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                t.modalidad == 'grupal'
                                    ? Icons.groups_outlined
                                    : Icons.person_outline_rounded,
                                size: 13,
                                color: c.textSecondary,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  t.ownerDisplayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: c.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Menú de opciones
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: c.primaryDeepWithAlpha(0.04),
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: c.textSecondary,
                        size: 20,
                      ),
                      color: c.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: c.primaryDeepWithAlpha(0.08)),
                      ),
                      elevation: 4,
                      onSelected: (v) {
                        if (v == 'edit') onEdit();
                        if (v == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: c.textPrimary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Editar',
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Eliminar',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
