import 'package:runn_front/features/challenges/data/models/reto_models.dart';

// ─── INICIO DE ACTIVIDAD ──────────────────────────────────────────────────────

class ActividadInicio {
  final String id;
  final DateTime horaInicio;

  const ActividadInicio({required this.id, required this.horaInicio});

  factory ActividadInicio.fromJson(Map<String, dynamic> json) {
    return ActividadInicio(
      id: json['actividad_id']?.toString() ?? '',
      horaInicio:
          DateTime.tryParse(json['hora_inicio']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

// ─── RESUMEN DE ACTIVIDAD ─────────────────────────────────────────────────────

class ActividadResumen {
  final String actividadId;
  final double distanciaKm;
  final int duracionSegs;
  final String duracionFormateada;
  final double velocidadPromedio;
  final double velocidadMax;
  final double ritmoPromedio;
  final int calorias;
  final int puntosGanados;
  final DateTime horaInicio;
  final DateTime horaFin;
  final LogrosCarrera? logros;

  const ActividadResumen({
    required this.actividadId,
    required this.distanciaKm,
    required this.duracionSegs,
    required this.duracionFormateada,
    required this.velocidadPromedio,
    required this.velocidadMax,
    required this.ritmoPromedio,
    required this.calorias,
    required this.puntosGanados,
    required this.horaInicio,
    required this.horaFin,
    this.logros,
  });

  factory ActividadResumen.fromApiResponse({
    required String actividadId,
    required Map<String, dynamic> resumen,
    required Map<String, dynamic> actividad,
    required int puntosGanados,
    Map<String, dynamic>? logros,
  }) {
    return ActividadResumen(
      actividadId: actividadId,
      distanciaKm: (resumen['distancia_km'] as num?)?.toDouble() ?? 0,
      duracionSegs: (resumen['duracion_segs'] as num?)?.toInt() ?? 0,
      duracionFormateada:
          resumen['duracion_formateada']?.toString() ?? '00:00:00',
      velocidadPromedio:
          (resumen['velocidad_promedio'] as num?)?.toDouble() ?? 0,
      velocidadMax: (resumen['velocidad_max'] as num?)?.toDouble() ?? 0,
      ritmoPromedio: (resumen['ritmo_promedio'] as num?)?.toDouble() ?? 0,
      calorias: (resumen['calorias'] as num?)?.toInt() ?? 0,
      puntosGanados: (puntosGanados as num?)?.toInt() ?? 0,
      horaInicio:
          DateTime.tryParse(actividad['hora_inicio']?.toString() ?? '') ??
          DateTime.now(),
      horaFin:
          DateTime.tryParse(actividad['hora_fin']?.toString() ?? '') ??
          DateTime.now(),
      logros: logros != null ? LogrosCarrera.fromJson(logros) : null,
    );
  }
}

// ─── HISTORIAL DE ACTIVIDADES ───────────────────────────────────────────────────

class ActividadHistorial {
  final String id;
  final String tipo;
  final String modalidad;
  final DateTime fecha;
  final DateTime? horaInicio;
  final DateTime? horaFin;
  final double distanciaKm;
  final int duracionSegs;
  final String duracionFormateada;
  final double velocidadPromedio;
  final double? velocidadMax;
  final double ritmoPromedio;
  final int? calorias;
  final double? elevacionGanadaM;
  final int? pasos;
  final int? frecuenciaCardiacaPromedio;
  final int puntosGanados;
  final String? fotoUrl;
  final bool compartida;
  final List<Map<String, double>>? puntosRuta;

  const ActividadHistorial({
    required this.id,
    required this.tipo,
    required this.modalidad,
    required this.fecha,
    this.horaInicio,
    this.horaFin,
    required this.distanciaKm,
    required this.duracionSegs,
    required this.duracionFormateada,
    required this.velocidadPromedio,
    this.velocidadMax,
    required this.ritmoPromedio,
    this.calorias,
    this.elevacionGanadaM,
    this.pasos,
    this.frecuenciaCardiacaPromedio,
    required this.puntosGanados,
    this.fotoUrl,
    required this.compartida,
    this.puntosRuta,
  });

  factory ActividadHistorial.fromJson(Map<String, dynamic> json) {
    // Helper para parsear campos Decimal de Prisma (vienen como String o num)
    double parseDecimal(dynamic v, [double fallback = 0.0]) {
      if (v == null) return fallback;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? fallback;
    }
    double? parseDecimalNullable(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    List<Map<String, double>>? puntosRutaParsed;
    if (json['puntos_ruta'] != null && json['puntos_ruta'] is List) {
      puntosRutaParsed = (json['puntos_ruta'] as List).map((p) {
        return {
          'lat': (p['lat'] as num).toDouble(),
          'lng': (p['lng'] as num).toDouble(),
        };
      }).toList();
    }

    return ActividadHistorial(
      id: json['id']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      modalidad: json['modalidad']?.toString() ?? '',
      fecha: DateTime.tryParse(json['fecha']?.toString() ?? '') ?? DateTime.now(),
      horaInicio: json['hora_inicio'] != null ? DateTime.tryParse(json['hora_inicio'].toString()) : null,
      horaFin: json['hora_fin'] != null ? DateTime.tryParse(json['hora_fin'].toString()) : null,
      distanciaKm: parseDecimal(json['distancia_km']),
      duracionSegs: (json['duracion_segs'] as num?)?.toInt() ?? 0,
      duracionFormateada: json['duracion_formateada']?.toString() ?? '00:00:00',
      velocidadPromedio: parseDecimal(json['velocidad_promedio']),
      velocidadMax: parseDecimalNullable(json['velocidad_max']),
      ritmoPromedio: parseDecimal(json['ritmo_promedio']),
      calorias: (json['calorias'] as num?)?.toInt(),
      elevacionGanadaM: parseDecimalNullable(json['elevacion_ganada_m']),
      pasos: (json['pasos'] as num?)?.toInt(),
      frecuenciaCardiacaPromedio: (json['frecuencia_cardiaca_promedio'] as num?)?.toInt(),
      puntosGanados: (json['puntos_ganados'] as num?)?.toInt() ?? 0,
      fotoUrl: json['foto_url']?.toString(),
      compartida: json['compartida'] == true,
      puntosRuta: puntosRutaParsed,
    );
  }
}

// ─── ESTADÍSTICAS GENERALES ───────────────────────────────────────────────────

class ActividadEstadisticas {
  final int totalCarreras;
  final double distanciaTotalKm;
  final String tiempoTotalFormateado;
  final double velocidadPromedioGeneral;
  final double ritmoPromedioGeneral;
  final int caloriasTotales;
  final Map<String, dynamic>? mejorCarrera;
  final Map<String, int> porTipo;

  const ActividadEstadisticas({
    required this.totalCarreras,
    required this.distanciaTotalKm,
    required this.tiempoTotalFormateado,
    required this.velocidadPromedioGeneral,
    required this.ritmoPromedioGeneral,
    required this.caloriasTotales,
    this.mejorCarrera,
    required this.porTipo,
  });

  factory ActividadEstadisticas.fromJson(Map<String, dynamic> json) {
    return ActividadEstadisticas(
      totalCarreras: (json['total_carreras'] as num?)?.toInt() ?? 0,
      distanciaTotalKm: (json['distancia_total_km'] as num?)?.toDouble() ?? 0.0,
      tiempoTotalFormateado: json['tiempo_total_formateado']?.toString() ?? '00:00:00',
      velocidadPromedioGeneral: (json['velocidad_promedio_general'] as num?)?.toDouble() ?? 0.0,
      ritmoPromedioGeneral: (json['ritmo_promedio_general'] as num?)?.toDouble() ?? 0.0,
      caloriasTotales: (json['calorias_totales'] as num?)?.toInt() ?? 0,
      mejorCarrera: json['mejor_carrera'] as Map<String, dynamic>?,
      porTipo: {
        'correr': (json['por_tipo']?['correr'] as num?)?.toInt() ?? 0,
        'senderismo': (json['por_tipo']?['senderismo'] as num?)?.toInt() ?? 0,
      },
    );
  }
}
