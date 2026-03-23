import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/eventos_service.dart';
import '../../domain/models/evento_model.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/services/http_client.dart';
import 'event_edit_page.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  EventoDetalleModel? _detalle;
  bool _isLoading = true;
  bool _isActionLoading = false;
  String _errorMsg = '';
  String? _userRol;

  @override
  void initState() {
    super.initState();
    _loadDetalle();
    _loadRol();
  }

  Future<void> _loadRol() async {
    final rol = await ApiConfig.getUserRol();
    if (mounted) setState(() => _userRol = rol);
  }

  Future<void> _loadDetalle() async {
    setState(() { _isLoading = true; _errorMsg = ''; });
    try {
      final detalle = await EventosService.getEvento(widget.eventId);
      if (mounted) setState(() { _detalle = detalle; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMsg = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _toggleInscripcion() async {
    if (_detalle == null || _isActionLoading) return;
    setState(() => _isActionLoading = true);
    try {
      if (_detalle!.yaInscrito) {
        await EventosService.salirseEvento(widget.eventId);
      } else {
        await EventosService.unirseEvento(widget.eventId);
      }
      await _loadDetalle();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  /// Navega a la pantalla de edición y recarga el detalle si hubo cambios.
  Future<void> _irAEditar() async {
    if (_detalle == null) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EventEditPage(
          eventId: widget.eventId,
          evento: _detalle!.evento,
        ),
      ),
    );
    // Si el usuario guardó cambios, recargar el detalle
    if (result == true && mounted) {
      _loadDetalle();
    }
  }

  /// Muestra diálogo de confirmación y elimina el evento.
  Future<void> _confirmarEliminar() async {
    final c = context.colors;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '¿Eliminar evento?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Esta acción no se puede deshacer. El evento y todos los registros de participantes serán eliminados permanentemente.',
          style: TextStyle(color: c.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar',
                style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    setState(() => _isActionLoading = true);
    try {
      await EventosService.eliminarEvento(widget.eventId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Evento eliminado correctamente ✅'),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      // Volver al listado de la comunidad
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Center(child: CircularProgressIndicator(color: c.primaryDeep)),
      );
    }

    if (_errorMsg.isNotEmpty || _detalle == null) {
      return Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(
          backgroundColor: c.card,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy_rounded, size: 64, color: c.primaryDeepWithAlpha(0.3)),
              const SizedBox(height: 16),
              Text('No se pudo cargar el evento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.textPrimary)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _loadDetalle, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    final evento = _detalle!.evento;
    final isAdmin = _userRol == 'admin';

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, evento, isAdmin),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainInfo(context, evento),
                  const SizedBox(height: 32),
                  _buildDescription(context, evento),
                  const SizedBox(height: 32),
                  if (evento.lugar != null || evento.rutaSugerida != null)
                    _buildRouteSection(context, evento),
                  if (evento.lugar != null || evento.rutaSugerida != null)
                    const SizedBox(height: 32),
                  _buildParticipantsSection(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomSheet(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, EventoModel evento, bool isAdmin) {
    final c = context.colors;
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: c.card,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: c.card.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      // Menú admin: solo visible si rol == 'admin'
      actions: isAdmin
          ? [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: c.card.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: c.textPrimary, size: 20),
                  color: c.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) async {
                    if (value == 'Editar evento') {
                      await _irAEditar();
                    } else if (value == 'Eliminar evento') {
                      await _confirmarEliminar();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'Editar evento',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, color: c.primaryDeep, size: 18),
                          const SizedBox(width: 12),
                          Text('Editar evento',
                              style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'Eliminar evento',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_rounded, color: Color(0xFFFF3B30), size: 18),
                          const SizedBox(width: 12),
                          const Text('Eliminar evento',
                              style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            evento.fotoUrl != null && evento.fotoUrl!.isNotEmpty
                ? Image.network(
                    evento.fotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFotoPlaceholder(c),
                  )
                : _buildFotoPlaceholder(c),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoPlaceholder(dynamic c) {
    return Container(
      color: c.primaryLight,
      child: Center(
        child: Icon(Icons.event_rounded, size: 72, color: c.primaryDeepWithAlpha(0.3)),
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context, EventoModel evento) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: c.primaryDeepWithAlpha(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.primaryDeepWithAlpha(0.2)),
              ),
              child: Text(
                'Evento Oficial',
                style: TextStyle(
                  color: c.primaryDeep,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          evento.titulo,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildInfoChip(context, Icons.calendar_today_rounded, evento.fechaFormateada),
            if (evento.horaFormateada.isNotEmpty)
              _buildInfoChip(context, Icons.access_time_rounded, evento.horaFormateada),
            if (evento.distanciaKm != null && evento.distanciaKm!.isNotEmpty)
              _buildInfoChip(context, Icons.straighten_rounded, '${evento.distanciaKm} km'),
            if (evento.lugar != null && evento.lugar!.isNotEmpty)
              _buildInfoChip(context, Icons.location_on_rounded, evento.lugar!),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c.textPrimary.withValues(alpha: 0.4)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: c.textPrimary.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, EventoModel evento) {
    final c = context.colors;
    if (evento.descripcion == null || evento.descripcion!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary),
        ),
        const SizedBox(height: 12),
        Text(
          evento.descripcion!,
          style: TextStyle(fontSize: 15, color: c.textSecondary, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildRouteSection(BuildContext context, EventoModel evento) {
    final c = context.colors;
    final texto = evento.rutaSugerida ?? evento.lugar ?? '';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.primaryDeepWithAlpha(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map_outlined, color: c.primaryDeep, size: 24),
              const SizedBox(width: 12),
              Text(
                'Lugar / Ruta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            texto,
            style: TextStyle(fontSize: 14, color: c.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120,
              width: double.infinity,
              color: c.primaryLight,
              child: Center(
                child: Icon(Icons.route_rounded, size: 40, color: c.textHint),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(BuildContext context) {
    final c = context.colors;
    final total = _detalle!.totalParticipantes;
    final preview = _detalle!.participantes.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Participantes ($total)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary),
            ),
            GestureDetector(
              onTap: () {
                context.pushNamed(
                  'event_participants',
                  pathParameters: {'eventId': widget.eventId},
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    color: c.primaryDeepWithAlpha(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (preview.isEmpty)
          Text('Sin participantes aún', style: TextStyle(color: c.textHint, fontSize: 14))
        else
          Row(
            children: preview.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: c.primaryLight,
                  backgroundImage: p.avatarUrl != null && p.avatarUrl!.isNotEmpty
                      ? NetworkImage(p.avatarUrl!) as ImageProvider
                      : null,
                  child: (p.avatarUrl == null || p.avatarUrl!.isEmpty)
                      ? Text(
                          p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.primaryDeep,
                          ),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    final c = context.colors;
    final yaInscrito = _detalle?.yaInscrito ?? false;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: c.card,
        border: Border(top: BorderSide(color: c.primaryDeepWithAlpha(0.05))),
      ),
      child: ElevatedButton(
        onPressed: _isActionLoading ? null : _toggleInscripcion,
        style: ElevatedButton.styleFrom(
          backgroundColor: yaInscrito ? c.primaryDeepWithAlpha(0.1) : c.primaryDeep,
          foregroundColor: yaInscrito ? c.primaryDeep : Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: yaInscrito
                ? BorderSide(color: c.primaryDeepWithAlpha(0.3))
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: _isActionLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: yaInscrito ? c.primaryDeep : Colors.white,
                ),
              )
            : Text(
                yaInscrito ? 'Desinscribirse ✓' : 'Unirse al evento',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
