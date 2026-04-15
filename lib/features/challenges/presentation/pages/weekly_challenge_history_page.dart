import 'package:flutter/material.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/challenges/data/models/reto_models.dart';
import 'package:runn_front/features/challenges/services/retos_service.dart';

class WeeklyChallengeHistoryPage extends StatefulWidget {
  const WeeklyChallengeHistoryPage({super.key});

  @override
  State<WeeklyChallengeHistoryPage> createState() => _WeeklyChallengeHistoryPageState();
}

class _WeeklyChallengeHistoryPageState extends State<WeeklyChallengeHistoryPage> {
  bool _loading = true;
  String? _error;
  List<HistorialRetoSemanal> _historial = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final h = await RetosService.obtenerHistorialSemanal();
      if (mounted) setState(() { _historial = h; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Error al cargar el historial'; _loading = false; });
    }
  }

  static const Map<String, IconData> _tipoIcon = {
    'distancia': Icons.straighten_rounded,
    'tiempo':    Icons.timer_rounded,
    'velocidad': Icons.speed_rounded,
    'calorias':  Icons.local_fire_department_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        title: Text('Historial semanal', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(c)
              : _historial.isEmpty
                  ? _buildEmpty(c)
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      color: c.primaryDeep,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _historial.length,
                        itemBuilder: (_, i) => _buildCard(c, _historial[i]),
                      ),
                    ),
    );
  }

  Widget _buildCard(dynamic c, HistorialRetoSemanal h) {
    final completado = h.completado;
    final color = completado ? const Color(0xFF3B82F6) : c.textHint as Color;
    final icon = _tipoIcon[h.tipo] ?? Icons.emoji_events_rounded;
    final progress = h.valorObjetivo > 0
        ? (h.progresoActual / h.valorObjetivo).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(completado ? Icons.check_circle_rounded : icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.titulo,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (h.periodoFmt.isNotEmpty)
                      Text(h.periodoFmt, style: TextStyle(fontSize: 11, color: c.textHint)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  completado ? '✓ Completado' : 'No completado',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progreso
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${h.progresoActual.toStringAsFixed(2)} / ${h.valorObjetivo.toStringAsFixed(0)} ${h.unidad}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.textSecondary),
              ),
            ],
          ),
          if (completado)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFD700)),
                  const SizedBox(width: 4),
                  Text('+${h.puntosRecompensa} puntos ganados',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty(dynamic c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📅', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('¡No has completado ningún reto semanal aún!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Cada semana trae un nuevo desafío. ¡Empieza esta semana!',
              style: TextStyle(fontSize: 13, color: c.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildError(dynamic c) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😕', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: c.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _cargar,
            style: ElevatedButton.styleFrom(backgroundColor: c.primaryDeep),
            child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
