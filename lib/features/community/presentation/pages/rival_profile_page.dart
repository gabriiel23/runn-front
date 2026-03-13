import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class RivalProfilePage extends StatelessWidget {
  final String userId;

  const RivalProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Mock data for the rival
    final rival = {
      'name': userId == '1'
          ? 'María González'
          : userId == '2'
          ? 'Carlos Ruiz'
          : 'Ana Martínez',
      'level': userId == '1'
          ? 12
          : userId == '2'
          ? 9
          : 15,
      'runs': 124,
      'km': 842,
      'territories': 18,
      'isFollowing': false,
    };

    final confrontations = [
      {
        'territory': 'Parque Metropolitano',
        'date': '24 Feb 2024',
        'winner': 'Tú',
        'won': true,
      },
      {
        'territory': 'Centro Histórico',
        'date': '18 Feb 2024',
        'winner': rival['name'],
        'won': false,
      },
      {
        'territory': 'Av. Amazonas',
        'date': '12 Feb 2024',
        'winner': rival['name'],
        'won': false,
      },
      {
        'territory': 'La Carolina',
        'date': '05 Feb 2024',
        'winner': 'Tú',
        'won': true,
      },
    ];

    final c = context.colors;
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
          'Perfil del Rival',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(rival, context),
            const SizedBox(height: 24),
            _buildMultimediaCarousel(context, rival),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  _buildRivalStats(rival, context),
                  const SizedBox(height: 32),
                  _buildConfrontationHistory(confrontations, context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> rival, BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: c.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.primaryDeepWithAlpha(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: c.primaryLight,
              child: Icon(
                Icons.person_rounded,
                size: 46,
                color: c.primaryDeepWithAlpha(0.7),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            rival['name'] as String,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB84D).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFB84D).withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              'Nivel ${rival['level']}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFCC8400),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('Siguiendo', style: TextStyle(color: c.textHint, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('97', style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 48),
              Column(
                children: [
                  Text('Seguidores', style: TextStyle(color: c.textHint, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('763', style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primaryDeep,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Seguir', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultimediaCarousel(BuildContext context, Map<String, dynamic> rival) {
    final c = context.colors;
    final mockImages = [
      'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=500&auto=format&fit=crop',
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: mockImages.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == mockImages.length) {
            return InkWell(
              onTap: () {
                context.pushNamed('rival_multimedia', pathParameters: {'userId': userId});
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.primaryDeepWithAlpha(0.1)),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Todos los\nmultimedia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              mockImages[index],
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 120,
                color: c.primaryDeepWithAlpha(0.1),
                child: Icon(Icons.broken_image_rounded, color: c.textHint),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRivalStats(Map<String, dynamic> rival, BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(24),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '${rival['runs']}',
            'Carreras',
            Icons.directions_run_rounded,
            context,
          ),
          _buildStatDivider(context),
          _buildStatItem(
            '${rival['km']}',
            'Kilómetros',
            Icons.location_on_rounded,
            context,
          ),
          _buildStatDivider(context),
          _buildStatItem(
            '${rival['territories']}',
            'Territorios',
            Icons.flag_rounded,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    BuildContext context,
  ) {
    final c = context.colors;
    return Column(
      children: [
        Icon(icon, color: c.primaryDeepWithAlpha(0.7), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: c.textHint,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    final c = context.colors;
    return Container(width: 1, height: 40, color: c.primaryDeepWithAlpha(0.1));
  }

  Widget _buildConfrontationHistory(
    List<Map<String, dynamic>> confrontations,
    BuildContext context,
  ) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de Enfrentamientos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: confrontations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = confrontations[index];
            final won = item['won'] as bool;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: (won ? const Color(0xFF7ED957) : c.primaryDeep)
                      .withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (won
                          ? const Color(0xFF7ED957).withValues(alpha: 0.1)
                          : c.primaryDeepWithAlpha(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      won ? Icons.emoji_events_rounded : Icons.close_rounded,
                      color: won ? const Color(0xFF7ED957) : c.primaryDeep,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['territory'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        ),
                        Text(
                          item['date'] as String,
                          style: TextStyle(fontSize: 12, color: c.textHint),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        won ? 'Ganaste' : 'Perdiste',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: won ? const Color(0xFF7ED957) : c.primaryDeep,
                        ),
                      ),
                      Text(
                        'Ganó: ${item['winner']}',
                        style: TextStyle(fontSize: 11, color: c.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
