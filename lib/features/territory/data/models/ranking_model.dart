import 'package:flutter/material.dart';

// ─── USUARIO EN RANKING ───────────────────────────────────────────────────────

class RankingUsuarioModel {
  final String id;
  final String nombre;
  final String? avatarUrl;
  final String? ciudad;
  final int puntos;
  final int totalTerritorios;
  final int posicion;

  const RankingUsuarioModel({
    required this.id,
    required this.nombre,
    this.avatarUrl,
    this.ciudad,
    required this.puntos,
    required this.totalTerritorios,
    required this.posicion,
  });

  factory RankingUsuarioModel.fromJson(Map<String, dynamic> json) {
    return RankingUsuarioModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      avatarUrl: json['avatar_url'] as String?,
      ciudad: json['ciudad'] as String?,
      puntos: json['puntos'] as int? ?? 0,
      totalTerritorios: json['total_territorios'] as int? ?? 0,
      posicion: json['posicion'] as int? ?? 0,
    );
  }

  /// Color por posición (1=dorado, 2=plata, 3=bronce, resto=azul)
  Color get accentColor {
    switch (posicion) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFB0C4D8);
      case 3: return const Color(0xFFCD7F32);
      default: return const Color(0xFF3B82F6);
    }
  }

  Color get medalColor {
    switch (posicion) {
      case 1: return const Color(0xFFFFB84D);
      case 2: return const Color(0xFFB0C4D8);
      case 3: return const Color(0xFFCD7F32);
      default: return const Color(0xFF3B82F6);
    }
  }
}

// ─── GRUPO EN RANKING ─────────────────────────────────────────────────────────

class RankingGrupoModel {
  final String id;
  final String nombre;
  final String? fotoUrl;
  final int totalTerritorios;
  final int posicion;

  const RankingGrupoModel({
    required this.id,
    required this.nombre,
    this.fotoUrl,
    required this.totalTerritorios,
    required this.posicion,
  });

  factory RankingGrupoModel.fromJson(Map<String, dynamic> json) {
    return RankingGrupoModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      fotoUrl: json['foto_url'] as String?,
      totalTerritorios: json['total_territorios'] as int? ?? 0,
      posicion: json['posicion'] as int? ?? 0,
    );
  }

  Color get medalColor {
    switch (posicion) {
      case 1: return const Color(0xFFFFB84D);
      case 2: return const Color(0xFFB0C4D8);
      case 3: return const Color(0xFFCD7F32);
      default: return const Color(0xFF3B82F6);
    }
  }
}
