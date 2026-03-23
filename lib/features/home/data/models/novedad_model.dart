class NovedadModel {
  final String id;
  final String titulo;
  final String? descripcion;
  final String? fotoUrl;
  final String tipo;
  final String? urlExterna;
  final bool activa;
  final bool destacada;
  final DateTime? publicadoEn;
  final DateTime? creadoEn;

  NovedadModel({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.fotoUrl,
    required this.tipo,
    this.urlExterna,
    required this.activa,
    required this.destacada,
    this.publicadoEn,
    this.creadoEn,
  });

  factory NovedadModel.fromJson(Map<String, dynamic> json) {
    return NovedadModel(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      fotoUrl: json['foto_url']?.toString(),
      tipo: json['tipo']?.toString() ?? 'noticia',
      urlExterna: json['url_externa']?.toString(),
      activa: json['activa'] == true,
      destacada: json['destacada'] == true,
      publicadoEn: json['publicado_en'] != null ? DateTime.tryParse(json['publicado_en']) : null,
      creadoEn: json['creado_en'] != null ? DateTime.tryParse(json['creado_en']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'foto_url': fotoUrl,
      'tipo': tipo,
      'url_externa': urlExterna,
      'activa': activa,
      'destacada': destacada,
      'publicado_en': publicadoEn?.toIso8601String(),
      'creado_en': creadoEn?.toIso8601String(),
    };
  }
}
