class HomeStatsModel {
  final double distanciaTotalKm;
  final double tiempoTotalHoras;
  final int ritmoCardiacoPromedio;
  final int territoriosNuevos;
  final List<double> barrasDias;
  final double distanciaSemanaKm;
  final Map<String, String> tendencias;

  const HomeStatsModel({
    required this.distanciaTotalKm,
    required this.tiempoTotalHoras,
    required this.ritmoCardiacoPromedio,
    required this.territoriosNuevos,
    required this.barrasDias,
    required this.distanciaSemanaKm,
    required this.tendencias,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic> json) {
    return HomeStatsModel(
      distanciaTotalKm: (json['distancia_total_km'] as num?)?.toDouble() ?? 0.0,
      tiempoTotalHoras: (json['tiempo_total_horas'] as num?)?.toDouble() ?? 0.0,
      ritmoCardiacoPromedio: (json['ritmo_cardiaco_promedio'] as num?)?.toInt() ?? 0,
      territoriosNuevos: (json['territorios_nuevos'] as num?)?.toInt() ?? 0,
      barrasDias: (json['barras_dias'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0, 0, 0, 0, 0, 0, 0],
      distanciaSemanaKm: (json['distancia_semana_km'] as num?)?.toDouble() ?? 0.0,
      tendencias: Map<String, String>.from(json['tendencias'] ?? {}),
    );
  }
}
