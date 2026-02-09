import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  void _onNavigate(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final navItems = [
      {'id': 'home', 'label': 'Inicio', 'icon': Icons.home},
      {'id': 'community', 'label': 'Comunidad', 'icon': Icons.people},
      {'id': 'territories', 'label': 'Territorios', 'icon': Icons.location_on},
      {'id': 'challenges', 'label': 'Retos', 'icon': Icons.emoji_events},
      {'id': 'profile', 'label': 'Perfil', 'icon': Icons.person},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: const Color(0xFFF4F6FA), width: 1),
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
          children: List.generate(navItems.length, (index) {
            final item = navItems[index];
            final label = item['label'] as String;
            final icon = item['icon'] as IconData;
            final isActive = navigationShell.currentIndex == index;

            return Expanded(
              child: _buildNavItem(
                context: context,
                index: index,
                label: label,
                icon: icon,
                isActive: isActive,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => _onNavigate(context, index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF1E5BFF).withValues(alpha: 0.1)
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
                  ? const Color(0xFF1E5BFF)
                  : const Color(0xFF6B6B6B),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? const Color(0xFF1E5BFF)
                    : const Color(0xFF6B6B6B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
