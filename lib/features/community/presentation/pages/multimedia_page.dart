import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/usuarios_service.dart';

class MultimediaPage extends StatefulWidget {
  final String userId;
  final dynamic extra;

  const MultimediaPage({super.key, required this.userId, this.extra});

  @override
  State<MultimediaPage> createState() => _MultimediaPageState();
}

class _MultimediaPageState extends State<MultimediaPage> {
  bool _isLoading = true;
  List<Map<String, String>> _images = [];

  @override
  void initState() {
    super.initState();
    _fetchMedia();
  }

  Future<void> _fetchMedia() async {
    try {
      final items = await UsuariosService.getUsuarioMedia(widget.userId);
      if (mounted) {
        setState(() {
          _images = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openGallery(int initialIndex) {
    if (_images.isEmpty) return;

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
              final imageUrl = _images[index]['url']!;
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrl),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
              );
            },
            itemCount: _images.length,
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
          'Galería',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : _images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_rounded,
                          size: 64, color: c.primaryDeepWithAlpha(0.3)),
                      const SizedBox(height: 16),
                      Text('Sin fotos',
                          style: TextStyle(
                              color: c.textHint,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    final imageUrl = _images[index]['url']!;
                    return GestureDetector(
                      onTap: () => _openGallery(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Hero(
                          tag: imageUrl,
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 250,
                              color: c.primaryDeepWithAlpha(0.1),
                              child: Icon(Icons.broken_image_rounded,
                                  color: c.textHint),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
