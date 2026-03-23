import '../../../core/services/http_client.dart';
import '../domain/models/usuario_community_model.dart';

/// Servicio para operaciones de comunidad relacionadas con usuarios.
/// Cubre listado, búsqueda, perfil ajeno y seguimiento.
class UsuariosService {
  // ─── LISTAR / BUSCAR USUARIOS ──────────────────────────────────────────────
  // GET /usuarios
  // GET /usuarios?buscar=nombre

  static Future<List<UsuarioCommunityModel>> getUsuarios({
    String? buscar,
    String? nivel,
    String? ciudad,
  }) async {
    final queryParams = <String, String>{};
    if (buscar != null && buscar.isNotEmpty) queryParams['buscar'] = buscar;
    if (nivel != null && nivel.isNotEmpty) queryParams['nivel'] = nivel;
    if (ciudad != null && ciudad.isNotEmpty) queryParams['ciudad'] = ciudad;

    final uri = Uri(path: '/usuarios', queryParameters: queryParams.isNotEmpty ? queryParams : null);
    
    final data = await RunnHttpClient.get(uri.toString());
    final lista = data['usuarios'] as List<dynamic>;

    return lista
        .map((u) => UsuarioCommunityModel.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  // ─── ESTADÍSTICAS COMUNIDAD ───────────────────────────────────────────────
  // GET /usuarios/stats

  static Future<Map<String, int>> getCommunityStats() async {
    final response = await RunnHttpClient.get('/usuarios/stats');
    return {
      'grupos': response['grupos'] as int? ?? 0,
      'runners': response['runners'] as int? ?? 0,
      'eventos': response['eventos'] as int? ?? 0,
    };
  }

  // ─── VER PERFIL DE OTRO USUARIO ───────────────────────────────────────────
  // GET /usuarios/:id

  static Future<UsuarioCommunityModel> getUsuarioPerfil(String id) async {
    final data = await RunnHttpClient.get('/usuarios/$id');

    // El backend devuelve { usuario, seguidores, seguidos, yo_lo_sigo }
    final usuarioJson = data['usuario'] as Map<String, dynamic>;
    usuarioJson['seguidores'] = data['seguidores'];
    usuarioJson['seguidos'] = data['seguidos'];
    usuarioJson['yo_lo_sigo'] = data['yo_lo_sigo'];

    return UsuarioCommunityModel.fromJson(usuarioJson);
  }

  // ─── SEGUIR USUARIO ───────────────────────────────────────────────────────
  // POST /usuarios/:id/seguir

  static Future<void> seguirUsuario(String id) async {
    await RunnHttpClient.post('/usuarios/$id/seguir');
  }

  // ─── DEJAR DE SEGUIR ──────────────────────────────────────────────────────
  // DELETE /usuarios/:id/seguir

  static Future<void> dejarDeSeguir(String id) async {
    await RunnHttpClient.delete('/usuarios/$id/seguir');
  }

  // ─── OBTENER MULTIMEDIA (PÚBLICA) ─────────────────────────────────────────
  // GET /usuarios/:id/media
  
  static Future<List<Map<String, String>>> getUsuarioMedia(String id) async {
    final response = await RunnHttpClient.get('/usuarios/$id/media');
    final fotosList = response['fotos'] as List<dynamic>? ?? [];
    
    return fotosList.map((m) => {
      'id': m['id']?.toString() ?? '',
      'url': m['url']?.toString() ?? '',
    }).toList();
  }
}
