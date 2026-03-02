import 'package:flutter/material.dart';

class BottomNavWidget extends StatelessWidget {
  final String activeScreen;
  final Function(String) onNavigate;

  const BottomNavWidget({
    super.key,
    required this.activeScreen,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'id': 'home', 'label': 'Inicio', 'icon': Icons.home},
      {'id': 'territories', 'label': 'Territorios', 'icon': Icons.location_on},
      {'id': 'community', 'label': 'Comunidad', 'icon': Icons.people},
      {'id': 'challenges', 'label': 'Retos', 'icon': Icons.emoji_events},
      {'id': 'profile', 'label': 'Perfil', 'icon': Icons.person},
    ];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(color: const Color(0xFFFDF5F7), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) {
              final id = item['id'] as String;
              final label = item['label'] as String;
              final icon = item['icon'] as IconData;
              final isActive = activeScreen == id;

              return Expanded(
                child: _buildNavItem(
                  id: id,
                  label: label,
                  icon: icon,
                  isActive: isActive,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String id,
    required String label,
    required IconData icon,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => onNavigate(id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFC94070).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? const Color(0xFFC94070)
                  : const Color(0xFF6B6B6B),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? const Color(0xFFC94070)
                    : const Color(0xFF6B6B6B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
