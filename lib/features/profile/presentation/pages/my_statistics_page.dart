import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/profile/domain/models/user_statistics.dart';

class MyStatisticsPage extends StatefulWidget {
  const MyStatisticsPage({super.key});

  @override
  State<MyStatisticsPage> createState() => _MyStatisticsPageState();
}

class _MyStatisticsPageState extends State<MyStatisticsPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // 0: Semana, 1: Mes, 2: Año
  bool _isLoading = true;
  UserStatistics? _statistics;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    setState(() => _isLoading = true);
    
    // Simulación de llamada al backend
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _statistics = UserStatistics.mock; // Usamos el mock del modelo
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'Mis estadísticas',
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8698A)))
        : _statistics == null
          ? _buildErrorView()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 32),
                    _buildStatsSummary(),
                    const SizedBox(height: 32),
                    _buildChartSection(context, 'Kilómetros recorridos', 'Km', _buildKmChart(context)),
                    SizedBox(height: 32),
                    _buildChartSection(context, 'Velocidad promedio', 'km/h', _buildSpeedChart(context)),
                    SizedBox(height: 32),
                    _buildChartSection(context, 'Ritmo promedio', 'min/km', _buildPaceChart(context)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorView() {
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 60, color: c.textHint),
          SizedBox(height: 16),
          Text('Error al cargar estadísticas', style: TextStyle(color: c.textPrimary)),
          TextButton(onPressed: _fetchStatistics, child: Text('Reintentar', style: TextStyle(color: c.primary))),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: c.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildPeriodButton(0, 'Semana'),
          _buildPeriodButton(1, 'Mes'),
          _buildPeriodButton(2, 'Año'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(int index, String label) {
    final c = context.colors;
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedIndex = index);
          _fetchStatistics(); // Simulamos recarga al cambiar periodo
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? c.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? c.surface : c.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(context, 'Total dist.', _statistics!.totalDistance, Icons.straighten_rounded),
          _buildSummaryItem(context, 'Promedio', _statistics!.averageDistance, Icons.analytics_rounded),
          _buildSummaryItem(context, 'Objetivo', _statistics!.distanceGoal, Icons.flag_rounded),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon) {
    final c = context.colors;
    return Column(
      children: [
        Icon(icon, color: c.primary.withValues(alpha: 0.6), size: 20),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: c.textPrimary.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context, String title, String unit, Widget chart) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                unit,
                style: TextStyle(
                  color: c.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: c.primary.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(16, 24, 24, 16),
          child: chart,
        ),
      ],
    );
  }

  Widget _buildKmChart(BuildContext context) {
    final points = _statistics!.kmPoints;
    final c = context.colors;
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= points.length) return Text('');
                return Text(
                  points[value.toInt()].label,
                  style: TextStyle(
                    color: c.textPrimary.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
              reservedSize: 22,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
            isCurved: true,
            color: c.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: c.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedChart(BuildContext context) {
    final points = _statistics!.speedPoints;
    final c = context.colors;
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= points.length) return Text('');
                return Text(
                  points[value.toInt()].label,
                  style: TextStyle(
                    color: c.textPrimary.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: points.asMap().entries.map((e) => _makeBarGroup(context, e.key, e.value.value)).toList(),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(BuildContext context, int x, double y) {
    final c = context.colors;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: c.primary,
          width: 14,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 15,
            color: c.primaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildPaceChart(BuildContext context) {
    final points = _statistics!.pacePoints;
    final c = context.colors;
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= points.length) return Text('');
                return Text(
                  points[value.toInt()].label,
                  style: TextStyle(
                    color: c.textPrimary.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
            isCurved: false,
            color: c.primaryDeep,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
