import '../../../core/services/http_client.dart';

/// Modelo básico para listar usuarios en el panel o funciones de administrador.
class UsuarioAdminModel {
  final String id;
  final String nombre;
  final String correo;
  final String? rol;
  final String? nivel;
  final String? ciudad;
  final String? avatarUrl;

  UsuarioAdminModel({
    required this.id,
    required this.nombre,
    required this.correo,
    this.rol,
    this.nivel,
    this.ciudad,
    this.avatarUrl,
  });

  factory UsuarioAdminModel.fromJson(Map<String, dynamic> json) {
    return UsuarioAdminModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      rol: json['rol'] as String?,
      nivel: json['nivel'] as String?,
      ciudad: json['ciudad'] as String?,
      avatarUrl: json['avatar_url'] as String?, // Por si el backend lo envía luego
    );
  }
}

/// Servicio dedicado a endpoints con el middleware de admin.
class AdminService {
  // ─── OBTENER TODOS LOS USUARIOS ───────────────────────────────────────────
  // GET /admin/usuarios

  static Future<List<UsuarioAdminModel>> getUsuarios() async {
    final response = await RunnHttpClient.get('/admin/usuarios');
    final lista = response['usuarios'] as List<dynamic>? ?? [];
    return lista
        .map((u) => UsuarioAdminModel.fromJson(u as Map<String, dynamic>))
        .toList();
  }
}
