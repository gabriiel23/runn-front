import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class TerritoryData {
  final int id;
  final String name;
  final String status; // owned | contested | rival | unclaimed
  final int dominance;
  final int runs;
  final double distance;
  final String ownerName;
  final String imageUrl;
  final int threatLevel;
  final List<Map<String, String>> history;

  const TerritoryData({
    required this.id,
    required this.name,
    required this.status,
    required this.dominance,
    required this.runs,
    required this.distance,
    required this.ownerName,
    required this.imageUrl,
    required this.threatLevel,
    required this.history,
  });

  bool get isOwned => status == 'owned';
  bool get isContested => status == 'contested';
  bool get isRival => status == 'rival';

  String get statusLabel {
    switch (status) {
      case 'owned':
        return 'Mio';
      case 'contested':
        return 'En disputa';
      case 'rival':
        return 'Perdido';
      default:
        return 'Libre';
    }
  }

  String get detailStatusLabel {
    switch (status) {
      case 'owned':
        return 'ASEGURADO';
      case 'contested':
        return 'EN DISPUTA';
      case 'rival':
        return 'PERDIDO';
      default:
        return 'LIBRE';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'owned':
        return const Color(0xFFE59CBF); // Mio = rosa
      case 'contested':
        return const Color(0xFF8CBBF2); // En disputa = celeste
      case 'rival':
        return const Color(0xFF98A1AF); // Perdido = gris
      default:
        return const Color(0xFFD2D8E2); // Libre = gris claro
    }
  }
}

const _territories = [
  TerritoryData(
    id: 1,
    name: 'Parque de Mexico',
    status: 'contested',
    dominance: 65,
    runs: 12,
    distance: 5.2,
    ownerName: 'FastRunner 99',
    imageUrl:
        'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=1200&q=80',
    threatLevel: 3,
    history: [
      {
        'runner': 'Elena Runner',
        'time': 'Hace 15m',
        'km': '5.2km',
        'team': 'ROSA',
        'avatar':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      },
      {
        'runner': 'Marco Polo',
        'time': 'Hace 2h',
        'km': '8.1km',
        'team': 'AZUL',
        'avatar':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      },
    ],
  ),
  TerritoryData(
    id: 2,
    name: 'Corredor Reforma',
    status: 'contested',
    dominance: 42,
    runs: 8,
    distance: 4.4,
    ownerName: '@BlueStreak',
    imageUrl:
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1200&q=80',
    threatLevel: 2,
    history: [
      {
        'runner': 'Sofia',
        'time': 'Hace 40m',
        'km': '4.3km',
        'team': 'ROSA',
        'avatar':
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      },
      {
        'runner': 'Jorge',
        'time': 'Hace 4h',
        'km': '3.6km',
        'team': 'AZUL',
        'avatar':
            'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?auto=format&fit=crop&w=200&q=80',
      },
    ],
  ),
  TerritoryData(
    id: 3,
    name: 'Plaza de la Paz',
    status: 'unclaimed',
    dominance: 0,
    runs: 0,
    distance: 0,
    ownerName: 'Sin dueno',
    imageUrl:
        'https://images.unsplash.com/photo-1470770903676-69b98201ea1c?auto=format&fit=crop&w=1200&q=80',
    threatLevel: 1,
    history: [],
  ),
  TerritoryData(
    id: 4,
    name: 'Centro Historico',
    status: 'owned',
    dominance: 84,
    runs: 15,
    distance: 24.5,
    ownerName: 'Tu control',
    imageUrl:
        'https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1200&q=80',
    threatLevel: 1,
    history: [
      {
        'runner': 'Tu equipo',
        'time': 'Hace 1h',
        'km': '7.8km',
        'team': 'ROSA',
        'avatar':
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80',
      },
      {
        'runner': 'Carlos',
        'time': 'Hace 3h',
        'km': '6.1km',
        'team': 'AZUL',
        'avatar':
            'https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?auto=format&fit=crop&w=200&q=80',
      },
    ],
  ),
  TerritoryData(
    id: 5,
    name: 'Zona Norte',
    status: 'rival',
    dominance: 18,
    runs: 3,
    distance: 2.2,
    ownerName: 'Rival Azul',
    imageUrl:
        'https://images.unsplash.com/photo-1473773508845-188df298d2d1?auto=format&fit=crop&w=1200&q=80',
    threatLevel: 3,
    history: [
      {
        'runner': 'Rival Azul',
        'time': 'Hace 2h',
        'km': '4.4km',
        'team': 'AZUL',
        'avatar':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      },
    ],
  ),
];

// Grid small preview for map screen.
const _mapPreviewGrid = [
  [4, 4, 4, 1, 1],
  [4, 4, 1, 1, 0],
  [4, 1, 1, 2, 0],
  [0, 1, 2, 5, 0],
];

