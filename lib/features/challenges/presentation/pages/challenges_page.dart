import 'package:flutter/material.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyChallenge = {
      'title': 'Corredor Imparable',
      'description': 'Corre 30 km esta semana',
      'progress': 18.5,
      'target': 30.0,
      'daysLeft': 3,
      'reward': 'Insignia de Resistencia',
    };

    final badges = [
      {'name': 'Velocista', 'icon': '⚡', 'unlocked': true},
      {'name': 'Maratonista', 'icon': '🏃', 'unlocked': true},
      {'name': 'Conquistador', 'icon': '👑', 'unlocked': true},
      {'name': 'Resistencia', 'icon': '💪', 'unlocked': false},
      {'name': 'Nocturno', 'icon': '🌙', 'unlocked': false},
      {'name': 'Social', 'icon': '🤝', 'unlocked': true},
    ];

    final communityRaces = [
      {
        'name': '5K Matutino',
        'creator': 'Runners Urbanos',
        'date': '28 Nov',
        'participants': 42,
        'distance': 5,
        'type': 'Carrera',
      },
      {
        'name': 'Desafío 10K',
        'creator': 'Trail Seekers',
        'date': '2 Dic',
        'participants': 67,
        'distance': 10,
        'type': 'Reto',
      },
      {
        'name': 'Media Maratón',
        'creator': 'Maratón Team',
        'date': '10 Dic',
        'participants': 128,
        'distance': 21,
        'type': 'Maratón',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E5BFF), Color(0xFF0D47D4)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Retos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Supera tus límites cada semana',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Weekly Challenge Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
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
                              'Reto de la semana',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${weeklyChallenge['daysLeft']} días',
                                style: const TextStyle(
                                  color: Color(0xFFFF3B30),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          weeklyChallenge['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weeklyChallenge['description'] as String,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: (weeklyChallenge['progress'] as double) /
                              (weeklyChallenge['target'] as double),
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF1E5BFF),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${weeklyChallenge['progress']} / ${weeklyChallenge['target']} km',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Recompensa: ${weeklyChallenge['reward']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Badges Grid
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mis insignias',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: badges.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      final unlocked = badge['unlocked'] as bool;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: unlocked
                              ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: unlocked
                                ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              badge['icon'] as String,
                              style: TextStyle(
                                fontSize: 32,
                                color: unlocked
                                    ? Colors.black
                                    : Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              badge['name'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Community Races
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Carreras de la comunidad',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...communityRaces.map(
                    (race) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            race['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Por ${race['creator']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${race['date']}'),
                              Text('${race['distance']} km'),
                              Text('${race['participants']}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Create Challenge Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E5BFF), Color(0xFF0D47D4)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () {}, // navegación futura
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Crear reto personalizado',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
