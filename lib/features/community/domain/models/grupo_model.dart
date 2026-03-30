/// Modelos del dominio de Grupos.
/// Cubre listado, mis-grupos, detalle, miembros, retos, actividades, multimedia y ranking.
library;

// ─── HELPERS ──────────────────────────────────────────────────────────────────

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString()).toLocal();
  } catch (_) {
    return null;
  }
}

String _fechaFormateada(DateTime? d) {
  if (d == null) return 'Fecha por definir';
  const meses = [
    '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];
  return '${d.day} de ${meses[d.month]} de ${d.year}';
}

/// Extrae la hora en formato HH:mm de un String ISO/fecha entera.
/// Los campos de hora del backend vienen como: "1970-01-01THH:mm:00.000Z"
String _horaFormateada(DateTime? d) {
  if (d == null) return '';
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

// ─── GRUPO (listado / mis-grupos) ────────────────────────────────────────────

class GrupoListItem {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? fotoUrl;
  final String modalidad;       // 'social' | 'territorial'
  final bool esPrivado;
  final String? creadoPorNombre;
  final int totalMiembros;
  final String? miRol;          // Solo en mis-grupos

  const GrupoListItem({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.fotoUrl,
    required this.modalidad,
    required this.esPrivado,
    this.creadoPorNombre,
    required this.totalMiembros,
    this.miRol,
  });

  factory GrupoListItem.fromJson(Map<String, dynamic> json) {
    return GrupoListItem(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      fotoUrl: json['foto_url']?.toString(),
      modalidad: json['modalidad']?.toString() ?? 'social',
      esPrivado: json['es_privado'] as bool? ?? false,
      creadoPorNombre: json['creado_por_nombre']?.toString(),
      totalMiembros: (json['total_miembros'] as num?)?.toInt() ?? 0,
      miRol: json['mi_rol']?.toString(),
    );
  }
}

// ─── MIEMBRO DEL GRUPO ────────────────────────────────────────────────────────

class MiembroGrupo {
  final String id;
  final String nombre;
  final String? avatarUrl;
  final String? ciudad;
  final String? nivel;
  final String rol;             // 'creador' | 'admin' | 'miembro'
  final DateTime? unidoEn;

  const MiembroGrupo({
    required this.id,
    required this.nombre,
    this.avatarUrl,
    this.ciudad,
    this.nivel,
    required this.rol,
    this.unidoEn,
  });

  factory MiembroGrupo.fromJson(Map<String, dynamic> json) {
    return MiembroGrupo(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      ciudad: json['ciudad']?.toString(),
      nivel: json['nivel']?.toString(),
      rol: json['rol']?.toString() ?? 'miembro',
      unidoEn: _parseDate(json['unido_en']),
    );
  }

  /// Etiqueta visual para el chip del rol
  String get rolLabel {
    switch (rol) {
      case 'creador':
        return 'Creador';
      case 'admin':
        return 'Admin';
      default:
        return 'Miembro';
    }
  }

  String get unidoEnFmt => _fechaFormateada(unidoEn);
}

// ─── RETO DEL GRUPO ──────────────────────────────────────────────────────────

class GrupoReto {
  final String id;
  final String titulo;
  final String? descripcion;
  final String? distanciaKm;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int participantes;      // _count.grupo_retos_usuario

  const GrupoReto({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.distanciaKm,
    this.fechaInicio,
    this.fechaFin,
    required this.participantes,
  });

  factory GrupoReto.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>?;
    return GrupoReto(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      distanciaKm: json['distancia_km']?.toString(),
      fechaInicio: _parseDate(json['fecha_inicio']),
      fechaFin: _parseDate(json['fecha_fin']),
      participantes: (count?['grupo_retos_usuario'] as num?)?.toInt() ?? 0,
    );
  }

  String get fechaInicioFmt => _fechaFormateada(fechaInicio);
  String get fechaFinFmt => _fechaFormateada(fechaFin);
}

// ─── ACTIVIDAD DEL GRUPO ──────────────────────────────────────────────────────

class GrupoActividad {
  final String id;
  final String titulo;
  final String? descripcion;
  final String tipo;            // 'correr' | 'senderismo'
  final String? lugar;
  final DateTime? fecha;
  final DateTime? hora;
  final int participantes;

  const GrupoActividad({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.tipo,
    this.lugar,
    this.fecha,
    this.hora,
    required this.participantes,
  });

  factory GrupoActividad.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>?;
    return GrupoActividad(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      tipo: json['tipo']?.toString() ?? 'senderismo',
      lugar: json['lugar']?.toString(),
      fecha: _parseDate(json['fecha']),
      hora: _parseDate(json['hora']),
      participantes: (count?['grupo_actividades_usuario'] as num?)?.toInt() ?? 0,
    );
  }

  String get fechaFmt => _fechaFormateada(fecha);
  String get horaFmt => _horaFormateada(hora);
}

// ─── MULTIMEDIA DEL GRUPO ────────────────────────────────────────────────────

class GrupoMultimedia {
  final String id;
  final String fotoUrl;
  final String? subidoPorNombre;

  const GrupoMultimedia({
    required this.id,
    required this.fotoUrl,
    this.subidoPorNombre,
  });

  factory GrupoMultimedia.fromJson(Map<String, dynamic> json) {
    return GrupoMultimedia(
      id: json['id']?.toString() ?? '',
      fotoUrl: (json['url'] ?? json['foto_url'])?.toString() ?? '',
      subidoPorNombre: json['subido_por_nombre']?.toString(),
    );
  }
}

// ─── DETALLE COMPLETO DEL GRUPO ──────────────────────────────────────────────

