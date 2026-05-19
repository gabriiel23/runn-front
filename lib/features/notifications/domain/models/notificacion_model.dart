/// Modelos del dominio de Notificaciones.
/// Soporta todos los tipos definidos en el backend.
library;

/// Tipos de notificacion soportados por el backend.
/// Cada tipo tiene un color asociado en la UI.
enum TipoNotificacion {
  // ── Grupos ──────────────────────────────────────────────
  invitacionGrupo('invitacion_grupo'),
  invitacionAceptada('invitacion_aceptada'),
  eliminadoGrupo('eliminado_grupo'),
  grupoEliminado('grupo_eliminado'),
  solicitudUnion('solicitud_union'),
  solicitudAceptada('solicitud_aceptada'),
  solicitudRechazada('solicitud_rechazada'),
  nuevoAdmin('nuevo_admin'),
  nuevoRetoGrupo('nuevo_reto_grupo'),
  nuevaActividadGrupo('nueva_actividad_grupo'),
  nuevaFotoGrupo('nueva_foto_grupo'),
  // ── Retos y logros ──────────────────────────────────────
  retoDiarioNuevo('reto_diario_nuevo'),
  retoSemanalNuevo('reto_semanal_nuevo'),
  retoCompletado('reto_completado'),
  retoCercaCompletar('reto_cerca_completar'),
  logroDesbloqueado('logro_desbloqueado'),
  progresoLogro('progreso_logro'),
  // ── Eventos ─────────────────────────────────────────────
  nuevoEvento('nuevo_evento'),
  inscripcionAdmitida('inscripcion_admitida'),
  inscripcionRechazada('inscripcion_rechazada'),
  eliminadoEvento('eliminado_evento'),
  eventoFinalizado('evento_finalizado'),
  listaEsperaEvento('lista_espera_evento'),
  // ── Otros ───────────────────────────────────────────────
  rolActualizado('rol_actualizado'),
  otros('otros');

  final String value;
  const TipoNotificacion(this.value);

  static TipoNotificacion fromString(String? value) {
    return TipoNotificacion.values.firstWhere(
      (t) => t.value == value,
      orElse: () => TipoNotificacion.otros,
    );
  }

  String get label {
    switch (this) {
      case TipoNotificacion.invitacionGrupo:
        return 'Invitación';
      case TipoNotificacion.invitacionAceptada:
        return 'Aceptada';
      case TipoNotificacion.eliminadoGrupo:
        return 'Eliminado';
      case TipoNotificacion.grupoEliminado:
        return 'Grupo';
      case TipoNotificacion.solicitudUnion:
        return 'Solicitud';
      case TipoNotificacion.solicitudAceptada:
        return 'Aceptada';
      case TipoNotificacion.solicitudRechazada:
        return 'Rechazada';
      case TipoNotificacion.nuevoAdmin:
        return 'Admin';
      case TipoNotificacion.nuevoRetoGrupo:
        return 'Nuevo reto';
      case TipoNotificacion.nuevaActividadGrupo:
        return 'Actividad';
      case TipoNotificacion.nuevaFotoGrupo:
        return 'Galería';
      case TipoNotificacion.retoDiarioNuevo:
        return '🔥 Reto diario';
      case TipoNotificacion.retoSemanalNuevo:
        return '📅 Reto semanal';
      case TipoNotificacion.retoCompletado:
        return '✅ Completado';
      case TipoNotificacion.retoCercaCompletar:
        return '⚡ ¡Casi!';
      case TipoNotificacion.logroDesbloqueado:
        return '🏅 Logro';
      case TipoNotificacion.progresoLogro:
        return '📈 Progreso';
      case TipoNotificacion.nuevoEvento:
        return '🎉 Nuevo evento';
      case TipoNotificacion.inscripcionAdmitida:
        return '✅ Admitido';
      case TipoNotificacion.inscripcionRechazada:
        return '❌ Rechazado';
      case TipoNotificacion.eliminadoEvento:
        return 'Eliminado';
      case TipoNotificacion.eventoFinalizado:
        return '🏁 Finalizado';
      case TipoNotificacion.listaEsperaEvento:
        return '⏳ En espera';
      case TipoNotificacion.rolActualizado:
        return '👑 Nuevo Rol';
      case TipoNotificacion.otros:
        return 'Otros';
    }
  }
}

/// Modelo de notificacion individual.
class NotificacionModel {
  final String id;
  final String usuarioId;
  final TipoNotificacion tipo;
  final String mensaje;
  final bool leida;
  final DateTime creadoEn;

  const NotificacionModel({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.mensaje,
    required this.leida,
    required this.creadoEn,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id: json['id']?.toString() ?? '',
      usuarioId: json['usuario_id']?.toString() ?? '',
      tipo: TipoNotificacion.fromString(json['tipo']?.toString()),
      mensaje: json['mensaje']?.toString() ?? '',
      leida: json['leida'] as bool? ?? false,
      creadoEn: _parseDate(json['creado_en']) ?? DateTime.now(),
    );
  }

