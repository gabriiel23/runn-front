import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/api_config.dart';
import '../../../core/services/http_client.dart';
import '../domain/models/usuario_model.dart';
import '../domain/models/insignia_model.dart';

/// Servicio para el perfil propio del usuario logueado.
/// Cubre los endpoints que afectan al usuario autenticado.
class ProfileService {
  // ─── OBTENER PERFIL PROPIO ─────────────────────────────────────────────────
  // GET /auth/perfil

  static Future<UsuarioModel> getMyProfile() async {
    final data = await RunnHttpClient.get('/auth/perfil');
    final usuario = UsuarioModel.fromJson(data['usuario'] as Map<String, dynamic>);

    // Sincronizar SharedPreferences con los datos frescos del servidor
    final prefs = await SharedPreferences.getInstance();
    await ApiConfig.saveUserSession(
      token: (await ApiConfig.getToken()) ?? '',
      id: usuario.id,
      nombre: usuario.nombre,
      correo: usuario.correo,
      nivel: usuario.nivel,
      puntos: usuario.puntos,
      biografia: usuario.biografia,
      avatarUrl: usuario.avatarUrl,
      ciudad: usuario.ciudad,
      pais: usuario.pais,
      pesoKg: usuario.pesoKg,
      alturaCm: usuario.alturaCm,
    );
    // Garantizar que el avatar URL esté siempre en caché
    if (usuario.avatarUrl != null && usuario.avatarUrl!.isNotEmpty) {
      await prefs.setString(ApiConfig.userAvatarKey, usuario.avatarUrl!);
    }

    return usuario;
  }

  // ─── OBTENER PERFIL DESDE CACHÉ LOCAL ─────────────────────────────────────
  // Lee los datos guardados en SharedPreferences sin hacer petición HTTP.
  // Usar cuando se quiere una carga instantánea y luego refrescar en segundo plano.

