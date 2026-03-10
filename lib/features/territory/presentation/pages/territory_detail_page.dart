import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/territory_data.dart';

class TerritoryDetailView extends StatelessWidget {
  final TerritoryData territory;
  final VoidCallback onBack;

  const TerritoryDetailView({
    super.key,
    required this.territory,
    required this.onBack,
  });

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
    final rivalControl = (100 - territory.dominance).clamp(0, 100);
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HeaderActionButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: onBack,
                  ),
                  Expanded(
                    child: Text(
                      territory.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _HeaderActionButton(
                    icon: Icons.share_outlined,
                    onTap: _shareTerritory,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 230,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(territory.imageUrl, fit: BoxFit.cover),
                      Positioned(
                        left: 14,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.card.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: context.colors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'CDMX, Mexico',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.textSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTADO DE LA ZONA',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          territory.detailStatusLabel,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: context.colors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${territory.dominance}',
                          style: TextStyle(
                            fontSize: 36,
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                        Text(
                          ' vs $rivalControl',
                          style: TextStyle(
                            fontSize: 19,
                            color: context.colors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: territory.dominance / 100,
                        minHeight: 8,
                        backgroundColor: context.colors.primaryMid,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colors.primaryMid,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: context.colors.primaryMid,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'TU CONTROL',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF68738D),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'RIVAL',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF68738D),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: context.colors.primaryLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MetricBubble(
                    icon: Icons.timer_outlined,
                    label: 'RECORD',
                    value: '04:22',
                  ),
                  const SizedBox(width: 8),
                  _MetricBubble(
                    icon: Icons.directions_run_rounded,
                    label: 'ACTIVOS',
                    value: '${territory.runs}',
                  ),
                  const SizedBox(width: 8),
                  _MetricBubble(
                    icon: Icons.flag_rounded,
                    label: 'AMENAZA',
                    value: territory.threatLevel >= 3 ? 'ALTA' : 'MEDIA',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Actividad',
                    style: TextStyle(
                      fontSize: 41,
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.9,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '24 HORAS',
                    style: TextStyle(
                      fontSize: 10,
                      color: context.colors.textPrimary.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...territory.history.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 21,
                          backgroundImage: NetworkImage(entry['avatar'] ?? ''),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry['runner'] ?? '-',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '${entry['km'] ?? ''}  •  ${entry['time'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF68738D),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: (entry['team'] == 'ROSA')
                                ? const Color(0xFFF8E7EF)
                                : context.colors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFE90084),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 20),
                  label: Text(
                    territory.isOwned ? '¡A DEFENDER!' : '¡IR A RECONQUISTAR!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
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
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Icon(icon, color: context.colors.textSecondary, size: 22),
      ),
    );
  }
}

class _MetricBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricBubble({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.colors.card),
        ),
        child: Column(
          children: [
            Icon(icon, size: 17, color: context.colors.primary),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
