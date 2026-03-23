import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/grupos_service.dart';
import '../../domain/models/grupo_model.dart';
import '../../../../core/services/http_client.dart';

class GroupRankingPage extends StatefulWidget {
  final String grupoId;
  final String tipo; // 'retos' | 'actividades'

  const GroupRankingPage({super.key, required this.grupoId, required this.tipo});

  @override
  State<GroupRankingPage> createState() => _GroupRankingPageState();
}

class _GroupRankingPageState extends State<GroupRankingPage> {
  List<RankingEntry> _ranking = [];
  bool _isLoading = true;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _errorMsg = ''; });
    try {
      final data = widget.tipo == 'retos'
          ? await GruposService.getRankingRetos(widget.grupoId)
          : await GruposService.getRankingActividades(widget.grupoId);
      if (mounted) setState(() { _ranking = data; _isLoading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _errorMsg = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMsg = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final titulo = widget.tipo == 'retos' ? 'Ranking de Retos' : 'Ranking de Actividades';

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary), onPressed: () => context.pop()),
        title: Text(titulo, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.5)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: c.primaryDeepWithAlpha(0.08), height: 1)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : _errorMsg.isNotEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.leaderboard_rounded, size: 64, color: c.primaryDeepWithAlpha(0.2)),
                  const SizedBox(height: 16),
                  Text('Error al cargar ranking', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
                ]))
              : _ranking.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.emoji_events_rounded, size: 64, color: c.primaryDeepWithAlpha(0.2)),
                      const SizedBox(height: 16),
                      Text('Nadie ha completado aún', style: TextStyle(color: c.textHint, fontSize: 16, fontWeight: FontWeight.w600)),
                    ]))
                  : _buildRankingList(c),
    );
  }

  Widget _buildRankingList(dynamic c) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _ranking.length,
      itemBuilder: (context, index) {
        final entry = _ranking[index];
        final pos = index + 1;

        Color? posColor;
        String posEmoji;
        if (pos == 1) { posEmoji = '🥇'; posColor = const Color(0xFFFFD700); }
        else if (pos == 2) { posEmoji = '🥈'; posColor = const Color(0xFFB0C4DE); }
        else if (pos == 3) { posEmoji = '🥉'; posColor = const Color(0xFFCD7F32); }
        else { posEmoji = '#$pos'; posColor = null; }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: pos <= 3 ? (posColor!.withValues(alpha: 0.07)) : c.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: pos <= 3 ? posColor!.withValues(alpha: 0.25) : c.primaryDeepWithAlpha(0.07)),
          ),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: pos <= 3 ? posColor!.withValues(alpha: 0.15) : c.primaryDeepWithAlpha(0.07),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: pos <= 3
                      ? Text(posEmoji, style: const TextStyle(fontSize: 22))
                      : Text('#$pos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textHint)),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 22,
                backgroundColor: c.primaryLight,
                backgroundImage: entry.avatarUrl != null && entry.avatarUrl!.isNotEmpty
                    ? NetworkImage(entry.avatarUrl!) as ImageProvider
                    : null,
                child: (entry.avatarUrl == null || entry.avatarUrl!.isEmpty)
                    ? Text(entry.nombre.isNotEmpty ? entry.nombre[0].toUpperCase() : '?',
                        style: TextStyle(color: c.primaryDeep, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.nombre,
                        style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary, fontSize: 15),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${entry.cantidad} ${widget.tipo == 'retos' ? 'retos' : 'actividades'} completados',
                        style: TextStyle(fontSize: 12, color: c.textSecondary)),
                  ],
                ),
              ),
              if (pos <= 3)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: posColor!.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text('${entry.cantidad}',
                      style: TextStyle(fontWeight: FontWeight.w800, color: posColor, fontSize: 16)),
                ),
            ],
          ),
        );
      },
    );
  }
}
