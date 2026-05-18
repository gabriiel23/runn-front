import '../../../core/services/http_client.dart';
import '../data/models/territory_model.dart';
import '../data/models/ranking_model.dart';

/// Servicio para el módulo de Territorios de RUNN.
/// Consume la API REST en /territorios.
class TerritorioService {
  // ─── LISTAR TODOS LOS TERRITORIOS ──────────────────────────────────────────
  // GET /territorios?modalidad=individual|grupal

  static Future<List<TerritoryModel>> getTerritorios({
    String? modalidad,
  }) async {
    final query = modalidad != null ? '?modalidad=$modalidad' : '';
    final data = await RunnHttpClient.get('/territorios$query');
    final lista = data['territorios'] as List<dynamic>? ?? [];
    return lista
        .map((t) => TerritoryModel.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  // ─── DETALLE DE UN TERRITORIO ──────────────────────────────────────────────
  // GET /territorios/:id

  static Future<TerritoryModel> getTerritorioDetalle(String id) async {
    final data = await RunnHttpClient.get('/territorios/$id');
    final territorioJson = data['territorio'] as Map<String, dynamic>;
    final historialJson = data['historial'] as List<dynamic>? ?? [];

    // Combinar territorio + historial en el modelo
    final merged = Map<String, dynamic>.from(territorioJson)
      ..['historial'] = historialJson;

    return TerritoryModel.fromJson(merged);
  }

  // ─── MIS TERRITORIOS ───────────────────────────────────────────────────────
  // GET /territorios/usuario/mis-territorios

  static Future<List<TerritoryModel>> getMisTerritorios() async {
    final data = await RunnHttpClient.get('/territorios/usuario/mis-territorios');
    final lista = data['territorios'] as List<dynamic>? ?? [];
    return lista
        .map((t) => TerritoryModel.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  // ─── TERRITORIOS DE UN GRUPO ───────────────────────────────────────────────
  // GET /territorios/grupo/:grupo_id

  static Future<List<TerritoryModel>> getTerritoriosGrupo(String grupoId) async {
    final data = await RunnHttpClient.get('/territorios/grupo/$grupoId');
    final lista = data['territorios'] as List<dynamic>? ?? [];
    return lista
        .map((t) => TerritoryModel.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  // ─── RANKING INDIVIDUAL ────────────────────────────────────────────────────
  // GET /territorios/ranking/individual

  static Future<List<RankingUsuarioModel>> getRankingIndividual() async {
    final data = await RunnHttpClient.get('/territorios/ranking/individual');
    final lista = data['ranking'] as List<dynamic>? ?? [];
    return lista
        .map((r) => RankingUsuarioModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ─── RANKING GRUPAL ────────────────────────────────────────────────────────
  // GET /territorios/ranking/grupal

  static Future<List<RankingGrupoModel>> getRankingGrupal() async {
    final data = await RunnHttpClient.get('/territorios/ranking/grupal');
    final lista = data['ranking'] as List<dynamic>? ?? [];
    return lista
        .map((r) => RankingGrupoModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ─── VERIFICAR PROXIMIDAD ───────────────────────────────────────────────────
  // GET /territorios/:id/proximidad?lat=&lng=

  /// Verifica si las coordenadas [lat]/[lng] están lo suficientemente cerca
  /// del polígono del territorio para iniciar una conquista (≤ 500 m).
  static Future<Map<String, dynamic>> verificarProximidad({
    required String territorioId,
    required double lat,
    required double lng,
  }) async {
    return await RunnHttpClient.get(
      '/territorios/$territorioId/proximidad?lat=$lat&lng=$lng',
    ) as Map<String, dynamic>;
  }

  // ─── CONQUISTAR / DISPUTAR TERRITORIO ─────────────────────────────────────
  // POST /territorios/:id/conquistar

  static Future<Map<String, dynamic>> conquistar({
    required String territorioId,
    required String actividadId,
    required int tiempoSegs,
    required String modalidad,
    String? grupoId,
  }) async {
    final body = <String, dynamic>{
      'actividad_id': actividadId,
      'tiempo_segs': tiempoSegs,
      'modalidad': modalidad,
      if (grupoId != null) 'grupo_id': grupoId,
    };
    return await RunnHttpClient.post(
      '/territorios/$territorioId/conquistar',
      body: body,
    ) as Map<String, dynamic>;
  }

  // ─── CRUD DE ADMINISTRADOR ─────────────────────────────────────────────────
  // POST /territorios

  static Future<void> createTerritorio({
    required String nombre,
    String? descripcion,
    required String poligono,
    String modalidad = 'individual',
  }) async {
    await RunnHttpClient.post('/territorios', body: {
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      'poligono': poligono,
      'modalidad': modalidad,
    });
  }

  // PUT /territorios/:id

  static Future<void> updateTerritorio({
    required String id,
    required String nombre,
    String? descripcion,
    required String poligono,
    String modalidad = 'individual',
  }) async {
    await RunnHttpClient.put('/territorios/$id', body: {
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      'poligono': poligono,
      'modalidad': modalidad,
    });
  }

  // DELETE /territorios/:id

  static Future<void> deleteTerritorio(String id) async {
    await RunnHttpClient.delete('/territorios/$id');
  }
}
