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
      {'label': 'Inicio', 'icon': Icons.home_rounded},
      {'label': 'Comunidad', 'icon': Icons.people_rounded},
      {'label': 'Territorios', 'icon': Icons.location_on_rounded},
      {'label': 'Retos', 'icon': Icons.emoji_events_rounded},
      {'label': 'Perfil', 'icon': Icons.person_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final label = item['label'] as String;
              final icon = item['icon'] as IconData;
              final isActive = navigationShell.currentIndex == index;

              return _buildNavItem(
                context: context,
                index: index,
                label: label,
                icon: icon,
                isActive: isActive,
              );
            }),
          ),
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
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF1E5BFF).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? const Color(0xFF1E5BFF)
                  : const Color(0xFF6B6B6B),
            ),
            if (isActive) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E5BFF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
