import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

// ─── PROPIETARIO ─────────────────────────────────────────────────────────────

class TerritorioPropietario {
  final String id;
  final String nombre;
  final String? avatarUrl;
  final String? ciudad;
  final String? nivel;

  const TerritorioPropietario({
    required this.id,
    required this.nombre,
    this.avatarUrl,
    this.ciudad,
    this.nivel,
  });

  factory TerritorioPropietario.fromJson(Map<String, dynamic> json) {
    return TerritorioPropietario(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      avatarUrl: json['avatar_url'] as String?,
      ciudad: json['ciudad'] as String?,
      nivel: json['nivel'] as String?,
    );
  }
}

class TerritorioPropietarioGrupo {
  final String id;
  final String nombre;
  final String? fotoUrl;

  const TerritorioPropietarioGrupo({
    required this.id,
    required this.nombre,
    this.fotoUrl,
  });

  factory TerritorioPropietarioGrupo.fromJson(Map<String, dynamic> json) {
    return TerritorioPropietarioGrupo(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      fotoUrl: json['foto_url'] as String?,
    );
  }
}

// ─── HISTORIAL ────────────────────────────────────────────────────────────────

class TerritorialHistorialEntry {
  final String id;
  final String tipo;         // conquista | disputa
  final String resultado;    // ganado | perdido
  final int tiempoSegs;
  final String tiempoFormateado;
  final int? tiempoAnteriorSegs;
  final String modalidad;
  final TerritorioPropietario? usuario;
  final TerritorioPropietarioGrupo? grupo;
  final DateTime? creadoEn;

  const TerritorialHistorialEntry({
    required this.id,
    required this.tipo,
    required this.resultado,
    required this.tiempoSegs,
    required this.tiempoFormateado,
    this.tiempoAnteriorSegs,
    required this.modalidad,
    this.usuario,
    this.grupo,
    this.creadoEn,
  });

  factory TerritorialHistorialEntry.fromJson(Map<String, dynamic> json) {
    return TerritorialHistorialEntry(
      id: json['id'] as String,
      tipo: json['tipo'] as String? ?? 'conquista',
      resultado: json['resultado'] as String? ?? 'perdido',
      tiempoSegs: json['tiempo_segs'] as int? ?? 0,
      tiempoFormateado: json['tiempo_formateado'] as String? ?? '00:00:00',
      tiempoAnteriorSegs: json['tiempo_anterior_segs'] as int?,
      modalidad: json['modalidad'] as String? ?? 'individual',
      usuario: json['usuario'] != null
          ? TerritorioPropietario.fromJson(json['usuario'] as Map<String, dynamic>)
          : null,
      grupo: json['grupo'] != null
          ? TerritorioPropietarioGrupo.fromJson(json['grupo'] as Map<String, dynamic>)
          : null,
      creadoEn: json['creado_en'] != null
          ? DateTime.tryParse(json['creado_en'] as String)
          : null,
    );
  }
}

// ─── TERRITORIO ───────────────────────────────────────────────────────────────

class TerritoryModel {
  final String id;
  final String nombre;
  final String? descripcion;
  final dynamic poligono;          // GeoJSON geometry object/array
  final String modalidad;          // individual | grupal
  final bool libre;
  final TerritorioPropietario? propietario;
  final TerritorioPropietarioGrupo? grupoPropietario;
  final int? tiempoRecordSegs;
  final String? tiempoRecordFormateado;
  final DateTime? conquistadoEn;
  final DateTime? ultimaDisputaEn;
  final int vecesDisputado;
  final int totalDefensas;
  final List<TerritorialHistorialEntry> historial;

  const TerritoryModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.poligono,
    required this.modalidad,
    required this.libre,
    this.propietario,
    this.grupoPropietario,
    this.tiempoRecordSegs,
    this.tiempoRecordFormateado,
    this.conquistadoEn,
    this.ultimaDisputaEn,
    this.vecesDisputado = 0,
    this.totalDefensas = 0,
    this.historial = const [],
  });

  factory TerritoryModel.fromJson(Map<String, dynamic> json) {
    return TerritoryModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      poligono: json['poligono'],
      modalidad: json['modalidad'] as String? ?? 'individual',
      libre: json['libre'] as bool? ?? true,
      propietario: json['propietario'] != null
          ? TerritorioPropietario.fromJson(json['propietario'] as Map<String, dynamic>)
          : null,
      grupoPropietario: json['grupo_propietario'] != null
          ? TerritorioPropietarioGrupo.fromJson(json['grupo_propietario'] as Map<String, dynamic>)
          : null,
      tiempoRecordSegs: json['tiempo_record_segs'] as int?,
      tiempoRecordFormateado: json['tiempo_record_formateado'] as String?,
      conquistadoEn: json['conquistado_en'] != null
          ? DateTime.tryParse(json['conquistado_en'] as String)
          : null,
      ultimaDisputaEn: json['ultima_disputa_en'] != null
          ? DateTime.tryParse(json['ultima_disputa_en'] as String)
          : null,
      vecesDisputado: json['veces_disputado'] as int? ?? 0,
      totalDefensas: json['total_defensas'] as int? ?? 0,
      historial: (json['historial'] as List<dynamic>? ?? [])
          .map((h) => TerritorialHistorialEntry.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }

  // ── Helpers de estado ─────────────────────────────────────────────────────

  bool isOwned(String userId) =>
      propietario != null && propietario!.id == userId;

  bool isOwnedByGroup(String groupId) =>
      grupoPropietario != null && grupoPropietario!.id == groupId;

  String get ownerDisplayName {
    if (libre) return 'Sin dueño';
    if (propietario != null) return propietario!.nombre;
    if (grupoPropietario != null) return grupoPropietario!.nombre;
    return 'Sin dueño';
  }

  /// Estado relativo al usuario actual.
  String statusFor(String userId) {
    if (libre) return 'unclaimed';
    if (isOwned(userId)) return 'owned';
    return 'rival';
  }

  Color statusColor(BuildContext context, String userId) {
    switch (statusFor(userId)) {
      case 'owned':
        return context.colors.primaryMid;
      case 'rival':
        return context.colors.textSecondary;
      default:
        return context.colors.surface;
    }
  }

  String statusLabel(String userId) {
    switch (statusFor(userId)) {
      case 'owned':
        return 'Mío';
      case 'rival':
        return 'Rival';
      default:
        return 'Libre';
    }
  }

  String get detailStatusLabel {
    if (libre) return 'LIBRE';
    return 'CONQUISTADO';
  }
}
