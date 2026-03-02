import 'package:flutter/material.dart';

class TerritoriesScreen extends StatelessWidget {
  const TerritoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              _buildHeader(),

              const SizedBox(height: 24),

              _buildSummaryCard(),

              const SizedBox(height: 24),

              _buildMapSection(),

              const SizedBox(height: 28),

              _buildRecentActivity(),

              const SizedBox(height: 28),

              _buildTerritoriesList(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: 30,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8698A).withValues(alpha: 0.04),
                    const Color(0xFFE8698A).withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7ED957).withValues(alpha: 0.03),
                    const Color(0xFF7ED957).withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Territorios",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Conquista y defiende tu zona",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B6B6B),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.map, color: Color(0xFFC94070)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mapa de dominio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Vista de la ciudad',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
                  ),
                ],
              ),
              const Text(
                'Expandir',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC94070),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8EBF2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildMapGrid(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  const Color(0xFF4CD964).withValues(alpha: 0.4),
                  const Color(0xFF4CD964).withValues(alpha: 0.6),
                  'Tuyo',
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  const Color(0xFFFF9500).withValues(alpha: 0.3),
                  const Color(0xFFFF9500).withValues(alpha: 0.5),
                  'Disputa',
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  const Color(0xFFFF3B30).withValues(alpha: 0.3),
                  const Color(0xFFFF3B30).withValues(alpha: 0.5),
                  'Rival',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Tu dominio",
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "12 / 45",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    "En disputa",
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "3",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9500),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.27,
              minHeight: 10,
              backgroundColor: const Color(0xFFF0F2F6),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFC94070)),
            ),
          ),

          const SizedBox(height: 6),

          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              "27%",
              style: TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapGrid() {
    final gridData = [
      // Row 1
      ['owned', 'owned', 'contested', 'unclaimed', 'unclaimed'],
      // Row 2
      ['owned', 'contested', 'contested', 'contested', 'unclaimed'],
      // Row 3
      ['owned', 'rival', 'rival', 'rival', 'unclaimed'],
      // Row 4
      ['owned', 'owned', 'unclaimed', 'unclaimed', 'rival'],
      // Row 5
      ['owned', 'owned', 'unclaimed', 'rival', 'rival'],
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 25,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final row = index ~/ 5;
        final col = index % 5;
        final status = gridData[row][col];

        Color bgColor;
        Color borderColor;

        switch (status) {
          case 'owned':
            bgColor = const Color(0xFF4CD964).withValues(alpha: 0.4);
            borderColor = const Color(0xFF4CD964).withValues(alpha: 0.6);
            break;
          case 'contested':
            bgColor = const Color(0xFFFF9500).withValues(alpha: 0.3);
            borderColor = const Color(0xFFFF9500).withValues(alpha: 0.5);
            break;
          case 'rival':
            bgColor = const Color(0xFFFF3B30).withValues(alpha: 0.3);
            borderColor = const Color(0xFFFF3B30).withValues(alpha: 0.5);
            break;
          default:
            bgColor = const Color(0xFFE5E5E5).withValues(alpha: 0.5);
            borderColor = const Color(0xFFD1D1D1).withValues(alpha: 0.5);
        }

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
          ),
          child: _buildGridIcon(row, col, status),
        );
      },
    );
  }

  Widget? _buildGridIcon(int row, int col, String status) {
    // Add icons to specific cells like in the original
    if (row == 0 && col == 0) {
      return Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF4CD964),
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    if (row == 1 && col == 2) {
      return const Center(
        child: Icon(Icons.emoji_events, color: Color(0xFFFF9500), size: 12),
      );
    }
    if (row == 2 && col == 2) {
      return const Center(
        child: Icon(Icons.gavel, color: Color(0xFFFF3B30), size: 12),
      );
    }
    return null;
  }

  Widget _buildLegendItem(Color bgColor, Color borderColor, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B6B6B)),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'type': 'stolen',
        'runner': 'Carlos M.',
        'territory': 'Parque Central',
        'percentage': 12,
        'time': '2 horas',
      },
      {
        'type': 'recovered',
        'territory': 'Centro Histórico',
        'percentage': 5,
        'time': '1 día',
      },
      {'type': 'defended', 'territory': 'Barrio Residencial', 'time': '2 días'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Actividad reciente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        ...activities.map(
          (activity) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildActivityItem(activity),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    Color bgColor, borderColor, iconBgColor, iconColor;
    IconData icon;

    switch (type) {
      case 'stolen':
        bgColor = const Color(0xFFFF3B30).withValues(alpha: 0.05);
        borderColor = const Color(0xFFFF3B30).withValues(alpha: 0.2);
        iconBgColor = const Color(0xFFFF3B30).withValues(alpha: 0.2);
        iconColor = const Color(0xFFFF3B30);
        icon = Icons.error_outline;
        break;
      case 'recovered':
        bgColor = const Color(0xFF4CD964).withValues(alpha: 0.05);
        borderColor = const Color(0xFF4CD964).withValues(alpha: 0.2);
        iconBgColor = const Color(0xFF4CD964).withValues(alpha: 0.2);
        iconColor = const Color(0xFF4CD964);
        icon = Icons.trending_up;
        break;
      default: // defended
        bgColor = const Color(0xFFC94070).withValues(alpha: 0.05);
        borderColor = const Color(0xFFC94070).withValues(alpha: 0.2);
        iconBgColor = const Color(0xFFC94070).withValues(alpha: 0.2);
        iconColor = const Color(0xFFC94070);
        icon = Icons.shield;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActivityTitle(activity),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getActivitySubtitle(activity),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hace ${activity['time']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityTitle(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    switch (type) {
      case 'stolen':
        return '${activity['runner']} robó ${activity['percentage']}%';
      case 'recovered':
        return 'Recuperaste ${activity['percentage']}%';
      default:
        return 'Defendiste tu territorio';
    }
  }

  String _getActivitySubtitle(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    switch (type) {
      case 'stolen':
        return 'de tu territorio en ${activity['territory']}';
      case 'recovered':
        return 'del territorio ${activity['territory']}';
      default:
        return '${activity['territory']} está asegurado';
    }
  }

  Widget _buildTerritoriesList() {
    final territories = [
      {
        'id': 1,
        'name': 'Centro Histórico',
        'dominance': 85,
        'status': 'owned',
        'runs': 8,
        'distance': 24.3,
        'lastRun': '2 días',
        'rivalActivity': 0,
        'color': const Color(0xFF4CD964),
      },
      {
        'id': 2,
        'name': 'Parque Central',
        'dominance': 62,
        'status': 'contested',
        'runs': 5,
        'distance': 18.7,
        'lastRun': '1 día',
        'rivalActivity': 38,
        'rivalName': 'Carlos M.',
        'color': const Color(0xFFFF9500),
      },
      {
        'id': 3,
        'name': 'Zona Norte',
        'dominance': 45,
        'status': 'contested',
        'runs': 3,
        'distance': 12.5,
        'lastRun': '3 días',
        'rivalActivity': 55,
        'rivalName': 'María R.',
        'color': const Color(0xFFFF9500),
      },
      {
        'id': 4,
        'name': 'Avenida Principal',
        'dominance': 0,
        'status': 'unclaimed',
        'runs': 0,
        'distance': 0.0,
        'color': const Color(0xFF9CA3AF),
      },
      {
        'id': 5,
        'name': 'Zona Industrial',
        'dominance': 0,
        'status': 'rival',
        'runs': 0,
        'distance': 0.0,
        'rivalName': 'Pedro L.',
        'rivalDominance': 78,
        'color': const Color(0xFFFF3B30),
      },
      {
        'id': 6,
        'name': 'Barrio Residencial',
        'dominance': 92,
        'status': 'owned',
        'runs': 2,
        'distance': 8.4,
        'lastRun': '5 horas',
        'rivalActivity': 0,
        'color': const Color(0xFF4CD964),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Todos los territorios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        ...territories.map(
          (territory) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTerritoryItem(territory),
          ),
        ),
      ],
    );
  }

  Widget _buildTerritoryItem(Map<String, dynamic> territory) {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mini Map Preview
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E5E5),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 1,
                      crossAxisSpacing: 1,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          color: (territory['color'] as Color).withValues(
                            alpha: 0.4,
                          ),
                        ),
                        Container(
                          color: (territory['color'] as Color).withValues(
                            alpha: territory['dominance'] > 50 ? 0.4 : 0.1,
                          ),
                        ),
                        Container(
                          color: (territory['color'] as Color).withValues(
                            alpha: territory['dominance'] > 70 ? 0.4 : 0.1,
                          ),
                        ),
                        Container(
                          color: (territory['color'] as Color).withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        territory['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusBadge(territory),
                      const SizedBox(height: 8),
                      _buildTerritoryStats(territory),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6B6B6B),
                  size: 20,
                ),
              ],
            ),
            if (territory['dominance'] > 0) ...[
              const SizedBox(height: 16),
              _buildDominanceProgress(territory),
            ],
            if (territory['status'] == 'unclaimed') ...[
              const SizedBox(height: 12),
              _buildActionButton(
                'Intentar conquistar',
                const Color(0xFFC94070),
                () => {},
              ),
            ],
            if (territory['status'] == 'rival') ...[
              const SizedBox(height: 12),
              _buildActionButton(
                'Robar territorio',
                const Color(0xFFFF3B30),
                () => {},
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> territory) {
    final status = territory['status'] as String;
    Color bgColor, textColor;
    IconData icon;
    String label;

    switch (status) {
      case 'owned':
        bgColor = const Color(0xFF4CD964).withValues(alpha: 0.1);
        textColor = const Color(0xFF4CD964);
        icon = Icons.emoji_events;
        label = 'Dominado por ti';
        break;
      case 'contested':
        bgColor = const Color(0xFFFF9500).withValues(alpha: 0.1);
        textColor = const Color(0xFFFF9500);
        icon = Icons.gavel;
        label = 'En disputa';
        break;
      case 'unclaimed':
        bgColor = const Color(0xFFE5E5E5);
        textColor = const Color(0xFF6B6B6B);
        icon = Icons.location_on;
        label = 'Sin dueño';
        break;
      default: // rival
        bgColor = const Color(0xFFFF3B30).withValues(alpha: 0.1);
        textColor = const Color(0xFFFF3B30);
        icon = Icons.people;
        label = 'Dominado por ${territory['rivalName']}';
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerritoryStats(Map<String, dynamic> territory) {
    final status = territory['status'] as String;

    if (status == 'unclaimed') {
      return const SizedBox.shrink();
    }

    if (status == 'rival') {
      return Text(
        'Control rival: ${territory['rivalDominance']}%',
        style: const TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${territory['runs']} carreras • ${territory['distance']} km',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
        ),
        if (territory['lastRun'] != null) ...[
          const SizedBox(height: 4),
          Text(
            'Última carrera: hace ${territory['lastRun']}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
          ),
        ],
      ],
    );
  }

  Widget _buildDominanceProgress(Map<String, dynamic> territory) {
    final dominance = territory['dominance'] as int;
    final status = territory['status'] as String;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tu control',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
            ),
            Text(
              '$dominance%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: dominance / 100,
            minHeight: 8,
            backgroundColor: const Color(0xFFFDF5F7),
            valueColor: AlwaysStoppedAnimation<Color>(
              status == 'owned'
                  ? const Color(0xFF4CD964)
                  : const Color(0xFFFF9500),
            ),
          ),
        ),
        if (territory['rivalActivity'] != null &&
            territory['rivalActivity'] > 0) ...[
          const SizedBox(height: 8),
          Text(
            '⚠️ ${territory['rivalName']} tiene ${territory['rivalActivity']}% aquí',
            style: const TextStyle(fontSize: 11, color: Color(0xFFFF3B30)),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
