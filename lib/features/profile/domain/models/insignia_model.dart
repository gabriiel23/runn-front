// Modelo para una insignia (general o de distancia)
class InsigniaModel {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? iconoUrl;
  final String? condicion;
  final bool desbloqueada;
  final DateTime? ganadoEn;
  final double? progreso; // 0.0 – 1.0

  // Solo para insignias de distancia
  final double? kmRequeridos;
  final String? nivel;

  const InsigniaModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.iconoUrl,
    this.condicion,
    required this.desbloqueada,
    this.ganadoEn,
    this.progreso,
    this.kmRequeridos,
    this.nivel,
  });

  factory InsigniaModel.fromJson(Map<String, dynamic> json) {
    return InsigniaModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      iconoUrl: json['icono_url']?.toString(),
      condicion: json['condicion']?.toString(),
      desbloqueada: json['desbloqueada'] == true,
      ganadoEn: json['ganado_en'] != null
          ? DateTime.tryParse(json['ganado_en'].toString())
          : null,
      progreso: (json['progreso'] as num?)?.toDouble(),
      kmRequeridos: (json['km_requeridos'] as num?)?.toDouble(),
      nivel: json['nivel']?.toString(),
    );
  }

  String get fechaFormateada {
    if (ganadoEn == null) return '';
    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                   'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${ganadoEn!.day} ${meses[ganadoEn!.month - 1]}. ${ganadoEn!.year}';
  }
}

class InsigniasResult {
  final List<InsigniaModel> generales;
  final List<InsigniaModel> distancia;
  final double distanciaTotalKm;

  const InsigniasResult({
    required this.generales,
    required this.distancia,
    required this.distanciaTotalKm,
  });

  List<InsigniaModel> get todas => [...generales, ...distancia];
  List<InsigniaModel> get desbloqueadas => todas.where((i) => i.desbloqueada).toList();
  List<InsigniaModel> get bloqueadas => todas.where((i) => !i.desbloqueada).toList();

  factory InsigniasResult.fromJson(Map<String, dynamic> json) {
    return InsigniasResult(
      generales: ((json['insignias'] as List?) ?? [])
          .map((e) => InsigniaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      distancia: ((json['insignias_distancia'] as List?) ?? [])
          .map((e) => InsigniaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      distanciaTotalKm: (json['distancia_total_km'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
