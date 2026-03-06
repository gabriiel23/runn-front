import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded groups for demonstration, matching existing UI style
    final groups = [
      {
        'name': 'Runners Urbanos',
        'members': 247,
        'location': 'Centro Histórico',
        'level': 'Todos los niveles',
        'color': const Color(0xFFE8698A),
      },
      {
        'name': 'Trail Seekers',
        'members': 189,
        'location': 'Bosque de Chapultepec',
        'level': 'Intermedio',
        'color': const Color(0xFF7ED957),
      },
      {
        'name': 'Maratón Team',
        'members': 156,
        'location': 'Polanco',
        'level': 'Avanzado',
        'color': const Color(0xFFFFB84D),
      },
      {
        'name': 'City Sprinters',
        'members': 92,
        'location': 'La Condesa',
        'level': 'Principiante',
        'color': const Color(0xFF69C2E8),
      },
      {
        'name': 'Amanecer Runner',
        'members': 64,
        'location': 'Parque Hundido',
        'level': 'Principiante',
        'color': const Color(0xFF9C69E8),
      },
      {
        'name': 'Elite Runners',
        'members': 42,
        'location': 'Estadio Olímpico',
        'level': 'Avanzado',
        'color': const Color(0xFFFF6B6B),
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
          'Explorar Grupos',
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF0A0A0A)),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groups.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildGroupItem(groups[index]);
              },
            ),
          ),
          const SizedBox(height: 32),
          _buildCreateGroupBanner(context),
          const SizedBox(height: 40),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/community/groups/create'),
        backgroundColor: const Color(0xFFE8698A),
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.group_add_rounded, color: Colors.white),
        label: const Text(
          'Crear Grupo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateGroupBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8698A), Color(0xFFC94070)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8698A).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿No encuentras tu grupo ideal?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Crea el tuyo propio y empieza a correr con otros.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/community/groups/create'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFE8698A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Empezar ahora',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupItem(Map<String, dynamic> group) {
    final color = group['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.groups_rounded,
              color: color.withValues(alpha: 0.8),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0A0A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${group['members']} miembros  ·  ${group['level']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: color.withValues(alpha: 0.7),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      group['location'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}
