import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/territory_data.dart';

class TerritoryDetailView extends StatelessWidget {
  final int territoryId;
  final VoidCallback onBack;

  const TerritoryDetailView({
    super.key,
    required this.territoryId,
    required this.onBack,
  });

  TerritoryData get territory => territoriesMock.firstWhere(
    (t) => t.id == territoryId,
    orElse: () => territoriesMock.first,
  );

  Future<void> _shareTerritory() async {
    final shareText =
        'Territorio: ${territory.name}\n'
        'Estado: ${territory.detailStatusLabel}\n'
        'Control: ${territory.dominance}%\n'
        'Dueno actual: ${territory.ownerName}\n'
        'Actividad reciente: ${territory.runs} corredores activos.';
    await Share.share(
      shareText,
      subject: 'Estado de territorio: ${territory.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rivalControl = (100 - territory.dominance).clamp(0, 100);
    territory.statusColor(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── TOP BAR ────────────────────────────────────────────────
              Row(
                children: [
                  _HeaderActionButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: onBack,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      territory.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _HeaderActionButton(
                    icon: Icons.share_outlined,
                    onTap: _shareTerritory,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── MAPA DEL TERRITORIO ─────────────────────────────────────
              _buildSectionHeader(
                'Mapa del territorio',
                Icons.map_rounded,
                context,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(context),
                child: Column(
                  children: [
                    _TerritoryGridMap(dominance: territory.dominance),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendDot(
                          label: 'TU CONTROL',
                          color: const Color(0xFF7ED957),
                        ),
                        const SizedBox(width: 16),
                        _LegendDot(
                          label: 'EN DISPUTA',
                          color: const Color(0xFFFFB84D),
                        ),
                        const SizedBox(width: 16),
                        _LegendDot(
                          label: 'RIVAL',
                          color: const Color(0xFFFF6B6B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── CONTROL ACTUAL ─────────────────────────────────────────
              _buildSectionHeader(
                'Control actual',
                Icons.shield_rounded,
                context,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(context),
                child: Column(
                  children: [
                    // Tu barra
                    _buildDominanceBar(
                      context: context,
                      label: 'Tú',
                      sublabel: territory.ownerName,
                      percent: territory.dominance,
                      color: const Color(0xFF7ED957),
                      isYou: true,
                    ),
                    const SizedBox(height: 16),
                    // Rival barra
                    _buildDominanceBar(
                      context: context,
                      label: 'Rival',
                      sublabel: 'Desafiante',
                      percent: rivalControl,
                      color: const Color(0xFFFF6B6B),
                      isYou: false,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      color: context.colors.primaryDeepWithAlpha(0.06),
                    ),
                    const SizedBox(height: 16),
                    // Stats grid
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildStatCell(
                            context,
                            Icons.map_rounded,
                            '${territory.distance}k',
                            'Distancia',
                            const Color(0xFF7ED957),
                          ),
                          _buildVerticalDivider(context),
                          _buildStatCell(
                            context,
                            Icons.directions_run_rounded,
                            '${territory.runs}',
                            'Corredores',
                            c.primaryDeep,
                          ),
                          _buildVerticalDivider(context),
                          _buildStatCell(
                            context,
                            Icons.flag_rounded,
                            territory.threatLevel >= 3 ? 'ALTA' : 'MEDIA',
                            'Amenaza',
                            const Color(0xFFFFB84D),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── CARRERAS RECIENTES ──────────────────────────────────────
              _buildSectionHeader(
                'Carreras en esta zona',
                Icons.directions_run_rounded,
                context,
              ),
              const SizedBox(height: 12),
              ...territory.history.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(context),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(entry['avatar'] ?? ''),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry['runner'] ?? '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: c.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${entry['km'] ?? ''}  •  ${entry['time'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: (entry['team'] == 'ROSA')
                                ? const Color(0xFFF8E7EF)
                                : c.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            entry['team'] ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: (entry['team'] == 'ROSA')
                                  ? const Color(0xFFC46F9A)
                                  : const Color(0xFF4B85CF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── ACTIVIDAD DE RIVALES ────────────────────────────────────
              _buildSectionHeader(
                'Actividad de rivales',
                Icons.groups_rounded,
                context,
              ),
              const SizedBox(height: 12),
              _ActivityAlertCard(
                title: '¡Alerta de Dominio!',
                message:
                    'FastRunner 99 corrió en esta zona. ¡Defiende tu territorio!',
                time: 'Hace 2h',
                isUrgent: true,
              ),
              const SizedBox(height: 10),
              _ActivityAlertCard(
                title: 'Intento de conquista',
                message: 'Un rival intentó tomar control de esta zona.',
                time: 'Hace 1 día',
                isUrgent: false,
              ),

              const SizedBox(height: 24),

              // ── CTA BUTTON ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [c.primaryDeep, c.primaryDark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: c.primaryDeepWithAlpha(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            territory.isOwned
                                ? '¡A DEFENDER!'
                                : '¡Unirse a la conquista!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
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

  // ── HELPERS ──────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration(BuildContext context) {
    final c = context.colors;
    return BoxDecoration(
      color: c.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

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
      ],
    );
  }

  Widget _buildDominanceBar({
    required BuildContext context,
    required String label,
    required String sublabel,
    required int percent,
    required Color color,
    required bool isYou,
  }) {
    final c = context.colors;
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                sublabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: c.textSecondary),
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCell(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final c = context.colors;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 60,
      color: context.colors.primaryDeepWithAlpha(0.07),
    );
  }
}

// ── TERRITORY GRID MAP ────────────────────────────────────────────────────────

class _TerritoryGridMap extends StatelessWidget {
  final int dominance;
  const _TerritoryGridMap({required this.dominance});

  @override
  Widget build(BuildContext context) {
    // 4x4 grid — cells colored by control based on dominance %
    const grid = [
      [1, 1, 1, 2],
      [1, 1, 3, 2],
      [1, 3, 2, 2],
      [1, 0, 2, 2],
    ];
    // 1 = yours, 2 = rival, 3 = disputed, 0 = neutral

    return Column(
      children: List.generate(4, (row) {
        return Padding(
          padding: EdgeInsets.only(bottom: row == 3 ? 0 : 6),
          child: Row(
            children: List.generate(4, (col) {
              final cell = grid[row][col];
              final color = switch (cell) {
                1 => const Color(0xFF7ED957),
                2 => const Color(0xFFFF6B6B),
                3 => const Color(0xFFFFB84D),
                _ => context.colors.primaryDeepWithAlpha(0.05),
              };
              final isActive = cell == 3;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: col == 3 ? 0 : 6),
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.5)),
                    ),
                    child: isActive
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB84D),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFB84D,
                                    ).withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              );
            }),
          ),
        );
      }),
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
      mainAxisSize: MainAxisSize.min,
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

// ── ACTIVITY ALERT CARD ───────────────────────────────────────────────────────

class _ActivityAlertCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final bool isUrgent;

  const _ActivityAlertCard({
    required this.title,
    required this.message,
    required this.time,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accentColor = isUrgent ? const Color(0xFFFF6B6B) : c.primaryDeep;

    return Container(
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isUrgent ? Icons.warning_rounded : Icons.info_outline_rounded,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isUrgent ? accentColor : c.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: c.primaryDeepWithAlpha(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: c.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── HEADER ACTION BUTTON ──────────────────────────────────────────────────────

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
        ),
        child: Icon(icon, color: c.textSecondary, size: 22),
      ),
    );
  }
}
