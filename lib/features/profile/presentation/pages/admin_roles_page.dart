import 'package:flutter/material.dart';
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

/// Modelo local para un usuario de la lista de admin.
class _UserRow {
  final String id;
  final String nombre;
  final String correo;
  final String? avatarUrl;
  String rolString; // e.g. "usuario", "admin_eventos,admin_noticias"

  _UserRow({
    required this.id,
    required this.nombre,
    required this.correo,
    this.avatarUrl,
    required this.rolString,
  });

  factory _UserRow.fromJson(Map<String, dynamic> j) => _UserRow(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        correo: j['correo'] as String? ?? '',
        avatarUrl: j['avatar_url'] as String?,
        rolString: j['rol'] as String? ?? 'usuario',
      );

  List<String> get roles => rolString.split(',').map((r) => r.trim()).toList();

  bool hasRol(String r) => roles.contains(r);
}

// ─── Constantes de roles ─────────────────────────────────────────────────────
const _kRoles = ['superadmin', 'admin_eventos', 'admin_noticias'];
const _kRolLabels = {
  'superadmin':     'Superadmin',
  'admin_eventos':  'Admin Eventos',
  'admin_noticias': 'Admin Noticias',
};
const _kRolIcons = {
  'superadmin':     Icons.verified_user_rounded,
  'admin_eventos':  Icons.event_rounded,
  'admin_noticias': Icons.article_rounded,
};
const _kRolColors = {
  'superadmin':     Color(0xFFFF6B35),
  'admin_eventos':  Color(0xFF5B8BF5),
  'admin_noticias': Color(0xFF34C759),
};

// ─── PÁGINA ──────────────────────────────────────────────────────────────────

class AdminRolesPage extends StatefulWidget {
  const AdminRolesPage({super.key});

  @override
  State<AdminRolesPage> createState() => _AdminRolesPageState();
}

class _AdminRolesPageState extends State<AdminRolesPage>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late AnimationController _entryAnim;
  late Animation<double> _fadeAnim;

  List<_UserRow> _todos = [];
  List<_UserRow> _filtrados = [];
  bool _isLoading = true;
  String _error = '';
  String? _myId;

  @override
  void initState() {
    super.initState();
    _entryAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _entryAnim, curve: Curves.easeOut);
    _searchCtrl.addListener(_applyFilter);
    _load();
  }

  @override
  void dispose() {
    _entryAnim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      _myId = await ApiConfig.getCurrentUserId();
      final data = await RunnHttpClient.get('/admin/usuarios') as Map<String, dynamic>;
      final lista = (data['usuarios'] as List)
          .map((j) => _UserRow.fromJson(j as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _todos = lista;
          _applyFilter();
          _isLoading = false;
        });
        _entryAnim.forward();
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtrados = q.isEmpty
          ? List.from(_todos)
          : _todos.where((u) =>
              u.nombre.toLowerCase().contains(q) ||
              u.correo.toLowerCase().contains(q)).toList();
    });
  }

  void _showRolSheet(_UserRow user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RolSheet(
        user: user,
        myId: _myId,
        onSaved: (newRol) async {
          await _updateRol(user, newRol);
        },
      ),
    );
  }

  Future<void> _updateRol(_UserRow user, String newRol) async {
    try {
      await RunnHttpClient.put(
        '/admin/usuarios/${user.id}/rol',
        body: {'rol': newRol},
      );
      setState(() {
        user.rolString = newRol;
        _applyFilter();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Rol actualizado exitosamente ✅'),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
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
        backgroundColor: c.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Gestión de Roles',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: c.primaryDeepWithAlpha(0.06)),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : _error.isNotEmpty
              ? _buildError(c)
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      _buildSearch(c),
                      _buildLegend(c),
                      Expanded(child: _buildList(c)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError(dynamic c) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: c.primaryDeepWithAlpha(0.3)),
          const SizedBox(height: 16),
          Text(_error, style: TextStyle(color: c.textSecondary, fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primaryDeep,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSearch(dynamic c) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: TextField(
      controller: _searchCtrl,
      style: TextStyle(color: c.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o correo…',
        hintStyle: TextStyle(color: c.textHint, fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded, color: c.textHint),
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.primaryDeepWithAlpha(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.primaryDeep, width: 1.5),
        ),
      ),
    ),
  );

  Widget _buildLegend(dynamic c) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Row(
      children: [
        Text(
          '${_filtrados.length} usuarios',
          style: TextStyle(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        ..._kRoles.map((r) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: _RolChip(rol: r),
        )),
      ],
    ),
  );

  Widget _buildList(dynamic c) => _filtrados.isEmpty
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 56, color: c.primaryDeepWithAlpha(0.2)),
              const SizedBox(height: 12),
              Text('Sin resultados', style: TextStyle(color: c.textSecondary, fontSize: 15)),
            ],
          ),
        )
      : ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          itemCount: _filtrados.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _UserCard(
            user: _filtrados[i],
            isMe: _filtrados[i].id == _myId,
            onTap: () => _showRolSheet(_filtrados[i]),
          ),
        );
}

