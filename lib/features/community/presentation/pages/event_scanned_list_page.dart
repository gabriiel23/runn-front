import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/eventos_service.dart';

class EventScannedListPage extends StatefulWidget {
  final String eventId;
  const EventScannedListPage({super.key, required this.eventId});

  @override
  State<EventScannedListPage> createState() => _EventScannedListPageState();
}

class _EventScannedListPageState extends State<EventScannedListPage> {
  bool _isLoading = true;
  List<dynamic> _escaneados = [];
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final res = await EventosService.getEscaneados(widget.eventId);
      setState(() {
        _escaneados = res['escaneados'] as List<dynamic>? ?? [];
        _total = (res['total'] as num?)?.toInt() ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(dynamic raw) {
    final dt = DateTime.tryParse(raw?.toString() ?? '');
    if (dt == null) return '--';
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card,
        foregroundColor: c.textPrimary,
        elevation: 0,
        title: Text(
          _isLoading ? 'Escaneados' : 'Escaneados ($_total)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: c.primaryDeepWithAlpha(0.1), height: 1),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: c.primaryDeep),
            onPressed: _fetch,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : _escaneados.isEmpty
              ? _buildEmpty(c)
              : _buildList(c),
    );
  }

  Widget _buildEmpty(dynamic c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner_rounded, size: 72, color: c.primaryDeepWithAlpha(0.2)),
          const SizedBox(height: 16),
          Text(
            'Nadie escaneado aún',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Los participantes aparecerán aquí\ncuando escaneen su código en la entrada.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: c.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildList(dynamic c) {
    return RefreshIndicator(
      onRefresh: _fetch,
      color: c.primaryDeep,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _escaneados.length,
        separatorBuilder: (_, __) => Divider(
          color: c.primaryDeepWithAlpha(0.05),
          height: 1,
          indent: 24,
          endIndent: 24,
        ),
        itemBuilder: (context, index) {
          final item = _escaneados[index];
          final usuario = item['usuario'] ?? {};
          final avatarUrl = usuario['avatar_url']?.toString();
          final nombre = usuario['nombre']?.toString() ?? 'Desconocido';
          final nivel = usuario['nivel']?.toString();
          final ciudad = usuario['ciudad']?.toString();
          final horaEscaneo = _formatDate(item['usado_en']);
          final codigo = item['codigo_alfanumerico']?.toString() ?? '';

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: c.primaryLight,
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? NetworkImage(avatarUrl) as ImageProvider
                  : null,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.primaryDeep),
                    )
                  : null,
            ),
            title: Text(nombre, style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                if (nivel != null || ciudad != null)
                  Text(
                    [if (ciudad != null && ciudad.isNotEmpty) ciudad, if (nivel != null && nivel.isNotEmpty) nivel].join(' · '),
                    style: TextStyle(color: c.textSecondary, fontSize: 12),
                  ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: c.primaryDeep),
                    const SizedBox(width: 4),
                    Text(
                      'Escaneado: $horaEscaneo',
                      style: TextStyle(color: c.primaryDeep, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                codigo,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