class TerritoriesScreen extends StatefulWidget {
  const TerritoriesScreen({super.key});

  @override
  State<TerritoriesScreen> createState() => _TerritoriesScreenState();
}

class _TerritoriesScreenState extends State<TerritoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TerritoryData _selected = _territories.first;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openDetail(TerritoryData territory) {
    setState(() => _selected = territory);
    _tabController.animateTo(2);
  }

  void _backToList() {
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController.index == 2) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        body: SafeArea(
          child: _TerritoryDetailView(
            territory: _selected,
            onBack: _backToList,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  _HeaderCircleIcon(icon: Icons.apps_rounded),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Territorios',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF20283A),
                        ),
                      ),
                    ),
                  ),
                  _HeaderCircleIcon(icon: Icons.tune_rounded),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF1F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  labelColor: const Color(0xFF2566B2),
                  unselectedLabelColor: const Color(0xFF768099),
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                  tabs: const [
                    Tab(text: 'Mapa de territorios'),
                    Tab(text: 'Mis territorios'),
                    Tab(text: 'Detalle'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TerritoryMapTab(onOpenDetail: _openDetail),
                  _MyTerritoriesTab(onOpenDetail: _openDetail),
                  const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCircleIcon extends StatelessWidget {
  final IconData icon;
  const _HeaderCircleIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F5),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF4B5568)),
    );
  }
}

class _TerritoryMapTab extends StatefulWidget {
  final void Function(TerritoryData) onOpenDetail;
  const _TerritoryMapTab({required this.onOpenDetail});

  @override
  State<_TerritoryMapTab> createState() => _TerritoryMapTabState();
}

