import 'dart:io';
import 'package:runn_front/core/services/http_client.dart';
import '../domain/actividad_model.dart';

class ActividadesService {
  // ─── INICIAR ACTIVIDAD ──────────────────────────────────────────────────────
  // POST /actividades/iniciar
  static Future<ActividadInicio> iniciarActividad({
    String tipo = 'correr',
    String modalidad = 'individual',
  }) async {
    final data = await RunnHttpClient.post('/actividades/iniciar', body: {
      'tipo': tipo,
      'modalidad': modalidad,
    });
    return ActividadInicio.fromJson(data as Map<String, dynamic>);
  }

  // ─── FINALIZAR ACTIVIDAD ────────────────────────────────────────────────────
  // PUT /actividades/:id/finalizar
  static Future<Map<String, dynamic>> finalizarActividad(
    String actividadId, {
    required double distanciaKm,
    required int duracionSegs,
    required double velocidadPromedio,
    required double velocidadMax,
    required double ritmoPromedio,
    required int calorias,
    String? ruta,
  }) async {
    final data = await RunnHttpClient.put(
      '/actividades/$actividadId/finalizar',
      body: {
        'distancia_km': distanciaKm,
        'duracion_segs': duracionSegs,
        'velocidad_promedio': velocidadPromedio,
        'velocidad_max': velocidadMax,
        'ritmo_promedio': ritmoPromedio,
        'calorias': calorias,
        if (ruta != null) 'ruta': ruta,
      },
    );
    return data as Map<String, dynamic>;
  }

  // ─── COMPARTIR ACTIVIDAD ────────────────────────────────────────────────────
  // PATCH /actividades/:id/compartir
  static Future<void> compartirActividad(String actividadId) async {
    await RunnHttpClient.patch('/actividades/$actividadId/compartir');
  }

  // ─── AGREGAR FOTO A ACTIVIDAD ───────────────────────────────────────────────
  // POST /actividades/:id/foto
  static Future<Map<String, dynamic>> agregarFoto(
    String actividadId,
    File foto,
  ) async {
    final bytes = await foto.readAsBytes();
    final filename = foto.path.split(Platform.pathSeparator).last;

    final response = await RunnHttpClient.postMultipart(
      '/actividades/$actividadId/foto',
      bytes: bytes,
      filename: filename,
      fieldName: 'foto',
    );
    return response as Map<String, dynamic>;
  }

  // ─── OBTENER HISTORIAL ──────────────────────────────────────────────────────
  // GET /actividades/mis-actividades/historial?limite=X&pagina=Y
  static Future<Map<String, dynamic>> obtenerHistorial({
    int limite = 20,
    int pagina = 1,
  }) async {
    // ignore: avoid_print
    print('[ActividadesService] GET /actividades/mis-actividades/historial?limite=$limite&pagina=$pagina');
    final response = await RunnHttpClient.get('/actividades/mis-actividades/historial?limite=$limite&pagina=$pagina');
    // ignore: avoid_print
    print('[ActividadesService] Respuesta historial raw: $response');
    
    final data = response as Map<String, dynamic>;
    final List<dynamic> historialJson = data['historial'] ?? [];

    final List<ActividadHistorial> historial = [];
    for (int i = 0; i < historialJson.length; i++) {
      try {
        final item = historialJson[i] as Map<String, dynamic>;
        // ignore: avoid_print
        print('[ActividadesService] Parseando item[$i]: id=${item['id']}, tipo=${item['tipo']}, distancia=${item['distancia_km']}');
        historial.add(ActividadHistorial.fromJson(item));
      } catch (e) {
        // ignore: avoid_print
        print('[ActividadesService] ERROR parseando item[$i]: $e');
        // ignore: avoid_print
        print('[ActividadesService] Item[$i] data: ${historialJson[i]}');
      }
    }
    // ignore: avoid_print
    print('[ActividadesService] Total parseados: ${historial.length} de ${historialJson.length}');
    
    return {
      'total': data['total'],
      'pagina': data['pagina'],
      'total_paginas': data['total_paginas'],
      'historial': historial,
    };
  }

  // ─── OBTENER ESTADÍSTICAS ───────────────────────────────────────────────────
  // GET /actividades/mis-actividades/estadisticas
  static Future<ActividadEstadisticas> obtenerEstadisticas() async {
    // ignore: avoid_print
    print('[ActividadesService] GET /actividades/mis-actividades/estadisticas');
    final response = await RunnHttpClient.get('/actividades/mis-actividades/estadisticas');
    // ignore: avoid_print
    print('[ActividadesService] Respuesta estadisticas: $response');
    return ActividadEstadisticas.fromJson(response as Map<String, dynamic>);
  }

  // ─── OBTENER DETALLE ────────────────────────────────────────────────────────
  // GET /actividades/:id
  static Future<ActividadHistorial> obtenerDetalle(String id) async {
    final response = await RunnHttpClient.get('/actividades/$id');
    final data = response as Map<String, dynamic>;
    return ActividadHistorial.fromJson(data['actividad'] as Map<String, dynamic>);
  }
}
