import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    // Mock data for the event
    final event = {
      'name': eventId == '1' ? 'Carrera Nocturna 10K' : 'Trail de la Montaña',
      'date': eventId == '1' ? '15 Mar 2024' : '22 Mar 2024',
      'time': eventId == '1' ? '19:00' : '07:00',
      'description': eventId == '1' 
          ? 'Una experiencia única recorriendo las calles más emblemáticas de la ciudad bajo las estrellas. El recorrido incluye hidratación, kit de corredor y medalla conmemorativa.'
          : 'Descubre la naturaleza en su estado más puro. Este trail te llevará por senderos técnicos, bosques frondosos y vistas espectaculares de la cordillera.',
      'participants': eventId == '1' ? 156 : 89,
      'image': eventId == '1' 
          ? 'https://images.unsplash.com/photo-1541252260730-0412e3e2104e?q=80&w=1000'
          : 'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=1000',
      'route': eventId == '1' ? 'Centro Histórico - Paseo de la Reforma' : 'Reserva Natural El Bosque',
      'distance': eventId == '1' ? '10 km' : '15 km',
      'color': const Color(0xFFE8698A),
    };

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, event),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainInfo(event),
                  const SizedBox(height: 32),
                  _buildDescription(event),
                  const SizedBox(height: 32),
                  _buildRouteSection(event),
                  const SizedBox(height: 32),
                  _buildParticipantsSection(event),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildJoinButton(event),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Map<String, dynamic> event) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A0A0A), size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              event['image'] as String,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfo(Map<String, dynamic> event) {
    final color = event['color'] as Color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Text(
                'Evento Oficial',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            Icon(Icons.share_rounded, color: const Color(0xFF0A0A0A).withValues(alpha: 0.3), size: 20),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          event['name'] as String,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0A0A0A),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildInfoChip(Icons.calendar_today_rounded, event['date'] as String),
            const SizedBox(width: 12),
            _buildInfoChip(Icons.access_time_rounded, event['time'] as String),
            const SizedBox(width: 12),
            _buildInfoChip(Icons.straighten_rounded, event['distance'] as String),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0A0A0A).withValues(alpha: 0.4)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFF0A0A0A).withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(Map<String, dynamic> event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          event['description'] as String,
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF0A0A0A).withValues(alpha: 0.6),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteSection(Map<String, dynamic> event) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0A0A0A).withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, color: Color(0xFFE8698A), size: 24),
              const SizedBox(width: 12),
              const Text(
                'Ruta sugerida',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event['route'] as String,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0A0A0A).withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120,
              width: double.infinity,
              color: const Color(0xFFF5F5F5),
              child: const Center(
                child: Icon(Icons.route_rounded, size: 40, color: Color(0xFFCBD5E0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(Map<String, dynamic> event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Participantes (${event['participants']})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Ver todos',
              style: TextStyle(
                color: const Color(0xFFE8698A).withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFFFF0F4),
                child: Icon(Icons.person_rounded, size: 18, color: const Color(0xFFE8698A).withValues(alpha: 0.7)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton(Map<String, dynamic> event) {
    final color = event['color'] as Color;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8698A),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text(
          'Unirse al evento',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
