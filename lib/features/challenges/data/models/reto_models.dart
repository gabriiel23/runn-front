// ─── HELPERS ─────────────────────────────────────────────────────────────────

double _parseNum(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int _parseInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

String _fechaFmt(String? iso) {
  if (iso == null) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];
  return '${dt.day} de ${meses[dt.month - 1]} de ${dt.year}';
}

String _fechaCorta(String? iso) {
  if (iso == null) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  const meses = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];
  return '${dt.day} de ${meses[dt.month - 1]}';
}

/// Formatea el objetivo según el tipo del reto.
String formatearObjetivo(String tipo, double valor, String unidad) {
  final valorStr = valor == valor.truncate()
      ? valor.toInt().toString()
      : valor.toStringAsFixed(1);
  switch (tipo) {
    case 'distancia':
      return 'Corre $valorStr $unidad';
    case 'tiempo':
      return 'Corre durante $valorStr $unidad';
    case 'velocidad':
      return 'Mantén una velocidad de $valorStr $unidad';
    case 'calorias':
      return 'Quema $valorStr $unidad';
    default:
      return '$valorStr $unidad';
  }
}

/// Devuelve la unidad automática según el tipo.
String unidadParaTipo(String tipo) {
  switch (tipo) {
    case 'distancia':
      return 'km';
    case 'tiempo':
      return 'minutos';
    case 'velocidad':
      return 'km/h';
    case 'calorias':
      return 'cal';
    default:
      return '';
  }
}

// ─── RETO DIARIO ─────────────────────────────────────────────────────────────

class RetoDiario {
  final String id;
  final String titulo;
  final String? descripcion;
  final String tipo;
  final double valorObjetivo;
  final String unidad;
  final int puntosRecompensa;
  final String fecha;
  final bool generadoPorIA;

  const RetoDiario({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.tipo,
    required this.valorObjetivo,
    required this.unidad,
    required this.puntosRecompensa,
    required this.fecha,
    required this.generadoPorIA,
  });

  factory RetoDiario.fromJson(Map<String, dynamic> j) {
    return RetoDiario(
      id: j['id']?.toString() ?? '',
      titulo: j['titulo']?.toString() ?? '',
      descripcion: j['descripcion']?.toString(),
      tipo: j['tipo']?.toString() ?? 'distancia',
      valorObjetivo: _parseNum(j['valor_objetivo']),
      unidad: j['unidad']?.toString() ?? '',
      puntosRecompensa: _parseInt(j['puntos_recompensa']),
      fecha: j['fecha']?.toString() ?? '',
      generadoPorIA: j['generado_por_ia'] == true,
    );
  }

  String get objetivoFormateado => formatearObjetivo(tipo, valorObjetivo, unidad);
}

// ─── RETO SEMANAL ─────────────────────────────────────────────────────────────

class RetoSemanal {
  final String id;
  final String titulo;
  final String? descripcion;
  final String tipo;
  final double valorObjetivo;
  final String unidad;
  final int puntosRecompensa;
  final String semanaInicio;
  final String semanaFin;
  final bool generadoPorIA;

  const RetoSemanal({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.tipo,
    required this.valorObjetivo,
    required this.unidad,
    required this.puntosRecompensa,
    required this.semanaInicio,
    required this.semanaFin,
    required this.generadoPorIA,
  });

  factory RetoSemanal.fromJson(Map<String, dynamic> j) {
    return RetoSemanal(
      id: j['id']?.toString() ?? '',
      titulo: j['titulo']?.toString() ?? '',
      descripcion: j['descripcion']?.toString(),
      tipo: j['tipo']?.toString() ?? 'distancia',
      valorObjetivo: _parseNum(j['valor_objetivo']),
      unidad: j['unidad']?.toString() ?? '',
      puntosRecompensa: _parseInt(j['puntos_recompensa']),
      semanaInicio: j['semana_inicio']?.toString() ?? '',
      semanaFin: j['semana_fin']?.toString() ?? '',
      generadoPorIA: j['generado_por_ia'] == true,
    );
  }

