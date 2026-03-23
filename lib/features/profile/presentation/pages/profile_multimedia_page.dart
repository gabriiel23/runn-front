import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/profile/services/profile_service.dart';

class ProfileMultimediaPage extends StatefulWidget {
  const ProfileMultimediaPage({super.key});

  @override
  State<ProfileMultimediaPage> createState() => _ProfileMultimediaPageState();
}

class _ProfileMultimediaPageState extends State<ProfileMultimediaPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditMode = false;

  /// Fotos confirmadas (cargadas del backend).
  List<Map<String, String>> _committed = [];

  /// Fotos pendientes de subir (en staging; tienen id: '').
  final List<Map<String, String>> _toAdd = [];

  /// IDs a eliminar del backend al guardar.
  final List<String> _toDelete = [];

  /// Vista combinada: committed (no borrados) + nuevos de staging
  List<Map<String, String>> get _preview {
    final deletedIds = _toDelete.toSet();
    return [
      ..._committed.where((m) => !deletedIds.contains(m['id'])),
      ..._toAdd,
    ];
  }

  bool get _hasPendingChanges => _toAdd.isNotEmpty || _toDelete.isNotEmpty;

  /// Mapa temporal: stagingKey → (bytes, filename)
  final Map<String, MapEntry<List<int>, String>> _stagingBytes = {};

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    setState(() => _isLoading = true);
    final items = await ProfileService.getMedia();
    if (mounted) {
      setState(() {
        _committed = items;
        _toAdd.clear();
        _toDelete.clear();
        _isLoading = false;
      });
    }
  }

  /// Seleccionar foto — solo la añade al staging, NO la sube aún.
  Future<void> _stageNewPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile == null) return;

    // Convertir a bytes y crear un URL temporal
    final bytes = await pickedFile.readAsBytes();
    final stagingKey = DateTime.now().millisecondsSinceEpoch.toString();
    _stagingBytes[stagingKey] = MapEntry(bytes, pickedFile.name);

    setState(() {
      _toAdd.add({'id': '', 'url': '__pending__$stagingKey'});
    });
  }

  /// Marcar foto para eliminar (o deshacer si estaba en staging)
  void _markForDelete(Map<String, String> item) {
    if (item['url']!.startsWith('__pending__')) {
      // Es una foto nueva en staging — simplemente la quitamos
      final key = item['url']!.replaceFirst('__pending__', '');
      setState(() {
        _toAdd.remove(item);
        _stagingBytes.remove(key);
      });
    } else {
      // Es una foto confirmada — la marcamos para borrar al guardar
      setState(() => _toDelete.add(item['id']!));
    }
  }

  /// Guardar: subir las nuevas fotos y eliminar las marcadas.
  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      // 1. Subir fotos nuevas
      for (final item in List.of(_toAdd)) {
        final key = item['url']!.replaceFirst('__pending__', '');
        final entry = _stagingBytes[key];
        if (entry == null) continue;
        await ProfileService.uploadMedia(entry.key, entry.value);
        _stagingBytes.remove(key);
      }
      // 2. Eliminar fotos marcadas
      for (final id in _toDelete) {
        if (id.isNotEmpty) {
          await ProfileService.deleteMedia(id);
          await ProfileService.removeLocalMedia(
            _committed.firstWhere((m) => m['id'] == id,
                orElse: () => {'url': ''})['url'] ?? '',
          );
        }
      }
      // 3. Recargar desde backend para sincronizar
      await _loadMedia();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Galería guardada'),
            ],
          ),
          backgroundColor: const Color(0xFF7ED957),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Descartar cambios pendientes y volver al estado guardado.
  void _discardChanges() {
    setState(() {
      _toAdd.clear();
      _toDelete.clear();
      _stagingBytes.clear();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasPendingChanges) return true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = ctx.colors;
        return AlertDialog(
          backgroundColor: c.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('¿Descartar cambios?',
              style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold)),
          content: Text(
              'Tienes fotos pendientes de guardar. Si sales ahora, se perderán.',
              style: TextStyle(color: c.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(false),
              child: Text('Cancelar',
                  style: TextStyle(color: c.textHint, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => ctx.pop(true),
              child: const Text('Salir',
                  style: TextStyle(
                      color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Future<void> _discardChangesWithAlert() async {
    if (_hasPendingChanges) {
      final ok = await _onWillPop();
      if (!ok) return;
    }
    _discardChanges();
    setState(() => _isEditMode = false);
  }

  void _openGallery(int initialIndex, List<Map<String, String>> previewItems) {
    if (previewItems.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              final imageUrl = previewItems[index]['url']!;
              final isPending = imageUrl.startsWith('__pending__');

              ImageProvider provider;
              if (isPending) {
                final key = imageUrl.replaceFirst('__pending__', '');
                provider = MemoryImage(Uint8List.fromList(_stagingBytes[key]!.key));
              } else {
                provider = NetworkImage(imageUrl);
              }

              return PhotoViewGalleryPageOptions(
                imageProvider: provider,
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
              );
            },
            itemCount: previewItems.length,
            pageController: PageController(initialPage: initialIndex),
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final preview = _preview;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_isEditMode) {
          if (_hasPendingChanges) {
            final ok = await _onWillPop();
            if (!ok) return;
          }
          _discardChanges();
          if (mounted) setState(() => _isEditMode = false);
        } else {
          if (context.mounted) context.pop(result);
        }
      },
      child: Scaffold(
        backgroundColor: c.bg,
        floatingActionButton: _isEditMode
            ? FloatingActionButton.extended(
                onPressed: _stageNewPhoto,
                backgroundColor: c.primary,
                icon: Icon(Icons.add_photo_alternate_rounded, color: c.primaryLight),
                label: Text('Añadir fotos', style: TextStyle(color: c.primaryLight, fontWeight: FontWeight.w600)),
              )
            : null,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: c.card,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
                onPressed: () async {
                  if (_isEditMode) {
                    if (_hasPendingChanges) {
                      final ok = await _onWillPop();
                      if (!ok) return;
                    }
                    _discardChanges();
                    setState(() => _isEditMode = false);
                  } else {
                    context.pop();
                  }
                },
              ),
              title: Text(
                'Mi Multimedia',
                style: TextStyle(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                if (!_isEditMode)
                  TextButton.icon(
                    onPressed: () => setState(() => _isEditMode = true),
                    icon: Icon(Icons.edit_rounded, color: c.primary, size: 18),
                    label: Text('Editar', style: TextStyle(color: c.primary, fontWeight: FontWeight.w700)),
                  )
                else ...[
                  TextButton(
                    onPressed: _discardChangesWithAlert,
                    child: Text('Cancelar', style: TextStyle(color: c.textHint, fontWeight: FontWeight.w700)),
                  ),
                  TextButton(
                    onPressed: _isSaving ? null : () async {
                      await _saveChanges();
                      if (mounted) setState(() => _isEditMode = false);
                    },
                    child: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7ED957)))
                        : const Text('Guardar', style: TextStyle(color: Color(0xFF7ED957), fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ],
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(child: _buildUserProfileHeader(c)),
            _isLoading
                ? SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: c.primary)),
                  )
                : preview.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library_outlined, color: c.textHint, size: 64),
                              const SizedBox(height: 16),
                              Text('Sin fotos', style: TextStyle(color: c.textHint, fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text('Toca "Editar" para añadir fotos', style: TextStyle(color: c.textHint, fontSize: 13)),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildPhotoTile(preview[index], c, preview),
                          ),
                          childCount: preview.length,
                        ),
                      ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)), // padding para el FAB
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileHeader(dynamic c) {
    return Container(
      width: double.infinity,
      color: c.card,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      margin: const EdgeInsets.only(bottom: 8), // Separador con fotos
      child: FutureBuilder<Map<String, dynamic>>(
        future: ProfileService.getLocalProfile(),
        builder: (context, snap) {
          final avatarUrl = snap.data?['avatar_url'] as String?;
          final nombre = snap.data?['nombre'] as String? ?? 'Mi Multimedia';
          return Column(
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF5E00), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: c.primaryLight,
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? Icon(Icons.person_rounded,
                              size: 36, color: c.primaryDeepWithAlpha(0.7))
                          : null,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle_rounded,
                        color: Color(0xFFFF5E00), size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(nombre,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhotoTile(Map<String, String> item, dynamic c, List<Map<String, String>> previewItems) {
    final isPending = item['url']!.startsWith('__pending__');
    final isMarkedForDelete = !isPending && _toDelete.contains(item['id']);
    final index = previewItems.indexOf(item);

    // Obtener los bytes si está en staging o url si es definitivo
    ImageProvider? imageProvider;
    if (isPending) {
      final key = item['url']!.replaceFirst('__pending__', '');
      if (_stagingBytes.containsKey(key)) {
        imageProvider = MemoryImage(Uint8List.fromList(_stagingBytes[key]!.key));
      }
    } else {
      imageProvider = NetworkImage(item['url']!);
    }

    return GestureDetector(
      onTap: () {
        if (!_isEditMode) {
          if (!isPending) _openGallery(index, previewItems);
        } else {
          if (isPending) {
            _showDeleteConfirmation(item);
          } else if (isMarkedForDelete) {
            setState(() => _toDelete.remove(item['id']));
          } else {
            _openGallery(index, previewItems);
          }
        }
      },
      onLongPress: _isEditMode ? () => _showDeleteConfirmation(item) : null,
      child: Stack(
        children: [
          Hero(
            tag: item['url']!,
            child: imageProvider != null
                ? Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: c.primaryDeepWithAlpha(0.1),
                      child: Icon(Icons.broken_image_rounded, color: c.textHint),
                    ),
                  )
                : Container(
                    height: 250,
                    color: c.primaryDeepWithAlpha(0.1),
                    child: Icon(Icons.broken_image_rounded, color: c.textHint),
                  ),
          ),
          
          if (isPending)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_rounded, color: Colors.white, size: 32),
                    const SizedBox(height: 6),
                    Text('Pendiente de subida',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

          if (_isEditMode && isMarkedForDelete)
            Positioned.fill(
              child: Container(
                color: const Color(0xFFFF3B30).withValues(alpha: 0.55),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_rounded, color: Colors.white, size: 36),
                    SizedBox(height: 4),
                    Text('Se eliminará',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            
          // Botón de quitar/restaurar en esquina
          if (_isEditMode)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  if (isMarkedForDelete) {
                    setState(() => _toDelete.remove(item['id']));
                  } else {
                    _showDeleteConfirmation(item);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isMarkedForDelete
                        ? Colors.white
                        : Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMarkedForDelete
                        ? Icons.undo_rounded
                        : Icons.close_rounded,
                    color: isMarkedForDelete
                        ? const Color(0xFFFF3B30)
                        : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Map<String, String> item) async {
    final isPending = item['url']!.startsWith('__pending__');
    if (isPending) {
      _markForDelete(item);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = ctx.colors;
        return AlertDialog(
          backgroundColor: c.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('¿Eliminar foto?',
              style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold)),
          content: Text(
              'Esta foto se marcará para eliminación. Recuerda presionar "Guardar" para aplicar los cambios.',
              style: TextStyle(color: c.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(false),
              child: Text('Cancelar',
                  style: TextStyle(color: c.textHint, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => ctx.pop(true),
              child: const Text('Eliminar',
                  style: TextStyle(
                      color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        if (!_toDelete.contains(item['id'])) {
          _toDelete.add(item['id']!);
        }
      });
    }
  }
}
