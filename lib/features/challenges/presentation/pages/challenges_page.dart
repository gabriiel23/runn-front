import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// El contenido de Retos fue integrado en la pantalla de Comunidad.
/// Esta pantalla redirige automáticamente a /community.
class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirigir a comunidad (donde ahora vive el tab de Retos)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/community');
    });
    return const Scaffold(
      backgroundColor: Color(0xFFFAFBFC),
      body: SizedBox.shrink(),
    );
  }
}
