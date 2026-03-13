import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [c.primaryWithAlpha(0.15), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: c.textPrimary,
                        iconSize: 24,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero image
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: c.primary, width: 3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                width: double.infinity,
                                height: 180,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        c.primaryWithAlpha(0.35),
                                        BlendMode.overlay,
                                      ),
                                      child: Image.asset(
                                        'assets/corredores.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _buildFallbackHero(c),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            Colors.black.withValues(
                                              alpha: 0.15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
                          child: Text(
                            'Únete a la carrera',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: c.textPrimary,
                              letterSpacing: -0.5,
                              height: 1.15,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                          child: Text(
                            'Regístrate para empezar a conquistar territorios en tu ciudad.',
                            style: TextStyle(
                              fontSize: 15,
                              color: c.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Nombre completo', c),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _nameController,
                                hint: 'Ej. Juan Pérez',
                                keyboardType: TextInputType.name,
                                c: c,
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('Correo electrónico', c),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _emailController,
                                hint: 'tu@email.com',
                                keyboardType: TextInputType.emailAddress,
                                c: c,
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('Contraseña', c),
                              const SizedBox(height: 8),
                              _buildPasswordField(
                                controller: _passwordController,
                                obscure: _obscurePassword,
                                onToggle: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                c: c,
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('Confirmar contraseña', c),
                              const SizedBox(height: 8),
                              _buildPasswordField(
                                controller: _confirmPasswordController,
                                obscure: _obscureConfirm,
                                onToggle: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                                c: c,
                              ),
                              const SizedBox(height: 28),

                              // Register button
                                GestureDetector(
                                  // Temporalmente enviando as splash -> home similar al login para match con el request.
                                  onTap: () {
                                    context.go('/splash', extra: '/home');
                                  },
                                  child: Container(
                                    width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: c.primary,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: c.primaryWithAlpha(0.5),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Registrarse',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: c.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: c.primaryMidWithAlpha(0.4),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'O regístrate con',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: c.textHint,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: c.primaryMidWithAlpha(0.4),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSocialButton(
                                      icon: Icons.g_mobiledata_rounded,
                                      iconColor: const Color(0xFFEA4335),
                                      label: 'Google',
                                      onTap: () {},
                                      c: c,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildSocialButton(
                                      icon: Icons.apple_rounded,
                                      iconColor: c.textPrimary,
                                      label: 'Apple',
                                      onTap: () {},
                                      c: c,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              Center(
                                child: GestureDetector(
                                  onTap: () => context.go('/login'),
                                  child: RichText(
                                    text: TextSpan(
                                      text: '¿Ya tienes una cuenta? ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: c.textSecondary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Inicia sesión',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: c.textPrimary,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: c.primaryMid,
                                            decorationThickness: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackHero(c) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemCount: 64,
          itemBuilder: (_, i) => Container(
            color: i % 3 == 0
                ? c.primaryWithAlpha(0.2)
                : c.primaryLight.withValues(alpha: 0.6),
          ),
        ),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: c.card.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: c.primaryDeepWithAlpha(0.25), blurRadius: 20),
              ],
            ),
            child: Icon(
              Icons.directions_run_rounded,
              color: c.primaryDeep,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, c) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: c.textPrimary,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    required c,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 15, color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: c.textHint,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: c.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: c.inputBorder.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.inputBorderFocused, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required c,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(fontSize: 15, color: c.textPrimary),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: TextStyle(color: c.textHint, fontSize: 15),
        filled: true,
        fillColor: c.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: c.inputBorder.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.inputBorderFocused, width: 2),
        ),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: c.textHint,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    required c,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.primaryMidWithAlpha(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: c.primaryWithAlpha(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
