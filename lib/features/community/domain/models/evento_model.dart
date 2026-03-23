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
      participantes: (json['participantes'] as num?)?.toInt() ?? 0,
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

  const EventoDetalleModel({
    required this.evento,
    required this.participantes,
    required this.totalParticipantes,
    required this.yaInscrito,
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
      yaInscrito: json['ya_inscrito'] as bool? ?? false,
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
