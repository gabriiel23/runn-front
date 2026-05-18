import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/eventos_service.dart';

class EventWaitingListPage extends StatefulWidget {
  final String eventId;

  const EventWaitingListPage({super.key, required this.eventId});

  @override
  State<EventWaitingListPage> createState() => _EventWaitingListPageState();
}

class _EventWaitingListPageState extends State<EventWaitingListPage> {
  bool _isLoading = true;
  List<dynamic> _pendientes = [];
  List<dynamic> _admitidos = [];
  List<dynamic> _rechazados = [];

  @override
  void initState() {
    super.initState();
    _fetchListaEspera();
  }

  Future<void> _fetchListaEspera() async {
    setState(() => _isLoading = true);
    try {
      final res = await EventosService.getListaEspera(widget.eventId);
      final List<dynamic> allRows = res['lista'] ?? [];
      
      setState(() {
        _pendientes = allRows.where((r) => r['estado'] == 'pendiente').toList();
        _admitidos = allRows.where((r) => r['estado'] == 'admitido').toList();
        _rechazados = allRows.where((r) => r['estado'] == 'rechazado').toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar lista: $e')));
      }
    }
  }

  Future<void> _cambiarEstado(String usuarioId, String accion) async {
    String? motivo;
    final c = context.colors;

    if (accion == 'rechazar') {
      final controller = TextEditingController();
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: c.card,
          title: Text('Rechazar Solicitud', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Motivo (opcional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(child: Text('Cancelar', style: TextStyle(color: c.textSecondary)), onPressed: () => Navigator.pop(ctx, false)),
            TextButton(
              child: const Text('Rechazar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      motivo = controller.text.trim();
    }

    try {
      await EventosService.admitirRechazarListaEspera(widget.eventId, usuarioId, accion, motivo: motivo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Usuario ${accion == 'admitir' ? 'admitido' : 'rechazado'}'),
          backgroundColor: accion == 'admitir' ? Colors.green : Colors.red,
        ));
        _fetchListaEspera(); // Reload
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildList(List<dynamic> items, String estado) {
    if (items.isEmpty) {
      return Center(child: Text('No hay registros', style: TextStyle(color: context.colors.textHint, fontSize: 16)));
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final usuario = item['usuarios'] ?? {};
        final dateObj = DateTime.tryParse(item['creado_en']?.toString() ?? '');
        final dateStr = dateObj != null 
            ? '${dateObj.day.toString().padLeft(2, '0')}/${dateObj.month.toString().padLeft(2, '0')} ${dateObj.hour.toString().padLeft(2, '0')}:${dateObj.minute.toString().padLeft(2, '0')}' 
            : 'Desconocido';

        return Container(
          decoration: BoxDecoration(
            color: context.colors.card, 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.primaryDeepWithAlpha(0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: context.colors.primaryLight,
              backgroundImage: (usuario['avatar_url'] != null && usuario['avatar_url'].toString().isNotEmpty)
                  ? NetworkImage(usuario['avatar_url']) as ImageProvider
                  : null,
              child: (usuario['avatar_url'] == null || usuario['avatar_url'].toString().isEmpty) 
                  ? Text(
                      usuario['nombre']?.isNotEmpty == true ? usuario['nombre'][0].toUpperCase() : '?',
                      style: TextStyle(color: context.colors.primaryDeep, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            title: Text(usuario['nombre'] ?? 'Usuario Desconocido', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Nivel: ${usuario['nivel'] ?? 'Principiante'} • Solicitado: $dateStr'),
                if (estado == 'admitido' && item['evento_codigos']?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Código Asignado: ${item['evento_codigos'][0]['codigo_alfanumerico']}',
                      style: TextStyle(color: context.colors.primaryDeep, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                if (estado == 'rechazado' && item['motivo'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Motivo: ${item['motivo']}', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
                if (item['comprobante_url'] != null && item['comprobante_url'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withValues(alpha: 0.9),
                          builder: (dialogCtx) => Stack(
                            children: [
                              Positioned.fill(
                                child: InteractiveViewer(
                                  child: Image.network(item['comprobante_url']!, fit: BoxFit.contain),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                right: 20,
                                child: Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                                    onPressed: () => Navigator.pop(dialogCtx),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.colors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.colors.primaryDeep.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 16, color: context.colors.primaryDeep),
                            const SizedBox(width: 6),
                            Text('Ver Comprobante', style: TextStyle(color: context.colors.primaryDeep, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            trailing: estado == 'pendiente' 
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                      onPressed: () => _cambiarEstado(item['usuario_id'].toString(), 'rechazar'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_rounded, color: Colors.green),
                      onPressed: () => _cambiarEstado(item['usuario_id'].toString(), 'admitir'),
                    ),
                  ],
                )
              : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(
          backgroundColor: c.card,
          foregroundColor: c.textPrimary,
          title: const Text('Lista de Espera', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: c.primaryDeepWithAlpha(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: const EdgeInsets.all(4),
                  indicatorPadding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: c.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                  tabs: [
                    Tab(text: 'Pendientes'),
                    Tab(text: 'Admitidos'),
                    Tab(text: 'Rechazados'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: _isLoading 
            ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
            : TabBarView(
                children: [
                  _buildList(_pendientes, 'pendiente'),
                  _buildList(_admitidos, 'admitido'),
                  _buildList(_rechazados, 'rechazado'),
                ],
              ),
      ),
    );
  }
}
