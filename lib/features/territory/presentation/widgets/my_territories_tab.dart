import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/territory_data.dart';

class MyTerritoriesTab extends StatelessWidget {
  final void Function(TerritoryData) onOpenDetail;
  const MyTerritoriesTab({super.key, required this.onOpenDetail});

  @override
  Widget build(BuildContext context) {
    final territories = territoriesMock
        .where((t) => t.isOwned || t.isContested)
        .toList();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
      itemBuilder: (_, index) {
        final territory = territories[index];
        return Container(
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  territory.imageUrl,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      territory.statusLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: territory.statusColor(context),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      territory.name,
                      style: TextStyle(
                        fontSize: 18,
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Batalla activa ${territory.runs} corredores',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => onOpenDetail(territory),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Ver detalles',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: territories.length,
    );
  }
}