  NotificacionModel copyWith({bool? leida}) {
    return NotificacionModel(
      id: id,
      usuarioId: usuarioId,
      tipo: tipo,
      mensaje: mensaje,
      leida: leida ?? this.leida,
      creadoEn: creadoEn,
    );
  }

  /// Extrae el grupo_id embebido al final del mensaje si existe.
  /// Formato del servidor: `...mensaje... grupo_id:<uuid>`
  String? get grupoIdEmbebido {
    final match = RegExp(r'grupo_id:([\w-]+)').firstMatch(mensaje);
    return match?.group(1);
  }

  /// Extrae el invitacion_id embebido al final del mensaje si existe.
  /// Formato del servidor: `...mensaje... invitacion_id:<uuid>`
  String? get invitacionIdEmbebida {
    final match = RegExp(r'invitacion_id:([\w-]+)').firstMatch(mensaje);
    return match?.group(1);
  }

  /// Extrae el reto_id embebido al final del mensaje si existe.
  /// Formato del servidor: `...mensaje... reto_id:<uuid>`
  String? get retoIdEmbebido {
    final match = RegExp(r'reto_id:([\w-]+)').firstMatch(mensaje);
    return match?.group(1);
  }

  /// Extrae el actividad_id embebido al final del mensaje si existe.
  /// Formato del servidor: `...mensaje... actividad_id:<uuid>`
  String? get actividadIdEmbebida {
    final match = RegExp(r'actividad_id:(\w[\w-]+)').firstMatch(mensaje);
    return match?.group(1);
  }

  /// Extrae el evento_id embebido al final del mensaje si existe.
  /// Formato del servidor: `...mensaje... evento_id:<uuid>`
  String? get eventoIdEmbebido {
    final match = RegExp(r'evento_id:([\w-]+)').firstMatch(mensaje);
    return match?.group(1);
  }

  /// Extrae los roles embebidos al final del mensaje.
  /// Formato: `...mensaje... roles_embebidos:admin_eventos,usuario`
  String? get rolesEmbebidos {
    final match = RegExp(r'roles_embebidos:([a-z,_]+)').firstMatch(mensaje);
    return match?.group(1);
  }

  /// Versión limpia del mensaje sin los suffixes de metadatos.
  String get mensajeLimpio => mensaje
      .replaceAll(RegExp(r'\s*grupo_id:[\w-]+'), '')
      .replaceAll(RegExp(r'\s*invitacion_id:[\w-]+'), '')
      .replaceAll(RegExp(r'\s*reto_id:[\w-]+'), '')
      .replaceAll(RegExp(r'\s*actividad_id:[\w-]+'), '')
      .replaceAll(RegExp(r'\s*evento_id:[\w-]+'), '')
      .replaceAll(RegExp(r'\s*roles_embebidos:[a-z,_]+'), '')
      .trim();
}

/// Modelo de respuesta del endpoint GET /notificaciones.
/// Contiene el total, no leidas y la lista de notificaciones.
class NotificacionesResponse {
  final int total;
  final int noLeidas;
  final List<NotificacionModel> notificaciones;

  const NotificacionesResponse({
    required this.total,
    required this.noLeidas,
    required this.notificaciones,
  });

  factory NotificacionesResponse.fromJson(Map<String, dynamic> json) {
    final lista = json['notificaciones'] as List<dynamic>? ?? [];
    return NotificacionesResponse(
      total: (json['total'] as num?)?.toInt() ?? 0,
      noLeidas: (json['no_leidas'] as num?)?.toInt() ?? 0,
      notificaciones: lista
          .map((n) => NotificacionModel.fromJson(n as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─── HELPERS ────────────────────────────────────────────────────────────────

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString()).toLocal();
  } catch (_) {
    return null;
  }
}

/// Calcula el tiempo transcurrido en formato legible.
/// Ejemplo: "hace 5 min", "hace 2 horas", "ayer", "Lun, 10:30"
String tiempoTranscurrido(DateTime fecha) {
  final ahora = DateTime.now();
  final diferencia = ahora.difference(fecha);

  // Menos de 1 minuto
  if (diferencia.inSeconds < 60) {
    return 'hace un momento';
  }

  // Menos de 1 hora
  if (diferencia.inMinutes < 60) {
    final min = diferencia.inMinutes;
    return 'hace $min ${min == 1 ? 'min' : 'min'}';
  }

  // Menos de 24 horas
  if (diferencia.inHours < 24) {
    final horas = diferencia.inHours;
    return 'hace $horas ${horas == 1 ? 'hora' : 'horas'}';
  }

  // Ayer
  if (diferencia.inDays == 1) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return 'Ayer, $hora:$min';
  }

  // Menos de 7 dias - mostrar dia de la semana
  if (diferencia.inDays < 7) {
    const dias = ['Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab'];
    final dia = dias[fecha.weekday % 7];
    final hora = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$dia, $hora:$min';
  }

  // Mas de 7 dias - mostrar fecha completa
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}