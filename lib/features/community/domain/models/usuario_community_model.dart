/// Modelo de usuario para vistas de comunidad (lista, perfil ajeno).
class UsuarioCommunityModel {
  final String id;
  final String nombre;
  final String? avatarUrl;
  final String? biografia;
  final String? ciudad;
  final String? nivel;
  final int puntos;

  // Solo disponible en GET /usuarios/:id
  final int seguidores;
  final int seguidos;
  final bool yoLoSigo;

  const UsuarioCommunityModel({
    required this.id,
    required this.nombre,
    this.avatarUrl,
    this.biografia,
    this.ciudad,
    this.nivel,
    this.puntos = 0,
    this.seguidores = 0,
    this.seguidos = 0,
    this.yoLoSigo = false,
  });

  factory UsuarioCommunityModel.fromJson(Map<String, dynamic> json) {
    return UsuarioCommunityModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      avatarUrl: json['avatar_url'] as String?,
      biografia: json['biografia'] as String?,
      ciudad: json['ciudad'] as String?,
      nivel: json['nivel'] as String?,
      puntos: (json['puntos'] as num?)?.toInt() ?? 0,
      seguidores: (json['seguidores'] as num?)?.toInt() ?? 0,
      seguidos: (json['seguidos'] as num?)?.toInt() ?? 0,
      yoLoSigo: json['yo_lo_sigo'] as bool? ?? false,
    );
  }

  UsuarioCommunityModel copyWith({bool? yoLoSigo, int? seguidores}) {
    return UsuarioCommunityModel(
      id: id,
      nombre: nombre,
      avatarUrl: avatarUrl,
      biografia: biografia,
      ciudad: ciudad,
      nivel: nivel,
      puntos: puntos,
      seguidores: seguidores ?? this.seguidores,
      seguidos: seguidos,
      yoLoSigo: yoLoSigo ?? this.yoLoSigo,
    );
  }
}