class _TerritoryMapTabState extends State<_TerritoryMapTab> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TerritoryData> get _results {
    final q = _query.trim().toLowerCase();
    final base = _territories.where((t) => t.status != 'unclaimed').toList();
    if (q.isEmpty) {
      return base.where((t) => t.isContested || t.isRival).toList();
    }
    return base.where((t) {
      final byName = t.name.toLowerCase().contains(q);
      final byOwner = t.ownerName.toLowerCase().contains(q);
      final byRunner = t.history.any(
        (h) => (h['runner'] ?? '').toLowerCase().contains(q),
      );
      return byName || byOwner || byRunner;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final searching = _query.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF1F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF8A93A9)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF283249),
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Buscar zona o corredor',
                      hintStyle: TextStyle(
                        color: Color(0xFF8A93A9),
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF8A93A9),
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4DAE4),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                const SizedBox(height: 6),
                const _TerritoryGridMap(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _LegendDot(label: 'MIO', color: Color(0xFFE59CBF)),
                    SizedBox(width: 12),
                    _LegendDot(label: 'EN DISPUTA', color: Color(0xFF8CBBF2)),
                    SizedBox(width: 12),
                    _LegendDot(label: 'PERDIDO', color: Color(0xFF98A1AF)),
                    SizedBox(width: 12),
                    _LegendDot(label: 'LIBRE', color: Color(0xFFD2D8E2)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            searching ? 'Resultados' : 'Territorios en disputa',
            style: const TextStyle(
              fontSize: 35,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E273A),
            ),
          ),
          Text(
            searching
                ? 'Coincidencias por zona, dueno o corredor'
                : 'Duelos activos cerca de ti',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF1E273A).withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          if (results.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'No se encontraron zonas.',
                style: TextStyle(
                  color: Color(0xFF717B91),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ...results.map(
            (territory) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DisputeCard(
                territory: territory,
                onOpenDetail: () => widget.onOpenDetail(territory),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TerritoryGridMap extends StatelessWidget {
  const _TerritoryGridMap();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: List.generate(_mapPreviewGrid.length, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: row == _mapPreviewGrid.length - 1 ? 0 : 5),
              child: Row(
                children: List.generate(_mapPreviewGrid[row].length, (col) {
                  final id = _mapPreviewGrid[row][col];
                  final territory = id == 0
                      ? null
                      : _territories.firstWhere((t) => t.id == id);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: col == _mapPreviewGrid[row].length - 1 ? 0 : 5,
                      ),
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          color: territory?.statusColor ?? const Color(0xFFD2D8E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
        const Positioned(
          top: -2,
          left: 86,
          child: _MapPinBadge(
            icon: Icons.local_fire_department_outlined,
            text: 'Zona Caliente',
            color: Color(0xFFE59CBF),
          ),
        ),
        const Positioned(
          top: -2,
          left: 172,
          child: _MapPinBadge(
            icon: Icons.bolt_rounded,
            text: 'Actividad Alta',
            color: Color(0xFF8CBBF2),
          ),
        ),
      ],
    );
  }
}

class _MapPinBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MapPinBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.4),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF2A3247),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF55607A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final TerritoryData territory;
  final VoidCallback onOpenDetail;

  const _DisputeCard({required this.territory, required this.onOpenDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  territory.name,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Color(0xFF1C2438),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'RESISTENCIA : ${territory.dominance}%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF4A86D3),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Dueno actual: ${territory.ownerName}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6E7890),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: territory.dominance / 100,
              minHeight: 4,
              backgroundColor: const Color(0xFFE8EDF4),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE59CBF)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.circle, size: 7, color: Color(0xFFE59CBF)),
              const SizedBox(width: 6),
              Text(
                territory.isRival ? 'Zona perdida' : 'Duelo en vivo',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF75809A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onOpenDetail,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF327FE8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Ver detalles',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyTerritoriesTab extends StatelessWidget {
  final void Function(TerritoryData) onOpenDetail;
  const _MyTerritoriesTab({required this.onOpenDetail});

  @override
  Widget build(BuildContext context) {
    final territories =
        _territories.where((t) => t.isOwned || t.isContested).toList();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
      itemBuilder: (_, index) {
        final territory = territories[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  territory.imageUrl,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      territory.statusLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: territory.statusColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      territory.name,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1C2438),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Batalla activa ${territory.runs} corredores',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6E7890),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => onOpenDetail(territory),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF327FE8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Ver detalles',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: territories.length,
    );
  }
}

class _TerritoryDetailView extends StatelessWidget {
  final TerritoryData territory;
  final VoidCallback onBack;

  const _TerritoryDetailView({
    required this.territory,
    required this.onBack,
  });

  Future<void> _shareTerritory() async {
    final shareText =
        'Territorio: ${territory.name}\n'
        'Estado: ${territory.detailStatusLabel}\n'
        'Control: ${territory.dominance}%\n'
        'Dueno actual: ${territory.ownerName}\n'
        'Actividad reciente: ${territory.runs} corredores activos.';
    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: 'Estado de territorio: ${territory.name}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rivalControl = (100 - territory.dominance).clamp(0, 100);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderActionButton(
                icon: Icons.chevron_left_rounded,
                onTap: onBack,
              ),
              Expanded(
                child: Text(
                  territory.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF111C31),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _HeaderActionButton(
                icon: Icons.share_outlined,
                onTap: _shareTerritory,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 230,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(territory.imageUrl, fit: BoxFit.cover),
                  Positioned(
                    left: 14,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Color(0xFF5C667D)),
                          SizedBox(width: 4),
                          Text(
                            'CDMX, Mexico',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF5C667D),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTADO DE LA ZONA',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7D869A),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      territory.detailStatusLabel,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF13203A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${territory.dominance}',
                      style: const TextStyle(
                        fontSize: 36,
                        color: Color(0xFF13203A),
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    Text(
                      ' vs $rivalControl',
                      style: const TextStyle(
                        fontSize: 19,
                        color: Color(0xFF7A8399),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: territory.dominance / 100,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFC1D8F4),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE59CBF)),
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Color(0xFFE59CBF)),
                    SizedBox(width: 4),
                    Text(
                      'TU CONTROL',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF68738D),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'RIVAL',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF68738D),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.circle, size: 8, color: Color(0xFF8CBBF2)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MetricBubble(
                icon: Icons.timer_outlined,
                label: 'RECORD',
                value: '04:22',
              ),
              const SizedBox(width: 8),
              _MetricBubble(
                icon: Icons.directions_run_rounded,
                label: 'ACTIVOS',
                value: '${territory.runs}',
              ),
              const SizedBox(width: 8),
              _MetricBubble(
                icon: Icons.flag_rounded,
                label: 'AMENAZA',
                value: territory.threatLevel >= 3 ? 'ALTA' : 'MEDIA',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Actividad',
                style: TextStyle(
                  fontSize: 41,
                  color: Color(0xFF111C31),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.9,
                ),
              ),
              const Spacer(),
              Text(
                '24 HORAS',
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFF111C31).withValues(alpha: 0.5),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...territory.history.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 21,
                      backgroundImage: NetworkImage(entry['avatar'] ?? ''),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry['runner'] ?? '-',
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color(0xFF111C31),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${entry['km'] ?? ''}  •  ${entry['time'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF68738D),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: (entry['team'] == 'ROSA')
                            ? const Color(0xFFF8E7EF)
                            : const Color(0xFFEAF2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry['team'] ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: (entry['team'] == 'ROSA')
                              ? const Color(0xFFC46F9A)
                              : const Color(0xFF4B85CF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFE90084),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.bolt_rounded, size: 20),
              label: Text(
                territory.isOwned ? '¡A DEFENDER!' : '¡IR A RECONQUISTAR!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF1F5),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Icon(icon, color: const Color(0xFF4C576C), size: 22),
      ),
    );
  }
}

class _MetricBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricBubble({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8EDF4)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 17, color: const Color(0xFF327FE8)),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF7A8399),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF111C31),
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
