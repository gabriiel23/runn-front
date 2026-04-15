/// Modelos del dominio de Eventos.
/// Cubre listado, detalle y participantes.
library;

// ─── PARTICIPANTE ─────────────────────────────────────────────────────────────

class ParticipanteModel {
  final String id;
  final String nombre;
  final String? avatarUrl;
  final String? ciudad;
  final String? nivel;

  const ParticipanteModel({
    required this.id,
    required this.nombre,
    this.avatarUrl,
    this.ciudad,
    this.nivel,
  });

  factory ParticipanteModel.fromJson(Map<String, dynamic> json) {
    return ParticipanteModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      ciudad: json['ciudad']?.toString(),
      nivel: json['nivel']?.toString(),
    );
  }
}

// ─── EVENTO (listado) ─────────────────────────────────────────────────────────

class EventoModel {
  final String id;
  final String titulo;
  final String? descripcion;
  final DateTime? fecha;
  final DateTime? hora;
  final String? lugar;
  final String? distanciaKm;
  final String? fotoUrl;
  final String? rutaSugerida;
  final int participantes;

  // Nuevos campos
  final bool esPago;
  final double precio;
  final int? limiteParticipantes;
  final int? limiteListaEspera;
  final List<dynamic>? waypoints;
  final Map<String, dynamic>? puntoInicio;
  final Map<String, dynamic>? puntoFin;
  final int participantesConfirmados;
  final int enListaEspera;
  final int? cupoDisponible;

  const EventoModel({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.fecha,
    this.hora,
    this.lugar,
    this.distanciaKm,
    this.fotoUrl,
    this.rutaSugerida,
    required this.participantes,
    this.esPago = false,
    this.precio = 0.0,
    this.limiteParticipantes,
    this.limiteListaEspera,
    this.waypoints,
    this.puntoInicio,
    this.puntoFin,
    this.participantesConfirmados = 0,
    this.enListaEspera = 0,
    this.cupoDisponible,
  });

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    return EventoModel(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      fecha: _parseDate(json['fecha']),
      hora: _parseDate(json['hora']),
      lugar: json['lugar']?.toString(),
      distanciaKm: json['distancia_km']?.toString(),
      fotoUrl: json['foto_url']?.toString(),
      rutaSugerida: json['ruta_sugerida']?.toString(),
      participantes: int.tryParse(json['participantes']?.toString() ?? '') ?? 0,
      esPago: json['es_pago'] == true || json['es_pago'] == 'true',
      precio: double.tryParse(json['precio']?.toString() ?? '') ?? 0.0,
      limiteParticipantes: int.tryParse(json['limite_participantes']?.toString() ?? ''),
      limiteListaEspera: int.tryParse(json['limite_lista_espera']?.toString() ?? ''),
      waypoints: json['waypoints'] as List<dynamic>?,
      puntoInicio: json['punto_inicio'] as Map<String, dynamic>?,
      puntoFin: json['punto_fin'] as Map<String, dynamic>?,
      participantesConfirmados: int.tryParse(json['participantes_confirmados']?.toString() ?? '') ?? 0,
      enListaEspera: int.tryParse(json['en_lista_espera']?.toString() ?? '') ?? 0,
      cupoDisponible: int.tryParse(json['cupo_disponible']?.toString() ?? ''),
    );
  }

  /// Retorna la fecha formateada: "20 de Abril de 2026"
  String get fechaFormateada {
    if (fecha == null) return 'Fecha por definir';
    const meses = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${fecha!.day} de ${meses[fecha!.month]} de ${fecha!.year}';
  }

  /// Retorna la hora en formato HH:mm
  String get horaFormateada {
    if (hora == null) return '';
    final h = hora!.hour.toString().padLeft(2, '0');
    final m = hora!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── EVENTO DETALLE ───────────────────────────────────────────────────────────

class EventoDetalleModel {
  final EventoModel evento;
  final List<ParticipanteModel> participantes;
  final int totalParticipantes;
  final bool yaInscrito;
  final String? enListaEsperaStatus;
  final Map<String, dynamic>? miCodigo;

  const EventoDetalleModel({
    required this.evento,
    required this.participantes,
    required this.totalParticipantes,
    required this.yaInscrito,
    this.enListaEsperaStatus,
    this.miCodigo,
  });

  factory EventoDetalleModel.fromJson(Map<String, dynamic> json) {
    final eventoJson = json['evento'] as Map<String, dynamic>;
    final participantesJson = json['participantes'] as List<dynamic>? ?? [];

    return EventoDetalleModel(
      evento: EventoModel.fromJson(eventoJson),
      participantes: participantesJson
          .map((p) => ParticipanteModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      totalParticipantes: (json['total_participantes'] as num?)?.toInt() ?? 0,
      yaInscrito: json['ya_inscrito'] == true || json['ya_inscrito'] == 'true',
      enListaEsperaStatus: json['en_lista_espera']?.toString(),
      miCodigo: json['mi_codigo'] as Map<String, dynamic>?,
    );
  }
}

// ─── HELPERS ──────────────────────────────────────────────────────────────────

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  try {
    return DateTime.parse(value.toString()).toLocal();
  } catch (_) {
    return null;
  }
}
