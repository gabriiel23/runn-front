import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/grupos_service.dart';
import '../../services/admin_service.dart';
import '../../domain/models/grupo_model.dart';
import '../../../../core/services/http_client.dart';

class GroupMembersPage extends StatefulWidget {
  final String grupoId;
  final String? miRol;
  final String? miId;

  const GroupMembersPage({super.key, required this.grupoId, this.miRol, this.miId});

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  List<MiembroGrupo> _miembros = [];
  bool _isLoading = true;
  bool _isActing = false;

  bool get _esCreador => widget.miRol == 'creador';
  bool get _esAdmin => widget.miRol == 'admin' || widget.miRol == 'creador';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final detalle = await GruposService.getGrupoDetalle(widget.grupoId);
      if (mounted) setState(() { _miembros = detalle.miembros; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarMiembro(MiembroGrupo m) async {
    final c = context.colors;
    final conf = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar miembro', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('¿Seguro que deseas expulsar a ${m.nombre} del grupo?', style: TextStyle(color: c.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar', style: TextStyle(color: c.textHint))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), foregroundColor: Colors.white, elevation: 0),
            child: const Text('Expulsar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (conf != true || !mounted) return;

    setState(() => _isActing = true);
    try {
      await GruposService.eliminarMiembro(widget.grupoId, m.id);
      // Actualizar vista localmente
      if (mounted) setState(() => _miembros.removeWhere((x) => x.id == m.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Miembro expulsado'), backgroundColor: Color(0xFF34C759)));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFFF3B30)));
      }
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  Future<void> _cambiarRol(MiembroGrupo m, String nuevoRol) async {
    setState(() => _isActing = true);
    try {
      await GruposService.cambiarRolMiembro(widget.grupoId, m.id, nuevoRol);
      // Actualizar vista localmente
      if (mounted) {
        setState(() {
          final idx = _miembros.indexWhere((x) => x.id == m.id);
          if (idx != -1) {
            _miembros[idx] = MiembroGrupo(
              id: m.id, nombre: m.nombre, avatarUrl: m.avatarUrl,
              rol: nuevoRol, unidoEn: m.unidoEn,
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rol actualizado'), backgroundColor: Color(0xFF34C759)));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFFF3B30)));
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
        onSuccess: () => _load(), // Recargar después de agregar
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary), onPressed: () => context.pop()),
        title: Text('Miembros', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.5)),
        actions: [
          if (_esAdmin)
            PopupMenuButton<String>(
              icon: Icon(Icons.person_add_rounded, color: c.primaryDeep),
              color: c.card,
              onSelected: (val) {
                if (val == 'agregar') _abrirBuscadorUsuarios(esParaInvitar: false);
                if (val == 'invitar') _abrirBuscadorUsuarios(esParaInvitar: true);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'agregar', child: Row(children: [Icon(Icons.add_circle_outline_rounded, color: c.primaryDeep, size: 20), const SizedBox(width: 8), Text('Agregar directo', style: TextStyle(color: c.textPrimary))])),
                PopupMenuItem(value: 'invitar', child: Row(children: [Icon(Icons.mail_outline_rounded, color: c.primaryDeep, size: 20), const SizedBox(width: 8), Text('Enviar invitación', style: TextStyle(color: c.textPrimary))])),
              ],
            ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: c.primaryDeepWithAlpha(0.08), height: 1)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : Stack(children: [
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _miembros.length,
                itemBuilder: (ctx, i) => _buildMiembroCard(c, _miembros[i]),
              ),
              if (_isActing) Container(color: Colors.black.withValues(alpha: 0.3), child: const Center(child: CircularProgressIndicator())),
            ]),
    );
  }

  Widget _buildMiembroCard(dynamic c, MiembroGrupo m) {
    final soyYo = m.id == widget.miId;
    final esCreadorDeGrupo = m.rol == 'creador';
    
    // Logica visual de roles
    Color badgeColor;
    String badgeText;
    if (m.rol == 'creador') { badgeColor = const Color(0xFFFF9500); badgeText = 'Creador'; }
    else if (m.rol == 'admin') { badgeColor = c.primaryDeep; badgeText = 'Admin'; }
    else { badgeColor = c.textHint; badgeText = 'Miembro'; }

    // Menú de opciones
    List<PopupMenuEntry<String>> opciones = [];
    
    // 1. Cambiar rol (sólo creador puede cambiar roles a admin o miembro, no a creador, ni a si mismo)
    if (_esCreador && !soyYo && !esCreadorDeGrupo) {
      if (m.rol == 'miembro') {
        opciones.add(PopupMenuItem(value: 'rol_admin', child: Text('Hacer Admin', style: TextStyle(color: c.primaryDeep))));
      } else if (m.rol == 'admin') {
        opciones.add(PopupMenuItem(value: 'rol_miembro', child: Text('Quitar Admin', style: TextStyle(color: c.primaryDeep))));
      }
    }

    // 2. Eliminar (admin/creador puede eliminar, pero no al creador, ni a sí mismo)
    if (_esAdmin && !soyYo && !esCreadorDeGrupo) {
      if (opciones.isNotEmpty) opciones.add(const PopupMenuDivider());
      opciones.add(const PopupMenuItem(value: 'eliminar', child: Text('Expulsar del grupo', style: TextStyle(color: Color(0xFFFF3B30)))));
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 24, backgroundColor: c.primaryLight,
        backgroundImage: m.avatarUrl != null && m.avatarUrl!.isNotEmpty ? NetworkImage(m.avatarUrl!) as ImageProvider : null,
        child: m.avatarUrl == null || m.avatarUrl!.isEmpty
            ? Text(m.nombre.isNotEmpty ? m.nombre[0].toUpperCase() : '?', style: TextStyle(color: c.primaryDeep, fontWeight: FontWeight.bold, fontSize: 18))
            : null,
      ),
      title: Row(children: [
        Flexible(child: Text(m.nombre + (soyYo ? ' (Tú)' : ''), style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: badgeColor.withValues(alpha: 0.3))),
          child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ),
      ]),
      subtitle: Text('Miembro desde ${m.unidoEnFmt}', style: TextStyle(color: c.textHint, fontSize: 12)),
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

// ─── MODAL REUTILIZABLE PARA BUSCAR Y AGREGAR / INVITAR ───────────────────

class _UserPickerModal extends StatefulWidget {
  final String grupoId;
  final bool esParaInvitar;
  final Set<String> miembrosActualesIds;
  final VoidCallback onSuccess;

  const _UserPickerModal({
    required this.grupoId, required this.esParaInvitar, required this.miembrosActualesIds, required this.onSuccess,
  });

  @override
  State<_UserPickerModal> createState() => _UserPickerModalState();
}

class _UserPickerModalState extends State<_UserPickerModal> {
  // Guardamos todos los usuarios y luego filtramos en memoria
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
      final res = await AdminService.getUsuarios();
      if (!mounted) return;
      setState(() {
        _todosUsuarios = res;
        // Filtrar a los que YA son miembros
        _todosUsuarios = _todosUsuarios.where((u) => !widget.miembrosActualesIds.contains(u.id)).toList();
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
            SnackBar(content: Text('Invitación enviada a $nombre'), backgroundColor: const Color(0xFF34C759)));
        }
      } else {
        await GruposService.agregarMiembro(widget.grupoId, targetUserId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$nombre agregado al grupo'), backgroundColor: const Color(0xFF34C759)));
        }
      }
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFFF3B30)));
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
      decoration: BoxDecoration(color: c.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: c.primaryDeepWithAlpha(0.2), borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(20), child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.textPrimary))),
        Divider(height: 1, color: c.primaryDeepWithAlpha(0.1)),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.primaryDeepWithAlpha(0.07))),
            child: TextField(
              onChanged: _filtrar,
              style: TextStyle(color: c.textPrimary),
              decoration: InputDecoration(hintText: 'Buscar usuario...', hintStyle: TextStyle(color: c.textHint), prefixIcon: Icon(Icons.search_rounded, color: c.primaryDeep, size: 20), border: InputBorder.none, contentPadding: const EdgeInsets.all(14)),
            ),
          ),
        ),
        Expanded(
          child: _isLoadingUsuarios
              ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
              : _usuariosFiltrados.isEmpty
                  ? Center(child: _busqueda.isEmpty 
                      ? Text('No hay usuarios disponibles', style: TextStyle(color: c.textHint)) 
                      : Text('No se encontraron resultados', style: TextStyle(color: c.textHint)))
                  : Stack(children: [
                      ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _usuariosFiltrados.length,
                        itemBuilder: (ctx, i) {
                          final u = _usuariosFiltrados[i];
                          final id = u.id;
                          final nombre = u.nombre;
                          final correo = u.correo;
                          
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: c.primaryLight, child: Text(nombre[0].toUpperCase(), style: TextStyle(color: c.primaryDeep, fontWeight: FontWeight.bold))),
                            title: Text(nombre, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600)),
                            subtitle: Text(correo, style: TextStyle(color: c.textSecondary, fontSize: 12)),
                            trailing: ElevatedButton(
                              onPressed: _isActing ? null : () => _ejecutarAccion(id, nombre),
                              style: ElevatedButton.styleFrom(backgroundColor: c.primaryDeep, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16), textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              child: Text(actionLabel),
                            ),
                          );
                        },
                      ),
                      if (_isActing) Container(color: Colors.black.withValues(alpha: 0.3), child: const Center(child: CircularProgressIndicator())),
                    ]),
        ),
      ]),
    );
  }
}