// ─── CARD DE USUARIO ─────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final _UserRow user;
  final bool isMe;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.isMe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final activeRoles = user.roles.where((r) => _kRoles.contains(r)).toList();
    final isOnlyUser = activeRoles.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activeRoles.isNotEmpty
                ? (_kRolColors[activeRoles.first] ?? c.primaryDeep).withValues(alpha: 0.25)
                : c.primaryDeepWithAlpha(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: c.primaryDeepWithAlpha(0.12),
                    backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                        ? NetworkImage(user.avatarUrl!) as ImageProvider
                        : null,
                    child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                        ? Text(
                            user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: c.primaryDeep,
                            ),
                          )
                        : null,
                  ),
                  if (isMe)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759),
                          shape: BoxShape.circle,
                          border: Border.all(color: c.card, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.nombre,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34C759).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Yo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF34C759))),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.correo,
                      style: TextStyle(color: c.textSecondary, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isOnlyUser) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: activeRoles.map((r) => _RolChip(rol: r)).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: c.textHint, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── CHIP DE ROL ─────────────────────────────────────────────────────────────

class _RolChip extends StatelessWidget {
  final String rol;
  const _RolChip({required this.rol});

  @override
  Widget build(BuildContext context) {
    final color = _kRolColors[rol] ?? Colors.grey;
    final label = _kRolLabels[rol] ?? rol;
    final icon = _kRolIcons[rol] ?? Icons.circle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

// ─── BOTTOM SHEET DE EDICIÓN DE ROL ──────────────────────────────────────────

class _RolSheet extends StatefulWidget {
  final _UserRow user;
  final String? myId;
  final Future<void> Function(String newRol) onSaved;

  const _RolSheet({required this.user, required this.myId, required this.onSaved});

  @override
  State<_RolSheet> createState() => _RolSheetState();
}

class _RolSheetState extends State<_RolSheet> {
  late Set<String> _selected;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.user.roles
        .where((r) => _kRoles.contains(r))
        .toSet();
  }

  bool get _isMe => widget.user.id == widget.myId;

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    String newRol;
    if (_selected.isEmpty) {
      newRol = 'usuario';
    } else {
      newRol = _selected.join(',');
    }

    await widget.onSaved(newRol);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.primaryDeepWithAlpha(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: c.primaryDeepWithAlpha(0.12),
                  backgroundImage: widget.user.avatarUrl != null && widget.user.avatarUrl!.isNotEmpty
                      ? NetworkImage(widget.user.avatarUrl!) as ImageProvider
                      : null,
                  child: widget.user.avatarUrl == null || widget.user.avatarUrl!.isEmpty
                      ? Text(
                          widget.user.nombre.isNotEmpty ? widget.user.nombre[0].toUpperCase() : '?',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.primaryDeep),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.nombre,
                        style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Text(
                        widget.user.correo,
                        style: TextStyle(color: c.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Divider(height: 1, color: c.primaryDeepWithAlpha(0.08)),
          const SizedBox(height: 16),

          // Roles checkboxes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Roles especiales',
                  style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  'Un usuario sin roles especiales es un "usuario" normal.',
                  style: TextStyle(color: c.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ..._kRoles.map((rol) {
                  final color = _kRolColors[rol] ?? c.primaryDeep;
                  final label = _kRolLabels[rol] ?? rol;
                  final icon = _kRolIcons[rol] ?? Icons.circle;
                  final isChecked = _selected.contains(rol);
                  final isSuperAdminRol = rol == 'superadmin';

                  return GestureDetector(
                    onTap: () {
                      if (_isMe && isSuperAdminRol) return; // No puede quitarse superadmin a sí mismo
                      setState(() {
                        if (_selected.contains(rol)) {
                          _selected.remove(rol);
                        } else {
                          _selected.add(rol);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isChecked
                            ? color.withValues(alpha: 0.08)
                            : c.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isChecked ? color.withValues(alpha: 0.4) : c.primaryDeepWithAlpha(0.08),
                          width: isChecked ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _rolDescription(rol),
                                  style: TextStyle(color: c.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isChecked ? color : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isChecked ? color : c.primaryDeepWithAlpha(0.3),
                                width: 2,
                              ),
                            ),
                            child: isChecked
                                ? const Icon(Icons.check, color: Colors.white, size: 14)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primaryDeep,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _rolDescription(String rol) {
    switch (rol) {
      case 'superadmin':  return 'Acceso total + gestión de roles';
      case 'admin_eventos':  return 'Puede crear y gestionar eventos';
      case 'admin_noticias': return 'Puede crear y gestionar noticias';
      default: return rol;
    }
  }
}
