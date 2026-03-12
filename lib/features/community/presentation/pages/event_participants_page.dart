import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class EventParticipantsPage extends StatelessWidget {
  final String eventId;

  const EventParticipantsPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    // Mock participants data for the event
    final participants = [
      {'name': 'Carlos Ruiz', 'level': 'Corredor Experto', 'image': null},
      {'name': 'Ana López', 'level': 'Principiante', 'image': null},
      {'name': 'Miguel Torres', 'level': 'Intermedio', 'image': null},
      {'name': 'Elena Rojas', 'level': 'Triatleta', 'image': null},
      {'name': 'David Silva', 'level': 'Avanzado', 'image': null},
      {'name': 'Sofia Navarro', 'level': 'Principiante', 'image': null},
      {'name': 'Hugo Méndez', 'level': 'Intermedio', 'image': null},
      {'name': 'Laura Gómez', 'level': 'Corredor Experto', 'image': null},
      {'name': 'Diego Castro', 'level': 'Intermedio', 'image': null},
      {'name': 'Carmen Vega', 'level': 'Profesional', 'image': null},
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
          'Participantes',
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
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: participants.length,
        separatorBuilder: (context, index) => Divider(
          color: c.primaryDeepWithAlpha(0.05),
          height: 1,
          indent: 24,
          endIndent: 24,
        ),
        itemBuilder: (context, index) {
          final p = participants[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: c.primaryLight,
              child: Icon(Icons.person_rounded, color: c.primaryDeepWithAlpha(0.7)),
            ),
            title: Text(
              p['name'] as String,
              style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary),
            ),
            subtitle: Text(
              p['level'] as String,
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                context.pushNamed(
                  'participant_profile',
                  pathParameters: {
                    'eventId': eventId,
                    'userId': 'user_$index',
                  },
                  extra: p,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primaryDeepWithAlpha(0.1),
                foregroundColor: c.primaryDeep,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Ver perfil', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          );
        },
      ),
    );
  }
}
