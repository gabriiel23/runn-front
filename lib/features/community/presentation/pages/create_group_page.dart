import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _inviteLinkEnabled = true;
  final List<String> _selectedMembers = [];
  
  // Dummy data for members
  final List<Map<String, String>> _availableRunners = [
    {'name': 'María González', 'emoji': '🏃‍♀️'},
    {'name': 'Carlos Ruiz', 'emoji': '🏃'},
    {'name': 'Ana Martínez', 'emoji': '🏃‍♀️'},
    {'name': 'Juan Pérez', 'emoji': '🏃'},
    {'name': 'Sofía López', 'emoji': '🏃‍♀️'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMember(String name) {
    setState(() {
      if (_selectedMembers.contains(name)) {
        _selectedMembers.remove(name);
      } else {
        _selectedMembers.add(name);
      }
    });
  }

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
          'Nuevo Grupo',
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Información básica'),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 32),
              
              _buildSectionHeader('Agregar miembros'),
              const SizedBox(height: 16),
              _buildMemberSelector(),
              const SizedBox(height: 32),
              
              _buildSectionHeader('Privacidad y Acceso'),
              const SizedBox(height: 16),
              _buildInviteLinkToggle(),
              if (_inviteLinkEnabled) ...[
                const SizedBox(height: 16),
                _buildGeneratedLinkField(),
              ],
              
              const SizedBox(height: 48),
              _buildCreateButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0A0A0A),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Nombre del grupo...',
          hintStyle: TextStyle(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.3),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFFE8698A)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFFE8698A).withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFFE8698A).withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE8698A), width: 1.5),
          ),
          contentPadding: const EdgeInsets.all(18),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa un nombre';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMemberSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8698A).withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          ..._availableRunners.map((runner) {
            final isSelected = _selectedMembers.contains(runner['name']);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFFF0F4),
                child: Text(runner['emoji']!),
              ),
              title: Text(
                runner['name']!,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              trailing: Checkbox(
                value: isSelected,
                activeColor: const Color(0xFFE8698A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (_) => _toggleMember(runner['name']!),
              ),
            );
          }),
          const Divider(height: 24),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_search_rounded, size: 18),
            label: const Text('Buscar más personas'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE8698A),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteLinkToggle() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enlace de invitación',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              Text(
                'Permite que otros se unan mediante un link.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(
          value: _inviteLinkEnabled,
          activeColor: const Color(0xFFE8698A),
          onChanged: (val) => setState(() => _inviteLinkEnabled = val),
        ),
      ],
    );
  }

  Widget _buildGeneratedLinkField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8698A).withValues(alpha: 0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.link_rounded, color: Color(0xFFE8698A), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'runn.app/join/urbanos-2024',
              style: TextStyle(
                color: Color(0xFFE8698A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Icon(Icons.copy_rounded, color: Color(0xFFE8698A), size: 18),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFE8698A), Color(0xFFC94070)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8698A).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Grupo creado con éxito!'),
                backgroundColor: Color(0xFF7ED957),
              ),
            );
            context.pop();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'Crear Grupo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
