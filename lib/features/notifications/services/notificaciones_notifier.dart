import 'package:flutter/foundation.dart';
import 'package:runn_front/features/notifications/services/notificaciones_service.dart';

/// Singleton notifier to keep track of unread notifications count across the app.
class NotificacionesNotifier extends ValueNotifier<int> {
  // Singleton instance
  static final NotificacionesNotifier _instance = NotificacionesNotifier._internal();

  factory NotificacionesNotifier() {
    return _instance;
  }

  // Use this to access the singleton easily
  static NotificacionesNotifier get instance => _instance;

  NotificacionesNotifier._internal() : super(0);

  bool _isFetching = false;

  /// Fetches the current unread count from the backend and updates the notifier value.
  Future<void> fetchUnreadCount() async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final res = await NotificacionesService.getNotificaciones();
      value = res.noLeidas;
    } catch (e) {
      debugPrint('Error fetching notification count: $e');
    } finally {
      _isFetching = false;
    }
  }

  /// Manually set the unread count (e.g. when opening notifications list)
  void markAllAsReadLocally() {
    value = 0;
  }
}
