import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/grupos_service.dart';
import '../../domain/models/grupo_model.dart';
import '../../../../core/services/http_client.dart';

class GroupGalleryPage extends StatefulWidget {
  final String grupoId;
  final bool esMiembro;

  const GroupGalleryPage({super.key, required this.grupoId, required this.esMiembro});

  @override
  State<GroupGalleryPage> createState() => _GroupGalleryPageState();
}

class _GroupGalleryPageState extends State<GroupGalleryPage> {
  List<GrupoMultimedia> _multimedia = [];
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    setState(() => _isLoading = true);
    try {
      final detalle = await GruposService.getGrupoDetalle(widget.grupoId);
      if (mounted) setState(() { _multimedia = detalle.multimedia; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _subirFoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img == null) return;
    final bytes = await img.readAsBytes();
    setState(() => _isUploading = true);
    try {
      await GruposService.subirFotoGrupo(
        grupoId: widget.grupoId,
        foto: bytes,
        mimeType: img.mimeType ?? 'image/jpeg',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto subida exitosamente ✅'), backgroundColor: Color(0xFF34C759)),
        );
        await _loadGallery();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFFF3B30)),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _abrirVisor(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _GalleryViewer(
          fotos: _multimedia,
          initialIndex: initialIndex,
        ),
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
        title: Text('Galería del grupo',
            style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.5)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: c.primaryDeepWithAlpha(0.08), height: 1)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : _multimedia.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.photo_library_rounded, size: 64, color: c.primaryDeepWithAlpha(0.2)),
                  const SizedBox(height: 16),
                  Text('Sin fotos aún', style: TextStyle(color: c.textHint, fontSize: 16, fontWeight: FontWeight.w600)),
                  if (widget.esMiembro) ...[
                    const SizedBox(height: 8),
                    Text('¡Sé el primero en subir una!', style: TextStyle(color: c.textHint, fontSize: 13)),
                  ],
                ]))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6,
                  ),
                  itemCount: _multimedia.length,
                  itemBuilder: (context, index) {
                    final foto = _multimedia[index];
                    return GestureDetector(
                      onTap: () => _abrirVisor(index),
                      child: Hero(
                        tag: 'gallery_${foto.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            foto.fotoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: c.primaryDeepWithAlpha(0.08),
                              child: Icon(Icons.broken_image_rounded, color: c.textHint),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: widget.esMiembro
          ? FloatingActionButton(
              onPressed: _isUploading ? null : _subirFoto,
              backgroundColor: c.primaryDeep,
              child: _isUploading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
            )
          : null,
    );
  }
}

// ─── VISOR DE GALERÍA COMPLETO ────────────────────────────────────────────────

class _GalleryViewer extends StatefulWidget {
  final List<GrupoMultimedia> fotos;
  final int initialIndex;

  const _GalleryViewer({required this.fotos, required this.initialIndex});

  @override
  State<_GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<_GalleryViewer> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Galería con swipe y zoom ──────────────────────────
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.fotos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (ctx, index) {
              final foto = widget.fotos[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(foto.fotoUrl),
                heroAttributes: PhotoViewHeroAttributes(tag: 'gallery_${foto.id}'),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 64),
                ),
              );
            },
            loadingBuilder: (_, __) =>
                const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),

          // ── Header overlay ────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      if (widget.fotos.length > 1)
                        Text(
                          '${_currentIndex + 1} / ${widget.fotos.length}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Chips de navegación (indicadores) ────────────────
          if (widget.fotos.length > 1)
            Positioned(
              bottom: 32, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.fotos.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _currentIndex ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentIndex ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }
}
