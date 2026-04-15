import 'package:flutter/material.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/challenges/data/models/reto_models.dart';
import 'package:runn_front/features/challenges/services/retos_service.dart';

class DailyChallengeHistoryPage extends StatefulWidget {
  const DailyChallengeHistoryPage({super.key});

  @override
  State<DailyChallengeHistoryPage> createState() => _DailyChallengeHistoryPageState();
}

class _DailyChallengeHistoryPageState extends State<DailyChallengeHistoryPage> {
  bool _loading = true;
  String? _error;
  List<HistorialRetoDiario> _historial = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final h = await RetosService.obtenerHistorialDiario();
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
        title: Text('Historial diario', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700)),
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

  Widget _buildCard(dynamic c, HistorialRetoDiario h) {
    final completado = h.completado;
    final color = completado ? const Color(0xFF7ED957) : c.textHint as Color;
    final icon = _tipoIcon[h.tipo] ?? Icons.emoji_events_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(completado ? Icons.check_circle_rounded : icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.titulo,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${formatearObjetivo(h.tipo, h.valorObjetivo, h.unidad)} • Progreso: ${h.progresoActual.toStringAsFixed(2)} ${h.unidad}',
                  style: TextStyle(fontSize: 11, color: c.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (h.fechaFmt.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(h.fechaFmt, style: TextStyle(fontSize: 11, color: c.textHint)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  completado ? '✓ Listo' : 'Pendiente',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                ),
              ),
              if (completado)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, size: 12, color: const Color(0xFFFFD700)),
                      const SizedBox(width: 2),
                      Text('+${h.puntosRecompensa} pts',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.textSecondary)),
                    ],
                  ),
                ),
            ],
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
            const Text('🏃', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('¡Aún no has participado en ningún reto diario!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Empieza hoy y construye tu historial de campeón.',
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
          Text('😕', style: const TextStyle(fontSize: 40)),
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
