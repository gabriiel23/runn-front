import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class HeaderCircleIcon extends StatelessWidget {
  final IconData icon;
  const HeaderCircleIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(icon, size: 18, color: context.colors.textSecondary),
    );
  }
}
