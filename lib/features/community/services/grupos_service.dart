import 'dart:typed_data';
import '../../../core/services/http_client.dart';
import '../domain/models/grupo_model.dart';

/// Servicio para operaciones del módulo de Grupos en RUNN.
/// Cubre: grupos, miembros, invitaciones, retos, actividades y multimedia.
class GruposService {
  // ─── LISTAR GRUPOS ────────────────────────────────────────────────────────
  // GET /grupos?buscar=text

  static Future<List<GrupoListItem>> getGrupos({
    String? buscar,
    String? modalidad,
    bool? esPrivado,
  }) async {
    final queryParams = <String, String>{};
    if (buscar != null && buscar.isNotEmpty) queryParams['buscar'] = buscar;
    if (modalidad != null && modalidad.isNotEmpty && modalidad != 'Todos') queryParams['modalidad'] = modalidad.toLowerCase();
    if (esPrivado != null) queryParams['es_privado'] = esPrivado.toString();

    final uri = Uri(path: '/grupos', queryParameters: queryParams.isNotEmpty ? queryParams : null);
    
    final data = await RunnHttpClient.get(uri.toString());
    final lista = data['grupos'] as List<dynamic>? ?? [];
    return lista.map((g) => GrupoListItem.fromJson(g as Map<String, dynamic>)).toList();
  }

  // ─── MIS GRUPOS ───────────────────────────────────────────────────────────
  // GET /grupos/mis-grupos

  static Future<List<GrupoListItem>> getMisGrupos() async {
    final data = await RunnHttpClient.get('/grupos/mis-grupos');
    final lista = data['grupos'] as List<dynamic>? ?? [];
    return lista.map((g) => GrupoListItem.fromJson(g as Map<String, dynamic>)).toList();
  }

  // ─── DETALLE DEL GRUPO ────────────────────────────────────────────────────
  // GET /grupos/:id

  static Future<GrupoDetalle> getGrupoDetalle(String id) async {
    final data = await RunnHttpClient.get('/grupos/$id');
    return GrupoDetalle.fromJson(data as Map<String, dynamic>);
  }

  // ─── CREAR GRUPO ──────────────────────────────────────────────────────────
  // POST /grupos (form-data con foto opcional)

  static Future<Map<String, dynamic>> crearGrupo({
    required String nombre,
    String? descripcion,
    String modalidad = 'social',
    bool esPrivado = false,
    Uint8List? foto,
    String? fotoMimeType,
  }) async {
    final fields = <String, String>{
      'nombre': nombre,
      'modalidad': modalidad,
      'es_privado': esPrivado.toString(),
      if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion,
    };

    if (foto != null) {
      final ext = (fotoMimeType ?? 'image/jpeg').split('/').last;
      return await RunnHttpClient.postMultipart(
        '/grupos',
        bytes: foto,
        filename: 'grupo_foto.$ext',
        fieldName: 'foto',
        fields: fields,
      ) as Map<String, dynamic>;
    }

    return await RunnHttpClient.post('/grupos', body: fields) as Map<String, dynamic>;
  }

  // ─── EDITAR GRUPO ─────────────────────────────────────────────────────────
  // PUT /grupos/:id (form-data con foto opcional)

  static Future<void> editarGrupo({
    required String id,
    String? nombre,
    String? descripcion,
    String? modalidad,
    bool? esPrivado,
    Uint8List? foto,
    String? fotoMimeType,
  }) async {
    final fields = <String, String>{
      if (nombre != null && nombre.isNotEmpty) 'nombre': nombre,
      if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion,
      if (modalidad != null) 'modalidad': modalidad,
      if (esPrivado != null) 'es_privado': esPrivado.toString(),
    };

    if (foto != null) {
      final ext = (fotoMimeType ?? 'image/jpeg').split('/').last;
      await RunnHttpClient.putMultipart(
        '/grupos/$id',
        fields: fields,
        bytes: foto,
        filename: 'grupo_foto.$ext',
        fieldName: 'foto',
      );
    } else if (fields.isNotEmpty) {
      await RunnHttpClient.put('/grupos/$id', body: fields);
    }
  }

  // ─── ELIMINAR GRUPO ───────────────────────────────────────────────────────
  // DELETE /grupos/:id
  // Nota: el backend acepta {motivo} para notificar al creador, pero el cliente
  // HTTP actual no soporta body en DELETE → se ignora silenciosamente.

  static Future<void> eliminarGrupo(String id, {String? motivo}) async {
    await RunnHttpClient.delete('/grupos/$id');
  }

