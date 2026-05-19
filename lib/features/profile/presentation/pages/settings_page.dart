import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/core/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ── Pending (local) theme state ─────────────────────────────────────────────
  // Initialized from the current global notifier in didChangeDependencies.
  late AppColorScheme _pendingScheme;
  late AppBrightness _pendingBrightness;
  bool _initialized = false;
  bool _isSuperAdmin = false;

  bool get _hasPendingChange {
    final notifier = context.themeNotifier;
    return _pendingScheme != notifier.scheme ||
        _pendingBrightness != notifier.brightness;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final notifier = context.themeNotifier;
      _pendingScheme = notifier.scheme;
      _pendingBrightness = notifier.brightness;
      _initialized = true;
      // Cargar permisos de superadmin asincrónicamente
      ApiConfig.isSuperAdmin().then((v) {
        if (mounted) setState(() => _isSuperAdmin = v);
      });
    }
  }

  void _applyTheme() {
    context.themeNotifier.setTheme(_pendingScheme, _pendingBrightness);
    // Re-sync so the "has pending change" check resets
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PopScope(
      // Apply theme on back navigation if there's a pending change
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _hasPendingChange) {
          context.themeNotifier.setTheme(_pendingScheme, _pendingBrightness);
        }
      },
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(
          backgroundColor: c.bg,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
            onPressed: () {
              if (_hasPendingChange) {
                context.themeNotifier.setTheme(
                  _pendingScheme,
                  _pendingBrightness,
                );
              }
              context.pop();
            },
          ),
          title: Text(
            'Configuración',
            style: TextStyle(
              color: c.textPrimary,
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
                  _buildSettingsItem(
                    Icons.person_outline_rounded,
                    'Editar perfil',
                    () => context.pushNamed('profile_edit'),
                  ),
                  _buildSettingsItem(
                    Icons.watch_rounded,
                    'Conectar wearable',
                    () => context.pushNamed('profile_wearables'),
                  ),
                  _buildSettingsItem(
                    Icons.lock_outline_rounded,
                    'Privacidad',
                    () {},
                  ),
                  _buildSettingsItem(
                    Icons.security_rounded,
                    'Seguridad',
                    () {},
                  ),
                ]),
                const SizedBox(height: 32),
                _buildSectionTitle('Aplicación'),
                _buildSettingsGroup([
                  _buildSettingsItem(
                    Icons.language_rounded,
                    'Idioma',
                    () {},
                    trailing: 'Español',
                  ),
                  _buildSettingsItem(
                    Icons.help_outline_rounded,
                    'Ayuda y soporte',
                    () {},
                  ),
                  _buildSettingsItem(
                    Icons.info_outline_rounded,
                    'Sobre la app',
                    () {},
                  ),
                ]),
                const SizedBox(height: 32),
                _buildSectionTitle('Apariencia'),
                _buildThemeSelector(),
                if (_isSuperAdmin) ...[
                  const SizedBox(height: 32),
                  _buildSectionTitle('Administración'),
                  _buildAdminGroup(),
                ],
                const SizedBox(height: 48),
                _buildLogoutButton(),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Versión 1.0.0 (Build 1)',
                    style: TextStyle(
                      fontSize: 12,
                      color: c.textPrimary.withValues(alpha: 0.3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Theme selector ──────────────────────────────────────────────────────────
  // All reads here use local _pendingScheme / _pendingBrightness.
  // No context.themeNotifier read → no InheritedWidget dependency here.
  // The only time we touch ThemeNotifier is in _applyTheme().

  Widget _buildThemeSelector() {
    final c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Color scheme ────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.palette_outlined, size: 20, color: c.primary),
              const SizedBox(width: 10),
              Text(
                'Color',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildSchemeChip(
                scheme: AppColorScheme.pink,
                label: 'Rosa',
                accent: const Color(0xFFE90084),
              ),
              const SizedBox(width: 12),
              _buildSchemeChip(
                scheme: AppColorScheme.blue,
                label: 'Azul',
                accent: const Color(0xFF2196F3),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: c.primary.withValues(alpha: 0.08)),
          const SizedBox(height: 16),
          // ── Brightness toggle ───────────────────────────────────────────────
          Row(
            children: [
              Icon(
                _pendingBrightness == AppBrightness.dark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: 20,
                color: c.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Modo',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const Spacer(),
              _buildBrightnessToggle(),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: c.primary.withValues(alpha: 0.08)),
          const SizedBox(height: 16),
          // ── Quick preview ───────────────────────────────────────────────────
          _buildThemePreviewRow(),
          // ── Apply button (only visible when there's a change) ──────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: _hasPendingChange
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _applyTheme,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.primary,
                          foregroundColor: Colors.grey[800],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded, size: 18),
                            SizedBox(width: 12),
                            Text(
                              'Aplicar tema',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeChip({
    required AppColorScheme scheme,
    required String label,
    required Color accent,
  }) {
    final c = context.colors;
    final isSelected = _pendingScheme == scheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _pendingScheme = scheme),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? accent.withValues(alpha: 0.12) : c.bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accent : c.cardBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? accent : c.textSecondary,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_rounded, size: 16, color: accent),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrightnessToggle() {
    final c = context.colors;
    final isDark = _pendingBrightness == AppBrightness.dark;

    return GestureDetector(
      onTap: () => setState(() {
        _pendingBrightness = isDark ? AppBrightness.light : AppBrightness.dark;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        width: 156,
        height: 38,
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.cardBorder),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 78,
                height: 38,
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.light_mode_rounded,
                          size: 14,
                          color: isDark ? c.textSecondary : Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Claro',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? c.textSecondary : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dark_mode_rounded,
                          size: 14,
                          color: isDark ? Colors.white : c.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Oscuro',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreviewRow() {
    final c = context.colors;
    final options = [
      (
        AppColorScheme.pink,
        AppBrightness.light,
        const Color(0xFFE90084),
        const Color(0xFFFFF5F9),
        'Rosa\nClaro',
      ),
      (
        AppColorScheme.pink,
        AppBrightness.dark,
        const Color(0xFFE90084),
        const Color(0xFF1A1220),
        'Rosa\nOscuro',
      ),
      (
        AppColorScheme.blue,
        AppBrightness.light,
        const Color(0xFF2196F3),
        const Color(0xFFF2F8FF),
        'Azul\nClaro',
      ),
      (
        AppColorScheme.blue,
        AppBrightness.dark,
        const Color(0xFF2196F3),
        const Color(0xFF0E1720),
        'Azul\nOscuro',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vista rápida — toca para seleccionar',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: options.map((opt) {
            final (scheme, brightness, accent, bg, name) = opt;
            final isSelected =
                _pendingScheme == scheme && _pendingBrightness == brightness;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _pendingScheme = scheme;
                  _pendingBrightness = brightness;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  height: 68,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? accent : c.cardBorder,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: accent,
                        )
                      else
                        Container(
                          width: 20,
                          height: 6,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      const SizedBox(height: 5),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: brightness == AppBrightness.dark
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Generic settings builders ───────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
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

  Widget _buildSettingsGroup(List<Widget> items) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? trailing,
  }) {
    final c = context.colors;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: c.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
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
                  color: c.textPrimary.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: c.textPrimary.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    final c = context.colors;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primaryLight,
          foregroundColor: const Color(0xffFF3B30),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: c.primaryMid),
          ),
        ),
        child: const Row(
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

  void _showLogoutDialog() {
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
            child: const Text(
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

  // ── Admin group ──────────────────────────────────────────────────────────────

  Widget _buildAdminGroup() {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.primaryDeep.withValues(alpha: 0.10),
            c.primaryDeep.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.primaryDeep.withValues(alpha: 0.20)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.primaryDeep.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.manage_accounts_rounded, color: c.primaryDeep, size: 22),
            ),
            title: Text(
              'Gestionar Roles de Usuarios',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              'Asigna y revoca roles de admin',
              style: TextStyle(color: c.textSecondary, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: c.primaryDeep),
            onTap: () => context.pushNamed('admin_roles'),
          ),
        ],
      ),
    );
  }
}
