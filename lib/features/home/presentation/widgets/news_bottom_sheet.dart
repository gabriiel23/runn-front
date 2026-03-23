import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/home/data/models/novedad_model.dart';
import 'package:runn_front/features/home/services/novedades_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';

class NewsDetailBottomSheet extends StatefulWidget {
  final NovedadModel novedad;
  final bool isAdmin;
  final VoidCallback onRefreshRequested;

  const NewsDetailBottomSheet({
    super.key,
    required this.novedad,
    required this.isAdmin,
    required this.onRefreshRequested,
  });

  @override
  State<NewsDetailBottomSheet> createState() => _NewsDetailBottomSheetState();
}

class _NewsDetailBottomSheetState extends State<NewsDetailBottomSheet> {
  late NovedadModel _novedad;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _novedad = widget.novedad;
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final nov = await NovedadesService.getNovedadDetalle(_novedad.id);
      if (mounted) {
        setState(() {
          _novedad = nov;
          _isLoading = false;
        });
        widget.onRefreshRequested();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchUrl() async {
    if (_novedad.urlExterna == null || _novedad.urlExterna!.isEmpty) return;
    final uri = Uri.parse(_novedad.urlExterna!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace.')),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  void _openFullScreenImage() {
    if (_novedad.fotoUrl == null || _novedad.fotoUrl!.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          extendBodyBehindAppBar: true,
          body: Center(
            child: PhotoView(
              imageProvider: NetworkImage(_novedad.fotoUrl!),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
            ),
          ),
        ),
      ),
    );
  }

  void _showAdminOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final c = context.colors;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: c.primaryDeepWithAlpha(0.2), borderRadius: BorderRadius.circular(10)),
                ),
                ListTile(
                  leading: Icon(Icons.edit_rounded, color: c.textPrimary),
                  title: Text('Editar Novedad', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final refresh = await context.push('/news/${_novedad.id}/edit');
                    if (refresh == true) {
                      _refreshData();
                    }
                  },
                ),
                ListTile(
                  leading: Icon(_novedad.destacada ? Icons.star_border_rounded : Icons.star_rounded, color: c.textPrimary),
                  title: Text(_novedad.destacada ? 'Quitar Destacado' : 'Hacer Destacada', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      await NovedadesService.cambiarDestacado(_novedad.id, !_novedad.destacada);
                      _refreshData();
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                ),
                ListTile(
                  leading: Icon(_novedad.activa ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: c.textPrimary),
                  title: Text(_novedad.activa ? 'Ocultar / Desactivar' : 'Activar / Publicar', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      await NovedadesService.cambiarEstado(_novedad.id, !_novedad.activa);
                      _refreshData();
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    _confirmDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) {
        final c = context.colors;
        return AlertDialog(
          backgroundColor: c.surface,
          title: Text("¿Eliminar novedad?", style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold)),
          content: Text("Esta acción no se puede deshacer.", style: TextStyle(color: c.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await NovedadesService.eliminarNovedad(_novedad.id);
                  widget.onRefreshRequested();
                  if (mounted) Navigator.pop(context); // close bottom sheet
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text("Eliminar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasImage = _novedad.fotoUrl != null && _novedad.fotoUrl!.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: c.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Top Drag Handle & Close Button
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                decoration: BoxDecoration(
                  color: c.bg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.isAdmin)
                      TextButton.icon(
                        icon: Icon(Icons.settings_rounded, size: 20, color: c.textPrimary),
                        label: Text('Opciones', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold)),
                        onPressed: _showAdminOptions,
                      )
                    else
                      const SizedBox(width: 48), // Spacer for centering
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: c.primaryDeepWithAlpha(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: c.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator())),

              if (!_isLoading)
                Expanded(
                  child: ListView(
                    controller: controller,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 40),
                    children: [
                      if (hasImage)
                        GestureDetector(
                          onTap: _openFullScreenImage,
                          child: Container(
                            height: 250,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(_novedad.fotoUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      if (!hasImage)
                        const SizedBox(height: 10),
                      
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: c.primaryDeep,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _novedad.tipo.replaceAll('_', ' ').toUpperCase(),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                                      ),
                                    ),
                                    if (_novedad.destacada) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFB84D),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.star_rounded, color: Colors.white, size: 12),
                                            SizedBox(width: 4),
                                            Text(
                                              'DESTACADA',
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _novedad.titulo,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: c.textPrimary,
                                letterSpacing: -0.5,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_novedad.publicadoEn != null)
                              Text(
                                _formatDate(_novedad.publicadoEn),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: c.textSecondary,
                                ),
                              ),
                            const SizedBox(height: 24),
                            if (_novedad.descripcion != null && _novedad.descripcion!.isNotEmpty)
                              Text(
                                _novedad.descripcion!,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: c.textPrimary.withValues(alpha: 0.9),
                                ),
                              ),
                            const SizedBox(height: 32),
                            if (_novedad.urlExterna != null && _novedad.urlExterna!.isNotEmpty)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: c.primaryDeep,
                                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                onPressed: _launchUrl,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.open_in_new_rounded, color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      'Abrir enlace externo',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
