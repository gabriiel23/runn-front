import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/grupos_service.dart';
import '../../../../core/services/http_client.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String _modalidad = 'social';
  bool _esPrivado = false;
  Uint8List? _foto;
  String? _fotoMimeType;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickFoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img == null) return;
    final bytes = await img.readAsBytes();
    setState(() {
      _foto = bytes;
      _fotoMimeType = img.mimeType ?? 'image/jpeg';
    });
  }

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await GruposService.crearGrupo(
        nombre: _nameController.text.trim(),
        descripcion: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        modalidad: _modalidad,
        esPrivado: _esPrivado,
        foto: _foto,
        fotoMimeType: _fotoMimeType,
      );
      if (!mounted) return;
      final nuevoGrupo = result['grupo'] as Map<String, dynamic>?;
      final nuevoId = nuevoGrupo?['id']?.toString();
      if (nuevoId != null) {
        context.pushReplacementNamed('group_detail', pathParameters: {'grupoId': nuevoId});
      } else {
        context.pop();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      final texto = e.message.contains('inapropiadas') || e.message.contains('inapropiado')
          ? '⚠️ El nombre o descripción contiene palabras inapropiadas. Por favor revisa el contenido.'
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(texto), backgroundColor: const Color(0xFFFF3B30), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e'), backgroundColor: const Color(0xFFFF3B30), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          icon: Icon(Icons.close_rounded, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Nuevo Grupo',
            style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.5)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: c.primaryDeepWithAlpha(0.08), height: 1),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto del grupo
                  _buildSectionHeader(c, 'Foto del grupo (opcional)'),
                  const SizedBox(height: 12),
                  _buildFotoSelector(c),
                  const SizedBox(height: 28),

                  // Nombre
                  _buildSectionHeader(c, 'Información básica'),
                  const SizedBox(height: 12),
                  _buildTextField(c, _nameController, 'Nombre del grupo *', Icons.edit_note_rounded, validator: (v) {
                    if (v == null || v.isEmpty) return 'El nombre es obligatorio';
                    return null;
                  }),
                  const SizedBox(height: 16),
                  _buildTextField(c, _descController, 'Descripción (opcional)', Icons.description_rounded),
                  const SizedBox(height: 28),

                  // Modalidad
                  _buildSectionHeader(c, 'Modalidad'),
                  const SizedBox(height: 12),
                  _buildModalidadSelector(c),
                  const SizedBox(height: 28),

                  // Privacidad
                  _buildSectionHeader(c, 'Privacidad'),
                  const SizedBox(height: 12),
                  _buildPrivacidadToggle(c),
                  const SizedBox(height: 48),

                  _buildCreateButton(c),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(dynamic c, String title) {
    return Text(title,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary, letterSpacing: -0.2));
  }

  Widget _buildFotoSelector(dynamic c) {
    return GestureDetector(
      onTap: _pickFoto,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.primaryDeepWithAlpha(0.1), width: 1.5),
        ),
        child: _foto != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(_foto!, fit: BoxFit.cover),
                    Positioned(
                      bottom: 12, right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_rounded, size: 48, color: c.primaryDeepWithAlpha(0.4)),
                  const SizedBox(height: 8),
                  Text('Toca para añadir una foto', style: TextStyle(color: c.textHint, fontSize: 14)),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField(dynamic c, TextEditingController controller, String hint, IconData icon, {String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
        color: c.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: hint.contains('scripción') ? 3 : 1,
        style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w500),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: c.textHint, fontWeight: FontWeight.w400),
          prefixIcon: Padding(padding: const EdgeInsets.only(top: 4), child: Icon(icon, color: c.primaryDeep)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _buildModalidadSelector(dynamic c) {
    return Row(
      children: [
        Expanded(child: _modalidadOption(c, 'social', '👟 Social', 'Correr en grupo libremente')),
        const SizedBox(width: 12),
        Expanded(child: _modalidadOption(c, 'territorial', '🗺 Territorial', 'Dominar zonas geográficas')),
      ],
    );
  }

  Widget _modalidadOption(dynamic c, String value, String label, String subtitle) {
    final isSelected = _modalidad == value;
    final color = value == 'territorial' ? const Color(0xFF7ED957) : c.primaryDeep;
    return GestureDetector(
      onTap: () => setState(() => _modalidad = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : c.primaryDeepWithAlpha(0.08), width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? color : c.textPrimary, fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, color: c.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacidadToggle(dynamic c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.primaryDeepWithAlpha(0.08))),
      child: Row(
        children: [
          Icon(_esPrivado ? Icons.lock_rounded : Icons.lock_open_rounded, color: c.primaryDeep, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_esPrivado ? 'Grupo privado' : 'Grupo público',
                    style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary, fontSize: 15)),
                Text(_esPrivado ? 'Solo por invitación o aprobación.' : 'Cualquiera puede unirse.',
                    style: TextStyle(color: c.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _esPrivado,
            activeThumbColor: c.primaryDeep,
            onChanged: (v) => setState(() => _esPrivado = v),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(dynamic c) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _crear,
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primaryDeep,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Crear Grupo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
      ),
    );
  }
}
