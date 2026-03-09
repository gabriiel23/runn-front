import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/territory_data.dart';

// Grid small preview for map screen.
const _mapPreviewGrid = [
  [4, 4, 4, 1, 1],
  [4, 4, 1, 1, 0],
  [4, 1, 1, 2, 0],
  [0, 1, 2, 5, 0],
];

class TerritoryMapTab extends StatefulWidget {
  final void Function(TerritoryData) onOpenDetail;
  const TerritoryMapTab({super.key, required this.onOpenDetail});

  @override
  State<TerritoryMapTab> createState() => _TerritoryMapTabState();
}

class _TerritoryMapTabState extends State<TerritoryMapTab> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TerritoryData> get _results {
    final q = _query.trim().toLowerCase();
    final base = territoriesMock.where((t) => t.status != 'unclaimed').toList();
    if (q.isEmpty) {
      return base.where((t) => t.isContested || t.isRival).toList();
    }
    return base.where((t) {
      final byName = t.name.toLowerCase().contains(q);
      final byOwner = t.ownerName.toLowerCase().contains(q);
      final byRunner = t.history.any(
        (h) => (h['runner'] ?? '').toLowerCase().contains(q),
      );
      return byName || byOwner || byRunner;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final searching = _query.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: context.colors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar zona o corredor',
                      hintStyle: TextStyle(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: context.colors.textSecondary,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                const SizedBox(height: 6),
                const _TerritoryGridMap(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(label: 'MIO', color: context.colors.primaryMid),
                    const SizedBox(width: 12),
                    _LegendDot(
                      label: 'EN DISPUTA',
                      color: context.colors.primaryLight,
                    ),
                    const SizedBox(width: 12),
                    _LegendDot(
                      label: 'PERDIDO',
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    _LegendDot(label: 'LIBRE', color: context.colors.surface),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            searching ? 'Resultados' : 'Territorios en disputa',
            style: TextStyle(
              fontSize: 35,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w900,
              color: context.colors.textPrimary,
            ),
          ),
          Text(
            searching
                ? 'Coincidencias por zona, dueno o corredor'
                : 'Duelos activos cerca de ti',
            style: TextStyle(
              fontSize: 12,
              color: context.colors.textPrimary.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          if (results.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'No se encontraron zonas.',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ...results.map(
            (territory) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DisputeCard(
                territory: territory,
                onOpenDetail: () => widget.onOpenDetail(territory),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TerritoryGridMap extends StatelessWidget {
  const _TerritoryGridMap();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: List.generate(_mapPreviewGrid.length, (row) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: row == _mapPreviewGrid.length - 1 ? 0 : 5,
              ),
              child: Row(
                children: List.generate(_mapPreviewGrid[row].length, (col) {
                  final id = _mapPreviewGrid[row][col];
                  final territory = id == 0
                      ? null
                      : territoriesMock.firstWhere((t) => t.id == id);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: col == _mapPreviewGrid[row].length - 1 ? 0 : 5,
                      ),
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          color:
                              territory?.statusColor(context) ??
                              context.colors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
        Positioned(
          top: -2,
          left: 86,
          child: _MapPinBadge(
            icon: Icons.local_fire_department_outlined,
            text: 'Zona Caliente',
            color: context.colors.primaryMid,
          ),
        ),
        Positioned(
          top: -2,
          left: 172,
          child: _MapPinBadge(
            icon: Icons.bolt_rounded,
            text: 'Actividad Alta',
            color: context.colors.primaryLight,
          ),
        ),
      ],
    );
  }
}

class _MapPinBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MapPinBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.surface, width: 1.4),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final TerritoryData territory;
  final VoidCallback onOpenDetail;

  const _DisputeCard({required this.territory, required this.onOpenDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  territory.name,
                  style: TextStyle(
                    fontSize: 17,
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'RESISTENCIA : ${territory.dominance}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: context.colors.primaryDeep,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Dueno actual: ${territory.ownerName}',
            style: TextStyle(
              fontSize: 12,
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: territory.dominance / 100,
              minHeight: 4,
              backgroundColor: context.colors.card,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colors.primaryMid,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.circle, size: 7, color: context.colors.primaryMid),
              const SizedBox(width: 6),
              Text(
                territory.isRival ? 'Zona perdida' : 'Duelo en vivo',
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onOpenDetail,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Ver detalles',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
