import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class MyBadgesPage extends StatelessWidget {
  const MyBadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final unlockedBadges = [
      {
        'id': '1',
        'title': 'Primer paso',
        'description': 'Completa tu primera carrera oficial.',
        'icon': Icons.directions_run_rounded,
        'color': const Color(0xFFE8698A),
        'unlocked': true,
        'date': '12 Ene 2024',
      },
      {
        'id': '2',
        'title': 'Conquistador',
        'description': 'Captura 10+ territorios en una semana.',
        'icon': Icons.emoji_events_rounded,
        'color': const Color(0xFFFFB84D),
        'unlocked': true,
        'date': '05 Feb 2024',
      },
      {
        'id': '3',
        'title': 'Velocista',
        'description': 'Alcanza un ritmo de 4:30 min/km.',
        'icon': Icons.bolt_rounded,
        'color': const Color(0xFF7ED957),
        'unlocked': true,
        'date': '20 Feb 2024',
      },
    ];

    final lockedBadges = [
      {
        'id': '4',
        'title': 'Maratonista',
        'description': 'Completa una distancia de 42.2 km.',
        'icon': Icons.straighten_rounded,
        'color': const Color(0xFF69C2E8),
        'unlocked': false,
        'progress': 0.5,
      },
      {
        'id': '5',
        'title': 'Rey de la Colina',
        'description': 'Gana 5 retos en terrenos elevados.',
        'icon': Icons.terrain_rounded,
        'color': const Color(0xFF9B51E0),
        'unlocked': false,
        'progress': 0.2,
      },
      {
        'id': '6',
        'title': 'Explorador',
        'description': 'Corre en 5 ciudades diferentes.',
        'icon': Icons.explore_rounded,
        'color': const Color(0xFF56CCF2),
        'unlocked': false,
        'progress': 0.8,
      },
    ];

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
          'Mis insignias',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSectionHeader(
            context,
            'Desbloqueadas (${unlockedBadges.length})',
          ),
          _buildBadgeGrid(context, unlockedBadges),
          _buildSectionHeader(
            context,
            'Por desbloquear (${lockedBadges.length})',
          ),
          _buildBadgeGrid(context, lockedBadges),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final c = context.colors;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeGrid(
    BuildContext context,
    List<Map<String, dynamic>> badges,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final isLandscape =
              constraints.crossAxisExtent > MediaQuery.of(context).size.height;
          final cols = isLandscape ? 4 : 3;
          final ratio = isLandscape ? 1.1 : 0.8;
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: ratio,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final badge = badges[index];
              return GestureDetector(
                onTap: () => _showBadgeDetails(context, badge),
                child: _buildBadgeItem(context, badge),
              );
            }, childCount: badges.length),
          );
        },
      ),
    );
  }

  Widget _buildBadgeItem(BuildContext context, Map<String, dynamic> badge) {
    final c = context.colors;
    final bool unlocked = badge['unlocked'];
    final Color color = badge['color'];

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: unlocked ? color.withValues(alpha: 0.1) : c.card,
              shape: BoxShape.circle,
              border: Border.all(
                color: unlocked
                    ? color.withValues(alpha: 0.3)
                    : c.textHint.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Icon(
                badge['icon'],
                size: 32,
                color: unlocked ? color : c.textHint.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          badge['title'],
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: unlocked ? c.textPrimary : c.textHint,
          ),
        ),
      ],
    );
  }

  void _showBadgeDetails(BuildContext context, Map<String, dynamic> badge) {
    final c = context.colors;
    final bool unlocked = badge['unlocked'];
    final Color color = badge['color'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: Icon(badge['icon'], size: 48, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              badge['title'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              unlocked ? '¡Logro desbloqueado!' : 'Logro bloqueado',
              style: TextStyle(
                color: unlocked
                    ? const Color(0xFF7ED957)
                    : const Color(0xFFE8698A),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              badge['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: c.textSecondary,
                height: 1.5,
              ),
            ),
            const Spacer(),
            if (unlocked)
              Text(
                'Conseguido el ${badge['date']}',
                style: TextStyle(
                  fontSize: 12,
                  color: c.textHint,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: badge['progress'],
                      minHeight: 8,
                      backgroundColor: c.primaryDeepWithAlpha(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progreso: ${(badge['progress'] * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
