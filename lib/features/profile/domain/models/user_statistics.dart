class StatPoint {
  final String label;
  final double value;

  StatPoint({required this.label, required this.value});

  factory StatPoint.fromJson(Map<String, dynamic> json) {
    return StatPoint(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }
}

class UserStatistics {
  final String totalDistance;
  final String averageDistance;
  final String distanceGoal;
  final List<StatPoint> kmPoints;
  final List<StatPoint> speedPoints;
  final List<StatPoint> pacePoints;

  UserStatistics({
    required this.totalDistance,
    required this.averageDistance,
    required this.distanceGoal,
    required this.kmPoints,
    required this.speedPoints,
    required this.pacePoints,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalDistance: json['totalDistance'] as String,
      averageDistance: json['averageDistance'] as String,
      distanceGoal: json['distanceGoal'] as String,
      kmPoints: (json['kmPoints'] as List).map((e) => StatPoint.fromJson(e)).toList(),
      speedPoints: (json['speedPoints'] as List).map((e) => StatPoint.fromJson(e)).toList(),
      pacePoints: (json['pacePoints'] as List).map((e) => StatPoint.fromJson(e)).toList(),
    );
  }

  // Helper for mock data
  static UserStatistics get mock => UserStatistics(
    totalDistance: '442 km',
    averageDistance: '12.4 km',
    distanceGoal: '20.0 km',
    kmPoints: [
      StatPoint(label: 'L', value: 5),
      StatPoint(label: 'M', value: 8),
      StatPoint(label: 'M', value: 4),
      StatPoint(label: 'J', value: 10),
      StatPoint(label: 'V', value: 7),
      StatPoint(label: 'S', value: 12),
      StatPoint(label: 'D', value: 9),
    ],
    speedPoints: [
      StatPoint(label: 'L', value: 11),
      StatPoint(label: 'M', value: 12.5),
      StatPoint(label: 'M', value: 10),
      StatPoint(label: 'J', value: 13),
      StatPoint(label: 'V', value: 11.5),
      StatPoint(label: 'S', value: 14),
      StatPoint(label: 'D', value: 12),
    ],
    pacePoints: [
      StatPoint(label: 'L', value: 5.2),
      StatPoint(label: 'M', value: 4.8),
      StatPoint(label: 'M', value: 5.5),
      StatPoint(label: 'J', value: 4.5),
      StatPoint(label: 'V', value: 5.0),
      StatPoint(label: 'S', value: 4.2),
      StatPoint(label: 'D', value: 4.9),
    ],
  );
}
