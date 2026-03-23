import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/home/data/models/novedad_model.dart';
import 'package:runn_front/features/home/services/novedades_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailPage extends StatefulWidget {
  final String novedadId;

  const NewsDetailPage({super.key, required this.novedadId});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  bool _isLoading = true;
  NovedadModel? _novedad;
  String _errorMsg = '';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkRoleAndLoad();
  }

  Future<void> _checkRoleAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final rol = prefs.getString('rol');
    if (mounted) {
      setState(() {
        _isAdmin = rol == 'admin';
      });
    }
    _fetchNovedad();
  }

  Future<void> _fetchNovedad() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    try {
      final nov = await NovedadesService.getNovedadDetalle(widget.novedadId);
      if (mounted) {
        setState(() {
          _novedad = nov;
          _isLoading = false;
        });
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          _errorMsg = err.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl() async {
    if (_novedad?.urlExterna == null || _novedad!.urlExterna!.isEmpty) return;
    final uri = Uri.parse(_novedad!.urlExterna!);
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

  void _showAdminOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final c = context.colors;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: Text('Editar Novedad', style: TextStyle(color: c.textPrimary)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final refresh = await context.push('/news/${widget.novedadId}/edit');
                  if (refresh == true) {
                    _fetchNovedad();
                  }
                },
              ),
              ListTile(
                leading: Icon(_novedad!.destacada ? Icons.star_border_rounded : Icons.star_rounded),
                title: Text(_novedad!.destacada ? 'Quitar Destacado' : 'Hacer Destacada', style: TextStyle(color: c.textPrimary)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    await NovedadesService.cambiarDestacado(_novedad!.id, !_novedad!.destacada);
                    _fetchNovedad();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado destacado actualizado')));
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
              ),
              ListTile(
                leading: Icon(_novedad!.activa ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                title: Text(_novedad!.activa ? 'Ocultar / Desactivar' : 'Activar / Publicar', style: TextStyle(color: c.textPrimary)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    await NovedadesService.cambiarEstado(_novedad!.id, !_novedad!.activa);
                    _fetchNovedad();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visibilidad actualizada')));
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  _confirmDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final c = context.colors;
        return AlertDialog(
          backgroundColor: c.surface,
          title: Text("¿Eliminar novedad?", style: TextStyle(color: c.textPrimary)),
          content: Text("Esta acción no se puede deshacer.", style: TextStyle(color: c.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await NovedadesService.eliminarNovedad(widget.novedadId);
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    context.pop(true); // Return home
                  }
                } catch (e) {
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_isLoading) {
      return Scaffold(backgroundColor: c.bg, body: const Center(child: CircularProgressIndicator()));
    }

    if (_errorMsg.isNotEmpty || _novedad == null) {
      return Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(backgroundColor: c.bg, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _errorMsg.isNotEmpty ? _errorMsg : 'Página no encontrada',
              style: TextStyle(color: c.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final nov = _novedad!;
    final hasImage = nov.fotoUrl != null && nov.fotoUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: hasImage ? 300.0 : 120.0,
            pinned: true,
            backgroundColor: c.surface,
            foregroundColor: hasImage ? Colors.white : c.textPrimary,
            elevation: 0,
            actions: [
              if (_isAdmin)
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: _showAdminOptions,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(nov.fotoUrl!, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black54, Colors.transparent, Colors.black87],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(color: c.primaryDeepWithAlpha(0.1)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          nov.tipo.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (nov.destacada) ...[
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
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_isAdmin && !nov.activa) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('OCULTA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nov.titulo,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: c.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (nov.publicadoEn != null)
                    Text(
                      _formatDate(nov.publicadoEn),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 32),
                  if (nov.descripcion != null && nov.descripcion!.isNotEmpty)
                    Text(
                      nov.descripcion!,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: c.textPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  const SizedBox(height: 40),
                  if (nov.urlExterna != null && nov.urlExterna!.isNotEmpty)
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
          ),
        ],
      ),
    );
  }
}
