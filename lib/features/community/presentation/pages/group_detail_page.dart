import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/grupos_service.dart';
import '../../domain/models/grupo_model.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/services/http_client.dart';

class GroupDetailPage extends StatefulWidget {
  final String grupoId;
  final Map<String, dynamic>? groupData; // kept for backward compat

  const GroupDetailPage({super.key, required this.grupoId, this.groupData});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  GrupoDetalle? _detalle;
  bool _isLoading = true;
  bool _isActing = false;
  String? _rolGlobal;
  String? _miUserId;
  List<RankingEntry> _rankingRetos = [];
  List<RankingEntry> _rankingActividades = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        GruposService.getGrupoDetalle(widget.grupoId),
        ApiConfig.getUserRol(),
        ApiConfig.getCurrentUserId(),
        GruposService.getRankingRetos(
          widget.grupoId,
        ).catchError((_) => <RankingEntry>[]),
        GruposService.getRankingActividades(
          widget.grupoId,
        ).catchError((_) => <RankingEntry>[]),
      ]);
      if (mounted) {
        setState(() {
          _detalle = results[0] as GrupoDetalle;
          _rolGlobal = results[1] as String?;
          _miUserId = results[2] as String?;
          _rankingRetos = results[3] as List<RankingEntry>;
          _rankingActividades = results[4] as List<RankingEntry>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── ACCIONES PRINCIPALES ─────────────────────────────────────────────────

  Future<void> _solicitarUnion() async {
    setState(() => _isActing = true);
    try {
      final data = await GruposService.solicitarUnion(widget.grupoId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['mensaje'] ?? 'Solicitud enviada exitosamente'),
            backgroundColor: const Color(0xFF34C759),
          ),
        );
        await _loadAll();
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

  Future<void> _salirseGrupo() async {
    final c = context.colors;
    final conf = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Salir del grupo',
          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que quieres salirte de este grupo?',
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
              'Salirme',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (conf != true || !mounted) return;
    setState(() => _isActing = true);
    try {
      await GruposService.salirseGrupo(widget.grupoId);
      if (mounted) context.pop();
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

  Future<void> _eliminarGrupo() async {
    final c = context.colors;
    final motivoCtrl = TextEditingController();
    final mostrarMotivo = _rolGlobal == 'admin' && _detalle?.miRol != 'creador';

    final conf = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar grupo',
          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Estás seguro de que quieres eliminar este grupo? Esta acción no se puede deshacer.',
              style: TextStyle(color: c.textSecondary),
            ),
            if (mostrarMotivo) ...[
              const SizedBox(height: 12),
              TextField(
                controller: motivoCtrl,
                style: TextStyle(color: c.textPrimary),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Motivo (opcional)',
                  hintStyle: TextStyle(color: c.textHint),
                  filled: true,
                  fillColor: c.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ],
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
              'Eliminar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (conf != true || !mounted) return;

    setState(() => _isActing = true);
    try {
      await GruposService.eliminarGrupo(
        widget.grupoId,
        motivo: motivoCtrl.text.trim().isNotEmpty
            ? motivoCtrl.text.trim()
            : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grupo eliminado exitosamente'),
            backgroundColor: Color(0xFF34C759),
          ),
        );
        context.pop();
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

  // ─── MENÚ DE TRES PUNTOS ─────────────────────────────────────────────────
  // Corrección 3 & 7: reorganiza las opciones por rol. Siempre visible.

  void _mostrarMenu() {
    final d = _detalle!;
    final c = context.colors;
    final rol = d.miRol; // 'creador' | 'admin' | 'miembro' | null
    final esAdminGlobal = _rolGlobal == 'admin';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: c.primaryDeepWithAlpha(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Admin global: Solo eliminar (con motivo) ─────────
            if (esAdminGlobal && rol != 'creador')
              _menuItem(
                c,
                Icons.delete_rounded,
                'Eliminar grupo',
                const Color(0xFFFF3B30),
                () {
                  Navigator.pop(context);
                  _eliminarGrupo();
                },
              ),

            // ── Creador: Editar + Gestionar + Eliminar ────────────
            if (rol == 'creador') ...[
              _menuItem(
                c,
                Icons.edit_rounded,
                'Editar grupo',
                c.textPrimary,
                () {
                  Navigator.pop(context);
                  _mostrarFormEditar();
                },
              ),
              _menuItem(
                c,
                Icons.people_alt_rounded,
                'Gestionar miembros',
                c.textPrimary,
                () {
                  Navigator.pop(context);
                  context.pushNamed(
                    'group_members',
                    pathParameters: {'grupoId': widget.grupoId},
                    extra: {'mi_rol': d.miRol, 'mi_id': _miUserId},
                  );
                },
              ),
              _menuItem(
                c,
                Icons.delete_rounded,
                'Eliminar grupo',
                const Color(0xFFFF3B30),
                () {
                  Navigator.pop(context);
                  _eliminarGrupo();
                },
              ),
            ],

            // ── Admin del grupo: Editar + Gestionar + Salirme ────
            if (rol == 'admin') ...[
              _menuItem(
                c,
                Icons.edit_rounded,
                'Editar grupo',
                c.textPrimary,
                () {
                  Navigator.pop(context);
                  _mostrarFormEditar();
                },
              ),
              _menuItem(
                c,
                Icons.people_alt_rounded,
                'Gestionar miembros',
                c.textPrimary,
                () {
                  Navigator.pop(context);
                  context.pushNamed(
                    'group_members',
                    pathParameters: {'grupoId': widget.grupoId},
                    extra: {'mi_rol': d.miRol, 'mi_id': _miUserId},
                  );
                },
              ),
              Divider(height: 12, color: c.primaryDeepWithAlpha(0.08)),
              _menuItem(
                c,
                Icons.exit_to_app_rounded,
                'Salirme del grupo',
                const Color(0xFFFF3B30),
                () {
                  Navigator.pop(context);
                  _salirseGrupo();
                },
              ),
            ],

            // ── Miembro: Solo salirme ─────────────────────────────
            if (rol == 'miembro')
              _menuItem(
                c,
                Icons.exit_to_app_rounded,
                'Salirme del grupo',
                const Color(0xFFFF3B30),
                () {
                  Navigator.pop(context);
                  _salirseGrupo();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    dynamic c,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      onTap: onTap,
    );
  }

  // ─── EDITAR GRUPO (Corrección 4: permite cambiar foto) ────────────────────

  void _mostrarFormEditar() {
    final d = _detalle!;
    final c = context.colors;
    final nombreCtrl = TextEditingController(text: d.grupo.nombre);
    final descCtrl = TextEditingController(text: d.grupo.descripcion ?? '');
    String modalidad = d.grupo.modalidad;
    bool esPrivado = d.grupo.esPrivado;
    Uint8List? nuevaFoto;
    String? nuevoMimeType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          height: MediaQuery.of(ctx).size.height * 0.9,
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
                  'Editar Grupo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: c.textPrimary,
                  ),
                ),
              ),
              Divider(height: 1, color: c.primaryDeepWithAlpha(0.1)),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Selector de Foto ──────────────────────────────
                      Text(
                        'Foto del grupo',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final img = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                          );
                          if (img == null) return;
                          final bytes = await img.readAsBytes();
                          setModal(() {
                            nuevaFoto = bytes;
                            nuevoMimeType = img.mimeType ?? 'image/jpeg';
                          });
                        },
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: c.primaryDeepWithAlpha(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Mostrar nueva foto o la foto actual del grupo
                                if (nuevaFoto != null)
                                  Image.memory(nuevaFoto!, fit: BoxFit.cover)
                                else if (d.grupo.fotoUrl != null &&
                                    d.grupo.fotoUrl!.isNotEmpty)
                                  Image.network(
                                    d.grupo.fotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _fotoEditPlaceholder(c),
                                  )
                                else
                                  _fotoEditPlaceholder(c),
                                // Overlay de edición
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Campos de texto ───────────────────────────────
                      Text(
                        'Información',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _textField(
                        c,
                        nombreCtrl,
                        'Nombre',
                        Icons.edit_note_rounded,
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        c,
                        descCtrl,
                        'Descripción',
                        Icons.description_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // ── Modalidad ─────────────────────────────────────
                      Text(
                        'Modalidad',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _modalOpt(
                              c,
                              'social',
                              '👟 Social',
                              modalidad,
                              (v) => setModal(() => modalidad = v),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _modalOpt(
                              c,
                              'territorial',
                              '🗺 Territorial',
                              modalidad,
                              (v) => setModal(() => modalidad = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Privacidad ────────────────────────────────────
                      Text(
                        'Privacidad',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: c.primaryDeepWithAlpha(0.07),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              esPrivado
                                  ? Icons.lock_rounded
                                  : Icons.lock_open_rounded,
                              color: c.primaryDeep,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                esPrivado ? 'Privado' : 'Público',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: c.textPrimary,
                                ),
                              ),
                            ),
                            Switch(
                              value: esPrivado,
                              activeThumbColor: c.primaryDeep,
                              onChanged: (v) => setModal(() => esPrivado = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Botón Guardar ─────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            setState(() => _isActing = true);
                            try {
                              await GruposService.editarGrupo(
                                id: widget.grupoId,
                                nombre: nombreCtrl.text.trim(),
                                descripcion: descCtrl.text.trim(),
                                modalidad: modalidad,
                                esPrivado: esPrivado,
                                foto: nuevaFoto,
                                fotoMimeType: nuevoMimeType,
                              );
                              if (mounted) await _loadAll();
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
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.primaryDeep,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Guardar Cambios',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
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

  Widget _fotoEditPlaceholder(dynamic c) => Container(
    color: c.primaryDeepWithAlpha(0.08),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_rounded,
          size: 40,
          color: c.primaryDeepWithAlpha(0.3),
        ),
        const SizedBox(height: 8),
        Text(
          'Toca para cambiar foto',
          style: TextStyle(color: c.textHint, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _textField(
    dynamic c,
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.primaryDeepWithAlpha(0.07)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(color: c.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: c.textHint),
          prefixIcon: Icon(icon, color: c.primaryDeep, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _modalOpt(
    dynamic c,
    String value,
    String label,
    String current,
    Function(String) onTap,
  ) {
    final sel = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sel ? c.primaryDeepWithAlpha(0.1) : c.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? c.primaryDeep : c.primaryDeepWithAlpha(0.08),
            width: sel ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: sel ? c.primaryDeep : c.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.bg,
        body: Center(
          child: CircularProgressIndicator(color: context.colors.primaryDeep),
        ),
      );
    }
    if (_detalle == null) {
      return Scaffold(
        backgroundColor: context.colors.bg,
        body: Center(
          child: Text(
            'Error al cargar el grupo',
            style: TextStyle(color: context.colors.textPrimary),
          ),
        ),
      );
    }

    final c = context.colors;
    final d = _detalle!;

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(c, d),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGroupInfo(c, d),
                      if (d.disputaActiva != null) ...[
                        const SizedBox(height: 24),
                        _buildDisputaBanner(c, d.disputaActiva!),
                      ],
                      const SizedBox(height: 24),
                      _buildChips(c, d),
                      const SizedBox(height: 24),
                      _buildRetosPreview(c, d),
                      const SizedBox(height: 24),
                      _buildActividadesPreview(c, d),
                      const SizedBox(height: 24),
                      _buildGalleryPreview(c, d),
                      const SizedBox(height: 28),
                      _buildMembersPreview(c, d),
                      // Espacio para el botón bottom (si aplica)
                      if (!d.soyMiembro) const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Botón bottom: SOLO para no-miembros (Unirse). Corrección 3 & 6.
          if (!d.soyMiembro)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                decoration: BoxDecoration(
                  color: c.bg.withValues(alpha: 0.95),
                  border: Border(
                    top: BorderSide(color: c.primaryDeepWithAlpha(0.08)),
                  ),
                ),
                child: _buildBottomButton(c, d),
              ),
            ),
          if (_isActing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(dynamic c, GrupoDetalle d) {
    // El botón ⋮ es siempre visible para miembros, omitido para no-miembros sin rol
    final mostrarMenu = d.soyMiembro || _rolGlobal == 'admin';

    return SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      backgroundColor: c.card,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (mostrarMenu)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: _mostrarMenu,
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Text(
          d.grupo.nombre,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            d.grupo.fotoUrl != null && d.grupo.fotoUrl!.isNotEmpty
                ? Image.network(
                    d.grupo.fotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fotoPlaceholder(c),
                  )
                : _fotoPlaceholder(c),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fotoPlaceholder(dynamic c) => Container(
    color: c.primaryDeep,
    child: Icon(
      Icons.groups_rounded,
      size: 80,
      color: Colors.white.withValues(alpha: 0.3),
    ),
  );

  Widget _buildGroupInfo(dynamic c, GrupoDetalle d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (d.grupo.descripcion != null && d.grupo.descripcion!.isNotEmpty)
          Text(
            d.grupo.descripcion!,
            style: TextStyle(color: c.textSecondary, fontSize: 14, height: 1.5),
          ),
        const SizedBox(height: 12),
        if (d.grupo.creadoPorNombre != null)
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 14, color: c.textHint),
              const SizedBox(width: 4),
              Text(
                'Creado por ${d.grupo.creadoPorNombre}',
                style: TextStyle(fontSize: 12, color: c.textHint),
              ),
            ],
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.people_alt_rounded, size: 14, color: c.textHint),
            const SizedBox(width: 4),
            Text(
              '${d.totalMiembros} miembros',
              style: TextStyle(fontSize: 12, color: c.textHint),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisputaBanner(dynamic c, GrupoDisputaActiva disputa) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE91E63).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE91E63), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¡Disputa Activa!',
                  style: const TextStyle(
                    color: Color(0xFFE91E63),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'El grupo está conquistando "${disputa.territorioNombre}". ¡Registra tu tiempo individual en las próximas ${disputa.horasRestantes} horas para sumar al promedio!',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChips(dynamic c, GrupoDetalle d) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _chip(
          c,
          d.grupo.modalidad == 'territorial' ? '🗺 Territorial' : '👟 Social',
          d.grupo.modalidad == 'territorial'
              ? const Color(0xFF7ED957)
              : c.primaryDeep,
        ),
        _chip(c, d.grupo.esPrivado ? '🔒 Privado' : '🌐 Público', c.textHint),
        if (d.miRol != null) _chip(c, 'Mi rol: ${d.miRol}', c.primaryDeep),
      ],
    );
  }

  Widget _chip(dynamic c, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
    ),
  );

  Widget _buildSectionHeader(
    dynamic c,
    String title, {
    VoidCallback? onVerTodo,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        if (onVerTodo != null)
          TextButton(
            onPressed: onVerTodo,
            child: Text(
              'Ver todo',
              style: TextStyle(
                color: c.primaryDeep,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMembersPreview(dynamic c, GrupoDetalle d) {
    final preview = d.miembros.take(6).toList();
    final extras = d.totalMiembros - preview.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '\ud83d\udc65 Nuestro Equipo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: c.textPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => context.pushNamed(
                'group_members',
                pathParameters: {'grupoId': widget.grupoId},
                extra: {'mi_rol': d.miRol, 'mi_id': _miUserId},
              ),
              icon: Icon(Icons.group_rounded, size: 14, color: c.primaryDeep),
              label: Text(
                'Ver todos (${d.totalMiembros})',
                style: TextStyle(
                  color: c.primaryDeep,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            children: [
              ...preview.map((m) => _memberCard(c, m)),
              if (extras > 0) _moreCard(c, extras, d.miRol),
            ],
          ),
        ),
      ],
    );
  }

  Widget _memberCard(dynamic c, MiembroGrupo m) {
    final roleColor = m.rol == 'creador'
        ? const Color(0xFFFFD700)
        : m.rol == 'admin'
        ? const Color(0xFF9C27B0)
        : c.primaryDeep as Color;
    final roleLabel = m.rol == 'creador'
        ? '\u2605 Creador'
        : m.rol == 'admin'
        ? '\u25ca Admin'
        : 'Miembro';

    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: c.card as Color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (c.primaryDeep as Color).withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: roleColor.withValues(alpha: 0.15),
            backgroundImage: m.avatarUrl != null && m.avatarUrl!.isNotEmpty
                ? NetworkImage(m.avatarUrl!)
                : null,
            child: m.avatarUrl == null || m.avatarUrl!.isEmpty
                ? Text(
                    m.nombre.isNotEmpty ? m.nombre[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            m.nombre.split(' ').first,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.textPrimary as Color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              roleLabel,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: roleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _moreCard(dynamic c, int extras, String? miRol) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        'group_members',
        pathParameters: {'grupoId': widget.grupoId},
        extra: {'mi_rol': miRol, 'mi_id': _miUserId},
      ),
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (c.primaryDeep as Color).withValues(alpha: 0.15),
              (c.primaryDeep as Color).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: (c.primaryDeep as Color).withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_add_rounded,
              color: c.primaryDeep as Color,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              '+$extras más',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: c.primaryDeep as Color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── CAMPEONES DEL DESAFÍO (Retos) ───────────────────────────────────────

  Widget _buildRetosPreview(dynamic c, GrupoDetalle d) {
    final top3 = _rankingRetos.take(3).toList();
    final primerReto = d.retos.isNotEmpty ? d.retos.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera con botones
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🏆 Campeones del',
                    style: TextStyle(
                      fontSize: 12,
                      color: c.textHint,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Desafío',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: c.textPrimary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _miniLink(
                  c,
                  'Ver ranking',
                  () => context.pushNamed(
                    'group_ranking',
                    pathParameters: {
                      'grupoId': widget.grupoId,
                      'tipo': 'retos',
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Podio top-3
        if (top3.isEmpty)
          _emptyHint(c, 'Sin datos de ranking aún')
        else
          _buildPodio(
            c,
            top3,
            const Color(0xFFFFD700),
            const Color(0xFFC0C0C0),
            const Color(0xFFCD7F32),
          ),

        const SizedBox(height: 16),

        // Card del reto actual
        if (primerReto != null)
          _buildRetoCard(c, primerReto, d)
        else
          _emptyActionHint(
            c,
            'Sin retos creados aún',
            'Ver / Crear retos',
            () => context.pushNamed(
              'group_challenges',
              pathParameters: {'grupoId': widget.grupoId},
              extra: {'mi_rol': d.miRol},
            ),
          ),
      ],
    );
  }

  Widget _buildPodio(
    dynamic c,
    List<dynamic> top,
    Color gold,
    Color silver,
    Color bronze,
  ) {
    final colors = [gold, silver, bronze];
    final emojis = ['🥇', '🥈', '🥉'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(top.length, (i) {
        final entry = top[i];
        final isFirst = i == 0;
        final barH = isFirst ? 80.0 : (i == 1 ? 60.0 : 46.0);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? 0 : 4,
              right: i == top.length - 1 ? 0 : 4,
            ),
            child: Column(
              children: [
                // Avatar
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topRight,
                  children: [
                    CircleAvatar(
                      radius: isFirst ? 26 : 20,
                      backgroundColor: colors[i].withValues(alpha: 0.2),
                      backgroundImage:
                          entry.avatarUrl != null && entry.avatarUrl!.isNotEmpty
                          ? NetworkImage(entry.avatarUrl!)
                          : null,
                      child: entry.avatarUrl == null || entry.avatarUrl!.isEmpty
                          ? Text(
                              entry.nombre.isNotEmpty
                                  ? entry.nombre[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: isFirst ? 18 : 14,
                                fontWeight: FontWeight.bold,
                                color: colors[i],
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Text(
                        emojis[i],
                        style: TextStyle(fontSize: isFirst ? 16 : 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  entry.nombre.split(' ').first,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Barra
                Container(
                  height: barH,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [colors[i], colors[i].withValues(alpha: 0.4)],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.cantidad}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRetoCard(dynamic c, GrupoReto r, GrupoDetalle d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.primaryDeep.withValues(alpha: 0.12),
            c.primaryDeep.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.primaryDeep.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c.primaryDeep.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.flag_rounded, color: c.primaryDeep, size: 18),
              ),
              const SizedBox(width: 10),

              // Título ocupa lo disponible pero deja espacio al botón
              Expanded(
                child: Text(
                  r.titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: c.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              // Botón a la derecha
              _miniLink(
                c,
                'Ver retos',
                () => context.pushNamed(
                  'group_challenges',
                  pathParameters: {'grupoId': widget.grupoId},
                  extra: {'mi_rol': d.miRol},
                ),
              ),
            ],
          ),
          if (r.descripcion != null && r.descripcion!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              r.descripcion!,
              style: TextStyle(
                fontSize: 12,
                color: c.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (r.distanciaKm != null)
                _tag(c, '📏 ${r.distanciaKm} km', c.primaryDeep),
              if (r.fechaFin != null)
                _tag(c, '📅 Hasta ${r.fechaFinFmt}', c.textSecondary),
              _tag(c, '👥 ${r.participantes} participantes', c.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  // ─── LÍDERES EN ACCIÓN (Actividades) ─────────────────────────────────────

  Widget _buildActividadesPreview(dynamic c, GrupoDetalle d) {
    final top3 = _rankingActividades.take(3).toList();
    final primeraActividad = d.actividades.isNotEmpty
        ? d.actividades.first
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera con botones
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚡ Líderes en',
                    style: TextStyle(
                      fontSize: 12,
                      color: c.textHint,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Acción',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: c.textPrimary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _miniLink(
                  c,
                  'Ver ranking',
                  () => context.pushNamed(
                    'group_ranking',
                    pathParameters: {
                      'grupoId': widget.grupoId,
                      'tipo': 'actividades',
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Podio top-3
        if (top3.isEmpty)
          _emptyHint(c, 'Sin datos de ranking aún')
        else
          _buildPodio(
            c,
            top3,
            const Color(0xFFFFD700),
            const Color(0xFFC0C0C0),
            const Color(0xFFCD7F32),
          ),

        const SizedBox(height: 16),

        // Card de la actividad actual
        if (primeraActividad != null)
          _buildActividadCard(c, primeraActividad, d)
        else
          _emptyActionHint(
            c,
            'Sin actividades creadas aún',
            'Ver / Crear actividades',
            () => context.pushNamed(
              'group_activities',
              pathParameters: {'grupoId': widget.grupoId},
              extra: {'mi_rol': d.miRol},
            ),
          ),
      ],
    );
  }

  Widget _buildActividadCard(dynamic c, GrupoActividad a, GrupoDetalle d) {
    final tipoIcon = a.tipo == 'correr'
        ? Icons.directions_run_rounded
        : Icons.terrain_rounded;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00BCD4).withValues(alpha: 0.12),
            const Color(0xFF00BCD4).withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF00BCD4).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tipoIcon, color: const Color(0xFF00BCD4), size: 18),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  a.titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: c.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              _miniLink(
                c,
                'Ver actividades',
                () => context.pushNamed(
                  'group_activities',
                  pathParameters: {'grupoId': widget.grupoId},
                  extra: {'mi_rol': d.miRol},
                ),
              ),
            ],
          ),
          if (a.descripcion != null && a.descripcion!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              a.descripcion!,
              style: TextStyle(
                fontSize: 12,
                color: c.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (a.lugar != null && a.lugar!.isNotEmpty)
                _tag(c, '📍 ${a.lugar}', const Color(0xFF00BCD4)),
              if (a.fecha != null) _tag(c, '📅 ${a.fechaFmt}', c.textSecondary),
              if (a.hora != null && a.horaFmt.isNotEmpty)
                _tag(c, '⏰ ${a.horaFmt}', c.textSecondary),
              _tag(c, '👥 ${a.participantes} participantes', c.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(dynamic c, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _miniLink(dynamic c, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: c.primaryDeep,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            decorationColor: c.primaryDeep.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryPreview(dynamic c, GrupoDetalle d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          c,
          '🖼 Galería',
          onVerTodo: () => context.pushNamed(
            'group_gallery',
            pathParameters: {'grupoId': widget.grupoId},
            extra: {'es_miembro': d.soyMiembro},
          ),
        ),
        const SizedBox(height: 10),
        if (d.multimedia.isEmpty)
          _emptyHint(c, 'Sin fotos aún')
        else
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: d.multimedia.take(5).length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final foto = d.multimedia[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    foto.fotoUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      color: c.primaryDeepWithAlpha(0.08),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _emptyHint(dynamic c, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: TextStyle(
        color: c.textHint,
        fontSize: 13,
        fontStyle: FontStyle.italic,
      ),
    ),
  );

  Widget _emptyActionHint(dynamic c, String text, String label, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: c.primaryDeep.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.primaryDeep.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, color: c.textHint, size: 32),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: c.textHint, fontSize: 13)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primaryDeep.withValues(alpha: 0.1),
              foregroundColor: c.primaryDeep,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(dynamic c, GrupoDetalle d) {
    if (d.solicitudPendiente) {
      return Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: c.primaryDeepWithAlpha(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.primaryDeepWithAlpha(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time_rounded, color: c.textHint, size: 20),
            const SizedBox(width: 8),
            Text(
              'Solicitud de unión enviada',
              style: TextStyle(
                color: c.textHint,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isActing ? null : _solicitarUnion,
        icon: const Icon(Icons.group_add_rounded, color: Colors.white),
        label: const Text(
          'Solicitar unirse',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primaryDeep,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