  // ─── SOLICITAR UNIÓN AL GRUPO ─────────────────────────────────────────────
  // POST /grupos/:id/unirse → ya no une directamente, crea solicitud

  static Future<Map<String, dynamic>> solicitarUnion(String id) async {
    return await RunnHttpClient.post('/grupos/$id/unirse');
  }

  /// Alias para compatibilidad con código anterior.
  static Future<void> unirseGrupo(String id) async {
    await solicitarUnion(id);
  }

  // ─── SALIRSE DEL GRUPO ────────────────────────────────────────────────────
  // DELETE /grupos/:id/unirse

  static Future<void> salirseGrupo(String id) async {
    await RunnHttpClient.delete('/grupos/$id/unirse');
  }

  // ─── OBTENER SOLICITUDES DE UNIÓN (admin del grupo) ───────────────────────
  // GET /grupos/:id/solicitudes

  static Future<List<SolicitudGrupo>> getSolicitudesGrupo(String grupoId) async {
    final data = await RunnHttpClient.get('/grupos/$grupoId/solicitudes');
    final lista = data['solicitudes'] as List<dynamic>? ?? [];
    return lista.map((s) => SolicitudGrupo.fromJson(s as Map<String, dynamic>)).toList();
  }

  // ─── RESPONDER SOLICITUD DE UNIÓN (admin del grupo) ───────────────────────
  // PUT /grupos/:id/solicitudes/:solicitud_id  body: {accion: 'aceptar'|'rechazar'}

  static Future<void> responderSolicitud(
    String grupoId,
    String solicitudId,
    String accion,
  ) async {
    await RunnHttpClient.put(
      '/grupos/$grupoId/solicitudes/$solicitudId',
      body: {'accion': accion},
    );
  }

  // ─── PANEL DE INVITACIONES ENVIADAS (admin del grupo) ─────────────────────
  // GET /grupos/:id/invitaciones-panel

  static Future<List<InvitacionPanel>> getInvitacionesPanel(String grupoId) async {
    final data = await RunnHttpClient.get('/grupos/$grupoId/invitaciones-panel');
    final lista = data['invitaciones'] as List<dynamic>? ?? [];
    return lista.map((i) => InvitacionPanel.fromJson(i as Map<String, dynamic>)).toList();
  }

  // ─── BUSCAR USUARIOS PARA INVITAR (admin del grupo) ───────────────────────
  // GET /grupos/:id/buscar-usuarios?q=texto

  static Future<List<Map<String, dynamic>>> buscarUsuariosParaGrupo(
    String grupoId, {
    String? query,
  }) async {
    final q = query != null && query.length >= 2 ? '?q=$query' : '';
    final data = await RunnHttpClient.get('/grupos/$grupoId/buscar-usuarios$q');
    final lista = data['usuarios'] as List<dynamic>? ?? [];
    return lista.cast<Map<String, dynamic>>();
  }

  // ─── AGREGAR MIEMBRO (admin del grupo) ────────────────────────────────────
  // POST /grupos/:id/miembros

  static Future<void> agregarMiembro(String grupoId, String usuarioId) async {
    await RunnHttpClient.post('/grupos/$grupoId/miembros', body: {'usuario_id': usuarioId});
  }

  // ─── ELIMINAR MIEMBRO (admin del grupo) ───────────────────────────────────
  // DELETE /grupos/:id/miembros/:usuario_id

  static Future<void> eliminarMiembro(String grupoId, String usuarioId) async {
    await RunnHttpClient.delete('/grupos/$grupoId/miembros/$usuarioId');
  }

  // ─── CAMBIAR ROL DE MIEMBRO (creador del grupo) ───────────────────────────
  // PUT /grupos/:id/miembros/:usuario_id/rol

  static Future<void> cambiarRolMiembro(
    String grupoId,
    String usuarioId,
    String nuevoRol,
  ) async {
    await RunnHttpClient.put('/grupos/$grupoId/miembros/$usuarioId/rol', body: {'rol': nuevoRol});
  }

  // ─── INVITAR USUARIO (admin del grupo) ────────────────────────────────────
  // POST /grupos/:id/invitar

  static Future<void> invitarUsuario(String grupoId, String usuarioId) async {
    await RunnHttpClient.post('/grupos/$grupoId/invitar', body: {'usuario_id': usuarioId});
  }

  // ─── RESPONDER INVITACIÓN (usuario invitado) ──────────────────────────────
  // PUT /grupos/invitaciones/:id  body: {accion: 'aceptar'|'rechazar'}

