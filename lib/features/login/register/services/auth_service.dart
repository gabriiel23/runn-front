import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/core/config/api_config.dart';

class AuthService {
  /// Registra un nuevo usuario en PostgreSQL.
  /// Si es exitoso, guarda el token JWT y los datos del usuario en SharedPreferences.
  static Future<void> registro({
    required String nombre,
    required String correo,
    required String contrasena,
    required String confirmarContrasena,
  }) async {
    final response = await RunnHttpClient.post(
      '/auth/registro',
      body: {
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasena,
        'confirmar_contrasena': confirmarContrasena,
      },
    );

    final token = response['token'] as String;
    final userData = response['usuario'] as Map<String, dynamic>;

    await ApiConfig.saveUserSession(
      token: token,
      id: userData['id'],
      nombre: userData['nombre'],
      correo: userData['correo'],
    );
  }

  /// Actualiza las métricas físicas del usuario (última parte del registro y perfil del corredor).
  static Future<void> updateMetricas({
    required String genero,
    required DateTime fechaNacimiento,
    required String pais,
    required String ciudad,
    required double alturaCm,
    required double pesoKg,
    required String nivel,
  }) async {
    final response = await RunnHttpClient.put(
      '/auth/metricas',
      body: {
        'genero': genero,
        'fecha_nacimiento': fechaNacimiento.toIso8601String(),
        'pais': pais,
        'ciudad': ciudad,
        'altura_cm': alturaCm,
        'peso_kg': pesoKg,
        'nivel': nivel,
      },
    );

    final userData = response['usuario'] as Map<String, dynamic>;

    // Actualizar la información del usuario en caché local para que Perfil y Home se enteren
    final token = await ApiConfig.getToken() ?? '';
    await ApiConfig.saveUserSession(
      token: token,
      id: userData['id']?.toString() ?? '',
      nombre: userData['nombre']?.toString() ?? '',
      correo: userData['correo']?.toString() ?? '',
      nivel: userData['nivel']?.toString(),
      ciudad: userData['ciudad']?.toString(),
      pais: userData['pais']?.toString(),
      pesoKg: double.tryParse(userData['peso_kg']?.toString() ?? ''),
      alturaCm: double.tryParse(userData['altura_cm']?.toString() ?? ''),
    );
  }
}

