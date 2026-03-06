import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A0A0A)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Configuración',
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Cuenta'),
              _buildSettingsGroup([
                _buildSettingsItem(Icons.person_outline_rounded, 'Información personal', () {}),
                _buildSettingsItem(Icons.notifications_none_rounded, 'Notificaciones', () {}),
                _buildSettingsItem(Icons.lock_outline_rounded, 'Privacidad', () {}),
                _buildSettingsItem(Icons.security_rounded, 'Seguridad', () {}),
              ]),
              const SizedBox(height: 32),
              _buildSectionTitle('Aplicación'),
              _buildSettingsGroup([
                _buildSettingsItem(Icons.language_rounded, 'Idioma', () {}, trailing: 'Español'),
                _buildSettingsItem(Icons.dark_mode_outlined, 'Tema', () {}, trailing: 'Claro'),
                _buildSettingsItem(Icons.help_outline_rounded, 'Ayuda y soporte', () {}),
                _buildSettingsItem(Icons.info_outline_rounded, 'Sobre la app', () {}),
              ]),
              const SizedBox(height: 48),
              _buildLogoutButton(context),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Versión 1.0.0 (Build 1)',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF0A0A0A).withValues(alpha: 0.3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0A0A0A),
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8698A).withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap, {String? trailing}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFFE8698A), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0A0A0A),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                trailing,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF0A0A0A).withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: const Color(0xFF0A0A0A).withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF0F4),
          foregroundColor: const Color(0xffFF3B30),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFFFE5EA)),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Cerrar sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text('Cerrar sesión', style: TextStyle(color: Color(0xffFF3B30), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
