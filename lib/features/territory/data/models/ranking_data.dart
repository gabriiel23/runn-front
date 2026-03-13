import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

class RankedRunner {
  final String id;
  final String name;
  final String handle;
  final String avatarUrl;
  final int territoriesOwned;
  final int totalKm;
  final String avgHoldTime; // e.g. "12 días"
  final int level;
  final String location;
  final Color accentColor;
  final List<RunnerTerritory> territories;

  const RankedRunner({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.territoriesOwned,
    required this.totalKm,
    required this.avgHoldTime,
    required this.level,
    required this.location,
    required this.accentColor,
    required this.territories,
  });
}

class RunnerTerritory {
  final String name;
  final String heldSince; // "Hace 3 días"
  final int dominance; // 0-100
  final double km;
  final String status; // owned | contested

  const RunnerTerritory({
    required this.name,
    required this.heldSince,
    required this.dominance,
    required this.km,
    required this.status,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────────────────────────────────────

final List<RankedRunner> territoryRankingMock = [
  RankedRunner(
    id: 'r1',
    name: 'FastRunner 99',
    handle: '@fastrunner99',
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
    territoriesOwned: 18,
    totalKm: 487,
    avgHoldTime: '14 días',
    level: 24,
    location: 'Quito, EC',
    accentColor: const Color(0xFF3B82F6),
    territories: [
      RunnerTerritory(
        name: 'Parque Jipiro',
        heldSince: 'Hace 3 días',
        dominance: 92,
        km: 5.2,
        status: 'owned',
      ),
      RunnerTerritory(
        name: 'Av. Universitaria',
        heldSince: 'Hace 8 días',
        dominance: 78,
        km: 3.8,
        status: 'owned',
      ),
      RunnerTerritory(
        name: 'Ciclovía Norte',
        heldSince: 'Hace 1 día',
        dominance: 55,
        km: 6.1,
        status: 'contested',
      ),
      RunnerTerritory(
        name: 'Boulevard Sur',
        heldSince: 'Hace 12 días',
        dominance: 88,
        km: 4.4,
        status: 'owned',
      ),
      RunnerTerritory(
        name: 'Parque Verde',
        heldSince: 'Hace 5 días',
        dominance: 71,
        km: 2.9,
        status: 'owned',
      ),
    ],
  ),
  RankedRunner(
    id: 'r2',
    name: 'Elena Runner',
    handle: '@elenarunner',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
    territoriesOwned: 15,
    totalKm: 412,
    avgHoldTime: '9 días',
    level: 20,
    location: 'Loja, EC',
    accentColor: const Color(0xFFE8698A),
    territories: [
      RunnerTerritory(
        name: 'Zona Sur',
        heldSince: 'Hace 6 días',
        dominance: 82,
        km: 4.6,
        status: 'owned',
      ),
      RunnerTerritory(
        name: 'Parque La Tebaida',
        heldSince: 'Hace 2 días',
        dominance: 64,
        km: 3.2,
        status: 'contested',
      ),
      RunnerTerritory(
        name: 'Malecón Central',
        heldSince: 'Hace 11 días',
        dominance: 90,
        km: 7.5,
        status: 'owned',
      ),
      RunnerTerritory(
        name: 'Colina Roja',
        heldSince: 'Hace 4 días',
        dominance: 77,
        km: 5.1,
        status: 'owned',
      ),
    ],
  ),
  RankedRunner(
    id: 'r3',
    name: 'Alex Runner',
    handle: '@alexrunner',
    avatarUrl: '',
    territoriesOwned: 12,
    totalKm: 352,
    avgHoldTime: '11 días',
    level: 10,
    location: 'Loja, EC',
    accentColor: const Color(0xFF7ED957),
    territories: [
      RunnerTerritory(
        name: 'Zona Norte',
        heldSince: 'Hace 15 días',
        dominance: 84,
        km: 24.5,
        status: 'owned',
      ),
      RunnerTerritory(
        name: 'Barrio Nuevo',
        heldSince: 'Hace 7 días',
        dominance: 69,
        km: 3.3,
        status: 'owned',
      ),
      RunnerTerritory(
        name: 'Represa',
        heldSince: 'Hace 3 días',
        dominance: 45,
        km: 4.0,
        status: 'contested',
      ),
    ],
  ),
  RankedRunner(
    id: 'r4',
    name: 'Marco Polo',
    handle: '@marcopolo_run',
    avatarUrl:
        'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?auto=format&fit=crop&w=200&q=80',
    territoriesOwned: 10,
    totalKm: 298,
    avgHoldTime: '6 días',
    level: 15,
    location: 'Cuenca, EC',
    accentColor: const Color(0xFF9B51E0),
    territories: [
      RunnerTerritory(
        name: 'Centro Histórico',
        heldSince: 'Hace 9 días',
        dominance: 73,
        km: 5.8,
        status: 'owned',
      ),
      RunnerTerritory(
        name: 'Río Tomebamba',
        heldSince: 'Hace 2 días',
        dominance: 52,
        km: 6.4,
        status: 'contested',
      ),
    ],
  ),
  RankedRunner(
    id: 'r5',
    name: 'BlueStreak',
    handle: '@bluestreak',
    avatarUrl:
        'https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?auto=format&fit=crop&w=200&q=80',
    territoriesOwned: 8,
    totalKm: 241,
    avgHoldTime: '7 días',
    level: 12,
    location: 'Guayaquil, EC',
    accentColor: const Color(0xFF56CCF2),
    territories: [
      RunnerTerritory(
        name: 'Parque Guayaquil',
        heldSince: 'Hace 4 días',
        dominance: 66,
        km: 4.1,
        status: 'owned',
      ),
      RunnerTerritory(
        name: 'Malecón 2000',
        heldSince: 'Hace 10 días',
        dominance: 80,
        km: 5.0,
        status: 'owned',
      ),
    ],
  ),
  RankedRunner(
    id: 'r6',
    name: 'Sofia Sprint',
    handle: '@sofiasprint',
    avatarUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
    territoriesOwned: 7,
    totalKm: 198,
    avgHoldTime: '5 días',
    level: 9,
    location: 'Ambato, EC',
    accentColor: const Color(0xFFFFB84D),
    territories: [
      RunnerTerritory(
        name: 'Parque Ambato',
        heldSince: 'Hace 5 días',
        dominance: 59,
        km: 3.7,
        status: 'owned',
      ),
    ],
  ),
  RankedRunner(
    id: 'r7',
    name: 'Rival Azul',
    handle: '@rivalazul',
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
    territoriesOwned: 6,
    totalKm: 175,
    avgHoldTime: '4 días',
    level: 8,
    location: 'Manta, EC',
    accentColor: const Color(0xFF3B82F6),
    territories: [
      RunnerTerritory(
        name: 'Zona Sur',
        heldSince: 'Hace 2 días',
        dominance: 18,
        km: 2.2,
        status: 'contested',
      ),
    ],
  ),
  RankedRunner(
    id: 'r8',
    name: 'Jorge Sprint',
    handle: '@jorgesprint',
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
    territoriesOwned: 5,
    totalKm: 143,
    avgHoldTime: '3 días',
    level: 7,
    location: 'Riobamba, EC',
    accentColor: const Color(0xFF7ED957),
    territories: [],
  ),
  RankedRunner(
    id: 'r9',
    name: 'Carlos V',
    handle: '@carlosv',
    avatarUrl:
        'https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?auto=format&fit=crop&w=200&q=80',
    territoriesOwned: 4,
    totalKm: 118,
    avgHoldTime: '2 días',
    level: 6,
    location: 'Ibarra, EC',
    accentColor: const Color(0xFFE8698A),
    territories: [],
  ),
  RankedRunner(
    id: 'r10',
    name: 'Tu equipo',
    handle: '@tuequipo',
    avatarUrl:
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80',
    territoriesOwned: 3,
    totalKm: 89,
    avgHoldTime: '2 días',
    level: 5,
    location: 'Lago Agrio, EC',
    accentColor: const Color(0x009B51E0),
    territories: [],
  ),
];
