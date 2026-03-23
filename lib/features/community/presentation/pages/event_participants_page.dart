import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/eventos_service.dart';
import '../../services/admin_service.dart';
import '../../domain/models/evento_model.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/services/http_client.dart';

class EventParticipantsPage extends StatefulWidget {
  final String eventId;

  const EventParticipantsPage({super.key, required this.eventId});

  @override
  State<EventParticipantsPage> createState() => _EventParticipantsPageState();
}

class _EventParticipantsPageState extends State<EventParticipantsPage> {
  List<ParticipanteModel> _participantes = [];
  int _total = 0;
  bool _isLoading = true;
  String _errorMsg = '';
  String? _userRol;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final rol = await ApiConfig.getUserRol();
    if (mounted) setState(() => _userRol = rol);
    await _loadParticipantes();
  }

  Future<void> _loadParticipantes() async {
    setState(() { _isLoading = true; _errorMsg = ''; });
    try {
      final detalle = await EventosService.getEvento(widget.eventId);
      if (mounted) {
        setState(() {
          _participantes = detalle.participantes;
          _total = detalle.totalParticipantes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _errorMsg = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _confirmarEliminarParticipante(ParticipanteModel p) async {
    final c = context.colors;
    final conf = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Expulsar de evento', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('¿Deseas eliminar a ${p.nombre} de este evento?', style: TextStyle(color: c.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar', style: TextStyle(color: c.textHint))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), foregroundColor: Colors.white, elevation: 0),
            child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (conf != true || !mounted) return;

    setState(() => _isActionLoading = true);
    try {
      await EventosService.eliminarParticipante(widget.eventId, p.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Participante eliminado'), backgroundColor: Color(0xFF34C759)));
        await _loadParticipantes();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFFF3B30)));
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _abrirModalAgregar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddParticipantModal(
        eventId: widget.eventId,
        currentParticipants: _participantes.map((p) => p.id).toSet(),
        onAdded: () {
          Navigator.pop(context);
          _loadParticipantes();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isLoading ? 'Participantes' : 'Participantes ($_total)',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: c.primaryDeepWithAlpha(0.1), height: 1),
        ),
      ),
      body: Stack(
        children: [
          _buildBody(c),
          if (_isActionLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: _userRol == 'admin'
          ? FloatingActionButton.extended(
              onPressed: _abrirModalAgregar,
              backgroundColor: c.primaryDeep,
              icon: const Icon(Icons.person_add_rounded, color: Colors.white),
              label: const Text('Agregar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildBody(dynamic c) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: c.primaryDeep));
    }

    if (_errorMsg.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off_rounded, size: 64, color: c.primaryDeepWithAlpha(0.3)),
            const SizedBox(height: 16),
            Text('No se pudo cargar los participantes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.textPrimary)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loadParticipantes, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    if (_participantes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_rounded, size: 64, color: c.primaryDeepWithAlpha(0.2)),
            const SizedBox(height: 16),
            Text(
              'Aún no hay participantes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: c.textHint,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¡Sé el primero en unirte!',
              style: TextStyle(fontSize: 14, color: c.textHint),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _participantes.length,
      separatorBuilder: (context, index) => Divider(
        color: c.primaryDeepWithAlpha(0.05),
        height: 1,
        indent: 24,
        endIndent: 24,
      ),
      itemBuilder: (context, index) {
        final p = _participantes[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: c.primaryLight,
            backgroundImage: p.avatarUrl != null && p.avatarUrl!.isNotEmpty
                ? NetworkImage(p.avatarUrl!) as ImageProvider
                : null,
            child: (p.avatarUrl == null || p.avatarUrl!.isEmpty)
                ? Text(
                    p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.primaryDeep,
                    ),
                  )
                : null,
          ),
          title: Text(
            p.nombre,
            style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary),
          ),
          subtitle: () {
            final parts = <String>[];
            if (p.ciudad != null && p.ciudad!.isNotEmpty) parts.add(p.ciudad!);
            if (p.nivel != null && p.nivel!.isNotEmpty) parts.add(p.nivel!);
            if (parts.isEmpty) return null;
            return Text(
              parts.join(' · '),
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            );
          }(),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_userRol == 'admin')
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.delete_rounded, color: Color(0xFFFF3B30), size: 22),
                    onPressed: () => _confirmarEliminarParticipante(p),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: () {
                  context.pushNamed(
                    'participant_profile',
                    pathParameters: {
                      'eventId': widget.eventId,
                      'userId': p.id,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primaryDeepWithAlpha(0.1),
                  foregroundColor: c.primaryDeep,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Ver perfil', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddParticipantModal extends StatefulWidget {
  final String eventId;
  final Set<String> currentParticipants;
  final VoidCallback onAdded;

  const _AddParticipantModal({
    required this.eventId,
    required this.currentParticipants,
    required this.onAdded,
  });

  @override
  State<_AddParticipantModal> createState() => _AddParticipantModalState();
}

class _AddParticipantModalState extends State<_AddParticipantModal> {
  List<UsuarioAdminModel> _usuarios = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
  }

  Future<void> _fetchUsuarios() async {
    try {
      final todos = await AdminService.getUsuarios();
      // Filtrar los que ya están inscritos
      final filtrados = todos.where((u) => !widget.currentParticipants.contains(u.id)).toList();
      if (mounted) setState(() { _usuarios = filtrados; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _agregar(UsuarioAdminModel usuario) async {
    setState(() => _isLoading = true);
    try {
      await EventosService.agregarParticipante(widget.eventId, usuario.id);
      widget.onAdded();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFFF3B30)));
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final height = MediaQuery.of(context).size.height * 0.7;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: c.primaryDeepWithAlpha(0.2), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.person_add_rounded, color: c.primaryDeep, size: 28),
                const SizedBox(width: 12),
                Text('Agregar corredor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.textPrimary)),
              ],
            ),
          ),
          Divider(height: 1, color: c.primaryDeepWithAlpha(0.1)),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
                : _error.isNotEmpty
                    ? Center(child: Text('Error: $_error', style: TextStyle(color: c.textHint)))
                    : _usuarios.isEmpty
                        ? Center(child: Text('No hay corredores disponibles para agregar', style: TextStyle(color: c.textHint)))
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _usuarios.length,
                            separatorBuilder: (_, __) => Divider(height: 1, indent: 24, endIndent: 24, color: c.primaryDeepWithAlpha(0.05)),
                            itemBuilder: (context, index) {
                              final u = _usuarios[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: c.primaryLight,
                                  backgroundImage: u.avatarUrl != null && u.avatarUrl!.isNotEmpty ? NetworkImage(u.avatarUrl!) as ImageProvider : null,
                                  child: u.avatarUrl == null || u.avatarUrl!.isEmpty
                                      ? Text(u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?', style: TextStyle(color: c.primaryDeep, fontWeight: FontWeight.bold))
                                      : null,
                                ),
                                title: Text(u.nombre, style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)),
                                subtitle: Text(u.correo, style: TextStyle(color: c.textSecondary, fontSize: 13)),
                                trailing: ElevatedButton(
                                  onPressed: () => _agregar(u),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: c.primaryDeep,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Añadir', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

