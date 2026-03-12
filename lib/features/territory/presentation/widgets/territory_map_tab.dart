import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  const TerritoryMapTab({super.key});

  @override
  State<TerritoryMapTab> createState() => _TerritoryMapTabState();
}

class _TerritoryMapTabState extends State<TerritoryMapTab>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final String _query = '';

  late AnimationController _animationController;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    final c = context.colors;
    final results = _results;
    final searching = _query.trim().isNotEmpty;

    return FadeTransition(
      opacity: _contentAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_contentAnimation),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── MAP SECTION ──────────────────────────────────────────────
              _buildSectionHeader('Mapa de zonas', Icons.map_rounded, context),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.primaryDeepWithAlpha(0.10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const _TerritoryGridMap(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendDot(label: 'MIO', color: c.primaryMid),
                        const SizedBox(width: 14),
                        _LegendDot(
                          label: 'EN DISPUTA',
                          color: const Color(0xFFFFB84D),
                        ),
                        const SizedBox(width: 14),
                        _LegendDot(label: 'PERDIDO', color: c.textSecondary),
                        const SizedBox(width: 14),
                        _LegendDot(
                          label: 'LIBRE',
                          color: c.primaryDeepWithAlpha(0.1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── ACTIVITY / RESULTS SECTION ───────────────────────────────
              _buildSectionHeader(
                searching ? 'Resultados' : 'Actividad Reciente',
                searching ? Icons.search_rounded : Icons.bolt_rounded,
                context,
              ),
              const SizedBox(height: 6),
              Text(
                searching
                    ? 'Coincidencias por zona, dueño o corredor'
                    : 'Alertas en tus territorios y alrededores',
                style: TextStyle(
                  fontSize: 13,
                  color: c.textSecondary,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              if (results.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: c.primaryDeepWithAlpha(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.search_off_rounded,
                          color: c.textSecondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'No se encontraron zonas.',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              if (!searching) ...[
                _ActivityAlertCard(
                  title: '¡Alerta de Dominio!',
                  message:
                      'FastRunner 99 esta corriendo en "Parque de Mexico". ¡Defiende tu territorio!',
                  time: 'Hace 5m',
                  isUrgent: true,
                  onTap: () => context.pushNamed(
                    'territory_detail',
                    pathParameters: {'id': territoriesMock[0].id.toString()},
                  ),
                ),
                const SizedBox(height: 12),
                _ActivityAlertCard(
                  title: 'Zona Vulnerable',
                  message: 'Tu control en "Corredor Reforma" bajo al 42%.',
                  time: 'Hace 40m',
                  isUrgent: false,
                  onTap: () => context.pushNamed(
                    'territory_detail',
                    pathParameters: {'id': territoriesMock[1].id.toString()},
                  ),
                ),
              ],

              if (searching)
                ...results.map(
                  (territory) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DisputeCard(
                      territory: territory,
                      onOpenDetail: () => context.pushNamed(
                        'territory_detail',
                        pathParameters: {'id': territory.id.toString()},
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    BuildContext context,
  ) {
    final c = context.colors;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: c.primaryDeepWithAlpha(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: c.primaryDeepWithAlpha(0.8)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              Text(
                'Ver más',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.primaryDeepWithAlpha(0.9),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: c.primaryDeepWithAlpha(0.9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── GRID MAP ──────────────────────────────────────────────────────────────────

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
                bottom: row == _mapPreviewGrid.length - 1 ? 0 : 6,
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
                        right: col == _mapPreviewGrid[row].length - 1 ? 0 : 6,
                      ),
                      child: Container(
                        height: 62,
                        decoration: BoxDecoration(
                          color:
                              territory?.statusColor(context) ??
                              context.colors.primaryDeepWithAlpha(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colors.primaryDeepWithAlpha(0.06),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── MAP PIN BADGE ─────────────────────────────────────────────────────────────

// ignore: unused_element
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
    final c = context.colors;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: c.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ── LEGEND DOT ────────────────────────────────────────────────────────────────

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

// ── DISPUTE CARD ──────────────────────────────────────────────────────────────

class _DisputeCard extends StatelessWidget {
  final TerritoryData territory;
  final VoidCallback onOpenDetail;

  const _DisputeCard({required this.territory, required this.onOpenDetail});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accentColor = territory.isRival
        ? const Color(0xFFFF6B6B)
        : const Color(0xFFFFB84D);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  territory.isRival ? Icons.flag_rounded : Icons.bolt_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      territory.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dueño: ${territory.ownerName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: c.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${territory.dominance}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: territory.dominance / 100,
              minHeight: 5,
              backgroundColor: accentColor.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                territory.isRival ? 'Zona perdida' : 'Duelo en vivo',
                style: TextStyle(
                  fontSize: 11,
                  color: c.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onOpenDetail,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: c.primaryDeepWithAlpha(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Ver detalles',
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
        ],
      ),
    );
  }
}

// ── ACTIVITY ALERT CARD ───────────────────────────────────────────────────────

class _ActivityAlertCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final bool isUrgent;
  final VoidCallback onTap;

  const _ActivityAlertCard({
    required this.title,
    required this.message,
    required this.time,
    this.isUrgent = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accentColor = isUrgent ? const Color(0xFFFF6B6B) : c.primaryDeep;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUrgent
              ? const Color(0xFFFF6B6B).withValues(alpha: 0.05)
              : c.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUrgent
                ? const Color(0xFFFF6B6B).withValues(alpha: 0.20)
                : c.primaryDeepWithAlpha(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isUrgent ? Icons.warning_rounded : Icons.info_outline_rounded,
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isUrgent ? accentColor : c.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: c.primaryDeepWithAlpha(0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      color: c.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