class GrupoDetalle {
  final GrupoListItem grupo;
  final List<MiembroGrupo> miembros;
  final int totalMiembros;
  final bool soyMiembro;
  final bool solicitudPendiente;
  final String? miRol;          // 'creador' | 'admin' | 'miembro' | null
  final List<GrupoReto> retos;
  final List<GrupoActividad> actividades;
  final List<GrupoMultimedia> multimedia;

  const GrupoDetalle({
    required this.grupo,
    required this.miembros,
    required this.totalMiembros,
    required this.soyMiembro,
    required this.solicitudPendiente,
    this.miRol,
    required this.retos,
    required this.actividades,
    required this.multimedia,
  });

  factory GrupoDetalle.fromJson(Map<String, dynamic> json) {
    final grupoJson = json['grupo'] as Map<String, dynamic>;
    final miembrosJson = json['miembros'] as List<dynamic>? ?? [];
    final retosJson = json['retos'] as List<dynamic>? ?? [];
    final actividadesJson = json['actividades'] as List<dynamic>? ?? [];
    final multimediaJson = json['multimedia'] as List<dynamic>? ?? [];

    return GrupoDetalle(
      grupo: GrupoListItem.fromJson(grupoJson),
      miembros: miembrosJson.map((m) => MiembroGrupo.fromJson(m as Map<String, dynamic>)).toList(),
      totalMiembros: (json['total_miembros'] as num?)?.toInt() ?? miembrosJson.length,
      soyMiembro: json['soy_miembro'] == true,
      solicitudPendiente: json['solicitud_pendiente'] == true,
      miRol: json['mi_rol']?.toString(),
      retos: retosJson.map((r) => GrupoReto.fromJson(r as Map<String, dynamic>)).toList(),
      actividades: actividadesJson.map((a) => GrupoActividad.fromJson(a as Map<String, dynamic>)).toList(),
      multimedia: multimediaJson.map((m) => GrupoMultimedia.fromJson(m as Map<String, dynamic>)).toList(),
    );
  }

  /// ¿Puede gestionar (admin o creador del grupo)?
  bool get esGestorDelGrupo => miRol == 'admin' || miRol == 'creador';
  bool get esCreador => miRol == 'creador';
}

// ─── RANKING ENTRY ────────────────────────────────────────────────────────────

class RankingEntry {
  final String usuarioId;
  final String nombre;
  final String? avatarUrl;
  final int cantidad; // retos_completados o actividades_completadas

  const RankingEntry({
    required this.usuarioId,
    required this.nombre,
    this.avatarUrl,
    required this.cantidad,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json, String cantidadKey) {
    final usuario = json['usuario'] as Map<String, dynamic>;
    return RankingEntry(
      usuarioId: usuario['id']?.toString() ?? '',
      nombre: usuario['nombre']?.toString() ?? '',
      avatarUrl: usuario['avatar_url']?.toString(),
      cantidad: (json[cantidadKey] as num?)?.toInt() ?? 0,
    );
  }
}

// ─── SOLICITUD DE UNIÓN ───────────────────────────────────────────────────────

class SolicitudGrupo {
  final String id;
  final String estado;
  final DateTime? creadoEn;
  final String usuarioId;
  final String usuarioNombre;
  final String? usuarioAvatarUrl;
  final String? usuarioCiudad;
  final String? usuarioNivel;

  const SolicitudGrupo({
    required this.id,
    required this.estado,
    this.creadoEn,
    required this.usuarioId,
    required this.usuarioNombre,
    this.usuarioAvatarUrl,
    this.usuarioCiudad,
    this.usuarioNivel,
  });

  factory SolicitudGrupo.fromJson(Map<String, dynamic> json) {
    final u = json['usuario'] as Map<String, dynamic>? ?? {};
    return SolicitudGrupo(
      id: json['id']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'pendiente',
      creadoEn: _parseDate(json['creado_en']),
      usuarioId: u['id']?.toString() ?? '',
      usuarioNombre: u['nombre']?.toString() ?? '',
      usuarioAvatarUrl: u['avatar_url']?.toString(),
      usuarioCiudad: u['ciudad']?.toString(),
      usuarioNivel: u['nivel']?.toString(),
    );
  }

  String get creadoEnFmt => _fechaFormateada(creadoEn);
  // Getters de conveniencia para la UI
  String get nombre => usuarioNombre;
  String? get avatarUrl => usuarioAvatarUrl;
}

// ─── INVITACIÓN (panel del admin) ─────────────────────────────────────────────

class InvitacionPanel {
  final String id;
  final String estado;           // 'pendiente' | 'aceptada' | 'rechazada'
  final DateTime? creadoEn;
  final String usuarioId;
  final String usuarioNombre;
  final String? usuarioAvatarUrl;
  final String? invitadoPorNombre;

  const InvitacionPanel({
    required this.id,
    required this.estado,
    this.creadoEn,
    required this.usuarioId,
    required this.usuarioNombre,
    this.usuarioAvatarUrl,
    this.invitadoPorNombre,
  });

  factory InvitacionPanel.fromJson(Map<String, dynamic> json) {
    final u = json['usuario'] as Map<String, dynamic>? ?? {};
    final inv = json['invitado_por'] as Map<String, dynamic>?;
    return InvitacionPanel(
      id: json['id']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'pendiente',
      creadoEn: _parseDate(json['creado_en']),
      usuarioId: u['id']?.toString() ?? '',
      usuarioNombre: u['nombre']?.toString() ?? '',
      usuarioAvatarUrl: u['avatar_url']?.toString(),
      invitadoPorNombre: inv?['nombre']?.toString(),
    );
  }

  String get creadoEnFmt => _fechaFormateada(creadoEn);
  // Getters de conveniencia para la UI
  String get nombre => usuarioNombre;
  String? get avatarUrl => usuarioAvatarUrl;
}
