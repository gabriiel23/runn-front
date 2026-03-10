import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController(text: 'Alex Runner');
  final _bioController = TextEditingController(
    text: 'Corriendo por el mundo, un kilómetro a la vez. 🏃‍♂️💨',
  );
  final _weightController = TextEditingController(text: '72');
  final _heightController = TextEditingController(text: '178');

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
            onPressed: () => context.pop(),
            child: Text(
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
      body: SingleChildScrollView(
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
              const SizedBox(height: 40),
              _buildDeleteAccountSection(context),
            ],
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
          child: const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1650452671134-28837b325586?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhdGhsZXRpYyUyMHBlcnNvbiUyMHJ1bm5pbmd8ZW58MXx8fHwxNzYzNjA1NjQzfDA&ixlib=rb-4.1.0&q=80&w=1080',
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
            child: Icon(Icons.camera_alt_rounded, color: c.surface, size: 20),
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
            prefixIcon: Icon(icon, color: c.textHint, size: 20),
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
              color: Color(0xffFF3B30),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
