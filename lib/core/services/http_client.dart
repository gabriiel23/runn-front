import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Excepción tipada para errores de la API.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? codigoError; // Campo estructurado del backend (ej: 'ruta_incompleta')

  const ApiException(this.message, {this.statusCode, this.codigoError});

  @override
  String toString() => 'ApiException($statusCode, $codigoError): $message';
}

/// Cliente HTTP centralizado para la API de RUNN.
/// Todos los métodos inyectan automáticamente el JWT de SharedPreferences.
class RunnHttpClient {
  // Timeout para todas las peticiones
  static const _timeout = Duration(seconds: 15);

  // ─── GET ──────────────────────────────────────────────────────────────────

  static Future<dynamic> get(String path) async {
    final headers = await ApiConfig.getAuthHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    try {
      final response = await http.get(uri, headers: headers).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException('Sin conexión al servidor. Verifica tu red.');
    } on http.ClientException {
      throw const ApiException('Error de conexión. Intenta de nuevo.');
    }
  }

  // ─── POST ─────────────────────────────────────────────────────────────────

  static Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final headers = await ApiConfig.getAuthHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    try {
      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException('Sin conexión al servidor. Verifica tu red.');
    } on http.ClientException {
      throw const ApiException('Error de conexión. Intenta de nuevo.');
    }
  }

  // ─── PUT ──────────────────────────────────────────────────────────────────

  static Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final headers = await ApiConfig.getAuthHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    try {
      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException('Sin conexión al servidor. Verifica tu red.');
    } on http.ClientException {
      throw const ApiException('Error de conexión. Intenta de nuevo.');
    }
  }

  // ─── PATCH ────────────────────────────────────────────────────────────────

  static Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final headers = await ApiConfig.getAuthHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    try {
      final response = await http
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException('Sin conexión al servidor. Verifica tu red.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException('Error de conexión. Intenta de nuevo.');
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  static Future<dynamic> delete(String path) async {
    final headers = await ApiConfig.getAuthHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    try {
      final response =
          await http.delete(uri, headers: headers).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException('Sin conexión al servidor. Verifica tu red.');
    } on http.ClientException {
      throw const ApiException('Error de conexión. Intenta de nuevo.');
    }
  }

  // ─── MULTIPART (subida de archivos) ───────────────────────────────────────

  /// Deduce el MIME type desde la extensión del nombre de archivo.
  static String _mimeTypeFromFilename(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg'; // fallback seguro para fotos de galería
    }
  }

  static Future<dynamic> postMultipart(
    String path, {
    required List<int> bytes,
    required String filename,
    required String fieldName,
    Map<String, String>? fields,
  }) async {
    final token = await ApiConfig.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    try {
      final request = http.MultipartRequest('POST', uri);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final mimeType = _mimeTypeFromFilename(filename);
      final parts = mimeType.split('/');
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: http.MediaType(parts[0], parts[1]),
        ),
      );

      final streamedResponse =
          await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException('Sin conexión al servidor. Verifica tu red.');
    } on TimeoutException {
      throw const ApiException('La conexión tardó demasiado (Timeout). Intenta de nuevo.');
    } on http.ClientException {
      throw const ApiException('Error de conexión. Intenta de nuevo.');
    }
  }

  /// Multipart PUT para actualizar recursos con archivo (ej: editar evento con foto).
  static Future<dynamic> putMultipart(
    String path, {
    required Map<String, String> fields,
    required List<int> bytes,
    required String filename,
    required String fieldName,
  }) async {
    final token = await ApiConfig.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    try {
      final request = http.MultipartRequest('PUT', uri);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Campos de texto (titulo, fecha, etc.)
      request.fields.addAll(fields);

      // Archivo
      final mimeType = _mimeTypeFromFilename(filename);
      final parts = mimeType.split('/');
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: http.MediaType(parts[0], parts[1]),
        ),
      );

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException('Sin conexión al servidor. Verifica tu red.');
    } on TimeoutException {
      throw const ApiException('La conexión tardó demasiado (Timeout). Intenta de nuevo.');
    } on http.ClientException {
      throw const ApiException('Error de conexión. Intenta de nuevo.');
    }
  }

  // ─── HANDLER DE RESPUESTA ─────────────────────────────────────────────────

  static dynamic _handleResponse(http.Response response) {
    // Intentar parsear JSON siempre
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      body = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Extraer mensaje de error del body si existe
    String errorMessage = 'Error del servidor (${response.statusCode})';
    String? codigoError;
    if (body is Map) {
      if (body.containsKey('mensaje')) {
        errorMessage = body['mensaje'] as String;
      }
      if (body.containsKey('codigo_error')) {
        codigoError = body['codigo_error'] as String?;
      }
    }

    throw ApiException(errorMessage, statusCode: response.statusCode, codigoError: codigoError);
  }
}
