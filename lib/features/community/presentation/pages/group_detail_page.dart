import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class GroupDetailPage extends StatelessWidget {
  final Map<String, dynamic>? groupData;
  // Fallback data in case someone navigates directly without passing the extra object
  const GroupDetailPage({super.key, this.groupData});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // Use passed data or some fallback mockup
    final String name = groupData?['name'] ?? 'Detalle del Grupo';
    final int members = groupData?['members'] ?? 0;
    final String location = groupData?['location'] ?? 'Ubicación Desconocida';
    final String level = groupData?['level'] ?? 'Nivel';
    final Color color = groupData?['color'] ?? c.primaryDeep;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: c.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildGroupHeader(context, c, name, members, location, level, color),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Sobre el grupo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Este grupo está enfocado en compartir rutas, entrenamientos y experiencias en $location. Ideal para corredores de nivel $level que buscan mantener un ritmo constante y mejorar sus tiempos en equipo.',
                    style: TextStyle(
                      fontSize: 14,
                      color: c.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildStatsRow(c),
                  const SizedBox(height: 32),
                  _buildMultimediaGallery(context, c, name),
                  const SizedBox(height: 32),
                  Text(
                    'Próximas actividades',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityCard(c, color, 'Carrera Dominical', 'Dom, 12 Mar • 07:00 AM', 15),
                  const SizedBox(height: 12),
                  _buildActivityCard(c, color, 'Entrenamiento en cuestas', 'Mié, 15 Mar • 06:00 PM', 5),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Unirse al grupo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildGroupHeader(BuildContext context, dynamic c, String name, int members, String location, String level, Color color) {
    return Container(
      width: double.infinity,
      color: c.card,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
            ),
            child: Icon(
              Icons.groups_rounded,
              color: color.withValues(alpha: 0.8),
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_rounded, color: c.textHint, size: 16),
              const SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(color: c.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Container(width: 4, height: 4, decoration: BoxDecoration(color: c.textHint, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Text(
                level,
                style: TextStyle(color: c.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: c.bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_alt_rounded, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$members miembros',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildActionButtonsRow(context, c, color, name, level, location),
        ],
      ),
    );
  }

  Widget _buildActionButtonsRow(BuildContext context, dynamic c, Color themeColor, String name, String level, String location) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(c, Icons.person_add_alt_1_rounded, 'Invitar', themeColor, () => _showInviteSheet(context, c, themeColor)),
        _buildActionButton(c, Icons.share_rounded, 'Compartir', themeColor, () => _copyShareLink(context, c, name)),
        _buildActionButton(c, Icons.info_outline_rounded, 'Resumen', themeColor, () => _showSummaryDialog(context, c, name, level, location)),
        _buildActionButton(c, Icons.calendar_today_rounded, 'Eventos', themeColor, () => _showEventsSheet(context, c, themeColor)),
      ],
    );
  }

  Widget _buildActionButton(dynamic c, IconData icon, String label, Color themeColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: c.bg,
              shape: BoxShape.circle,
              border: Border.all(color: c.primaryDeepWithAlpha(0.1)),
            ),
            child: Icon(icon, color: c.textPrimary, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: c.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteSheet(BuildContext context, dynamic c, Color themeColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: c.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(bottom: BorderSide(color: c.primaryDeepWithAlpha(0.1))),
                ),
                child: Text('Invitar corredores', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary, letterSpacing: -0.5)),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildInviteUserTile(c, 'Carlos Ruiz', 'Corredor Experto', themeColor),
                    _buildInviteUserTile(c, 'Ana López', 'Principiante', themeColor),
                    _buildInviteUserTile(c, 'Miguel Torres', 'Intermedio', themeColor),
                    _buildInviteUserTile(c, 'Elena Rojas', 'Triatleta', themeColor),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInviteUserTile(dynamic c, String userName, String subtitle, Color themeColor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: c.primaryLight,
        child: Icon(Icons.person_rounded, color: c.primaryDeepWithAlpha(0.7)),
      ),
      title: Text(userName, style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)),
      subtitle: Text(subtitle, style: TextStyle(color: c.textSecondary, fontSize: 13)),
      trailing: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor.withValues(alpha: 0.1),
          foregroundColor: themeColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Text('Invitar', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _copyShareLink(BuildContext context, dynamic c, String groupName) {
    Clipboard.setData(ClipboardData(text: 'https://runn.app/groups/${groupName.replaceAll(' ', '').toLowerCase()}')).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: c.bg),
              const SizedBox(width: 12),
              const Text('Enlace copiado al portapapeles'),
            ],
          ),
          backgroundColor: c.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 80),
        ),
      );
    });
  }

  void _showSummaryDialog(BuildContext context, dynamic c, String name, String level, String location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Resumen del Grupo', style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary, letterSpacing: -0.5)),
        content: Text(
          '$name es un grupo ubicado en $location, enfocado en compartir experiencias y mejorar los tiempos. Recomendado para corredores de nivel $level.',
          style: TextStyle(color: c.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: TextStyle(color: c.primaryDeep, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showEventsSheet(BuildContext context, dynamic c, Color themeColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: c.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(bottom: BorderSide(color: c.primaryDeepWithAlpha(0.1))),
                ),
                child: Text('Eventos rápidos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary, letterSpacing: -0.5)),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                  children: [
                    _buildActivityCard(c, themeColor, 'Carrera Dominical', 'Dom, 12 Mar • 07:00 AM', 15),
                    const SizedBox(height: 16),
                    _buildActivityCard(c, themeColor, 'Entrenamiento en cuestas', 'Mié, 15 Mar • 06:00 PM', 5),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(dynamic c) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.directions_run_rounded, color: c.primaryDeep, size: 24),
                const SizedBox(height: 12),
                Text('Actividades', style: TextStyle(color: c.textHint, fontSize: 12)),
                const SizedBox(height: 4),
                Text('142', style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.emoji_events_rounded, color: const Color(0xFFFFB84D), size: 24),
                const SizedBox(height: 12),
                Text('Retos ganados', style: TextStyle(color: c.textHint, fontSize: 12)),
                const SizedBox(height: 4),
                Text('28', style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(dynamic c, Color themeColor, String title, String subtitle, int km) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.event_rounded, color: themeColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: c.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: c.bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$km km',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultimediaGallery(BuildContext context, dynamic c, String name) {
    final mockImages = [
      'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=500&auto=format&fit=crop',
    ];

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Galería del grupo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    'rival_multimedia', 
                    pathParameters: {'userId': 'group123'},
                    extra: {'name': name}, // Pass the group name explicitly
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Ver todo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.primaryDeep,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: c.primaryDeep,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: mockImages.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      mockImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: c.primaryDeepWithAlpha(0.1),
                        child: Icon(Icons.broken_image_rounded, color: c.textHint),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
