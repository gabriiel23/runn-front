import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class TerritoryData {
  final int id;
  final String name;
  final String status; // owned | contested | rival | unclaimed
  final int dominance;
  final int runs;
  final double distance;
  final String ownerName;
  final String imageUrl;
  final int threatLevel;
  final List<Map<String, String>> history;

  const TerritoryData({
    required this.id,
    required this.name,
    required this.status,
    required this.dominance,
    required this.runs,
    required this.distance,
    required this.ownerName,
    required this.imageUrl,
    required this.threatLevel,
    required this.history,
  });

  bool get isOwned => status == 'owned';
  bool get isContested => status == 'contested';
  bool get isRival => status == 'rival';

  String get statusLabel {
    switch (status) {
      case 'owned':
        return 'Mio';
      case 'contested':
        return 'En disputa';
      case 'rival':
        return 'Perdido';
      default:
        return 'Libre';
    }
  }

  String get detailStatusLabel {
    switch (status) {
      case 'owned':
        return 'ASEGURADO';
      case 'contested':
        return 'EN DISPUTA';
      case 'rival':
        return 'PERDIDO';
      default:
        return 'LIBRE';
    }
  }

  Color statusColor(BuildContext context) {
    switch (status) {
      case 'owned':
        return context.colors.primaryMid; // Mio = rosa
      case 'contested':
        return context.colors.primaryLight; // En disputa = celeste
      case 'rival':
        return context.colors.textSecondary; // Perdido = gris
      default:
        return context.colors.surface; // Libre = gris claro
    }
  }
}

final territoriesMock = [
  TerritoryData(
    id: 1,
    name: 'Parque de Mexico',
    status: 'contested',
    dominance: 65,
    runs: 12,
    distance: 5.2,
    ownerName: 'FastRunner 99',
    imageUrl:
        'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=1200&q=80',
    threatLevel: 3,
    history: [
      {
        'runner': 'Elena Runner',
        'time': 'Hace 15m',
        'km': '5.2km',
        'team': 'ROSA',
        'avatar':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      },
      {
        'runner': 'Marco Polo',
        'time': 'Hace 2h',
        'km': '8.1km',
        'team': 'AZUL',
        'avatar':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      },
    ],
  ),
  TerritoryData(
    id: 2,
    name: 'Corredor Reforma',
    status: 'contested',
    dominance: 42,
    runs: 8,
    distance: 4.4,
    ownerName: '@BlueStreak',
    imageUrl:
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1200&q=80',
    threatLevel: 2,
    history: [
      {
        'runner': 'Sofia',
        'time': 'Hace 40m',
        'km': '4.3km',
        'team': 'ROSA',
        'avatar':
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      },
      {
        'runner': 'Jorge',
        'time': 'Hace 4h',
        'km': '3.6km',
        'team': 'AZUL',
        'avatar':
            'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?auto=format&fit=crop&w=200&q=80',
      },
    ],
  ),
  TerritoryData(
    id: 3,
    name: 'Plaza de la Paz',
    status: 'unclaimed',
    dominance: 0,
    runs: 0,
    distance: 0,
    ownerName: 'Sin dueno',
    imageUrl:
        'https://images.unsplash.com/photo-1470770903676-69b98201ea1c?auto=format&fit=crop&w=1200&q=80',
    threatLevel: 1,
    history: [],
  ),
  TerritoryData(
    id: 4,
    name: 'Centro Historico',
    status: 'owned',
    dominance: 84,
    runs: 15,
    distance: 24.5,
    ownerName: 'Tu control',
    imageUrl:
        'https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1200&q=80',
    threatLevel: 1,
    history: [
      {
        'runner': 'Tu equipo',
        'time': 'Hace 1h',
        'km': '7.8km',
        'team': 'ROSA',
        'avatar':
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80',
      },
      {
        'runner': 'Carlos',
        'time': 'Hace 3h',
        'km': '6.1km',
        'team': 'AZUL',
        'avatar':
            'https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?auto=format&fit=crop&w=200&q=80',
      },
    ],
  ),
  TerritoryData(
    id: 5,
    name: 'Zona Norte',
    status: 'rival',
    dominance: 18,
    runs: 3,
    distance: 2.2,
    ownerName: 'Rival Azul',
    imageUrl:
        'https://images.unsplash.com/photo-1473773508845-188df298d2d1?auto=format&fit=crop&w=1200&q=80',
    threatLevel: 3,
    history: [
      {
        'runner': 'Rival Azul',
        'time': 'Hace 2h',
        'km': '4.4km',
        'team': 'AZUL',
        'avatar':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      },
    ],
  ),
];
