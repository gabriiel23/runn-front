import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class WearablesPage extends StatelessWidget {
  const WearablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final brands = [
      {
        'name': 'Garmin',
        'logo': 'G',
        'color': const Color(0xFF000000),
        'status': 'Desconectado',
        'icon': Icons.watch_rounded,
      },
      {
        'name': 'Strava',
        'logo': 'S',
        'color': const Color(0xFFFC6100),
        'status': 'Conectado',
        'icon': Icons.directions_run_rounded,
      },
      {
        'name': 'Apple Watch',
        'logo': 'A',
        'color': const Color(0xFF555555),
        'status': 'Desconectado',
        'icon': Icons.watch_rounded,
      },
      {
        'name': 'Fitbit',
        'logo': 'F',
        'color': const Color(0xFF00B0B9),
        'status': 'Desconectado',
        'icon': Icons.watch_outlined,
      },
      {
        'name': 'Polar',
        'logo': 'P',
        'color': const Color(0xFFE31E24),
        'status': 'Desconectado',
        'icon': Icons.watch_rounded,
      },
    ];

    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Conectar wearable',
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
              Text(
                'Sincroniza tus carreras automáticamente desde tus dispositivos favoritos.',
                style: TextStyle(
                  fontSize: 15,
                  color: c.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ...brands.map((brand) => _buildBrandItem(context, brand)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandItem(BuildContext context, Map<String, dynamic> brand) {
    final c = context.colors;
    final isConnected = brand['status'] == 'Conectado';
    final Color color = brand['color'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.textPrimary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(brand['icon'], color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  brand['status'],
                  style: TextStyle(
                    fontSize: 13,
                    color: isConnected ? c.primaryDeep : c.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isConnected ? c.primaryLight : c.primaryDeep,
              foregroundColor: isConnected ? c.primaryDeep : c.surface,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isConnected ? 'Desvincular' : 'Vincular',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
