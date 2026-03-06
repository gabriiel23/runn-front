import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController(text: 'Alex Runner');
  final _bioController = TextEditingController(text: 'Corriendo por el mundo, un kilómetro a la vez. 🏃‍♂️💨');
  final _weightController = TextEditingController(text: '72');
  final _heightController = TextEditingController(text: '178');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF0A0A0A)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: Color(0xFFE8698A),
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
              _buildPhotoPicker(),
              const SizedBox(height: 32),
              _buildTextField('Nombre completo', _nameController, Icons.person_outline_rounded),
              const SizedBox(height: 20),
              _buildTextField('Biografía', _bioController, Icons.edit_note_rounded, maxLines: 3),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Peso (kg)', _weightController, Icons.monitor_weight_outlined, keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildTextField('Altura (cm)', _heightController, Icons.height_rounded, keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildDeleteAccountSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE8698A).withValues(alpha: 0.2), width: 3),
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
            decoration: const BoxDecoration(
              color: Color(0xFFE8698A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF0A0A0A).withValues(alpha: 0.4), size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF0A0A0A).withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE8698A), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteAccountSection() {
    return Column(
      children: [
        Divider(color: const Color(0xFF0A0A0A).withValues(alpha: 0.05), height: 32),
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
