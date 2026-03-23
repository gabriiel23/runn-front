import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/features/profile/services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _currentAvatarUrl;
  Map<String, String> _originalData = {};

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    setState(() => _isLoading = true);
    try {
      final local = await ProfileService.getLocalProfile();
      _nameController.text = local['nombre'] as String? ?? '';
      _bioController.text = local['biografia'] as String? ?? '';
      _weightController.text = local['peso_kg']?.toString() ?? '';
      _heightController.text = local['altura_cm']?.toString() ?? '';
      _cityController.text = local['ciudad'] as String? ?? '';
      _countryController.text = local['pais'] as String? ?? '';
      _currentAvatarUrl = local['avatar_url'] as String?;

      _originalData = {
        'nombre': _nameController.text,
        'biografia': _bioController.text,
        'peso_kg': _weightController.text,
        'altura_cm': _heightController.text,
        'ciudad': _cityController.text,
        'pais': _countryController.text,
      };
    } catch (_) {
      // No hay caché, se dejan vacíos
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await ProfileService.editProfile(
        nombre: _nameController.text.trim(),
        biografia: _bioController.text.trim(),
        pesoKg: double.tryParse(_weightController.text.trim()),
        alturaCm: double.tryParse(_heightController.text.trim()),
        ciudad: _cityController.text.trim(),
        pais: _countryController.text.trim(),
      );

      _originalData = {
        'nombre': _nameController.text.trim(),
        'biografia': _bioController.text.trim(),
        'peso_kg': _weightController.text.trim(),
        'altura_cm': _heightController.text.trim(),
        'ciudad': _cityController.text.trim(),
        'pais': _countryController.text.trim(),
      };

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Perfil actualizado', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: const Color(0xFF7ED957),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('No se pudo guardar el perfil. Intenta de nuevo.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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

  bool _hasChanges() {
    if (_nameController.text.trim() != _originalData['nombre']) return true;
    if (_bioController.text.trim() != _originalData['biografia']) return true;
    if (_weightController.text.trim() != _originalData['peso_kg']) return true;
    if (_heightController.text.trim() != _originalData['altura_cm']) return true;
    if (_cityController.text.trim() != _originalData['ciudad']) return true;
    if (_countryController.text.trim() != _originalData['pais']) return true;
    return false;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges()) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        final c = context.colors;
        return AlertDialog(
          backgroundColor: c.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            '¿Descartar cambios?',
            style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Tienes datos sin guardar. Si retrocedes ahora, perderás tus modificaciones.',
            style: TextStyle(color: c.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: Text('Cancelar', style: TextStyle(color: c.textHint, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text('Descartar', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    return shouldPop ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop(result);
        }
      },
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(
          backgroundColor: c.card,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: c.textPrimary),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                context.pop();
              }
            },
          ),
          title: Text(
            'Editar perfil',
            style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.primary,
                      ),
                    )
                  : Text(
                      'Guardar',
                      style: TextStyle(
                        color: c.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: c.primary))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildPhotoPicker(context),
                      const SizedBox(height: 32),
                      _buildTextField(
                        context,
                        'Nombre completo',
                        _nameController,
                        Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        context,
                        'Biografía',
                        _bioController,
                        Icons.edit_note_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              context,
                              'Ciudad',
                              _cityController,
                              Icons.location_city_rounded,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildTextField(
                              context,
                              'País',
                              _countryController,
                              Icons.flag_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              context,
                              'Peso (kg)',
                              _weightController,
                              Icons.monitor_weight_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildTextField(
                              context,
                              'Altura (cm)',
                              _heightController,
                              Icons.height_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      _buildDeleteAccountSection(context),
                      const SizedBox(height: 70), // padding extra inferior
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPhotoPicker(BuildContext context) {
    final c = context.colors;
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.primaryWithAlpha(0.2), width: 3),
          ),
          child: CircleAvatar(
            radius: 56,
            backgroundColor: c.primaryLight,
            backgroundImage:
                _currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                ? NetworkImage(_currentAvatarUrl!)
                : null,
            child: _currentAvatarUrl == null || _currentAvatarUrl!.isEmpty
                ? Icon(
                    Icons.person_rounded,
                    color: c.primaryDeepWithAlpha(0.7),
                    size: 50,
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isUploadingAvatar
                ? null
                : () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 70,
                    );
                    if (pickedFile != null) {
                      setState(() => _isUploadingAvatar = true);
                      try {
                        final bytes = await pickedFile.readAsBytes();
                        final newUrl = await ProfileService.uploadAvatar(
                          bytes,
                          pickedFile.name,
                        );
                        // Evictar el caché de la imagen anterior para que
                        // NetworkImage recargue desde Supabase sin reiniciar.
                        if (_currentAvatarUrl != null) {
                          await NetworkImage(_currentAvatarUrl!).evict();
                        }
                        // Añadir timestamp para forzar una petición fresca
                        final bustedUrl = '$newUrl?t=${DateTime.now().millisecondsSinceEpoch}';
                        setState(() => _currentAvatarUrl = bustedUrl);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Foto de perfil actualizada'),
                            backgroundColor: const Color(0xFF7ED957),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        );
                      } on ApiException catch (e) {
                        if (!context.mounted) return;
                        _showError(e.message);
                      } catch (e) {
                        if (!context.mounted) return;
                        _showError('Error al subir avatar: $e');
                      } finally {
                        if (mounted) setState(() => _isUploadingAvatar = false);
                      }
                    }
                  },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
              child: _isUploadingAvatar
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: c.surface),
                    )
                  : Icon(Icons.camera_alt_rounded, color: c.surface, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: c.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 ? Icon(icon, color: c.textHint, size: 20) : null,
            filled: true,
            fillColor: c.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: c.primaryDeepWithAlpha(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: c.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteAccountSection(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Divider(color: c.primaryDeepWithAlpha(0.05), height: 32),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Eliminar cuenta',
            style: TextStyle(
              color: Color(0xFFFF3B30),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        Text(
          'Esta acción no se puede deshacer',
          style: TextStyle(color: c.textHint, fontSize: 12),
        ),
      ],
    );
  }
}
