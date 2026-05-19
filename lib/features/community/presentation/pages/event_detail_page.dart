import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/eventos_service.dart';
import '../../domain/models/evento_model.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/services/http_client.dart';
import 'event_edit_page.dart';
import 'event_payment_page.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> with RouteAware {
  EventoDetalleModel? _detalle;
  bool _isLoading = true;
  bool _isActionLoading = false;
  String _errorMsg = '';
  bool _isAdminEventos = false;

  GoogleMapController? _mapController;

  // RouteObserver to detect when we return to this page
  static final RouteObserver<ModalRoute<void>> _routeObserver = RouteObserver<ModalRoute<void>>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) _routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Called when this route becomes active again (e.g., after Navigator.pop from participants page)
  @override
  void didPopNext() {
    _loadDetalle();
  }

  @override
  void initState() {
    super.initState();
    _loadDetalle();
    _loadRol();
  }

  Future<void> _loadRol() async {
    final esAdmin = await ApiConfig.isAdminEventos();
    if (mounted) setState(() => _isAdminEventos = esAdmin);
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

  Future<void> _handlePrimaryAction() async {
    if (_detalle == null || _isActionLoading) return;
    
    // Si ya inscrito o admitido, ir al ticket
    if (_detalle!.yaInscrito || _detalle!.enListaEsperaStatus == 'admitido') {
      context.pushNamed('event_ticket', pathParameters: {'eventId': widget.eventId});
      return;
    }

    if (_detalle!.evento.esPago) {
      final subio = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => EventPaymentPage(evento: _detalle!.evento)),
      );
      if (subio == true && mounted) {
        _loadDetalle();
      }
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      final res = await EventosService.unirseEvento(widget.eventId);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['mensaje'] ?? 'Solicitud enviada')));

      await _loadDetalle();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
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
    final isAdmin = _isAdminEventos;

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
                  const SizedBox(height: 24),
                  _buildCapacityBar(context, evento),
                  const SizedBox(height: 32),
                  if (isAdmin) _buildAdminControls(context),
                  if (isAdmin) const SizedBox(height: 32),
                  _buildDescription(context, evento),
                  const SizedBox(height: 32),
                  if (evento.puntoInicio != null || evento.rutaSugerida != null || evento.lugar != null)
                    _buildRouteSection(context, evento),
                  if (evento.puntoInicio != null || evento.rutaSugerida != null || evento.lugar != null)
                    const SizedBox(height: 32),
                  _buildParticipantsSection(context),
                  const SizedBox(height: 120), // Aumentado para que el botón flotante no tape a los participantes
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _detalle == null ? null : _buildBottomSheet(context),
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
                    } else if (value == 'Ver participantes') {
                      context.pushNamed('event_participants', pathParameters: {'eventId': widget.eventId});
                    } else if (value == 'Escanear QR') {
                      context.pushNamed('event_scanner', pathParameters: {'eventId': widget.eventId});
                    } else if (value == 'Ver escaneados') {
                      context.pushNamed('event_scanned_list', pathParameters: {'eventId': widget.eventId});
                    } else if (value == 'Lista de espera') {
                      context.pushNamed('event_waiting_list', pathParameters: {'eventId': widget.eventId});
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'Editar evento',
                      child: Row(children: [Icon(Icons.edit_rounded, color: c.primaryDeep, size: 18), const SizedBox(width: 12), Text('Editar evento', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600))]),
                    ),
                    PopupMenuItem(
                      value: 'Ver participantes',
                      child: Row(children: [Icon(Icons.group_rounded, color: c.primaryDeep, size: 18), const SizedBox(width: 12), Text('Ver participantes', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600))]),
                    ),
                    PopupMenuItem(
                      value: 'Lista de espera',
                      child: Row(children: [Icon(Icons.queue_rounded, color: c.primaryDeep, size: 18), const SizedBox(width: 12), Text('Lista de espera', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600))]),
                    ),
                    PopupMenuItem(
                      value: 'Escanear QR',
                      child: Row(children: [Icon(Icons.qr_code_scanner_rounded, color: c.primaryDeep, size: 18), const SizedBox(width: 12), Text('Escanear códigos', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600))]),
                    ),
                    PopupMenuItem(
                      value: 'Ver escaneados',
                      child: Row(children: [Icon(Icons.checklist_rounded, color: Colors.green, size: 18), const SizedBox(width: 12), Text('Ver escaneados', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600))]),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'Eliminar evento',
                      child: Row(children: [const Icon(Icons.delete_rounded, color: Color(0xFFFF3B30), size: 18), const SizedBox(width: 12), const Text('Eliminar evento', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.w600))]),
                    ),
                  ],
                ),
              ),
            ]
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: () {
            if (evento.fotoUrl == null || evento.fotoUrl!.isEmpty) return;
            showDialog(
              context: context,
              barrierColor: Colors.black.withValues(alpha: 0.9),
              builder: (dialogContext) => Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      maxScale: 5.0,
                      child: Image.network(evento.fotoUrl!, fit: BoxFit.contain),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Stack(
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
            _buildInfoChip(
              context, 
              evento.esPago ? Icons.monetization_on_rounded : Icons.money_off_rounded, 
              evento.esPago ? '\$${evento.precio.toInt()}' : 'Gratuito',
              color: evento.esPago ? Colors.blueAccent : Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCapacityBar(BuildContext context, EventoModel evento) {
    if (evento.limiteParticipantes == null) {
      return Text('Sin límite de participantes', style: TextStyle(color: context.colors.textSecondary, fontSize: 13));
    }
    
    final int ocupados = evento.participantesConfirmados;
    final int limite = evento.limiteParticipantes!;
    final double percent = ocupados / limite;
    final c = context.colors;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Lugares ocupados', style: TextStyle(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
            Text('$ocupados de $limite', style: TextStyle(color: c.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: c.primaryDeepWithAlpha(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 1.0 ? Colors.orange : c.primaryDeep),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminControls(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.primaryDeepWithAlpha(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Controles Administrativos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c.primaryDeep)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.pushNamed('event_waiting_list', pathParameters: {'eventId': widget.eventId}),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primaryDeep,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.list_alt_rounded, size: 16),
                  label: const Text('Lista espera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.pushNamed('event_scanner', pathParameters: {'eventId': widget.eventId}),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: c.primaryDeep,
                    side: BorderSide(color: c.primaryDeep),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                  label: const Text('Escanear QR'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text, {Color? color}) {
    final c = context.colors;
    final itemColor = color ?? c.textPrimary.withValues(alpha: 0.6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: itemColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: itemColor,
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

    Set<Marker> markers = {};
    Set<Polyline> polylines = {};
    LatLng? initialMapPosition;

    if (evento.puntoInicio != null && evento.puntoFin != null) {
      final start = LatLng(evento.puntoInicio!['lat'], evento.puntoInicio!['lng']);
      final end = LatLng(evento.puntoFin!['lat'], evento.puntoFin!['lng']);
      initialMapPosition = start;

      markers.add(Marker(
        markerId: const MarkerId('start'),
        position: start,
        infoWindow: InfoWindow(title: evento.puntoInicio!['nombre'] ?? 'Inicio'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));

      markers.add(Marker(
        markerId: const MarkerId('end'),
        position: end,
        infoWindow: InfoWindow(title: evento.puntoFin!['nombre'] ?? 'Meta'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));

      List<LatLng> points = [start];
      if (evento.waypoints != null && evento.waypoints!.isNotEmpty) {
        final sortedList = List.from(evento.waypoints!);
        sortedList.sort((a, b) => (a['orden'] as int).compareTo(b['orden'] as int));
        for (var wp in sortedList) {
          points.add(LatLng(wp['lat'], wp['lng']));
        }
      }
      points.add(end);

      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: c.primaryDeep,
        width: 4,
      ));
    }

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
              height: 200,
              width: double.infinity,
              color: c.primaryLight,
              child: initialMapPosition != null
                  ? Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(target: initialMapPosition, zoom: 14),
                          markers: markers,
                          polylines: polylines,
                          mapType: MapType.normal,
                          zoomControlsEnabled: false, // Desactivado para mayor limpieza
                          scrollGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          onMapCreated: (controller) => _mapController = controller,
                          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                          },
                        ),
                        // Botón para centrar mapa
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Material(
                            color: Colors.white,
                            elevation: 4,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                _mapController?.animateCamera(
                                  CameraUpdate.newLatLng(initialMapPosition!),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(Icons.my_location_rounded, color: c.primaryDeep, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(child: Icon(Icons.route_rounded, size: 40, color: c.textHint)),
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
    final isAdmin = _isAdminEventos;
    if (_detalle == null || isAdmin) return const SizedBox.shrink();

    final yaInscrito = _detalle!.yaInscrito;
    final status = _detalle!.enListaEsperaStatus;
    final cupo = _detalle!.evento.cupoDisponible;

    // Lógica inteligente de botón
    Widget buttonChild;
    Color bgColor = c.primaryDeep;
    Color fgColor = Colors.white;
    Function()? onPressed = _handlePrimaryAction;

    if (yaInscrito || status == 'admitido') {
      buttonChild = Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.confirmation_number_outlined), SizedBox(width: 8), Text('Ver mi ticket')]);
    } else if (status == 'pendiente') {
      buttonChild = const Text('En lista de espera — Pendiente', style: TextStyle(color: Colors.orangeAccent));
      bgColor = Colors.orange.withValues(alpha: 0.1);
      onPressed = null;
    } else if (status == 'rechazado') {
      if (_detalle!.evento.esPago) {
        buttonChild = const Text('Prueba de pago rechazada. Reintentar', style: TextStyle(color: Colors.redAccent));
        bgColor = Colors.red.withValues(alpha: 0.1);
        onPressed = _handlePrimaryAction;
      } else {
        buttonChild = const Text('Solicitud rechazada', style: TextStyle(color: Colors.redAccent));
        bgColor = Colors.red.withValues(alpha: 0.1);
        onPressed = null;
      }
    } else if (cupo == 0) {
      buttonChild = const Text('Unirse a lista de espera');
    } else {
      buttonChild = const Text('Inscribirme');
    }

    if (_isActionLoading) {
      buttonChild = SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: fgColor));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: c.bg.withValues(alpha: 0.8), // Glassmorphism sutil
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c.bg.withValues(alpha: 0.0),
            c.bg.withValues(alpha: 1.0),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            minimumSize: const Size(double.infinity, 60),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: fgColor, letterSpacing: 0.5),
            child: buttonChild,
          ),
        ),
      ),
    );
  }
}
