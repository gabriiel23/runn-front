import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/territory_model.dart';
import '../../services/territory_service.dart';

class MyTerritoriesTab extends StatefulWidget {
  const MyTerritoriesTab({super.key});

  @override
  State<MyTerritoriesTab> createState() => _MyTerritoriesTabState();
}

class _MyTerritoriesTabState extends State<MyTerritoriesTab> {
  List<TerritoryModel>? _territorios;
  String? _error;
  bool _loading = true;
  String? _miId;

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
      _miId = await ApiConfig.getCurrentUserId();
      final lista = await TerritorioService.getMisTerritorios();
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
            Text('Error al cargar territorios', style: TextStyle(color: c.textSecondary)),
            const SizedBox(height: 8),
            TextButton(onPressed: _cargar, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    final territorios = _territorios ?? [];

    if (territorios.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: c.primaryDeepWithAlpha(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.map_outlined, color: c.primaryDeepWithAlpha(0.5), size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'Sin territorios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Completa una actividad y conquista tu primer territorio',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: c.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      color: c.primaryDeep,
      backgroundColor: c.surface,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 90),
        itemCount: territorios.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          return TerritoryCard(
            territory: territorios[index],
            userId: _miId ?? '',
          );
        },
      ),
    );
  }
}

// ─── TERRITORY CARD ───────────────────────────────────────────────────────────

class TerritoryCard extends StatelessWidget {
  final TerritoryModel territory;
  final String userId;

  const TerritoryCard({super.key, required this.territory, required this.userId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final statusColor = territory.statusColor(context, userId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
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
          // ─ Icono de estado
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.map_rounded,
                  color: statusColor.withValues(alpha: 0.7),
                  size: 30,
                ),
                Positioned(
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      territory.statusLabel(userId).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 7,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // ─ Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
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
                if (territory.descripcion != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    territory.descripcion!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: c.textSecondary),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Chip(
                      icon: Icons.timer_outlined,
                      label: territory.tiempoRecordFormateado ?? '--:--:--',
                      color: c.primaryDeep,
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      icon: Icons.shield_outlined,
                      label: '${territory.totalDefensas} def.',
                      color: const Color(0xFF4CAF50),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ─ Botón ver
          GestureDetector(
            onTap: () => context.pushNamed(
              'territory_detail',
              pathParameters: {'id': territory.id},
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

// ─── CHIP PEQUEÑO ─────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
