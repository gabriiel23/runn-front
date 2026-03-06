import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          'Conectar wearable',
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
              const Text(
                'Sincroniza tus carreras automáticamente desde tus dispositivos favoritos.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ...brands.map((brand) => _buildBrandItem(brand)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandItem(Map<String, dynamic> brand) {
    final isConnected = brand['status'] == 'Conectado';
    final Color color = brand['color'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0A0A0A).withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              color: color.withOpacity(0.1),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  brand['status'],
                  style: TextStyle(
                    fontSize: 13,
                    color: isConnected ? const Color(0xFF7ED957) : const Color(0xFF0A0A0A).withOpacity(0.4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isConnected ? const Color(0xFFFFF0F4) : const Color(0xFFE8698A),
              foregroundColor: isConnected ? const Color(0xFFE8698A) : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