  String get objetivoFormateado => formatearObjetivo(tipo, valorObjetivo, unidad);

  String get periodoFormateado {
    final ini = _fechaCorta(semanaInicio);
    final fin = _fechaCorta(semanaFin);
    return '$ini — $fin';
  }
}

// ─── PARTICIPACIÓN ────────────────────────────────────────────────────────────

class RetoParticipacion {
  final bool completado;
  final double progresoActual;
  final String? completadoEn;

  const RetoParticipacion({
    required this.completado,
    required this.progresoActual,
    this.completadoEn,
  });

  factory RetoParticipacion.fromJson(Map<String, dynamic> j) {
    return RetoParticipacion(
      completado: j['completado'] == true,
      progresoActual: _parseNum(j['progreso_actual']),
      completadoEn: j['completado_en']?.toString(),
    );
  }

  factory RetoParticipacion.empty() {
    return const RetoParticipacion(completado: false, progresoActual: 0);
  }
}

// ─── COMBINADOS ───────────────────────────────────────────────────────────────

class RetoDiarioConParticipacion {
  final RetoDiario reto;
  final RetoParticipacion participacion;

  const RetoDiarioConParticipacion({
    required this.reto,
    required this.participacion,
  });

  factory RetoDiarioConParticipacion.fromJson(Map<String, dynamic> j) {
    return RetoDiarioConParticipacion(
      reto: RetoDiario.fromJson(j['reto'] as Map<String, dynamic>),
      participacion: j['participacion'] != null
          ? RetoParticipacion.fromJson(j['participacion'] as Map<String, dynamic>)
          : RetoParticipacion.empty(),
    );
  }
}

class RetoSemanalConParticipacion {
  final RetoSemanal reto;
  final RetoParticipacion participacion;

  const RetoSemanalConParticipacion({
    required this.reto,
    required this.participacion,
  });

  factory RetoSemanalConParticipacion.fromJson(Map<String, dynamic> j) {
    return RetoSemanalConParticipacion(
      reto: RetoSemanal.fromJson(j['reto'] as Map<String, dynamic>),
      participacion: j['participacion'] != null
          ? RetoParticipacion.fromJson(j['participacion'] as Map<String, dynamic>)
          : RetoParticipacion.empty(),
    );
  }
}

// ─── HISTORIAL ────────────────────────────────────────────────────────────────

class HistorialRetoDiario {
  final bool completado;
  final double progresoActual;
  final String? completadoEn;
  final String titulo;
  final String tipo;
  final double valorObjetivo;
  final String unidad;
  final String? fecha;
  final int puntosRecompensa;

  const HistorialRetoDiario({
    required this.completado,
    required this.progresoActual,
    this.completadoEn,
    required this.titulo,
    required this.tipo,
    required this.valorObjetivo,
    required this.unidad,
    this.fecha,
    required this.puntosRecompensa,
  });

  factory HistorialRetoDiario.fromJson(Map<String, dynamic> j) {
    final rd = j['retos_diarios'] as Map<String, dynamic>? ?? {};
    return HistorialRetoDiario(
      completado: j['completado'] == true,
      progresoActual: _parseNum(j['progreso_actual']),
      completadoEn: j['completado_en']?.toString(),
      titulo: rd['titulo']?.toString() ?? '',
      tipo: rd['tipo']?.toString() ?? '',
      valorObjetivo: _parseNum(rd['valor_objetivo']),
      unidad: rd['unidad']?.toString() ?? '',
      fecha: rd['fecha']?.toString(),
      puntosRecompensa: _parseInt(rd['puntos_recompensa']),
    );
  }

  String get fechaFmt => _fechaFmt(fecha);
}

