import '../../../core/services/http_client.dart';
import '../domain/models/evento_model.dart';

/// Servicio para operaciones de Eventos de la comunidad RUNN.
class EventosService {
  // ─── LISTAR EVENTOS ───────────────────────────────────────────────────────
  // GET /eventos

  static Future<List<EventoModel>> getEventos() async {
    final data = await RunnHttpClient.get('/eventos');
    final lista = data['eventos'] as List<dynamic>? ?? [];
    return lista
        .map((e) => EventoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── DETALLE DE UN EVENTO ─────────────────────────────────────────────────
  // GET /eventos/:id

  static Future<EventoDetalleModel> getEvento(String id) async {
    final data = await RunnHttpClient.get('/eventos/$id');
    return EventoDetalleModel.fromJson(data as Map<String, dynamic>);
  }

  // ─── UNIRSE AL EVENTO ─────────────────────────────────────────────────────
  // POST /eventos/:id/unirse

  static Future<Map<String, dynamic>> unirseEvento(String id) async {
    return await RunnHttpClient.post('/eventos/$id/unirse');
  }

  // ─── SALIRSE DEL EVENTO ───────────────────────────────────────────────────
  // DELETE /eventos/:id/unirse

  static Future<void> salirseEvento(String id) async {
    await RunnHttpClient.delete('/eventos/$id/unirse');
  }

  // ─── EDITAR EVENTO (solo admin) ───────────────────────────────────────────
  // PUT /eventos/:id — JSON sin foto | multipart con foto

  static Future<void> editarEvento(
    String id, {
    required Map<String, String> campos,
    List<int>? fotoBytes,
    String? fotoFilename,
  }) async {
    if (fotoBytes != null && fotoFilename != null) {
      await RunnHttpClient.putMultipart(
        '/eventos/$id',
        fields: campos,
        bytes: fotoBytes,
        filename: fotoFilename,
        fieldName: 'foto',
      );
    } else {
      await RunnHttpClient.put('/eventos/$id', body: campos.cast<String, dynamic>());
    }
  }

  // ─── CREAR EVENTO (solo admin) ────────────────────────────────────────────
  // POST /eventos — multipart con foto opcional

  static Future<void> crearEvento({
    required Map<String, String> campos,
    List<int>? fotoBytes,
    String? fotoFilename,
  }) async {
    if (fotoBytes != null && fotoFilename != null) {
      await RunnHttpClient.postMultipart(
        '/eventos',
        bytes: fotoBytes,
        filename: fotoFilename,
        fieldName: 'foto',
        fields: campos,
      );
    } else {
      await RunnHttpClient.post('/eventos', body: campos.cast<String, dynamic>());
    }
  }

  // ─── ELIMINAR EVENTO (solo admin) ─────────────────────────────────────────
  // DELETE /eventos/:id

  static Future<void> eliminarEvento(String id) async {
    await RunnHttpClient.delete('/eventos/$id');
  }

  // ─── AGREGAR PARTICIPANTE MANUALMENTE (solo admin) ──────────────────────
  // POST /eventos/:id/participantes

  static Future<void> agregarParticipante(String id, String usuarioId) async {
    await RunnHttpClient.post('/eventos/$id/participantes', body: {
      'usuario_id': usuarioId,
    });
  }

  // ─── ELIMINAR PARTICIPANTE MANUALMENTE (solo admin) ──────────────────────
  // DELETE /eventos/:id/participantes/:usuario_id

  static Future<void> eliminarParticipante(String id, String usuarioId) async {
    await RunnHttpClient.delete('/eventos/$id/participantes/$usuarioId');
  }

  // ─── OBTENER LISTA DE ESPERA (solo admin) ───────────────────────────────
  // GET /eventos/:id/lista-espera

  static Future<Map<String, dynamic>> getListaEspera(String id) async {
    return await RunnHttpClient.get('/eventos/$id/lista-espera');
  }

  // ─── ADMITIR/RECHAZAR EN LISTA DE ESPERA (solo admin) ───────────────────
  // PUT /eventos/:id/lista-espera/:usuarioId

  static Future<void> admitirRechazarListaEspera(
    String id,
    String usuarioId,
    String accion, {
    String? motivo,
  }) async {
    await RunnHttpClient.put('/eventos/$id/lista-espera/$usuarioId', body: {
      'accion': accion,
      if (motivo != null) 'motivo': motivo,
    });
  }

  // ─── VERIFICAR CÓDIGO QR (solo admin) ───────────────────────────────────
  // POST /eventos/:id/verificar-codigo

  static Future<Map<String, dynamic>> verificarCodigo(String id, String codigo) async {
    return await RunnHttpClient.post('/eventos/$id/verificar-codigo', body: {
      'codigo': codigo,
    });
  }
}

