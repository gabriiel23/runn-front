import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/territory_data.dart';

class MyTerritoriesTab extends StatelessWidget {
  const MyTerritoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final territories = territoriesMock.toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 90),
      itemBuilder: (_, index) {
        final territory = territories[index];
        return TerritoryCard(territory: territory);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: territories.length,
    );
  }
}

class TerritoryCard extends StatelessWidget {
  final TerritoryData territory;
  const TerritoryCard({super.key, required this.territory});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final statusColor = territory.statusColor(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen con badge de status superpuesto
          SizedBox(
            width: 68,
            height: 74, // altura extra para el badge que sobresale
            child: Stack(
              clipBehavior: Clip.none,
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
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        territory.statusLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Info — Expanded para que no compita con el botón
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  territory.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 12,
                      color: c.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        territory.ownerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: c.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.map_rounded, size: 12, color: c.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${territory.distance}k  •  ${territory.runs} corredores',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: c.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Botón chip — tamaño fijo, no crece
          GestureDetector(
            onTap: () => context.pushNamed(
              'territory_detail',
              pathParameters: {'id': territory.id.toString()},
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c.primaryDeepWithAlpha(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Ver',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c.primaryDeepWithAlpha(0.9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
