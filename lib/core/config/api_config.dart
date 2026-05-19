import 'package:shared_preferences/shared_preferences.dart';

/// Configuración central de la API de RUNN.
/// Ajusta [baseUrl] si cambias de emulador a dispositivo físico.
class ApiConfig {
  // IP desplegada
  // static const String baseUrl = 'http://31.97.100.216';

  // IP local casa
  static const String baseUrl = 'http://192.168.1.92:8005';

  // IP local empresa
  // static const String baseUrl = 'http://192.168.101.5:8005';

  // Claves de SharedPreferences
  static const String tokenKey = 'runn_token';
  static const String userIdKey = 'runn_user_id';
  static const String userNameKey = 'runn_user_nombre';
  static const String userEmailKey = 'runn_user_correo';
  static const String userNivelKey = 'runn_user_nivel';
  static const String userPuntosKey = 'runn_user_puntos';
  static const String userBioKey = 'runn_user_biografia';
  static const String userAvatarKey = 'runn_user_avatar_url';
  static const String userCiudadKey = 'runn_user_ciudad';
  static const String userPaisKey = 'runn_user_pais';
  static const String userPesoKey = 'runn_user_peso_kg';
  static const String userAlturaKey = 'runn_user_altura_cm';
  static const String userRolKey = 'runn_user_rol';

  /// Retorna los headers HTTP con Authorization Bearer si hay token.
  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey) ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Retorna el token guardado, o null si no existe.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  /// Guarda los datos del usuario después del login/registro.
  static Future<void> saveUserSession({
    required String token,
    required String id,
    required String nombre,
    required String correo,
    String? nivel,
    int? puntos,
    String? biografia,
    String? avatarUrl,
    String? ciudad,
    String? pais,
    double? pesoKg,
    double? alturaCm,
    String? rol,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userIdKey, id);
    await prefs.setString(userNameKey, nombre);
    await prefs.setString(userEmailKey, correo);
    if (nivel != null) await prefs.setString(userNivelKey, nivel);
    if (puntos != null) await prefs.setInt(userPuntosKey, puntos);
    if (biografia != null) await prefs.setString(userBioKey, biografia);
    if (avatarUrl != null) await prefs.setString(userAvatarKey, avatarUrl);
    if (ciudad != null) await prefs.setString(userCiudadKey, ciudad);
    if (pais != null) await prefs.setString(userPaisKey, pais);
    if (pesoKg != null) await prefs.setDouble(userPesoKey, pesoKg);
    if (alturaCm != null) await prefs.setDouble(userAlturaKey, alturaCm);
    if (rol != null) await prefs.setString(userRolKey, rol);
  }

  /// Retorna el rol completo del usuario guardado en sesión, o null si no existe.
  /// El rol puede ser una cadena compuesta separada por comas, p.ej. "admin_eventos,admin_noticias".
  static Future<String?> getUserRol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userRolKey);
  }

  // ─── HELPERS DE VERIFICACIÓN DE ROLES ─────────────────────────────────────

  /// Verifica si el usuario tiene un rol específico.
  /// Soporta roles compuestos separados por comas.
  /// `superadmin` y el heredado `admin` tienen acceso a todo.
  static Future<bool> _tieneRol(String rolRequerido) async {
    final rolString = await getUserRol();
    if (rolString == null || rolString.isEmpty) return false;
    final roles = rolString.split(',').map((r) => r.trim().toLowerCase()).toList();
    if (roles.contains('superadmin') || roles.contains('admin')) return true;
    return roles.contains(rolRequerido.toLowerCase());
  }

  /// Retorna true si el usuario es superadmin (o tiene el rol heredado 'admin').
  static Future<bool> isSuperAdmin() => _tieneRol('superadmin');

  /// Retorna true si el usuario puede crear/editar eventos.
  static Future<bool> isAdminEventos() => _tieneRol('admin_eventos');

  /// Retorna true si el usuario puede crear/editar noticias y frases.
  static Future<bool> isAdminNoticias() => _tieneRol('admin_noticias');

  /// Retorna el ID del usuario actual.
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  /// Limpia la sesión (logout).
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