  static Future<void> responderInvitacion(String invitacionId, String accion) async {
    await RunnHttpClient.put('/grupos/invitaciones/$invitacionId', body: {'accion': accion});
  }

  // ─── CREAR RETO (admin del grupo) ─────────────────────────────────────────
  // POST /grupos/:id/retos

  static Future<void> crearReto({
    required String grupoId,
    required String titulo,
    String? descripcion,
    String? distanciaKm,
    String? fechaInicio,  // ISO date string
    String? fechaFin,     // ISO date string
  }) async {
    await RunnHttpClient.post('/grupos/$grupoId/retos', body: {
      'titulo': titulo,
      if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion,
      if (distanciaKm != null && distanciaKm.isNotEmpty) 'distancia_km': distanciaKm,
      if (fechaInicio != null) 'fecha_inicio': fechaInicio,
      if (fechaFin != null) 'fecha_fin': fechaFin,
    });
  }

  // ─── PARTICIPAR EN RETO ───────────────────────────────────────────────────
  // POST /grupos/:id/retos/:reto_id/participar

  static Future<void> participarReto(String grupoId, String retoId) async {
    await RunnHttpClient.post('/grupos/$grupoId/retos/$retoId/participar');
  }

  // ─── COMPLETAR RETO ───────────────────────────────────────────────────────
  // PUT /grupos/:id/retos/:reto_id/completar

  static Future<void> completarReto(String grupoId, String retoId) async {
    await RunnHttpClient.put('/grupos/$grupoId/retos/$retoId/completar');
  }

  // ─── RANKING DE RETOS ─────────────────────────────────────────────────────
  // GET /grupos/:id/retos/ranking

  static Future<List<RankingEntry>> getRankingRetos(String grupoId) async {
    final data = await RunnHttpClient.get('/grupos/$grupoId/retos/ranking');
    final lista = data['ranking'] as List<dynamic>? ?? [];
    return lista
        .map((r) => RankingEntry.fromJson(r as Map<String, dynamic>, 'retos_completados'))
        .toList();
  }

  // ─── CREAR ACTIVIDAD (admin del grupo) ────────────────────────────────────
  // POST /grupos/:id/actividades

  static Future<void> crearActividad({
    required String grupoId,
    required String titulo,
    String? descripcion,
    String tipo = 'senderismo',
    String? lugar,
    String? fecha,   // ISO date string
    String? hora,    // HH:mm
  }) async {
    await RunnHttpClient.post('/grupos/$grupoId/actividades', body: {
      'titulo': titulo,
      'tipo': tipo,
      if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion,
      if (lugar != null && lugar.isNotEmpty) 'lugar': lugar,
      if (fecha != null) 'fecha': fecha,
      if (hora != null) 'hora': hora,
    });
  }

  // ─── PARTICIPAR EN ACTIVIDAD ──────────────────────────────────────────────
  // POST /grupos/:id/actividades/:actividad_id/participar

  static Future<void> participarActividad(String grupoId, String actividadId) async {
    await RunnHttpClient.post('/grupos/$grupoId/actividades/$actividadId/participar');
  }

  // ─── COMPLETAR ACTIVIDAD ──────────────────────────────────────────────────
  // PUT /grupos/:id/actividades/:actividad_id/completar

  static Future<void> completarActividad(String grupoId, String actividadId) async {
    await RunnHttpClient.put('/grupos/$grupoId/actividades/$actividadId/completar');
  }



  // ─── RANKING DE ACTIVIDADES ───────────────────────────────────────────────
  // GET /grupos/:id/actividades/ranking

  static Future<List<RankingEntry>> getRankingActividades(String grupoId) async {
    final data = await RunnHttpClient.get('/grupos/$grupoId/actividades/ranking');
    final lista = data['ranking'] as List<dynamic>? ?? [];
    return lista
        .map((r) => RankingEntry.fromJson(r as Map<String, dynamic>, 'actividades_completadas'))
        .toList();
  }

  // ─── SUBIR FOTO AL GRUPO (miembros) ──────────────────────────────────────
  // POST /grupos/:id/multimedia  form-data key: foto

  static Future<void> subirFotoGrupo({
    required String grupoId,
    required Uint8List foto,
    String mimeType = 'image/jpeg',
  }) async {
    final ext = mimeType.split('/').last;
    await RunnHttpClient.postMultipart(
      '/grupos/$grupoId/multimedia',
      bytes: foto,
      filename: 'grupo_media_${DateTime.now().millisecondsSinceEpoch}.$ext',
      fieldName: 'foto',
    );
  }
}
