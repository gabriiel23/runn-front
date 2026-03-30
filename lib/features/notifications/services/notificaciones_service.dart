import '../../../core/services/http_client.dart';
import '../domain/models/notificacion_model.dart';

/// Servicio para operaciones del modulo de Notificaciones en RUNN.
/// Cubre: obtener notificaciones, marcar como leida, marcar todas, eliminar.
class NotificacionesService {
  // ─── OBTENER NOTIFICACIONES ──────────────────────────────────────────────
  // GET /notificaciones
  // Retorna: { total, no_leidas, notificaciones: [...] }

  static Future<NotificacionesResponse> getNotificaciones() async {
    final data = await RunnHttpClient.get('/notificaciones');
    return NotificacionesResponse.fromJson(data as Map<String, dynamic>);
  }

  // ─── MARCAR UNA NOTIFICACION COMO LEIDA ───────────────────────────────────
  // PATCH /notificaciones/:id/leer

  static Future<void> marcarComoLeida(String notificacionId) async {
    await RunnHttpClient.patch('/notificaciones/$notificacionId/leer');
  }

  // ─── MARCAR TODAS COMO LEIDAS ─────────────────────────────────────────────
  // PATCH /notificaciones/leer-todas

  static Future<void> marcarTodasComoLeidas() async {
    await RunnHttpClient.patch('/notificaciones/leer-todas');
  }

  // ─── ELIMINAR UNA NOTIFICACION ────────────────────────────────────────────
  // DELETE /notificaciones/:id

  static Future<void> eliminarNotificacion(String notificacionId) async {
    await RunnHttpClient.delete('/notificaciones/$notificacionId');
  }

  // ─── ELIMINAR TODAS LAS NOTIFICACIONES ────────────────────────────────────
  // DELETE /notificaciones

  static Future<void> eliminarTodasNotificaciones() async {
    await RunnHttpClient.delete('/notificaciones');
  }
}