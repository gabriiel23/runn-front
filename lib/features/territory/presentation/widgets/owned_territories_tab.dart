import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/territory_data.dart';
import 'my_territories_tab.dart';

class OwnedTerritoriesTab extends StatelessWidget {
  const OwnedTerritoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Filtramos para mostrar únicamente los territorios propios
    final territories = territoriesMock.where((t) => t.isOwned).toList();

    if (territories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flag_outlined,
                size: 64,
                color: context.colors.textHint.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Aún no tienes territorios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Compite en el apartado de Territorios para conquistar zonas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textHint,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