  static Future<Map<String, dynamic>> getLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(ApiConfig.userIdKey) ?? '',
      'nombre': prefs.getString(ApiConfig.userNameKey) ?? '',
      'correo': prefs.getString(ApiConfig.userEmailKey) ?? '',
      'nivel': prefs.getString(ApiConfig.userNivelKey),
      'puntos': prefs.getInt(ApiConfig.userPuntosKey) ?? 0,
      'biografia': prefs.getString(ApiConfig.userBioKey),
      'avatar_url': prefs.getString(ApiConfig.userAvatarKey),
      'ciudad': prefs.getString(ApiConfig.userCiudadKey),
      'pais': prefs.getString(ApiConfig.userPaisKey),
      'peso_kg': prefs.getDouble(ApiConfig.userPesoKey),
      'altura_cm': prefs.getDouble(ApiConfig.userAlturaKey),
    };
  }

  // ─── EDITAR PERFIL ─────────────────────────────────────────────────────────
  // PUT /usuarios/perfil

  static Future<UsuarioModel> editProfile({
    String? nombre,
    String? biografia,
    double? pesoKg,
    double? alturaCm,
    String? ciudad,
    String? pais,
    String? nivel,
    String? genero,
  }) async {
    final body = <String, dynamic>{};
    if (nombre != null && nombre.isNotEmpty) body['nombre'] = nombre;
    if (biografia != null) body['biografia'] = biografia;
    if (pesoKg != null) body['peso_kg'] = pesoKg;
    if (alturaCm != null) body['altura_cm'] = alturaCm;
    if (ciudad != null && ciudad.isNotEmpty) body['ciudad'] = ciudad;
    if (pais != null && pais.isNotEmpty) body['pais'] = pais;
    if (nivel != null && nivel.isNotEmpty) body['nivel'] = nivel;
    if (genero != null && genero.isNotEmpty) body['genero'] = genero;

    final data = await RunnHttpClient.put('/usuarios/perfil', body: body);
    final usuario = UsuarioModel.fromJson(data['usuario'] as Map<String, dynamic>);

    // Actualizar caché local con los nuevos datos
    final prefs = await SharedPreferences.getInstance();
    if (nombre != null) await prefs.setString(ApiConfig.userNameKey, usuario.nombre);
    if (biografia != null) await prefs.setString(ApiConfig.userBioKey, usuario.biografia ?? '');
    if (ciudad != null) await prefs.setString(ApiConfig.userCiudadKey, usuario.ciudad ?? '');
    if (pais != null) await prefs.setString(ApiConfig.userPaisKey, usuario.pais ?? '');
    if (nivel != null) await prefs.setString(ApiConfig.userNivelKey, usuario.nivel ?? '');
    if (pesoKg != null) await prefs.setDouble(ApiConfig.userPesoKey, usuario.pesoKg ?? 0);
    if (alturaCm != null) await prefs.setDouble(ApiConfig.userAlturaKey, usuario.alturaCm ?? 0);

    return usuario;
  }

  // ─── SUBIR AVATAR ──────────────────────────────────────────────────────────
  // POST /usuarios/avatar

  static Future<String> uploadAvatar(List<int> bytes, String filename) async {
    final data = await RunnHttpClient.postMultipart(
      '/usuarios/avatar',
      bytes: bytes,
      filename: filename,
      fieldName: 'avatar',
    );

    final avatarUrl = data['avatar_url'] as String;

    // Actualizar caché local
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.userAvatarKey, avatarUrl);

    return avatarUrl;
  }

  static Future<String> uploadMedia(List<int> bytes, String filename) async {
    final data = await RunnHttpClient.postMultipart(
      '/usuarios/media',
      bytes: bytes,
      filename: filename,
      fieldName: 'foto',
    );
    final url = data['url'] as String;
    await addLocalMedia(url);
    return url;
  }

  // ─── MULTIMEDIA (BACKEND) ─────────────────────────────────────────────────
  // GET /usuarios/media

  /// Devuelve la lista de fotos multimedia del usuario desde el servidor.
  /// Cada elemento es un Map con `id` y `url`.
  static Future<List<Map<String, String>>> getMedia() async {
    try {
      final data = await RunnHttpClient.get('/usuarios/media');
      final fotos = data['fotos'] as List<dynamic>? ?? [];
      final result = fotos.map((f) => {
        'id': f['id']?.toString() ?? '',
        'url': f['url']?.toString() ?? '',
      }).where((m) => m['url']!.isNotEmpty).toList();

      // Sincronizar URLs en caché local para acceso offline
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'userMediaUrls',
        result.map((m) => m['url']!).toList(),
      );

      return result;
    } catch (_) {
      // Fallback: devolver el caché local como sólo-urls (sin id)
      return (await getLocalMedia())
          .map((url) => {'id': '', 'url': url})
          .toList();
    }
  }

  // DELETE /usuarios/media/:id

  static Future<void> deleteMedia(String id) async {
    await RunnHttpClient.delete('/usuarios/media/$id');
  }

  // ─── CACHÉ LOCAL DE MULTIMEDIA (fallback) ─────────────────────────────────

  static Future<List<String>> getLocalMedia() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('userMediaUrls') ?? [];
  }

  static Future<void> addLocalMedia(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final urls = prefs.getStringList('userMediaUrls') ?? [];
    if (!urls.contains(url)) urls.add(url);
    await prefs.setStringList('userMediaUrls', urls);
  }

  static Future<void> removeLocalMedia(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final urls = prefs.getStringList('userMediaUrls') ?? [];
    urls.remove(url);
    await prefs.setStringList('userMediaUrls', urls);
  }

  // ─── MIS SEGUIDORES ────────────────────────────────────────────────────────
  // GET /usuarios/yo/seguidores

  static Future<Map<String, dynamic>> getMisSeguidores() async {
    return await RunnHttpClient.get('/usuarios/yo/seguidores')
        as Map<String, dynamic>;
  }

  // ─── A QUIÉNES SIGO ────────────────────────────────────────────────────────
  // GET /usuarios/yo/siguiendo

  static Future<Map<String, dynamic>> getMisSiguiendo() async {
    return await RunnHttpClient.get('/usuarios/yo/siguiendo')
        as Map<String, dynamic>;
  }
  // ─── MIS INSIGNIAS ─────────────────────────────────────────────────────────
  // GET /actividades/mis-actividades/insignias

  static Future<InsigniasResult> getInsignias() async {
    final data = await RunnHttpClient.get('/actividades/mis-actividades/insignias');
    return InsigniasResult.fromJson(data as Map<String, dynamic>);
  }
}
