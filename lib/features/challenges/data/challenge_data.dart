import 'package:flutter/material.dart';

class WeeklyChallenge {
  final String id;
  final String title;
  final String description;
  final double targetKm;
  final double currentKm;
  final String daysLeft;
  final String badge;
  final String badgeEmoji;
  final String period; // e.g. "Semana del 6 al 12 mar"
  final bool isActive;
  final List<DayStat> dailyStats;

  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetKm,
    required this.currentKm,
    required this.daysLeft,
    required this.badge,
    required this.badgeEmoji,
    required this.period,
    required this.isActive,
    required this.dailyStats,
  });

  double get progress => (currentKm / targetKm).clamp(0, 1);
  bool get completed => currentKm >= targetKm;
}

class DayStat {
  final String day;
  final double km;

  const DayStat({required this.day, required this.km});
}

/// Reto activo de la semana actual
final WeeklyChallenge activeWeeklyChallenge = WeeklyChallenge(
  id: 'wk_current',
  title: 'Corredor Imparable',
  description:
      'Corre 30 km esta semana y demuestra que eres un corredor de élite. '
      'Cada kilómetro cuenta para conseguir la Insignia de Resistencia.',
  targetKm: 30.0,
  currentKm: 18.5,
  daysLeft: '3 días',
  badge: 'Insignia de Resistencia',
  badgeEmoji: '🏅',
  period: 'Semana del 6 al 12 mar',
  isActive: true,
  dailyStats: [
    DayStat(day: 'Lun', km: 5.2),
    DayStat(day: 'Mar', km: 7.8),
    DayStat(day: 'Mié', km: 5.5),
    DayStat(day: 'Jue', km: 0.0),
    DayStat(day: 'Vie', km: 0.0),
    DayStat(day: 'Sáb', km: 0.0),
    DayStat(day: 'Dom', km: 0.0),
  ],
);

/// Historial de retos semanales pasados
final List<WeeklyChallenge> pastWeeklyChallenges = [
  WeeklyChallenge(
    id: 'wk_5',
    title: 'Maratonista de Élite',
    description: 'Corre 40 km en una semana.',
    targetKm: 40.0,
    currentKm: 40.0,
    daysLeft: '0 días',
    badge: 'Trofeo de Élite',
    badgeEmoji: '🏆',
    period: 'Semana del 27 feb al 5 mar',
    isActive: false,
    dailyStats: [
      DayStat(day: 'Lun', km: 6.0),
      DayStat(day: 'Mar', km: 8.0),
      DayStat(day: 'Mié', km: 5.0),
      DayStat(day: 'Jue', km: 7.5),
      DayStat(day: 'Vie', km: 4.5),
      DayStat(day: 'Sáb', km: 5.0),
      DayStat(day: 'Dom', km: 4.0),
    ],
  ),
  WeeklyChallenge(
    id: 'wk_4',
    title: 'Velocista Urbano',
    description: 'Completa 25 km en zonas urbanas esta semana.',
    targetKm: 25.0,
    currentKm: 22.3,
    daysLeft: '0 días',
    badge: 'Insignia Urbana',
    badgeEmoji: '🏙️',
    period: 'Semana del 20 al 26 feb',
    isActive: false,
    dailyStats: [
      DayStat(day: 'Lun', km: 4.0),
      DayStat(day: 'Mar', km: 6.3),
      DayStat(day: 'Mié', km: 3.5),
      DayStat(day: 'Jue', km: 5.0),
      DayStat(day: 'Vie', km: 3.5),
      DayStat(day: 'Sáb', km: 0.0),
      DayStat(day: 'Dom', km: 0.0),
    ],
  ),
  WeeklyChallenge(
    id: 'wk_3',
    title: 'Conquistador de Rutas',
    description: 'Explora 3 rutas diferentes esta semana.',
    targetKm: 20.0,
    currentKm: 20.0,
    daysLeft: '0 días',
    badge: 'Insignia Explorador',
    badgeEmoji: '🗺️',
    period: 'Semana del 13 al 19 feb',
    isActive: false,
    dailyStats: [
      DayStat(day: 'Lun', km: 5.0),
      DayStat(day: 'Mar', km: 0.0),
      DayStat(day: 'Mié', km: 7.0),
      DayStat(day: 'Jue', km: 0.0),
      DayStat(day: 'Vie', km: 8.0),
      DayStat(day: 'Sáb', km: 0.0),
      DayStat(day: 'Dom', km: 0.0),
    ],
  ),
  WeeklyChallenge(
    id: 'wk_2',
    title: 'Resistencia Total',
    description: 'Corre al menos 3 km cada día durante 5 días.',
    targetKm: 15.0,
    currentKm: 15.0,
    daysLeft: '0 días',
    badge: 'Insignia Constancia',
    badgeEmoji: '💪',
    period: 'Semana del 6 al 12 feb',
    isActive: false,
    dailyStats: [
      DayStat(day: 'Lun', km: 3.5),
      DayStat(day: 'Mar', km: 3.0),
      DayStat(day: 'Mié', km: 3.2),
      DayStat(day: 'Jue', km: 0.0),
      DayStat(day: 'Vie', km: 3.0),
      DayStat(day: 'Sáb', km: 2.3),
      DayStat(day: 'Dom', km: 0.0),
    ],
  ),
  WeeklyChallenge(
    id: 'wk_1',
    title: 'Primera Carrera',
    description: 'Completa tu primer reto semanal corriendo 10 km.',
    targetKm: 10.0,
    currentKm: 10.0,
    daysLeft: '0 días',
    badge: 'Insignia Debut',
    badgeEmoji: '⭐',
    period: 'Semana del 30 ene al 5 feb',
    isActive: false,
    dailyStats: [
      DayStat(day: 'Lun', km: 3.0),
      DayStat(day: 'Mar', km: 0.0),
      DayStat(day: 'Mié', km: 4.0),
      DayStat(day: 'Jue', km: 0.0),
      DayStat(day: 'Vie', km: 3.0),
      DayStat(day: 'Sáb', km: 0.0),
      DayStat(day: 'Dom', km: 0.0),
    ],
  ),
];

