import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/challenge_data.dart';

class CommunityRaceDetailPage extends StatelessWidget {
  final String raceId;

  const CommunityRaceDetailPage({super.key, required this.raceId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final race = communityRaces.firstWhere(
      (r) => r.id == raceId,
      orElse: () => communityRaces.first,
    );

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          race.name,
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (race.isEnrolled)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF7ED957).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '✓ Inscrito',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7ED957),
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: c.primaryDeepWithAlpha(0.1), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero card ─────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          race.color,
                          race.color.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: race.color.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: Text(
                                  '${race.distance}K',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    race.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Por ${race.creator}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.75),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _HeroStat(
                              icon: Icons.calendar_today_rounded,
                              label: race.date,
                            ),
                            const SizedBox(width: 20),
                            _HeroStat(
                              icon: Icons.access_time_rounded,
                              label: race.startTime,
                            ),
                            const SizedBox(width: 20),
                            _HeroStat(
                              icon: Icons.people_rounded,
                              label: '${race.participants} inscritos',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Descripción ───────────────────────────────
                  Text(
                    'Acerca de la carrera',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: c.primaryDeepWithAlpha(0.07)),
                    ),
                    child: Text(
                      race.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: c.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Logística ─────────────────────────────────
                  Text(
                    'Logística',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: c.primaryDeepWithAlpha(0.07)),
                    ),
                    child: Column(
                      children: [
                        _LogisticRow(
                          icon: Icons.location_on_rounded,
                          title: 'Lugar',
                          value: race.location,
                          color: race.color,
                          c: c,
                        ),
                        const SizedBox(height: 14),
                        Divider(height: 1, color: c.primaryDeepWithAlpha(0.07)),
                        const SizedBox(height: 14),
                        _LogisticRow(
                          icon: Icons.flag_rounded,
                          title: 'Punto de encuentro',
                          value: race.meetingPoint,
                          color: race.color,
                          c: c,
                        ),
                        const SizedBox(height: 14),
                        Divider(height: 1, color: c.primaryDeepWithAlpha(0.07)),
                        const SizedBox(height: 14),
                        _LogisticRow(
                          icon: Icons.access_time_rounded,
                          title: 'Hora de inicio',
                          value: race.startTime,
                          color: race.color,
                          c: c,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Requisitos ────────────────────────────────
                  Text(
                    'Requisitos',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: c.primaryDeepWithAlpha(0.07)),
                    ),
                    child: Column(
                      children: race.requirements
                          .asMap()
                          .entries
                          .map(
                            (e) => Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    e.key < race.requirements.length - 1
                                        ? 12
                                        : 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: race.color,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: c.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Botón fijo al fondo ──────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            decoration: BoxDecoration(
              color: c.card,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: race.isEnrolled ? null : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: race.isEnrolled
                      ? const Color(0xFF7ED957)
                      : race.color,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF7ED957).withValues(alpha: 0.8),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  race.isEnrolled ? '✓ Ya estás inscrito' : 'Unirse a la carrera',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LogisticRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final dynamic c;

  const _LogisticRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: c.textHint,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
