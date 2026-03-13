import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class SplashPage extends StatefulWidget {
  final String nextRoute;

  const SplashPage({super.key, required this.nextRoute});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Navegar automáticamente después de 2.5 segundos
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go(widget.nextRoute);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String imagePath = isDark
        ? 'assets/RUNN-oscuro.png'
        : 'assets/RUNN-claro.png';

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: Stack(
        children: [
          // Logo Animado
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  imagePath,
                  width: 220,
                ),
              ),
            ),
          ),

          // Footer
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Text(
              'Desarrollado por 1998 - Desarrollo Digital y Marketing',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.colors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
