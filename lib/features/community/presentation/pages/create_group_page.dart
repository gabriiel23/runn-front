import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

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
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: context.colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Nuevo Grupo',
          style: TextStyle(
            color: context.colors.textPrimary,
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
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: context.colors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.inputFill,
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
        style: TextStyle(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Nombre del grupo...',
          hintStyle: TextStyle(
            color: context.colors.textHint,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.edit_note_rounded,
            color: context.colors.primaryDeep,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: context.colors.primaryDeepWithAlpha(0.1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: context.colors.primaryDeepWithAlpha(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: context.colors.primaryDeep,
              width: 1.5,
            ),
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
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.primaryDeepWithAlpha(0.08)),
      ),
      child: Column(
        children: [
          ..._availableRunners.map((runner) {
            final isSelected = _selectedMembers.contains(runner['name']);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: context.colors.primaryLight,
                child: Text(runner['emoji']!),
              ),
              title: Text(
                runner['name']!,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              trailing: Checkbox(
                value: isSelected,
                activeColor: context.colors.primaryDeep,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
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
              foregroundColor: context.colors.primaryDeep,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enlace de invitación',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                'Permite que otros se unan mediante un link.',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: _inviteLinkEnabled,
          activeThumbColor: context.colors.primaryDeep,
          onChanged: (val) => setState(() => _inviteLinkEnabled = val),
        ),
      ],
    );
  }

  Widget _buildGeneratedLinkField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.primaryDeepWithAlpha(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.link_rounded, color: context.colors.primaryDeep, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'runn.app/join/urbanos-2024',
              style: TextStyle(
                color: context.colors.primaryDeep,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Icon(Icons.copy_rounded, color: context.colors.primaryDeep, size: 18),
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
        gradient: LinearGradient(
          colors: [context.colors.primaryDeep, context.colors.primaryMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.primaryDeepWithAlpha(0.3),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
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
