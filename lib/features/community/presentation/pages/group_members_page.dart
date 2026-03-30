import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../../../core/services/http_client.dart';
import '../../services/grupos_service.dart';
import '../../services/admin_service.dart';
import '../../domain/models/grupo_model.dart';

class GroupMembersPage extends StatefulWidget {
  final String grupoId;
  final String? miRol;
  final String? miId;

  const GroupMembersPage({
    super.key,
    required this.grupoId,
    this.miRol,
    this.miId,
  });

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage>
    with SingleTickerProviderStateMixin {
  List<MiembroGrupo> _miembros = [];
  List<SolicitudGrupo> _solicitudes = [];
  List<InvitacionPanel> _invitaciones = [];
  bool _isLoading = true;
  bool _isActing = false;
  late TabController _tabController;

  bool get _esCreador => widget.miRol == 'creador';
  bool get _esAdmin => widget.miRol == 'admin' || widget.miRol == 'creador';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _esAdmin ? 3 : 1, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final detalle = await GruposService.getGrupoDetalle(widget.grupoId);
      List<SolicitudGrupo> sol = [];
      List<InvitacionPanel> inv = [];
      if (_esAdmin) {
        sol = await GruposService.getSolicitudesGrupo(widget.grupoId);
        inv = await GruposService.getInvitacionesPanel(widget.grupoId);
      }
      if (mounted) {
        setState(() {
          _miembros = detalle.miembros;
          if (_esAdmin) {
            _solicitudes = sol;
            _invitaciones = inv;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _responderSolicitud(SolicitudGrupo s, String accion) async {
    setState(() => _isActing = true);
    try {
      await GruposService.responderSolicitud(widget.grupoId, s.id, accion);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Solicitud ${accion == 'aceptar' ? 'aceptada' : 'rechazada'}',
            ),
            backgroundColor: const Color(0xFF34C759),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  Future<void> _eliminarMiembro(MiembroGrupo m) async {
    final c = context.colors;
    final conf = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar miembro',
          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Seguro que deseas expulsar a ${m.nombre} del grupo?',
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
              backgroundColor: const Color(0xFFFF3B30),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text(
              'Expulsar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (conf != true || !mounted) return;

    setState(() => _isActing = true);
    try {
      await GruposService.eliminarMiembro(widget.grupoId, m.id);
      if (mounted) setState(() => _miembros.removeWhere((x) => x.id == m.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Miembro expulsado'),
            backgroundColor: Color(0xFF34C759),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  Future<void> _cambiarRol(MiembroGrupo m, String nuevoRol) async {
    setState(() => _isActing = true);
    try {
      await GruposService.cambiarRolMiembro(widget.grupoId, m.id, nuevoRol);
      if (mounted) {
        setState(() {
          final idx = _miembros.indexWhere((x) => x.id == m.id);
          if (idx != -1) {
            _miembros[idx] = MiembroGrupo(
              id: m.id,
              nombre: m.nombre,
              avatarUrl: m.avatarUrl,
              rol: nuevoRol,
              unidoEn: m.unidoEn,
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rol actualizado'),
            backgroundColor: Color(0xFF34C759),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  void _abrirBuscadorUsuarios({required bool esParaInvitar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UserPickerModal(
        grupoId: widget.grupoId,
        esParaInvitar: esParaInvitar,
        miembrosActualesIds: _miembros.map((m) => m.id).toSet(),
        onSuccess: () => _load(),
      ),
    );
  }

  void _mostrarOpcionesAgregar() {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.primaryDeepWithAlpha(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Agregar al grupo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.add_circle_outline_rounded,
              label: 'Agregar directo',
              color: c.primaryDeep,
              onTap: () {
                Navigator.pop(ctx);
                _abrirBuscadorUsuarios(esParaInvitar: false);
              },
            ),
            const SizedBox(height: 12),
            _OptionTile(
              icon: Icons.mail_outline_rounded,
              label: 'Enviar invitación',
              color: c.primaryDeep,
              onTap: () {
                Navigator.pop(ctx);
                _abrirBuscadorUsuarios(esParaInvitar: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pendientes = _solicitudes
        .where((s) => s.estado == 'pendiente')
        .length;

    return Scaffold(
      backgroundColor: c.bg,
      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Gestión del grupo',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        // ── TabBar con el estilo pill ──────────────────────────────────
        bottom: _esAdmin
            ? PreferredSize(
                preferredSize: const Size.fromHeight(72),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.primaryDeepWithAlpha(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      padding: const EdgeInsets.all(4),
                      indicatorPadding: EdgeInsets.zero,
                      indicator: BoxDecoration(
                        color: c.primary,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      labelColor: c.card,
                      unselectedLabelColor: c.textSecondary,
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                      tabs: [
                        const Tab(text: 'Miembros'),
                        Tab(
                          text: pendientes > 0
                              ? 'Solicitudes ($pendientes)'
                              : 'Solicitudes',
                        ),
                        const Tab(text: 'Invitaciones'),
                      ],
                    ),
                  ),
                ),
              )
            : PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: c.primaryDeepWithAlpha(0.08),
                  height: 1,
                ),
              ),
      ),
      // ── FAB ─────────────────────────────────────────────────────────────
      floatingActionButton: _esAdmin
          ? FloatingActionButton(
              onPressed: _mostrarOpcionesAgregar,
              backgroundColor: c.primaryDeep,
              foregroundColor: c.card,
              elevation: 2,
              child: const Icon(Icons.person_add_rounded),
            )
          : null,
      // ── Body ────────────────────────────────────────────────────────────
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : Stack(
              children: [
                _esAdmin
                    ? TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMiembrosTab(c),
                          _buildSolicitudesTab(c),
                          _buildInvitacionesTab(c),
                        ],
                      )
                    : _buildMiembrosTab(c),
                if (_isActing)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }

  // ── Tabs ────────────────────────────────────────────────────────────────

  Widget _buildMiembrosTab(dynamic c) {
    if (_miembros.isEmpty) {
      return Center(
        child: Text('No hay miembros', style: TextStyle(color: c.textHint)),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: c.primaryDeep,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: _miembros.length,
        itemBuilder: (ctx, i) => _buildMiembroCard(c, _miembros[i]),
      ),
    );
  }

  Widget _buildSolicitudesTab(dynamic c) {
    final pendientes = _solicitudes
        .where((s) => s.estado == 'pendiente')
        .toList();
    if (pendientes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: c.textHint),
            const SizedBox(height: 12),
            Text(
              'Sin solicitudes pendientes',
              style: TextStyle(color: c.textHint, fontSize: 15),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: c.primaryDeep,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        itemCount: pendientes.length,
        itemBuilder: (ctx, i) {
          final s = pendientes[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: c.primaryLight,
                  backgroundImage:
                      s.avatarUrl != null && s.avatarUrl!.isNotEmpty
                      ? NetworkImage(s.avatarUrl!) as ImageProvider
                      : null,
                  child: s.avatarUrl == null || s.avatarUrl!.isEmpty
                      ? Text(
                          s.nombre.isNotEmpty ? s.nombre[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: c.primaryDeep,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        s.creadoEnFmt,
                        style: TextStyle(color: c.textHint, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _isActing
                          ? null
                          : () => _responderSolicitud(s, 'rechazar'),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFFF3B30),
                        size: 22,
                      ),
                      tooltip: 'Rechazar',
                    ),
                    IconButton(
                      onPressed: _isActing
                          ? null
                          : () => _responderSolicitud(s, 'aceptar'),
                      icon: Icon(
                        Icons.check_circle_rounded,
                        color: c.primaryDeep,
                        size: 22,
                      ),
                      tooltip: 'Aceptar',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvitacionesTab(dynamic c) {
    if (_invitaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mail_outline_rounded, size: 48, color: c.textHint),
            const SizedBox(height: 12),
            Text(
              'Sin invitaciones enviadas',
              style: TextStyle(color: c.textHint, fontSize: 15),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: c.primaryDeep,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        itemCount: _invitaciones.length,
        itemBuilder: (ctx, i) {
          final inv = _invitaciones[i];
          Color estadoColor;
          IconData estadoIcon;
          switch (inv.estado) {
            case 'aceptada':
              estadoColor = const Color(0xFF34C759);
              estadoIcon = Icons.check_circle_outline_rounded;
              break;
            case 'rechazada':
              estadoColor = const Color(0xFFFF3B30);
              estadoIcon = Icons.cancel_outlined;
              break;
            default:
              estadoColor = const Color(0xFFFF9500);
              estadoIcon = Icons.access_time_rounded;
              break;
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: c.primaryLight,
                  backgroundImage:
                      inv.avatarUrl != null && inv.avatarUrl!.isNotEmpty
                      ? NetworkImage(inv.avatarUrl!) as ImageProvider
                      : null,
                  child: inv.avatarUrl == null || inv.avatarUrl!.isEmpty
                      ? Text(
                          inv.nombre.isNotEmpty
                              ? inv.nombre[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: c.primaryDeep,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        inv.creadoEnFmt,
                        style: TextStyle(color: c.textHint, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(estadoIcon, color: estadoColor, size: 20),
                const SizedBox(width: 4),
                Text(
                  inv.estado.substring(0, 1).toUpperCase() +
                      inv.estado.substring(1),
                  style: TextStyle(
                    color: estadoColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiembroCard(dynamic c, MiembroGrupo m) {
    final soyYo = m.id == widget.miId;
    final esCreadorDeGrupo = m.rol == 'creador';

    Color badgeColor;
    String badgeText;
    if (m.rol == 'creador') {
      badgeColor = const Color(0xFFFF9500);
      badgeText = 'Creador';
    } else if (m.rol == 'admin') {
      badgeColor = c.primaryDeep;
      badgeText = 'Admin';
    } else {
      badgeColor = c.textHint;
      badgeText = 'Miembro';
    }

    List<PopupMenuEntry<String>> opciones = [];

    if (_esCreador && !soyYo && !esCreadorDeGrupo) {
      if (m.rol == 'miembro') {
        opciones.add(
          PopupMenuItem(
            value: 'rol_admin',
            child: Text('Hacer Admin', style: TextStyle(color: c.primaryDeep)),
          ),
        );
      } else if (m.rol == 'admin') {
        opciones.add(
          PopupMenuItem(
            value: 'rol_miembro',
            child: Text('Quitar Admin', style: TextStyle(color: c.primaryDeep)),
          ),
        );
      }
    }

    if (_esAdmin && !soyYo && !esCreadorDeGrupo) {
      if (opciones.isNotEmpty) opciones.add(const PopupMenuDivider());
      opciones.add(
        const PopupMenuItem(
          value: 'eliminar',
          child: Text(
            'Expulsar del grupo',
            style: TextStyle(color: Color(0xFFFF3B30)),
          ),
        ),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: c.primaryLight,
        backgroundImage: m.avatarUrl != null && m.avatarUrl!.isNotEmpty
            ? NetworkImage(m.avatarUrl!) as ImageProvider
            : null,
        child: m.avatarUrl == null || m.avatarUrl!.isEmpty
            ? Text(
                m.nombre.isNotEmpty ? m.nombre[0].toUpperCase() : '?',
                style: TextStyle(
                  color: c.primaryDeep,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              m.nombre + (soyYo ? ' (Tú)' : ''),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        'Miembro desde ${m.unidoEnFmt}',
        style: TextStyle(color: c.textHint, fontSize: 12),
      ),
      trailing: opciones.isNotEmpty
          ? PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: c.textHint),
              color: c.card,
              onSelected: (val) {
                if (val == 'eliminar') _eliminarMiembro(m);
                if (val == 'rol_admin') _cambiarRol(m, 'admin');
                if (val == 'rol_miembro') _cambiarRol(m, 'miembro');
              },
              itemBuilder: (_) => opciones,
            )
          : null,
    );
  }
}

// ── Widget auxiliar para opciones del bottom sheet ──────────────────────────

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.primaryDeepWithAlpha(0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: c.textHint, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── MODAL REUTILIZABLE PARA BUSCAR Y AGREGAR / INVITAR ───────────────────

class _UserPickerModal extends StatefulWidget {
  final String grupoId;
  final bool esParaInvitar;
  final Set<String> miembrosActualesIds;
  final VoidCallback onSuccess;

  const _UserPickerModal({
    required this.grupoId,
    required this.esParaInvitar,
    required this.miembrosActualesIds,
    required this.onSuccess,
  });

  @override
  State<_UserPickerModal> createState() => _UserPickerModalState();
}

class _UserPickerModalState extends State<_UserPickerModal> {
  List<UsuarioAdminModel> _todosUsuarios = [];
  List<UsuarioAdminModel> _usuariosFiltrados = [];
  bool _isLoadingUsuarios = true;
  bool _isActing = false;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarTodosUsuarios();
  }

  Future<void> _cargarTodosUsuarios() async {
    try {
      final res = await GruposService.buscarUsuariosParaGrupo(widget.grupoId);
      if (!mounted) return;
      setState(() {
        _todosUsuarios = res
            .map(
              (u) => UsuarioAdminModel(
                id: u['id'] as String,
                nombre: u['nombre'] as String,
                correo: u['correo'] as String,
                nivel: u['nivel'] as String?,
                ciudad: u['ciudad'] as String?,
                avatarUrl: u['avatar_url'] as String?,
              ),
            )
            .toList();
        _todosUsuarios = _todosUsuarios
            .where((u) => !widget.miembrosActualesIds.contains(u.id))
            .toList();
        _usuariosFiltrados = _todosUsuarios;
        _isLoadingUsuarios = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingUsuarios = false);
    }
  }

  void _filtrar(String query) {
    _busqueda = query.trim().toLowerCase();
    setState(() {
      if (_busqueda.isEmpty) {
        _usuariosFiltrados = _todosUsuarios;
      } else {
        _usuariosFiltrados = _todosUsuarios.where((u) {
          final nombre = u.nombre.toLowerCase();
          final correo = u.correo.toLowerCase();
          return nombre.contains(_busqueda) || correo.contains(_busqueda);
        }).toList();
      }
    });
  }

  Future<void> _ejecutarAccion(String targetUserId, String nombre) async {
    setState(() => _isActing = true);
    try {
      if (widget.esParaInvitar) {
        await GruposService.invitarUsuario(widget.grupoId, targetUserId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invitación enviada a $nombre'),
              backgroundColor: const Color(0xFF34C759),
            ),
          );
        }
      } else {
        await GruposService.agregarMiembro(widget.grupoId, targetUserId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$nombre agregado al grupo'),
              backgroundColor: const Color(0xFF34C759),
            ),
          );
        }
      }
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final title = widget.esParaInvitar ? 'Invitar Usuario' : 'Agregar Miembro';
    final actionLabel = widget.esParaInvitar ? 'Invitar' : 'Agregar';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.primaryDeepWithAlpha(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
          ),
          Divider(height: 1, color: c.primaryDeepWithAlpha(0.1)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.primaryDeepWithAlpha(0.07)),
              ),
              child: TextField(
                onChanged: _filtrar,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar usuario...',
                  hintStyle: TextStyle(color: c.textHint),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: c.primaryDeep,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoadingUsuarios
                ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
                : _usuariosFiltrados.isEmpty
                ? Center(
                    child: _busqueda.isEmpty
                        ? Text(
                            'No hay usuarios disponibles',
                            style: TextStyle(color: c.textHint),
                          )
                        : Text(
                            'No se encontraron resultados',
                            style: TextStyle(color: c.textHint),
                          ),
                  )
                : Stack(
                    children: [
                      ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _usuariosFiltrados.length,
                        itemBuilder: (ctx, i) {
                          final u = _usuariosFiltrados[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: c.primaryLight,
                              child: Text(
                                u.nombre[0].toUpperCase(),
                                style: TextStyle(
                                  color: c.primaryDeep,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              u.nombre,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              u.correo,
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: _isActing
                                  ? null
                                  : () => _ejecutarAccion(u.id, u.nombre),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: c.primaryDeep,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(actionLabel),
                            ),
                          );
                        },
                      ),
                      if (_isActing)
                        Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