Color challengeStatusColor(WeeklyChallenge c) {
  if (c.completed) return const Color(0xFF7ED957);
  if (c.progress >= 0.5) return const Color(0xFFFFB84D);
  return const Color(0xFFE8698A);
}

String challengeStatusLabel(WeeklyChallenge c) {
  if (c.completed) return 'Completado ✓';
  if (c.progress >= 0.5) return 'En progreso';
  return 'No completado';
}

// ─────────────────────────────────────────────────────────────
// DESAFÍOS SEMANALES (tarjetas de la sección inferior)
// ─────────────────────────────────────────────────────────────

class ChallengeItem {
  final String id;
  final String title;
  final String description;
  final String fullDescription;
  final String reward;
  final bool done;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String difficulty;
  final String estimatedTime;
  final List<String> tips;

  const ChallengeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.fullDescription,
    required this.reward,
    required this.done,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.difficulty,
    required this.estimatedTime,
    required this.tips,
  });
}

final List<ChallengeItem> weeklyChallengeItems = [
  ChallengeItem(
    id: 'ch_1',
    title: 'Carrera matutina',
    description: 'Corre 5 km antes de las 9 AM',
    fullDescription:
        'Activa tu metabolismo y comienza el día con energía. '
        'Completa una carrera de 5 km antes de las 9:00 AM para ganar '
        'puntos de bonificación matutina. El ejercicio temprano mejora '
        'la concentración durante todo el día.',
    reward: '+50 pts',
    done: true,
    icon: Icons.directions_run_rounded,
    iconColor: const Color(0xFF3B82F6),
    iconBgColor: const Color(0xFFEFF6FF),
    difficulty: 'Fácil',
    estimatedTime: '25–35 min',
    tips: [
      'Hidratate bien antes de salir.',
      'Calienta 5 minutos de caminata.',
      'Mantén un ritmo conversacional.',
    ],
  ),
  ChallengeItem(
    id: 'ch_2',
    title: 'Conquista nueva zona',
    description: 'Visita un territorio que no sea tuyo',
    fullDescription:
        'Explora nuevos territorios en tu ciudad. Visita y recorre '
        'al menos un territorio que no esté asignado a tu perfil. '
        'Esta es tu oportunidad para expandir tu zona de influencia '
        'y ganar puntos de territorio.',
    reward: '+80 pts',
    done: false,
    icon: Icons.flag_rounded,
    iconColor: const Color(0xFF7ED957),
    iconBgColor: const Color(0xFFF4FDF0),
    difficulty: 'Moderado',
    estimatedTime: '40–60 min',
    tips: [
      'Revisa el mapa de territorios disponibles.',
      'Lleva agua extra si el territorio es lejano.',
      'Registra tu entrada al territorio vía GPS.',
    ],
  ),
  ChallengeItem(
    id: 'ch_3',
    title: 'Corre en grupo',
    description: 'Completa una ruta con al menos 1 amigo',
    fullDescription:
        'El running es más divertido en compañía. Invita a un amigo o '
        'compañero de la comunidad y completen juntos cualquier ruta '
        'de al menos 3 km. Los puntos se asignan a ambos participantes.',
    reward: '+60 pts',
    done: false,
    icon: Icons.people_rounded,
    iconColor: const Color(0xFFFFB84D),
    iconBgColor: const Color(0xFFFFF8F0),
    difficulty: 'Fácil',
    estimatedTime: '20–40 min',
    tips: [
      'Coordina el horario con anticipación.',
      'Ajusten el ritmo al participante más lento.',
      'Compartan la ruta por el chat de la comunidad.',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────
// CARRERAS DE LA COMUNIDAD
// ─────────────────────────────────────────────────────────────

class CommunityRace {
  final String id;
  final String name;
  final String creator;
  final String date;
  final int participants;
  final int distance;
  final Color color;
  final String location;
  final String description;
  final String startTime;
  final String meetingPoint;
  final List<String> requirements;
  final bool isEnrolled;

  const CommunityRace({
    required this.id,
    required this.name,
    required this.creator,
    required this.date,
    required this.participants,
    required this.distance,
    required this.color,
    required this.location,
    required this.description,
    required this.startTime,
    required this.meetingPoint,
    required this.requirements,
    required this.isEnrolled,
  });
}

final List<CommunityRace> communityRaces = [
  CommunityRace(
    id: 'r_1',
    name: '5K Matutino',
    creator: 'Runners Urbanos',
    date: '28 Mar',
    participants: 42,
    distance: 5,
    color: const Color(0xFF3B82F6),
    location: 'Parque La Carolina, Quito',
    description:
        'Una carrera matutina perfecta para todos los niveles. '
        'El recorrido pasa por las zonas más bonitas del parque y '
        'termina con un desayuno comunitario.',
    startTime: '7:00 AM',
    meetingPoint: 'Entrada norte del Parque La Carolina',
    requirements: [
      'Ropa deportiva cómoda',
      'Hidratación personal',
      'Inscripción previa en la app',
    ],
    isEnrolled: false,
  ),
  CommunityRace(
    id: 'r_2',
    name: 'Desafío 10K',
    creator: 'Trail Seekers',
    date: '2 Abr',
    participants: 67,
    distance: 10,
    color: const Color(0xFF7ED957),
    location: 'Ciclovía Av. Amazonas, Quito',
    description:
        'Un recorrido de 10 km por la icónica Avenida Amazonas, '
        'con paradas de hidratación cada 2.5 km. Ideal para corredores '
        'intermedios que quieran mejorar su marca personal.',
    startTime: '6:30 AM',
    meetingPoint: 'Intersección Amazonas y Naciones Unidas',
    requirements: [
      'Mínimo 3 meses de experiencia corriendo',
      'Completar al menos un reto semanal previo',
      'Inscripción previa en la app',
    ],
    isEnrolled: true,
  ),
  CommunityRace(
    id: 'r_3',
    name: 'Media Maratón',
    creator: 'Maratón Team',
    date: '10 Abr',
    participants: 128,
    distance: 21,
    color: const Color(0xFFFFB84D),
    location: 'Centro Histórico, Quito',
    description:
        'La media maratón más emocionante del año. Un recorrido panorámico '
        'de 21 km por el patrimonio histórico de Quito. Habrá premiación '
        'en categorías por edad y tiempo.',
    startTime: '6:00 AM',
    meetingPoint: 'Plaza Grande, Centro Histórico',
    requirements: [
      'Experiencia previa en carreras de 10K',
      'Estado físico evaluado (formulario en la app)',
      'Inscripción con mínimo 2 semanas de anticipación',
    ],
    isEnrolled: false,
  ),
];
