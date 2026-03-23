import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/home/services/novedades_service.dart';

class NewsEditPage extends StatefulWidget {
  final String novedadId;

  const NewsEditPage({super.key, required this.novedadId});

  @override
  State<NewsEditPage> createState() => _NewsEditPageState();
}

class _NewsEditPageState extends State<NewsEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInitLoading = true;

  String _titulo = '';
  String? _descripcion;
  String _tipo = 'noticia';
  String? _urlExterna;
  bool _activa = true;
  bool _destacada = false;

  Uint8List? _imageBytes;
  String? _existingImageUrl;

  final List<String> _tiposDisponibles = [
    'noticia',
    'evento_especial',
    'actualizacion',
    'tip_del_dia'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.novedadId == 'new') {
      setState(() => _isInitLoading = false);
      return;
    }
    
    try {
      final novedad = await NovedadesService.getNovedadDetalle(widget.novedadId);
      if (mounted) {
        setState(() {
          _titulo = novedad.titulo;
          _descripcion = novedad.descripcion;
          _tipo = novedad.tipo.isEmpty ? 'noticia' : novedad.tipo;
          if (!_tiposDisponibles.contains(_tipo)) {
            _tiposDisponibles.add(_tipo);
          }
          _urlExterna = novedad.urlExterna;
          _activa = novedad.activa;
          _destacada = novedad.destacada;
          _existingImageUrl = novedad.fotoUrl;
          _isInitLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    
    try {
      final data = {
        'titulo': _titulo,
        'descripcion': _descripcion ?? '',
        'tipo': _tipo,
        'url_externa': _urlExterna ?? '',
        'activa': _activa.toString(),
        'destacada': _destacada.toString(),
      };

      final bytes = _imageBytes;

      if (widget.novedadId == 'new') {
        await NovedadesService.crearNovedad(data, fotoBytes: bytes);
      } else {
        await NovedadesService.editarNovedad(widget.novedadId, data, fotoBytes: bytes);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guardado exitosamente')),
        );
        context.pop(true); // Return true to signal refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildImagePicker(dynamic c) {
    bool hasImage = _imageBytes != null || (_existingImageUrl != null && _existingImageUrl!.isNotEmpty);
    ImageProvider? imgProvider;

    if (_imageBytes != null) {
      imgProvider = MemoryImage(_imageBytes!);
    } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      imgProvider = NetworkImage(_existingImageUrl!);
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.primaryDeepWithAlpha(0.2)),
          image: hasImage && imgProvider != null
              ? DecorationImage(image: imgProvider, fit: BoxFit.cover)
              : null,
        ),
        child: hasImage
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black45,
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 40),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 48, color: c.textSecondary),
                  const SizedBox(height: 8),
                  Text('Toca para añadir una imagen', style: TextStyle(color: c.textSecondary)),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isNew = widget.novedadId == 'new';

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(isNew ? 'Nueva Novedad' : 'Editar Novedad'),
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        elevation: 0,
      ),
      body: _isInitLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePicker(c),
                    const SizedBox(height: 24),
                    TextFormField(
                      initialValue: _titulo,
                      style: TextStyle(color: c.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Título',
                        labelStyle: TextStyle(color: c.textSecondary),
                        filled: true,
                        fillColor: c.card,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                      onSaved: (val) => _titulo = val ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _descripcion,
                      maxLines: 4,
                      style: TextStyle(color: c.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Descripción (Opcional)',
                        labelStyle: TextStyle(color: c.textSecondary),
                        filled: true,
                        fillColor: c.card,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onSaved: (val) => _descripcion = val,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _tipo,
                      dropdownColor: c.card,
                      style: TextStyle(color: c.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        labelStyle: TextStyle(color: c.textSecondary),
                        filled: true,
                        fillColor: c.card,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: _tiposDisponibles.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t.replaceAll('_', ' ').toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _tipo = val);
                      },
                      onSaved: (val) => _tipo = val ?? 'noticia',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _urlExterna,
                      style: TextStyle(color: c.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'URL externa o web (Opcional)',
                        labelStyle: TextStyle(color: c.textSecondary),
                        filled: true,
                        fillColor: c.card,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onSaved: (val) => _urlExterna = val,
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: Text('Novedad Activa (Visible)', style: TextStyle(color: c.textPrimary)),
                      activeThumbColor: c.primaryDeep,
                      value: _activa,
                      onChanged: (val) => setState(() => _activa = val),
                    ),
                    SwitchListTile(
                      title: Text('Destacada', style: TextStyle(color: c.textPrimary)),
                      activeThumbColor: const Color(0xFFFFB84D),
                      value: _destacada,
                      onChanged: (val) => setState(() => _destacada = val),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primaryDeep,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Guardar Cambios',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
