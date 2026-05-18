import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/core/utils/format_utils.dart';
import '../../../start_career/domain/actividad_model.dart';
import '../../../start_career/services/actividades_service.dart';

class RunHistoryPage extends StatefulWidget {
  const RunHistoryPage({super.key});

  @override
  State<RunHistoryPage> createState() => _RunHistoryPageState();
}

class _RunHistoryPageState extends State<RunHistoryPage> {
  final ScrollController _scrollCtrl = ScrollController();
  final List<ActividadHistorial> _actividades = [];
  
  bool _isLoading = false;
  bool _isFetchingMore = false;
  int _paginaActual = 1;
  int _totalPaginas = 1;

  @override
  void initState() {
    super.initState();
    _fetchHistory(isRefresh: true);
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isFetchingMore && _paginaActual < _totalPaginas) {
        _fetchHistory(isRefresh: false);
      }
    }
  }

  Future<void> _fetchHistory({required bool isRefresh}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _paginaActual = 1;
        _actividades.clear();
      });
    } else {
      setState(() => _isFetchingMore = true);
      _paginaActual++;
    }

    try {
      final res = await ActividadesService.obtenerHistorial(limite: 10, pagina: _paginaActual);
      final list = res['historial'] as List<ActividadHistorial>;
      final totalPag = res['total_paginas'] as int;

      if (mounted) {
        setState(() {
          _actividades.addAll(list);
          _totalPaginas = totalPag;
        });
      }
    } catch (_) {
      // Manejar error de red
      if (mounted && !isRefresh) {
        setState(() => _paginaActual--); // revertir la página actual
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    // Ejemplo: 20 de Marzo de 2026
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${meses[date.month - 1]} de ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: c.bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Historial de Carreras',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: c.primaryDeep),
              ),
            )
          else if (_actividades.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_run_rounded, size: 60, color: c.textHint),
                    const SizedBox(height: 16),
                    Text(
                      'Aún no hay carreras',
                      style: TextStyle(
                        fontSize: 16,
                        color: c.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i == _actividades.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(color: c.primaryDeep, strokeWidth: 2),
                        ),
                      );
                    }
                    return _buildActivityCard(context, _actividades[i]);
                  },
                  childCount: _actividades.length + (_isFetchingMore ? 1 : 0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActividadHistorial a) {
    final c = context.colors;
    final isRunning = a.tipo == 'correr';
    final color = isRunning ? c.primaryDeep : const Color(0xFF34C759);
    final icon = isRunning ? Icons.directions_run_rounded : Icons.terrain_rounded;

    return GestureDetector(
      onTap: () async {
        final recargar = await context.pushNamed<bool>('run_detail', extra: {'actividad_id': a.id});
        if (recargar == true) {
          _fetchHistory(isRefresh: true);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.primaryDeep.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Cabecera: Fecha y Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(a.fecha),
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (a.compartida)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.primaryDeep.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share_rounded, size: 10, color: c.primaryDeep),
                        const SizedBox(width: 4),
                        Text(
                          'COMPARTIDA',
                          style: TextStyle(
                            color: c.primaryDeep,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Contenido Principal
            Row(
              children: [
                // Imagen o Placeholder
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: a.fotoUrl != null && a.fotoUrl!.isNotEmpty
                      ? Image.network(a.fotoUrl!, fit: BoxFit.cover)
                      : Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                // Estadísticas Rápidas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(builder: (_) {
                        final dist = formatDistancia(a.distanciaKm);
                        return Text(
                          '${dist.valor} ${dist.unidad}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      Text(
                        '${a.duracionFormateada} • ${a.ritmoPromedio.toStringAsFixed(1)} min/km',
                        style: TextStyle(
                          fontSize: 13,
                          color: c.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Puntos Ganados
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB84D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFB84D).withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFB84D), size: 20),
                      const SizedBox(height: 2),
                      Text(
                        '+${a.puntosGanados}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFFD68A1B),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
