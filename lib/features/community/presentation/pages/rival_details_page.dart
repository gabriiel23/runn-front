import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class RivalDetailsPage extends StatelessWidget {
  final String userId;
  final Map<String, dynamic>? rivalData;

  const RivalDetailsPage({super.key, required this.userId, this.rivalData});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final String name = rivalData?['name'] as String? ?? 'Rival User';
    final int level = rivalData?['level'] as int? ?? 1;
    final int challenges = rivalData?['challenges'] as int? ?? 0;
    final int territoriesLost = rivalData?['territoriesLost'] as int? ?? 0;

    // Detailed mock data for what they have challenged and territories taken
    final detailedChallenges = List.generate(
      challenges > 0 ? challenges : 3,
      (index) => {
        'date': '1${index + 1} Mar 2024',
        'type': 'Carrera 5K',
        'location': 'Parque Metropolitano',
        'result': index % 2 == 0 ? 'Perdiste' : 'Ganaste',
      },
    );

    final detailedTerritories = List.generate(
      territoriesLost > 0 ? territoriesLost : 2,
      (index) => {
        'date': '0${index + 5} Mar 2024',
        'location': index == 0 ? 'Centro Histórico' : 'La Carolina',
        'timeTaken': '14:32',
      },
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
          'Detalles del Rival',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: c.primaryDeepWithAlpha(0.1), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with simple rival info
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: c.primaryLight,
                  child: Icon(Icons.person_rounded, size: 32, color: c.primaryDeepWithAlpha(0.7)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB84D).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFB84D).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        'Nivel $level',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFCC8400),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Challenges section
            Text(
              'Retos Recientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 16),
            ...detailedChallenges.map((challenge) => _buildChallengeItem(challenge, context)),
            
            const SizedBox(height: 32),

            // Territories section
            Text(
              'Territorios Quitados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 16),
            ...detailedTerritories.map((territory) => _buildTerritoryItem(territory, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeItem(Map<String, String> challenge, BuildContext context) {
    final c = context.colors;
    final isWin = challenge['result'] == 'Ganaste';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.primaryDeepWithAlpha(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.directions_run_rounded, color: c.primaryDeep),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['type']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  '${challenge['location']} • ${challenge['date']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            challenge['result']!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isWin ? const Color(0xFF7ED957) : const Color(0xFFFF6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerritoryItem(Map<String, String> territory, BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.2)),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flag_rounded, color: Color(0xFFFF6B6B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  territory['location']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  territory['date']!,
                  style: TextStyle(
                    fontSize: 13,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Perdido',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
              Text(
                territory['timeTaken']!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
