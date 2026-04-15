import 'package:runn_front/core/services/http_client.dart';
import '../data/models/reto_models.dart';

class RetosService {
  // ─── RETO DIARIO ──────────────────────────────────────────────────────────
  static Future<RetoDiarioConParticipacion> obtenerRetoDiarioHoy() async {
    final data = await RunnHttpClient.get('/retos/diario/hoy');
    return RetoDiarioConParticipacion.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<HistorialRetoDiario>> obtenerHistorialDiario() async {
    final data = await RunnHttpClient.get('/retos/diario/historial');
    final list = (data as Map<String, dynamic>)['historial'] as List<dynamic>? ?? [];
    return list
        .map((e) => HistorialRetoDiario.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── RETO SEMANAL ─────────────────────────────────────────────────────────
  static Future<RetoSemanalConParticipacion> obtenerRetoSemanalActual() async {
    final data = await RunnHttpClient.get('/retos/semanal/actual');
    return RetoSemanalConParticipacion.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<HistorialRetoSemanal>> obtenerHistorialSemanal() async {
    final data = await RunnHttpClient.get('/retos/semanal/historial');
    final list = (data as Map<String, dynamic>)['historial'] as List<dynamic>? ?? [];
    return list
        .map((e) => HistorialRetoSemanal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── RACHA ────────────────────────────────────────────────────────────────
  static Future<RachaModel> obtenerRacha() async {
    final data = await RunnHttpClient.get('/retos/racha');
    return RachaModel.fromJson(data as Map<String, dynamic>);
  }

  // ─── INSIGNIAS ────────────────────────────────────────────────────────────
  static Future<InsigniasResponse> obtenerInsignias() async {
    final data = await RunnHttpClient.get('/retos/insignias/distancia');
    return InsigniasResponse.fromJson(data as Map<String, dynamic>);
  }

  // ─── ADMIN: Consultas futuras ──────────────────────────────────────────────
  static Future<RetoDiario?> obtenerRetoDiarioManana() async {
    final data = await RunnHttpClient.get('/retos/admin/diario/manana');
    final retoMap = (data as Map<String, dynamic>)['reto'];
    if (retoMap == null) return null;
    return RetoDiario.fromJson(retoMap as Map<String, dynamic>);
  }

  static Future<RetoSemanal?> obtenerRetoSemanalProxima() async {
    final data = await RunnHttpClient.get('/retos/admin/semanal/proxima');
    final retoMap = (data as Map<String, dynamic>)['reto'];
    if (retoMap == null) return null;
    return RetoSemanal.fromJson(retoMap as Map<String, dynamic>);
  }

  // ─── ADMIN: Generar con IA ─────────────────────────────────────────────────
  static Future<RetoDiario> generarRetoDiarioIA({bool manana = false}) async {
    final body = manana ? {'fecha_objetivo': 'manana'} : null;
    final data = await RunnHttpClient.post('/retos/generar/diario', body: body);
    return RetoDiario.fromJson((data as Map<String, dynamic>)['reto'] as Map<String, dynamic>);
  }

  static Future<RetoSemanal> generarRetoSemanalIA({bool proxima = false}) async {
    final body = proxima ? {'fecha_objetivo': 'proxima'} : null;
    final data = await RunnHttpClient.post('/retos/generar/semanal', body: body);
    return RetoSemanal.fromJson((data as Map<String, dynamic>)['reto'] as Map<String, dynamic>);
  }

  // ─── ADMIN: Crear manual ──────────────────────────────────────────────────
  static Future<RetoDiario> crearRetoDiarioManual({
    required String titulo,
    String? descripcion,
    required String tipo,
    required double valorObjetivo,
    required String unidad,
    int puntosRecompensa = 10,
    String? fecha,
  }) async {
    final body = <String, dynamic>{
      'titulo': titulo,
      if (descripcion != null) 'descripcion': descripcion,
      'tipo': tipo,
      'valor_objetivo': valorObjetivo,
      'unidad': unidad,
      'puntos_recompensa': puntosRecompensa,
      if (fecha != null) 'fecha': fecha,
    };
    final data = await RunnHttpClient.post('/retos/diario/manual', body: body);
    return RetoDiario.fromJson((data as Map<String, dynamic>)['reto'] as Map<String, dynamic>);
  }

  static Future<RetoSemanal> crearRetoSemanalManual({
    required String titulo,
    String? descripcion,
    required String tipo,
    required double valorObjetivo,
    required String unidad,
    int puntosRecompensa = 50,
    String? semanaInicio,
  }) async {
    final body = <String, dynamic>{
      'titulo': titulo,
      if (descripcion != null) 'descripcion': descripcion,
      'tipo': tipo,
      'valor_objetivo': valorObjetivo,
      'unidad': unidad,
      'puntos_recompensa': puntosRecompensa,
      if (semanaInicio != null) 'semana_inicio': semanaInicio,
    };
    final data = await RunnHttpClient.post('/retos/semanal/manual', body: body);
    return RetoSemanal.fromJson((data as Map<String, dynamic>)['reto'] as Map<String, dynamic>);
  }

  // ─── ADMIN: Editar ────────────────────────────────────────────────────────
  static Future<void> editarRetoDiario(String id, Map<String, dynamic> body) async {
    await RunnHttpClient.put('/retos/diario/$id', body: body);
  }

  static Future<void> editarRetoSemanal(String id, Map<String, dynamic> body) async {
    await RunnHttpClient.put('/retos/semanal/$id', body: body);
  }

  // ─── ADMIN: Eliminar ──────────────────────────────────────────────────────
  static Future<void> eliminarRetoDiario(String id) async {
    await RunnHttpClient.delete('/retos/diario/$id');
  }

  static Future<void> eliminarRetoSemanal(String id) async {
    await RunnHttpClient.delete('/retos/semanal/$id');
  }
}
