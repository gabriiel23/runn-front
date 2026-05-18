import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/features/home/data/models/frase_model.dart';

class FrasesService {
  static Future<List<FraseModel>> getFrasesActivas() async {
    final response = await RunnHttpClient.get('/frases');
    final List list = (response as Map<String, dynamic>)['frases'] as List;
    return list.map((e) => FraseModel.fromJson(e)).toList();
  }

  static Future<List<FraseModel>> getAdminFrases() async {
    final response = await RunnHttpClient.get('/frases/admin/todas');
    final List list = (response as Map<String, dynamic>)['frases'] as List;
    return list.map((e) => FraseModel.fromJson(e)).toList();
  }

  static Future<FraseModel> generarConIA() async {
    final response = await RunnHttpClient.post('/frases/generar');
    return FraseModel.fromJson((response as Map<String, dynamic>)['frase']);
  }

  static Future<FraseModel> regenerarConIA(String id) async {
    final response = await RunnHttpClient.post('/frases/$id/regenerar');
    return FraseModel.fromJson((response as Map<String, dynamic>)['frase']);
  }

  static Future<FraseModel> crearFraseManual({
    required String frase,
    required String autor,
    DateTime? vigenteDesde,
    DateTime? vigenteHasta,
  }) async {
    final response = await RunnHttpClient.post(
      '/frases/manual',
      body: {
        'frase': frase,
        'autor': autor,
        if (vigenteDesde != null) 'vigente_desde': vigenteDesde.toIso8601String(),
        if (vigenteHasta != null) 'vigente_hasta': vigenteHasta.toIso8601String(),
      },
    );
    return FraseModel.fromJson((response as Map<String, dynamic>)['frase']);
  }

  static Future<FraseModel> actualizarFrase({
    required String id,
    String? frase,
    String? autor,
    bool? activa,
    DateTime? vigenteDesde,
    DateTime? vigenteHasta,
  }) async {
    final body = <String, dynamic>{};
    if (frase != null) body['frase'] = frase;
    if (autor != null) body['autor'] = autor;
    if (activa != null) body['activa'] = activa;
    if (vigenteDesde != null) body['vigente_desde'] = vigenteDesde.toIso8601String();
    if (vigenteHasta != null) body['vigente_hasta'] = vigenteHasta.toIso8601String();

    // Permitir enviar null explicitly (requires backend logic adjustment but assuming standard behavior)
    if (body.isEmpty) return FraseModel(id: id, frase: '', autor: ''); // Dummy return on empty update

    final response = await RunnHttpClient.put('/frases/$id', body: body);
    return FraseModel.fromJson((response as Map<String, dynamic>)['frase']);
  }

  static Future<void> eliminarFrase(String id) async {
    await RunnHttpClient.delete('/frases/$id');
  }
}
