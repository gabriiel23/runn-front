import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/features/home/data/models/novedad_model.dart';

class NovedadesService {
  static Future<String?> _getToken() async {
    return await ApiConfig.getToken();
  }

  /// Obtiene la lista de novedades para el frontend comercial (solo las activas).
  static Future<List<NovedadModel>> getNovedades({String? tipo}) async {
    final queryParams = <String, String>{};
    if (tipo != null && tipo.isNotEmpty) {
      queryParams['tipo'] = tipo;
    }

    final queryStr = queryParams.isNotEmpty 
        ? '?${Uri(queryParameters: queryParams).query}'
        : '';

    final res = await RunnHttpClient.get('/novedades$queryStr');
    if (res['novedades'] != null) {
      return (res['novedades'] as List).map((n) => NovedadModel.fromJson(n)).toList();
    }
    return [];
  }

  /// Obtiene la lista COMPLETA de novedades para administradores (incluye inactivas).
  static Future<List<NovedadModel>> getAdminNovedades() async {
    final res = await RunnHttpClient.get('/novedades/admin');
    if (res['novedades'] != null) {
      return (res['novedades'] as List).map((n) => NovedadModel.fromJson(n)).toList();
    }
    return [];
  }

  /// Obtiene los detalles de una novedad por ID.
  static Future<NovedadModel> getNovedadDetalle(String id) async {
    final res = await RunnHttpClient.get('/novedades/$id');
    if (res['novedad'] != null) {
      return NovedadModel.fromJson(res['novedad']);
    }
    throw ApiException('No se encontró la novedad solicitada.');
  }

  /// Crea una nueva novedad (solo admin).
  static Future<NovedadModel> crearNovedad(Map<String, dynamic> data, {Uint8List? fotoBytes}) async {
    return _sendMultipartRequest('POST', '/novedades', data, fotoBytes: fotoBytes);
  }

  /// Edita una novedad existente (solo admin).
  static Future<NovedadModel> editarNovedad(String id, Map<String, dynamic> data, {Uint8List? fotoBytes}) async {
    return _sendMultipartRequest('PUT', '/novedades/$id', data, fotoBytes: fotoBytes);
  }

  /// Cambia el estado (activa/inactiva) de una novedad.
  static Future<void> cambiarEstado(String id, bool activa) async {
    await RunnHttpClient.patch('/novedades/$id/estado', body: {'activa': activa});
  }

  /// Cambia el estado destacado de una novedad.
  static Future<void> cambiarDestacado(String id, bool destacada) async {
    await RunnHttpClient.patch('/novedades/$id/destacar', body: {'destacada': destacada});
  }

  /// Elimina una novedad físicamente.
  static Future<void> eliminarNovedad(String id) async {
    await RunnHttpClient.delete('/novedades/$id');
  }

  /// Lógica de envío común para Multipart (Crear y Editar con o sin imagen).
  static Future<NovedadModel> _sendMultipartRequest(String method, String endpoint, Map<String, dynamic> data, {Uint8List? fotoBytes}) async {
    final token = await _getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final request = http.MultipartRequest(method, uri);

    request.headers.addAll({
      if (token != null) 'Authorization': 'Bearer $token',
    });

    data.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (fotoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'foto',
          fotoBytes,
          filename: 'novedad_foto.jpg',
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['novedad'] != null) {
          return NovedadModel.fromJson(responseData['novedad']);
        }
        throw ApiException('Respuesta inesperada del servidor.');
      } else {
        throw ApiException(responseData['mensaje'] ?? 'Error desconocido');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error de conexión con el servidor: $e');
    }
  }
}
