import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyBadgesPage extends StatelessWidget {
  const MyBadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: const Color(0xFFFFFBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A0A0A)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mis insignias',
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSectionHeader('Desbloqueadas (${unlockedBadges.length})'),
          _buildBadgeGrid(context, unlockedBadges),
          _buildSectionHeader('Por desbloquear (${lockedBadges.length})'),
          _buildBadgeGrid(context, lockedBadges),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0A0A0A),
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeGrid(BuildContext context, List<Map<String, dynamic>> badges) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final badge = badges[index];
            return GestureDetector(
              onTap: () => _showBadgeDetails(context, badge),
              child: _buildBadgeItem(badge),
            );
          },
          childCount: badges.length,
        ),
      ),
    );
  }

  Widget _buildBadgeItem(Map<String, dynamic> badge) {
    final bool unlocked = badge['unlocked'];
    final Color color = badge['color'];

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: unlocked ? color.withOpacity(0.1) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: unlocked ? color.withOpacity(0.3) : const Color(0xFFE0E0E0),
                width: 2,
              ),
              boxShadow: unlocked ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : [],
            ),
            child: Center(
              child: Icon(
                badge['icon'],
                size: 32,
                color: unlocked ? color : const Color(0xffBDBDBD),
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
            color: unlocked ? const Color(0xFF0A0A0A) : const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }

  void _showBadgeDetails(BuildContext context, Map<String, dynamic> badge) {
    final bool unlocked = badge['unlocked'];
    final Color color = badge['color'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
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
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3), width: 3),
              ),
              child: Icon(badge['icon'], size: 48, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              badge['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              unlocked ? '¡Logro desbloqueado!' : 'Logro bloqueado',
              style: TextStyle(
                color: unlocked ? const Color(0xFF7ED957) : const Color(0xFFE8698A),
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
                color: const Color(0xFF0A0A0A).withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const Spacer(),
            if (unlocked)
              Text(
                'Conseguido el ${badge['date']}',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF0A0A0A).withOpacity(0.4),
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
                      backgroundColor: const Color(0xFFFFF0F4),
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
