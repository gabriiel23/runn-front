class FraseModel {
  final String id;
  final String frase;
  final String autor;
  final bool activa;
  final bool generadoPorIa;
  final DateTime? vigenteDesde;
  final DateTime? vigenteHasta;
  final DateTime? creadoEn;

  FraseModel({
    required this.id,
    required this.frase,
    required this.autor,
    this.activa = true,
    this.generadoPorIa = false,
    this.vigenteDesde,
    this.vigenteHasta,
    this.creadoEn,
  });

  factory FraseModel.fromJson(Map<String, dynamic> json) {
    return FraseModel(
      id: json['id'] as String,
      frase: json['frase'] as String,
      autor: json['autor'] as String,
      activa: json['activa'] as bool? ?? true,
      generadoPorIa: json['generado_por_ia'] as bool? ?? false,
      vigenteDesde: json['vigente_desde'] != null ? DateTime.parse(json['vigente_desde'] as String) : null,
      vigenteHasta: json['vigente_hasta'] != null ? DateTime.parse(json['vigente_hasta'] as String) : null,
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en'] as String).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frase': frase,
      'autor': autor,
      'activa': activa,
      'generado_por_ia': generadoPorIa,
      'vigente_desde': vigenteDesde?.toIso8601String(),
      'vigente_hasta': vigenteHasta?.toIso8601String(),
      'creado_en': creadoEn?.toIso8601String(),
    };
  }
}