class HistorialRetoSemanal {
  final bool completado;
  final double progresoActual;
  final String? completadoEn;
  final String titulo;
  final String tipo;
  final double valorObjetivo;
  final String unidad;
  final String? semanaInicio;
  final String? semanaFin;
  final int puntosRecompensa;

  const HistorialRetoSemanal({
    required this.completado,
    required this.progresoActual,
    this.completadoEn,
    required this.titulo,
    required this.tipo,
    required this.valorObjetivo,
    required this.unidad,
    this.semanaInicio,
    this.semanaFin,
    required this.puntosRecompensa,
  });

  factory HistorialRetoSemanal.fromJson(Map<String, dynamic> j) {
    final rs = j['retos_semanales'] as Map<String, dynamic>? ?? {};
    return HistorialRetoSemanal(
      completado: j['completado'] == true,
      progresoActual: _parseNum(j['progreso_actual']),
      completadoEn: j['completado_en']?.toString(),
      titulo: rs['titulo']?.toString() ?? '',
      tipo: rs['tipo']?.toString() ?? '',
      valorObjetivo: _parseNum(rs['valor_objetivo']),
      unidad: rs['unidad']?.toString() ?? '',
      semanaInicio: rs['semana_inicio']?.toString(),
      semanaFin: rs['semana_fin']?.toString(),
      puntosRecompensa: _parseInt(rs['puntos_recompensa']),
    );
  }

  String get periodoFmt {
    final ini = _fechaCorta(semanaInicio);
    final fin = _fechaCorta(semanaFin);
    if (ini.isEmpty && fin.isEmpty) return '';
    return '$ini — $fin';
  }
}

// ─── INSIGNIAS ────────────────────────────────────────────────────────────────

class InsigniaDistancia {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? iconoUrl;
  final double kmRequeridos;
  final String nivel;
  final bool desbloqueada;
  final String? ganadoEn;
  final double progreso; // 0-100

  const InsigniaDistancia({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.iconoUrl,
    required this.kmRequeridos,
    required this.nivel,
    required this.desbloqueada,
    this.ganadoEn,
    required this.progreso,
  });

  factory InsigniaDistancia.fromJson(Map<String, dynamic> j) {
    return InsigniaDistancia(
      id: j['id']?.toString() ?? '',
      nombre: j['nombre']?.toString() ?? '',
      descripcion: j['descripcion']?.toString(),
      iconoUrl: j['icono_url']?.toString(),
      kmRequeridos: _parseNum(j['km_requeridos']),
      nivel: j['nivel']?.toString() ?? 'normal',
      desbloqueada: j['desbloqueada'] == true,
      ganadoEn: j['ganado_en']?.toString(),
      progreso: _parseNum(j['progreso']),
    );
  }

  String get ganadoEnFmt => _fechaFmt(ganadoEn);

  String get kmFaltantes {
    final faltan = kmRequeridos - (kmRequeridos * progreso / 100);
    return faltan <= 0 ? '0 km' : '${faltan.toStringAsFixed(1)} km';
  }
}

class InsigniasResponse {
  final double kmTotales;
  final List<InsigniaDistancia> insignias;

  const InsigniasResponse({required this.kmTotales, required this.insignias});

  factory InsigniasResponse.fromJson(Map<String, dynamic> j) {
    final list = (j['insignias'] as List<dynamic>? ?? [])
        .map((e) => InsigniaDistancia.fromJson(e as Map<String, dynamic>))
        .toList();
    return InsigniasResponse(
      kmTotales: _parseNum(j['km_totales']),
      insignias: list,
    );
  }
}

// ─── RACHA ────────────────────────────────────────────────────────────────────

class ProximoNivel {
  final String nivel;
  final int semanasNecesarias;
  final int semanasRestantes;

  const ProximoNivel({
    required this.nivel,
    required this.semanasNecesarias,
    required this.semanasRestantes,
  });

