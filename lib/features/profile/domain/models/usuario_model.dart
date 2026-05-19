/// Modelo del perfil propio del usuario logueado.
class UsuarioModel {
  final String id;
  final String nombre;
  final String correo;
  final String? avatarUrl;
  final String? biografia;
  final String? genero;
  final String? pais;
  final String? ciudad;
  final double? pesoKg;
  final double? alturaCm;
  final String? nivel;
  final String? objetivo;
  final int puntos;
  final String? rol;
  final DateTime? creadoEn;

  const UsuarioModel({
    required this.id,
    required this.nombre,
    required this.correo,
    this.avatarUrl,
    this.biografia,
    this.genero,
    this.pais,
    this.ciudad,
    this.pesoKg,
    this.alturaCm,
    this.nivel,
    this.objetivo,
    this.puntos = 0,
    this.rol,
    this.creadoEn,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      biografia: json['biografia'] as String?,
      genero: json['genero'] as String?,
      pais: json['pais'] as String?,
      ciudad: json['ciudad'] as String?,
      pesoKg: json['peso_kg'] != null ? double.tryParse(json['peso_kg'].toString()) : null,
      alturaCm: json['altura_cm'] != null ? double.tryParse(json['altura_cm'].toString()) : null,
      nivel: json['nivel'] as String?,
      objetivo: json['objetivo'] as String?,
      puntos: (json['puntos'] as num?)?.toInt() ?? 0,
      rol: json['rol'] as String?,
      creadoEn: json['creado_en'] != null
          ? DateTime.tryParse(json['creado_en'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'correo': correo,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (biografia != null) 'biografia': biografia,
        if (genero != null) 'genero': genero,
        if (pais != null) 'pais': pais,
        if (ciudad != null) 'ciudad': ciudad,
        if (pesoKg != null) 'peso_kg': pesoKg,
        if (alturaCm != null) 'altura_cm': alturaCm,
        if (nivel != null) 'nivel': nivel,
        if (objetivo != null) 'objetivo': objetivo,
        'puntos': puntos,
        if (rol != null) 'rol': rol,
      };

  /// Crear una copia con algunos campos actualizados.
  UsuarioModel copyWith({
    String? nombre,
    String? biografia,
    String? avatarUrl,
    String? ciudad,
    String? pais,
    String? nivel,
    String? genero,
    double? pesoKg,
    double? alturaCm,
    int? puntos,
  }) {
    return UsuarioModel(
      id: id,
      nombre: nombre ?? this.nombre,
      correo: correo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      biografia: biografia ?? this.biografia,
      genero: genero ?? this.genero,
      pais: pais ?? this.pais,
      ciudad: ciudad ?? this.ciudad,
      pesoKg: pesoKg ?? this.pesoKg,
      alturaCm: alturaCm ?? this.alturaCm,
      nivel: nivel ?? this.nivel,
      objetivo: objetivo,
      puntos: puntos ?? this.puntos,
      creadoEn: creadoEn,
    );
  }
}
