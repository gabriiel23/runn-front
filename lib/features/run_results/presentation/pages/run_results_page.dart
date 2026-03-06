import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const kPink = Color(0xFFFFD3E0);
const kPinkDark = Color(0xFFE8A0B8);
const kPinkDeep = Color(0xFFC4607A);
const kPinkLight = Color(0xFFFFF0F5);
const kPinkMid = Color(0xFFFFB8CE);
const kPinkBg = Color(0xFFFAF0F4);

class RunResultsScreen extends StatelessWidget {
  const RunResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const runData = (
      distance: 5.47,
      time: '32:15',
      pace: '5:54',
      calories: 328,
      date: '20 Nov 2024',
      startTime: '18:35',
      endTime: '19:07',
      avgSpeed: '10.2',
    );

    return Scaffold(
      backgroundColor: kPinkBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Success Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kPinkDeep, kPinkDark],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 36),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Carrera completada!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Excelente trabajo, sigue así',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Route Map ─────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: kPink.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu ruta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                // Grid background
                                Container(color: kPinkLight),
                                GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 8,
                                        mainAxisSpacing: 1,
                                        crossAxisSpacing: 1,
                                      ),
                                  itemCount: 64,
                                  itemBuilder: (_, i) => Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: i % 3 == 0
                                            ? const [
                                                Color(0xFFFFF0F5),
                                                Color(0xFFFFD3E0),
                                              ]
                                            : const [
                                                Color(0xFFFFF8FB),
                                                Color(0xFFFFF0F5),
                                              ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Route path
                                CustomPaint(
                                  size: Size.infinite,
                                  painter: _RouteResultPainter(),
                                ),

                                // Start marker
                                Positioned(
                                  top: MediaQuery.of(context).size.width * 0.38,
                                  left: MediaQuery.of(context).size.width * 0.1,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: kPinkMid,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: kPinkMid.withValues(
                                                alpha: 0.5,
                                              ),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: CircleAvatar(
                                            radius: 3,
                                            backgroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: kPink.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          'Inicio',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: kPinkDeep,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // End marker
                                Positioned(
                                  top: MediaQuery.of(context).size.width * 0.62,
                                  left:
                                      MediaQuery.of(context).size.width * 0.35,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: kPink.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          'Fin',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: kPinkDeep,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: kPinkDeep,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: kPinkDeep.withValues(
                                                alpha: 0.5,
                                              ),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: CircleAvatar(
                                            radius: 3,
                                            backgroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
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
                  const SizedBox(height: 20),

                  // ── Main Stats ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildMainStatCard(
                          icon: Icons.location_on,
                          iconColor: kPinkDeep,
                          bgColor: kPink.withValues(alpha: 0.2),
                          borderColor: kPink.withValues(alpha: 0.5),
                          label: 'Distancia total',
                          value: '${runData.distance}',
                          unit: 'kilómetros',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMainStatCard(
                          icon: Icons.access_time_rounded,
                          iconColor: kPinkDark,
                          bgColor: kPinkMid.withValues(alpha: 0.2),
                          borderColor: kPinkMid.withValues(alpha: 0.5),
                          label: 'Tiempo total',
                          value: runData.time,
                          unit: 'minutos',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Additional Stats ──────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: kPink.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estadísticas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniStatRow(
                                icon: Icons.trending_up,
                                iconColor: kPinkDark,
                                iconBg: kPinkDark.withValues(alpha: 0.12),
                                label: 'Ritmo promedio',
                                value: runData.pace,
                                unit: 'min/km',
                              ),
                            ),
                            Expanded(
                              child: _buildMiniStatRow(
                                icon: Icons.local_fire_department,
                                iconColor: kPinkDeep,
                                iconBg: kPinkDeep.withValues(alpha: 0.12),
                                label: 'Calorías',
                                value: '${runData.calories}',
                                unit: 'kcal',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(
                          color: kPink.withValues(alpha: 0.4),
                          thickness: 1,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Velocidad promedio',
                          '${runData.avgSpeed} km/h',
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Fecha', runData.date),
                        const SizedBox(height: 12),
                        _buildDetailRow('Hora de inicio', runData.startTime),
                        const SizedBox(height: 12),
                        _buildDetailRow('Hora de fin', runData.endTime),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Action Buttons ────────────────────────────────────
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPinkDeep, kPinkDark],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: kPinkDeep.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Compartir carrera',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: kPinkMid, width: 1.5),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.download_rounded,
                                  size: 18,
                                  color: Color(0xFF1A1A1A),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Guardar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.go('/home'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: kPinkMid, width: 1.5),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home_rounded,
                                  size: 18,
                                  color: Color(0xFF1A1A1A),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Inicio',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgColor, bgColor.withValues(alpha: 0.4)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required String unit,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              unit,
              style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B6B6B)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

class _RouteResultPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kPinkDeep
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.45);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.35,
      size.width * 0.38,
      size.height * 0.42,
    );
    path.quadraticBezierTo(
      size.width * 0.52,
      size.height * 0.48,
      size.width * 0.58,
      size.height * 0.55,
    );
    path.quadraticBezierTo(
      size.width * 0.64,
      size.height * 0.62,
      size.width * 0.58,
      size.height * 0.72,
    );
    path.quadraticBezierTo(
      size.width * 0.52,
      size.height * 0.80,
      size.width * 0.42,
      size.height * 0.76,
    );

    // Glow
    canvas.drawPath(
      path,
      paint
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..color = kPinkMid.withValues(alpha: 0.5),
    );
    // Line
    canvas.drawPath(
      path,
      paint
        ..maskFilter = null
        ..color = kPinkDeep,
    );
  }

  @override
  bool shouldRepaint(_RouteResultPainter old) => false;
}
