import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _headerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                FadeTransition(
                  opacity: _contentAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(_contentAnimation),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 28),
                          _buildWeeklyChallenge(),
                          const SizedBox(height: 32),
                          _buildDailyChallenges(),
                          const SizedBox(height: 32),
                          _buildCommunityRaces(),
                          const SizedBox(height: 32),
                          _buildBadges(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final c = context.colors;
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: c.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 30,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFB84D).withValues(alpha: 0.06),
                      const Color(0xFFFFB84D).withValues(alpha: 0.01),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFE8698A).withValues(alpha: 0.04),
                      const Color(0xFFE8698A).withValues(alpha: 0.01),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: context.colors.primaryDeepWithAlpha(0.8),
                            size: 22,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/notifications'),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: c.primaryDeepWithAlpha(0.8),
                                    size: 22,
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF6B6B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Retos',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Supera tus límites cada día',
                      style: TextStyle(
                        fontSize: 15,
                        color: c.textSecondary,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.2,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Stats rápidas
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: c.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildHeaderStat(
                            '3',
                            'Activos',
                            Icons.bolt_rounded,
                            context,
                          ),
                          _buildHeaderDivider(),
                          _buildHeaderStat(
                            '18.5',
                            'km hoy',
                            Icons.location_on_rounded,
                            context,
                          ),
                          _buildHeaderDivider(),
                          _buildHeaderStat(
                            '4',
                            'Insignias',
                            Icons.emoji_events_rounded,
                            context,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(
    String value,
    String label,
    IconData icon,
    BuildContext context,
  ) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: c.primaryDeepWithAlpha(0.7), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: c.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderDivider() {
    final c = context.colors;
    return Container(width: 1, height: 40, color: c.primaryDeepWithAlpha(0.1));
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration({Color? accentColor}) {
    final c = context.colors;
    return BoxDecoration(
      color: c.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: (accentColor ?? c.primaryDeep).withValues(alpha: 0.10),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
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

  // ──────────────────────────────────────────────────────────────────────────
  // WEEKLY CHALLENGE
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildWeeklyChallenge() {
    final c = context.colors;
    const progress = 18.5;
    const target = 30.0;
    const progressRatio = progress / target;

    return Column(
      children: [
        _buildSectionHeader(
          'Reto de la semana',
          Icons.emoji_events_rounded,
          context,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c.primaryDeep, c.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: c.primaryDeepWithAlpha(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Corredor Imparable',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '3 días',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Corre 30 km esta semana',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '18.5 km',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'de ${target.toStringAsFixed(0)} km',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🏅', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text(
                      'Insignia de Resistencia',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
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
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DAILY CHALLENGES
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildDailyChallenges() {
    final c = context.colors;
    final challenges = [
      {
        'icon': Icons.directions_run_rounded,
        'iconColor': c.primaryDeep,
        'iconBgColor': c.primaryLight,
        'title': 'Carrera matutina',
        'description': 'Corre 5 km antes de las 9 AM',
        'reward': '+50 pts',
        'done': true,
      },
      {
        'icon': Icons.flag_rounded,
        'iconColor': const Color(0xFF7ED957),
        'iconBgColor': const Color(0xFFF4FDF0),
        'title': 'Conquista nueva zona',
        'description': 'Visita un territorio que no sea tuyo',
        'reward': '+80 pts',
        'done': false,
      },
      {
        'icon': Icons.people_rounded,
        'iconColor': const Color(0xFFFFB84D),
        'iconBgColor': const Color(0xFFFFF8F0),
        'title': 'Corre en grupo',
        'description': 'Completa una ruta con al menos 1 amigo',
        'reward': '+60 pts',
        'done': false,
      },
    ];

    return Column(
      children: [
        _buildSectionHeader('Desafíos diarios', Icons.bolt_rounded, context),
        const SizedBox(height: 16),
        ...challenges.map(
          (challenge) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDailyChallengeItem(challenge),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallengeItem(Map<String, dynamic> challenge) {
    final c = context.colors;
    final isDone = challenge['done'] as bool;
    final iconColor = challenge['iconColor'] as Color;
    final iconBgColor = challenge['iconBgColor'] as Color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF4FDF0) : c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone
              ? const Color(0xFF7ED957).withValues(alpha: 0.3)
              : iconColor.withValues(alpha: 0.1),
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
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF7ED957).withValues(alpha: 0.15)
                  : iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isDone ? Icons.check_rounded : challenge['icon'] as IconData,
              color: isDone ? const Color(0xFF7ED957) : iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['title'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDone ? const Color(0xFF7ED957) : c.textPrimary,
                    letterSpacing: -0.2,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  challenge['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: c.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF7ED957).withValues(alpha: 0.1)
                  : iconColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isDone ? '✓' : challenge['reward'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDone ? const Color(0xFF7ED957) : iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // COMMUNITY RACES
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildCommunityRaces() {
    final c = context.colors;
    final races = [
      {
        'name': '5K Matutino',
        'creator': 'Runners Urbanos',
        'date': '28 Nov',
        'participants': 42,
        'distance': 5,
        'color': c.primaryDeep,
      },
      {
        'name': 'Desafío 10K',
        'creator': 'Trail Seekers',
        'date': '2 Dic',
        'participants': 67,
        'distance': 10,
        'color': const Color(0xFF7ED957),
      },
      {
        'name': 'Media Maratón',
        'creator': 'Maratón Team',
        'date': '10 Dic',
        'participants': 128,
        'distance': 21,
        'color': const Color(0xFFFFB84D),
      },
    ];

    return Column(
      children: [
        _buildSectionHeader(
          'Carreras de la comunidad',
          Icons.flag_rounded,
          context,
        ),
        const SizedBox(height: 16),
        ...races.map(
          (race) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRaceItem(race),
          ),
        ),
      ],
    );
  }

  Widget _buildRaceItem(Map<String, dynamic> race) {
    final c = context.colors;
    final color = race['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(accentColor: color),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '${race['distance']}K',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  race['name'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Por ${race['creator']}',
                  style: TextStyle(fontSize: 12, color: c.textSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: c.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      race['date'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: c.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.people_rounded, size: 12, color: c.textHint),
                    const SizedBox(width: 4),
                    Text(
                      '${race['participants']} inscritos',
                      style: TextStyle(
                        fontSize: 12,
                        color: c.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Unirse',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BADGES
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildBadges() {
    final c = context.colors;
    final badges = [
      {'name': 'Velocista', 'icon': '⚡', 'unlocked': true},
      {'name': 'Maratonista', 'icon': '🏃', 'unlocked': true},
      {'name': 'Conquistador', 'icon': '👑', 'unlocked': true},
      {'name': 'Resistencia', 'icon': '💪', 'unlocked': false},
      {'name': 'Nocturno', 'icon': '🌙', 'unlocked': false},
      {'name': 'Social', 'icon': '🤝', 'unlocked': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Mis insignias',
          Icons.workspace_premium_rounded,
          context,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            final cols = isWide ? 6 : 3;
            final ratio = isWide ? 1.1 : 1.0;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: badges.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: ratio,
              ),
              itemBuilder: (context, index) {
                final badge = badges[index];
                final unlocked = badge['unlocked'] as bool;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? const Color(0xFFFFD700).withValues(alpha: 0.12)
                        : c.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: unlocked
                          ? const Color(0xFFFFD700).withValues(alpha: 0.35)
                          : c.textHint.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: unlocked
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFFFD700,
                              ).withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        badge['icon'] as String,
                        style: TextStyle(
                          fontSize: isWide ? 22 : 30,
                          color: unlocked ? c.textPrimary : c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        badge['name'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: unlocked ? c.textPrimary : c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
