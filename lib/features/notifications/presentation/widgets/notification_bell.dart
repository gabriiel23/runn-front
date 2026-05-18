import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/notifications/services/notificaciones_notifier.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    return GestureDetector(
      onTap: () {
        // Set to 0 instantly for immediate UX response
        NotificacionesNotifier.instance.markAllAsReadLocally();
        // Navigate
        context.push('/notifications').then((_) {
          // Re-fetch on return just tracking if there are new ones
          NotificacionesNotifier.instance.fetchUnreadCount();
        });
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: c.primaryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: NotificacionesNotifier.instance,
          builder: (context, unreadCount, child) {
            return Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: c.primaryDeepWithAlpha(0.8),
                    size: 22,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
