import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/territory_model.dart';
import '../../data/models/ranking_model.dart';
import '../../services/territory_service.dart';

class TerritoryMapTab extends StatefulWidget {
  final bool isGrupal;
  const TerritoryMapTab({super.key, this.isGrupal = false});

  @override
  State<TerritoryMapTab> createState() => _TerritoryMapTabState();
}

class _TerritoryMapTabState extends State<TerritoryMapTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _contentAnimation;

  List<TerritoryModel>? _territorios;
  List<dynamic>? _ranking;
  bool _loading = true;
  String? _error;
  String? _miId;

  GoogleMapController? _mapController;
  Set<Polygon> _polygons = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
    _cargar();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TerritoryMapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGrupal != widget.isGrupal) {
      _cargar();
    }
  }

  Future<void> _cargar() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _miId = await ApiConfig.getCurrentUserId();
      final results = await Future.wait([
        // Pedimos TODOS los territorios para mostrarlos en el mapa sin importar la modalidad
        TerritorioService.getTerritorios(),
        widget.isGrupal 
            ? TerritorioService.getRankingGrupal() 
            : TerritorioService.getRankingIndividual(),
      ]);
      if (!mounted) return;
      final territoriosAsList = results[0] as List<TerritoryModel>;
      final ranking = results[1] as List<dynamic>;
      
      // El mapa usa TODOS
      final polygons = _buildPolygons(territoriosAsList);
      
      setState(() {
        _territorios = territoriosAsList;
        _ranking = ranking;
        _polygons = polygons;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Construye polígonos de Google Maps a partir de los datos GeoJSON.
  Set<Polygon> _buildPolygons(List<TerritoryModel> territorios) {
    final uid = _miId ?? '';
    final polygons = <Polygon>{};

    for (final t in territorios) {
      final geo = t.poligono;
      if (geo == null) continue;

      List<LatLng>? points;
      try {
        // Soporte para GeoJSON Polygon { type: "Polygon", coordinates: [...] }
        // o directamente un array de coordenadas [[lng, lat], ...]
        if (geo is Map<String, dynamic>) {
          final type = geo['type'] as String?;
          if (type == 'Polygon') {
            final coords = (geo['coordinates'] as List).first as List;
            points = coords
                .map((c) {
                  final arr = c as List;
                  return LatLng(
                    (arr[1] as num).toDouble(),
                    (arr[0] as num).toDouble(),
                  );
                })
                .toList();
          }
        } else if (geo is List) {
          points = geo
              .map((c) {
                final arr = c as List;
                return LatLng(
                  (arr[1] as num).toDouble(),
                  (arr[0] as num).toDouble(),
                );
              })
              .toList();
        }
      } catch (_) {
        continue;
      }

      if (points == null || points.isEmpty) continue;

      Color fillColor;
      Color strokeColor;

      if (t.libre) {
        fillColor = const Color(0x1A3B82F6);
        strokeColor = const Color(0x663B82F6);
      } else if (t.isOwned(uid)) {
        fillColor = const Color(0x337ED957);
        strokeColor = const Color(0xFF7ED957);
      } else {
        fillColor = const Color(0x33FF6B6B);
        strokeColor = const Color(0xFFFF6B6B);
      }

      polygons.add(Polygon(
        polygonId: PolygonId(t.id),
        points: points,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidth: 2,
        consumeTapEvents: true,
        onTap: () => context.pushNamed(
          'territory_detail',
          pathParameters: {'id': t.id},
        ),
      ));
    }
    return polygons;
  }

  /// Calcula el centro geográfico de todos los territorios catalogados.
  CameraPosition _initialCamera() {
    final territorios = _territorios ?? [];
    if (territorios.isEmpty) {
      return const CameraPosition(
        target: LatLng(-0.22985, -78.52495), // Quito, Ecuador
        zoom: 14,
      );
    }

    double latSum = 0, lngSum = 0;
    int count = 0;
    for (final t in territorios) {
      final geo = t.poligono;
      if (geo == null) continue;
      try {
        List<dynamic>? coords;
        if (geo is Map<String, dynamic> && geo['type'] == 'Polygon') {
          coords = (geo['coordinates'] as List).first as List;
        } else if (geo is List) {
          coords = geo;
        }
        if (coords != null && coords.isNotEmpty) {
          final first = coords.first as List;
          latSum += (first[1] as num).toDouble();
          lngSum += (first[0] as num).toDouble();
          count++;
        }
      } catch (_) {}
    }

    if (count == 0) {
      return const CameraPosition(
        target: LatLng(-0.22985, -78.52495),
        zoom: 14,
      );
    }

    return CameraPosition(
      target: LatLng(latSum / count, lngSum / count),
      zoom: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: c.textSecondary, size: 48),
            const SizedBox(height: 12),
            Text('Error al cargar territorios',
                style: TextStyle(color: c.textSecondary)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _cargar, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    final todosTerritorios = _territorios ?? [];
    // Filtramos para las métricas
    final stringModalidad = widget.isGrupal ? 'grupal' : 'individual';
    final territoriosModalidad = todosTerritorios.where((t) => t.modalidad == stringModalidad).toList();

    final ranking = _ranking ?? [];
    final top3 = ranking.take(3).toList();

    return FadeTransition(
      opacity: _contentAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_contentAnimation),
        child: RefreshIndicator(
          onRefresh: _cargar,
          color: c.primaryDeep,
          backgroundColor: c.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── MAPA ──────────────────────────────────────────────────────
                _buildSectionHeader('Mapa de zonas', Icons.map_rounded, context),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.primaryDeepWithAlpha(0.10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 260,
                          child: GoogleMap(
                            initialCameraPosition: _initialCamera(),
                            polygons: _polygons,
                            zoomControlsEnabled: false,
                            compassEnabled: false,
                            mapToolbarEnabled: false,
                            myLocationButtonEnabled: false,
                            onMapCreated: (ctrl) => _mapController = ctrl,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegendDot(
                              label: 'MÍO',
                              color: const Color(0xFF7ED957)),
                          const SizedBox(width: 14),
                          _LegendDot(
                              label: 'RIVAL',
                              color: const Color(0xFFFF6B6B)),
                          const SizedBox(width: 14),
                          _LegendDot(
                              label: 'LIBRE',
                              color: const Color(0xFF3B82F6)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── RESUMEN ────────────────────────────────────────────────────
                _buildSectionHeader('Resumen', Icons.dashboard_rounded, context),
                const SizedBox(height: 12),
                _buildResumen(context, territoriosModalidad),

                const SizedBox(height: 32),

                // ── RANKING TOP 3 ──────────────────────────────────────────────
                if (top3.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Ranking Top 3',
                    Icons.leaderboard_rounded,
                    context,
                    onTapVerMas: () => context.pushNamed('territory_ranking'),
                  ),
                  const SizedBox(height: 16),
                  _RankingTop3Card(top3: top3),
                  const SizedBox(height: 32),
                ],

                // ── ACTIVIDAD RECIENTE ─────────────────────────────────────────
                _buildSectionHeader(
                  'Actividad Reciente',
                  Icons.bolt_rounded,
                  context,
                ),
                const SizedBox(height: 6),
                Text(
                  'Últimas conquistas y disputas en la zona',
                  style: TextStyle(
                    fontSize: 13,
                    color: c.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActividadReciente(context, territoriosModalidad),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── RESUMEN ──────────────────────────────────────────────────────────────────

  Widget _buildResumen(BuildContext context, List<TerritoryModel> territorios) {
    final c = context.colors;
    final uid = _miId ?? '';
    final propios =
        territorios.where((t) => t.isOwned(uid)).length;
    final libres = territorios.where((t) => t.libre).length;
    final rivales =
        territorios.where((t) => !t.libre && !t.isOwned(uid)).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          _ResumenStat(
              value: '$propios',
              label: 'Míos',
              color: const Color(0xFF7ED957)),
          _VerticalDivider(),
          _ResumenStat(
              value: '$rivales',
              label: 'Rivales',
              color: const Color(0xFFFF6B6B)),
          _VerticalDivider(),
          _ResumenStat(
              value: '$libres',
              label: 'Libres',
              color: const Color(0xFF3B82F6)),
          _VerticalDivider(),
          _ResumenStat(
              value: '${territorios.length}',
              label: 'Total',
              color: c.primaryDeep),
        ],
      ),
    );
  }

  // ── ACTIVIDAD RECIENTE ────────────────────────────────────────────────────────

  Widget _buildActividadReciente(
      BuildContext context, List<TerritoryModel> territorios) {
    // Recopilar las últimas entradas de historial de todos los territorios
    final all = <_AlertaEntry>[];
    for (final t in territorios) {
      for (final h in t.historial) {
        all.add(_AlertaEntry(territorio: t, historial: h));
      }
    }
    all.sort((a, b) => (b.historial.creadoEn ?? DateTime(0))
        .compareTo(a.historial.creadoEn ?? DateTime(0)));
    final recientes = all.take(5).toList();

    if (recientes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: context.colors.primaryDeepWithAlpha(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.primaryDeepWithAlpha(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.bolt_outlined,
                  color: context.colors.textSecondary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Sin actividad reciente',
              style: TextStyle(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recientes.map((entry) {
        final h = entry.historial;
        final t = entry.territorio;
        final gano = h.resultado == 'ganado';
        final accentColor =
            gano ? const Color(0xFF7ED957) : const Color(0xFFFF6B6B);
        final nombre = h.usuario?.nombre ?? h.grupo?.nombre ?? 'Alguien';
        final tiempoRelativo = _tiempoRelativo(h.creadoEn);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => context.pushNamed(
              'territory_detail',
              pathParameters: {'id': t.id},
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: accentColor.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      gano
                          ? Icons.flag_rounded
                          : Icons.shield_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                gano
                                    ? '$nombre conquistó "${t.nombre}"'
                                    : '$nombre disputó "${t.nombre}"',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.colors
                                    .primaryDeepWithAlpha(0.06),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tiempoRelativo,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${h.tipo == 'conquista' ? 'Conquista' : 'Disputa'} · ${h.tiempoFormateado}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _tiempoRelativo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    BuildContext context, {
    VoidCallback? onTapVerMas,
  }) {
    final c = context.colors;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: c.primaryDeepWithAlpha(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: c.primaryDeepWithAlpha(0.8)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        if (onTapVerMas != null)
          GestureDetector(
            onTap: onTapVerMas,
            child: Row(
              children: [
                Text(
                  'Ver más',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.primaryDeepWithAlpha(0.9),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: c.primaryDeepWithAlpha(0.9),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── ENTRY para actividad ─────────────────────────────────────────────────────

class _AlertaEntry {
  final TerritoryModel territorio;
  final TerritorialHistorialEntry historial;
  const _AlertaEntry({required this.territorio, required this.historial});
}

// ── LEYENDA ───────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ── RESUMEN STAT ─────────────────────────────────────────────────────────────

class _ResumenStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _ResumenStat(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
                fontSize: 10,
                color: c.textSecondary,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: context.colors.primaryDeepWithAlpha(0.08),
    );
  }
}

// ── RANKING TOP 3 CARD ────────────────────────────────────────────────────────

class _RankingTop3Card extends StatelessWidget {
  final List<dynamic> top3;
  const _RankingTop3Card({required this.top3});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Garantizar 3 ítems
    final items = List<dynamic>.from(top3);
    while (items.length < 3) {
      items.add(null);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumItem(context, items[1], 2, 80),
          _buildPodiumItem(context, items[0], 1, 110),
          _buildPodiumItem(context, items[2], 3, 60),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    dynamic entity,
    int rank,
    double height,
  ) {
    final c = context.colors;
    
    // Extraer datos usando validación de tipo, si no existe asume valores por defecto
    String nombre = '—';
    String? fotoUrl;
    int totalZonas = 0;
    
    if (entity is RankingUsuarioModel) {
      nombre = entity.nombre;
      fotoUrl = entity.avatarUrl;
      totalZonas = entity.totalTerritorios;
    } else if (entity is RankingGrupoModel) {
      nombre = entity.nombre;
      fotoUrl = entity.fotoUrl;
      totalZonas = entity.totalTerritorios;
    }

    // Color medalla dependiendo de la posición actual del podio
    Color medalColor;
    switch (rank) {
      case 1: medalColor = const Color(0xFFFFB84D); break;
      case 2: medalColor = const Color(0xFFB0C4D8); break;
      case 3: medalColor = const Color(0xFFCD7F32); break;
      default: medalColor = const Color(0xFF3B82F6);
    }

    return Column(
      children: [
        CircleAvatar(
          radius: rank == 1 ? 26 : 22,
          backgroundColor: medalColor.withValues(alpha: 0.15),
          backgroundImage:
              fotoUrl != null && fotoUrl.isNotEmpty
                  ? NetworkImage(fotoUrl)
                  : null,
          child: fotoUrl == null || fotoUrl.isEmpty
              ? Icon(
                  entity is RankingGrupoModel ? Icons.groups_rounded : Icons.person_rounded,
                  color: medalColor, 
                  size: rank == 1 ? 24 : 18
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          nombre.split(' ').first,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '$totalZonas zonas',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                medalColor.withValues(alpha: 0.4),
                medalColor.withValues(alpha: 0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
