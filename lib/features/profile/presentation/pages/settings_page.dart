import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.colors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Configuración',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Cuenta'),
              _buildSettingsGroup(context, [
                _buildSettingsItem(
                  context,
                  Icons.person_outline_rounded,
                  'Información personal',
                  () {},
                ),
                _buildSettingsItem(
                  context,
                  Icons.notifications_none_rounded,
                  'Notificaciones',
                  () {},
                ),
                _buildSettingsItem(
                  context,
                  Icons.lock_outline_rounded,
                  'Privacidad',
                  () {},
                ),
                _buildSettingsItem(
                  context,
                  Icons.security_rounded,
                  'Seguridad',
                  () {},
                ),
              ]),
              SizedBox(height: 32),
              _buildSectionTitle(context, 'Aplicación'),
              _buildSettingsGroup(context, [
                _buildSettingsItem(
                  context,
                  Icons.language_rounded,
                  'Idioma',
                  () {},
                  trailing: 'Español',
                ),
                _buildSettingsItem(
                  context,
                  Icons.dark_mode_outlined,
                  'Tema',
                  () {},
                  trailing: 'Claro',
                ),
                _buildSettingsItem(
                  context,
                  Icons.help_outline_rounded,
                  'Ayuda y soporte',
                  () {},
                ),
                _buildSettingsItem(
                  context,
                  Icons.info_outline_rounded,
                  'Sobre la app',
                  () {},
                ),
              ]),
              SizedBox(height: 48),
              _buildLogoutButton(context),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'Versión 1.0.0 (Build 1)',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textPrimary.withValues(alpha: 0.3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: context.colors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.colors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: context.colors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                trailing,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textPrimary.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: context.colors.textPrimary.withValues(alpha: 0.2),
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
          backgroundColor: context.colors.primaryLight,
          foregroundColor: Color(0xffFF3B30),
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.colors.primaryMid),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Cerrar sesión',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
        backgroundColor: context.colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Cerrar sesión',
          style: TextStyle(color: context.colors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.colors.textHint),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: Text(
              'Cerrar sesión',
              style: TextStyle(
                color: Color(0xffFF3B30),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
