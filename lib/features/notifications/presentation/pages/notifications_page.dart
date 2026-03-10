import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      type: _NotifType.achievement,
      title: '¡Nuevo logro desbloqueado!',
      body: 'Completaste 10 carreras este mes. ¡Eres imparable!',
      time: 'Hace 5 min',
      isRead: false,
    ),
    _NotificationItem(
      type: _NotifType.social,
      title: 'Carlos te sigue ahora',
      body: 'Carlos Mendoza comenzó a seguirte en Runn.',
      time: 'Hace 23 min',
      isRead: false,
    ),
    _NotificationItem(
      type: _NotifType.challenge,
      title: 'Reto por vencer',
      body: 'Te quedan 2 días para completar el reto "10K en semana".',
      time: 'Hace 1 hora',
      isRead: false,
    ),
    _NotificationItem(
      type: _NotifType.run,
      title: 'Resumen semanal listo',
      body: 'Esta semana corriste 24.3 km. Tu mejor semana hasta ahora.',
      time: 'Hace 3 horas',
      isRead: true,
    ),
    _NotificationItem(
      type: _NotifType.social,
      title: 'Ana comentó tu carrera',
      body: '"¡Qué ritmo tan increíble! Inspirador 🔥"',
      time: 'Ayer, 20:14',
      isRead: true,
    ),
    _NotificationItem(
      type: _NotifType.achievement,
      title: 'Racha de 7 días',
      body: 'Llevas 7 días consecutivos corriendo. ¡No pares!',
      time: 'Ayer, 08:00',
      isRead: true,
    ),
    _NotificationItem(
      type: _NotifType.challenge,
      title: 'Nuevo reto disponible',
      body: 'El reto "Maratón mensual" ya está abierto. ¿Te apuntas?',
      time: 'Lun, 10:30',
      isRead: true,
    ),
    _NotificationItem(
      type: _NotifType.run,
      title: 'Récord personal batido',
      body: 'Corriste 5K en 24:10. ¡Tu mejor tiempo hasta ahora!',
      time: 'Dom, 07:45',
      isRead: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _dismissNotification(int index) {
    setState(() => _notifications.removeAt(index));
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                color: context.colors.card,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.colors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notificaciones',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        if (_unreadCount > 0)
                          Text(
                            '$_unreadCount sin leer',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.colors.primaryDeep,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllRead,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primaryLight,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: context.colors.primaryMid,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Leer todo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: context.colors.primaryDeep,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Unread badge strip ───────────────────────────────────────
            if (_unreadCount > 0)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primaryDeep.withValues(alpha: 0.15),
                      context.colors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: context.colors.primaryMid.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.colors.primaryDeep,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tienes $_unreadCount notificaciones nuevas desde tu última visita.',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── List ─────────────────────────────────────────────────────
            Expanded(
              child: _notifications.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: _unreadCount > 0 ? 0 : 16,
                        bottom: 32,
                      ),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotifCard(index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifCard(int index) {
    final notif = _notifications[index];

    return Dismissible(
      key: Key('notif_$index${notif.title}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _dismissNotification(index),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.colors.primaryDeep.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(
          Icons.delete_outline_rounded,
          color: context.colors.primaryDeep,
          size: 24,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() => notif.isRead = true);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notif.isRead
                ? context.colors.card
                : context.colors.primaryLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notif.isRead
                  ? Colors.transparent
                  : context.colors.primaryMid.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: notif.isRead
                    ? Colors.black.withValues(alpha: 0.04)
                    : context.colors.primary.withValues(alpha: 0.1),
                blurRadius: notif.isRead ? 8 : 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _iconBg(notif.type, notif.isRead),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconData(notif.type),
                  color: _iconColor(notif.type),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notif.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colors.primaryDeep,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: notif.isRead
                            ? context.colors.textHint
                            : context.colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: context.colors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notif.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textHint,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _tagBg(notif.type),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            _tagLabel(notif.type),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _iconColor(notif.type),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: context.colors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.primaryMid, width: 2),
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 40,
              color: context.colors.primaryDark,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando tengas actividad nueva\naparecerá aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  IconData _iconData(_NotifType type) {
    switch (type) {
      case _NotifType.achievement:
        return Icons.emoji_events_rounded;
      case _NotifType.social:
        return Icons.person_add_rounded;
      case _NotifType.challenge:
        return Icons.flag_rounded;
      case _NotifType.run:
        return Icons.directions_run_rounded;
    }
  }

  Color _iconColor(_NotifType type) {
    switch (type) {
      case _NotifType.achievement:
        return context.colors.primaryDeep;
      case _NotifType.social:
        return context.colors.primaryDark;
      case _NotifType.challenge:
        return const Color(0xFFB05070);
      case _NotifType.run:
        return context.colors.primaryMid;
    }
  }

  Color _iconBg(_NotifType type, bool isRead) {
    final base = _iconColor(type);
    return base.withValues(alpha: isRead ? 0.08 : 0.18);
  }

  Color _tagBg(_NotifType type) => _iconColor(type).withValues(alpha: 0.12);

  String _tagLabel(_NotifType type) {
    switch (type) {
      case _NotifType.achievement:
        return 'Logro';
      case _NotifType.social:
        return 'Social';
      case _NotifType.challenge:
        return 'Reto';
      case _NotifType.run:
        return 'Carrera';
    }
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

enum _NotifType { achievement, social, challenge, run }

class _NotificationItem {
  final _NotifType type;
  final String title;
  final String body;
  final String time;
  bool isRead;

  _NotificationItem({
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}
