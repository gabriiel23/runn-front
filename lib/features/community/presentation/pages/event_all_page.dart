import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/eventos_service.dart';
import '../../domain/models/evento_model.dart';
import '../../../../core/config/api_config.dart';

class EventAllPage extends StatefulWidget {
  const EventAllPage({super.key});

  @override
  State<EventAllPage> createState() => _EventAllPageState();
}

class _EventAllPageState extends State<EventAllPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<EventoModel> _proximos = [];
  List<EventoModel> _pasados = [];
  bool _isLoading = true;
  String? _userRol;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final rolFuture = ApiConfig.getUserRol();
      final eventosFuture = EventosService.getEventos();
      final results = await Future.wait([rolFuture, eventosFuture]);
      final rol = results[0] as String?;
      final todos = results[1] as List<EventoModel>;

      final now = DateTime.now();
      final proximos = todos.where((e) {
        final fecha = e.fecha;
        if (e.finalizado) return false;
        if (fecha == null) return true;
        return fecha.isAfter(now) || fecha.day == now.day;
      }).toList();

      final pasados = todos.where((e) {
        final fecha = e.fecha;
        if (e.finalizado) return true;
        if (fecha == null) return false;
        return fecha.isBefore(now) && fecha.day != now.day;
      }).toList();

      if (mounted) {
        setState(() {
          _userRol = rol;
          _proximos = proximos;
          _pasados = pasados;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmarFinalizar(EventoModel evento) async {
    final c = context.colors;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Finalizar Evento',
          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Deseas marcar "${evento.titulo}" como finalizado? Esta acción moverá el evento a la lista de pasados.',
          style: TextStyle(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: c.textHint)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primaryDeep,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text(
              'Finalizar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    try {
      await EventosService.finalizarEvento(evento.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Evento finalizado ✅'),
            backgroundColor: context.colors.primaryDeep,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
        title: const Text(
          'Todos los Eventos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                controller: _tabController,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                tabs: [
                  Tab(text: 'Próximos (${_isLoading ? '…' : _proximos.length})'),
                  Tab(text: 'Pasados (${_isLoading ? '…' : _pasados.length})'),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _userRol == 'admin'
          ? FloatingActionButton.extended(
              onPressed: () =>
                  context.pushNamed('event_create').then((_) => _loadAll()),
              backgroundColor: c.primaryDeep,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Crear Evento',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_proximos, isPast: false),
                _buildList(_pasados, isPast: true),
              ],
            ),
    );
  }

  Widget _buildList(List<EventoModel> eventos, {required bool isPast}) {
    final c = context.colors;

    if (eventos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPast ? Icons.history_rounded : Icons.event_available_rounded,
              size: 72,
              color: c.primaryDeepWithAlpha(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              isPast ? 'Sin eventos pasados' : 'No hay eventos próximos',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      color: c.primaryDeep,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: eventos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) => _buildCard(eventos[i], isPast: isPast),
      ),
    );
  }

  Widget _buildCard(EventoModel evento, {required bool isPast}) {
    final c = context.colors;
    final isAdmin = _userRol == 'admin';

    return GestureDetector(
      onTap: () => context
          .pushNamed('event_detail', pathParameters: {'eventId': evento.id})
          .then((_) => _loadAll()),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: evento.fotoUrl != null && evento.fotoUrl!.isNotEmpty
                      ? Image.network(
                          evento.fotoUrl!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImgPlaceholder(c),
                        )
                      : _buildImgPlaceholder(c),
                ),
                // Chips
                Positioned(
                  top: 12,
                  left: 12,
                  child: Row(
                    children: [
                      _buildChip(
                        evento.esPago
                            ? 'De pago \$${evento.precio.toStringAsFixed(0)}'
                            : 'Gratuito',
                        evento.esPago ? Colors.blue : Colors.green,
                      ),
                      if (isPast || evento.finalizado) ...[
                        const SizedBox(width: 6),
                        _buildChip('Finalizado', Colors.grey.shade600),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: c.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        evento.fechaFormateada,
                        style: TextStyle(color: c.textSecondary, fontSize: 13),
                      ),
                      if (evento.horaFormateada.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: c.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          evento.horaFormateada,
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (evento.lugar != null && evento.lugar!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: c.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            evento.lugar!,
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people_rounded,
                        size: 14,
                        color: c.primaryDeep,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        evento.limiteParticipantes != null
                            ? '${evento.participantesConfirmados}/${evento.limiteParticipantes} participantes'
                            : '${evento.participantesConfirmados} participantes',
                        style: TextStyle(
                          color: c.primaryDeep,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      // Botón Finalizar (solo admin, solo en próximos)
                      if (isAdmin && !isPast && !evento.finalizado)
                        TextButton.icon(
                          onPressed: () => _confirmarFinalizar(evento),
                          icon: const Icon(Icons.flag_rounded, size: 14),
                          label: const Text(
                            'Finalizar',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.orangeAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImgPlaceholder(dynamic c) {
    return Container(
      height: 160,
      color: c.primaryLight,
      child: Center(
        child: Icon(
          Icons.directions_run_rounded,
          size: 40,
          color: c.primaryDeep,
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