  factory ProximoNivel.fromJson(Map<String, dynamic> j) {
    return ProximoNivel(
      nivel: j['nivel']?.toString() ?? '',
      semanasNecesarias: _parseInt(j['semanas_necesarias']),
      semanasRestantes: _parseInt(j['semanas_restantes']),
    );
  }
}

class RachaModel {
  final int rachaActual;
  final int rachaMaxima;
  final String nivelActual;
  final int semanasAcumuladas;
  final String? ultimaSemanaCompletada;
  final ProximoNivel? proximoNivel;

  const RachaModel({
    required this.rachaActual,
    required this.rachaMaxima,
    required this.nivelActual,
    required this.semanasAcumuladas,
    this.ultimaSemanaCompletada,
    this.proximoNivel,
  });

  factory RachaModel.fromJson(Map<String, dynamic> j) {
    return RachaModel(
      rachaActual: _parseInt(j['racha_actual']),
      rachaMaxima: _parseInt(j['racha_maxima']),
      nivelActual: j['nivel_actual']?.toString() ?? 'sin_nivel',
      semanasAcumuladas: _parseInt(j['semanas_acumuladas']),
      ultimaSemanaCompletada: j['ultima_semana_completada']?.toString(),
      proximoNivel: j['proximo_nivel'] != null
          ? ProximoNivel.fromJson(j['proximo_nivel'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ─── LOGROS POST-CARRERA ──────────────────────────────────────────────────────

class LogroInsignia {
  final String nombre;
  final String? descripcion;
  final String nivel;

  const LogroInsignia({
    required this.nombre,
    this.descripcion,
    required this.nivel,
  });

  factory LogroInsignia.fromJson(Map<String, dynamic> j) {
    return LogroInsignia(
      nombre: j['nombre']?.toString() ?? '',
      descripcion: j['descripcion']?.toString(),
      nivel: j['nivel']?.toString() ?? 'normal',
    );
  }
}

class LogroReto {
  final String titulo;
  final int puntosRecompensa;
  final bool completado;
  final double progreso;

  const LogroReto({
    required this.titulo,
    required this.puntosRecompensa,
    required this.completado,
    required this.progreso,
  });

  factory LogroReto.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return const LogroReto(titulo: '', puntosRecompensa: 0, completado: false, progreso: 0);
    }
    final reto = j['reto'] as Map<String, dynamic>? ?? {};
    return LogroReto(
      titulo: reto['titulo']?.toString() ?? '',
      puntosRecompensa: _parseInt(reto['puntos_recompensa']),
      completado: j['completado'] == true,
      progreso: _parseNum(j['progreso']),
    );
  }
}

class LogrosCarrera {
  final List<LogroInsignia> nuevasInsignias;
  final LogroReto retoDiario;
  final LogroReto retoSemanal;

  const LogrosCarrera({
    required this.nuevasInsignias,
    required this.retoDiario,
    required this.retoSemanal,
  });

  factory LogrosCarrera.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return LogrosCarrera(
        nuevasInsignias: [],
        retoDiario: LogroReto.fromJson(null),
        retoSemanal: LogroReto.fromJson(null),
      );
    }
    final insignias = (j['nuevas_insignias'] as List<dynamic>? ?? [])
        .map((e) => LogroInsignia.fromJson(e as Map<String, dynamic>))
        .toList();
    return LogrosCarrera(
      nuevasInsignias: insignias,
      retoDiario: LogroReto.fromJson(j['reto_diario'] as Map<String, dynamic>?),
      retoSemanal: LogroReto.fromJson(j['reto_semanal'] as Map<String, dynamic>?),
    );
  }

  bool get tieneLogros =>
      nuevasInsignias.isNotEmpty ||
      retoDiario.completado ||
      retoSemanal.completado;

  int get totalPuntosLogros {
    int total = 0;
    if (retoDiario.completado) total += retoDiario.puntosRecompensa;
    if (retoSemanal.completado) total += retoSemanal.puntosRecompensa;
    return total;
  }
}
