import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/features/notifications/services/notificaciones_service.dart';
import 'package:runn_front/features/notifications/domain/models/notificacion_model.dart';
import 'package:runn_front/features/community/presentation/widgets/invitation_action_bottom_sheet.dart';

/// Estados de carga para la pantalla de notificaciones.
enum _LoadState { initial, loading, loaded, error }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<NotificacionModel> _notifications = [];
  int _noLeidas = 0;
  _LoadState _loadState = _LoadState.initial;
  String? _errorMessage;

  int get _unreadCount => _noLeidas;

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
    _cargarNotificaciones();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ─── CARGAR NOTIFICACIONES DEL BACKEND ──────────────────────────────────────

  Future<void> _cargarNotificaciones() async {
    if (!mounted) return;

    setState(() {
      _loadState = _LoadState.loading;
      _errorMessage = null;
    });

    try {
      final response = await NotificacionesService.getNotificaciones();
      if (!mounted) return;

      setState(() {
        _notifications = response.notificaciones;
        _noLeidas = response.noLeidas;
        _loadState = _LoadState.loaded;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _loadState = _LoadState.error;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error inesperado al cargar notificaciones';
        _loadState = _LoadState.error;
      });
    }
  }

  // ─── MARCAR TODAS COMO LEIDAS ──────────────────────────────────────────────

  Future<void> _markAllRead() async {
    // Actualizacion optimista del UI
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(leida: true)).toList();
      _noLeidas = 0;
    });

    try {
      await NotificacionesService.marcarTodasComoLeidas();
      // Recargar para asegurar sincronizacion con backend
      await _cargarNotificaciones();
    } on ApiException catch (e) {
      if (!mounted) return;
      _mostrarErrorSnack(e.message);
      // Revertir en caso de error
      await _cargarNotificaciones();
    }
  }

  // ─── TAP NOTIFICACION ──────────────────────────────────────────────────────

  Future<void> _onNotificacionTap(NotificacionModel notif, int index) async {
    // 1. Marcar como leída si no lo estaba
    if (!notif.leida) {
      setState(() {
        _notifications[index] = notif.copyWith(leida: true);
        if (_noLeidas > 0) _noLeidas--;
      });

      try {
        await NotificacionesService.marcarComoLeida(notif.id);
      } on ApiException catch (e) {
        if (!mounted) return;
        _mostrarErrorSnack(e.message);
      }
    }

    // Verificar que el widget siga montado antes de usar context
    if (!mounted) return;

    // 2. Acción según tipo
    final grupoId = notif.grupoIdEmbebido;
    
    switch (notif.tipo) {
      case TipoNotificacion.invitacionGrupo:
        final invId = notif.invitacionIdEmbebida;
        if (grupoId != null && invId != null) {
          InvitationActionBottomSheet.show(
            context: context,
            grupoId: grupoId,
            invitacionId: invId,
            onHandled: (_) async {
              // Eliminar la notificación al haber sido gestionada (aceptar/rechazar)
              try {
                await NotificacionesService.eliminarNotificacion(notif.id);
              } catch (_) {}
              _cargarNotificaciones();
            },
          );
        } else {
          _mostrarErrorSnack('Datos de la invitación incompletos');
        }
        break;

      case TipoNotificacion.solicitudUnion:
        if (grupoId != null) {
          context.pushNamed('group_members',
              pathParameters: {'grupoId': grupoId});
        }
        break;

      case TipoNotificacion.invitacionAceptada:
      case TipoNotificacion.solicitudAceptada:
        if (grupoId != null) {
          context.pushNamed('group_detail',
              pathParameters: {'grupoId': grupoId});
        }
        break;

      case TipoNotificacion.nuevoAdmin:
        if (grupoId != null) {
          context.pushNamed('group_detail',
              pathParameters: {'grupoId': grupoId});
        }
        break;

      case TipoNotificacion.nuevoRetoGrupo:
        if (grupoId != null) {
          context.pushNamed('group_challenges',
              pathParameters: {'grupoId': grupoId});
        }
        break;

      case TipoNotificacion.nuevaActividadGrupo:
        if (grupoId != null) {
          context.pushNamed('group_activities',
              pathParameters: {'grupoId': grupoId});
        }
        break;

      case TipoNotificacion.nuevaFotoGrupo:
        if (grupoId != null) {
          context.pushNamed('group_gallery',
              pathParameters: {'grupoId': grupoId});
        }
        break;

      case TipoNotificacion.solicitudRechazada:
      case TipoNotificacion.eliminadoGrupo:
      case TipoNotificacion.grupoEliminado:
      case TipoNotificacion.otros:
        // No hay navegación específica
        break;
    }
  }

  // ─── ELIMINAR NOTIFICACION ────────────────────────────────────────────────

  void _dismissNotification(int index) async {
    final notif = _notifications[index];

    // Actualizacion optimista
    setState(() {
      _notifications.removeAt(index);
      if (!notif.leida && _noLeidas > 0) _noLeidas--;
    });

    try {
      await NotificacionesService.eliminarNotificacion(notif.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      _mostrarErrorSnack(e.message);
      // Reinsertar en caso de error
      setState(() {
        _notifications.insert(index, notif);
        if (!notif.leida) _noLeidas++;
      });
    }
  }

  // ─── MOSTRAR ERROR EN SNACKBAR ────────────────────────────────────────────

  void _mostrarErrorSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.primaryDeep,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            _buildHeader(),

            // ── Unread badge strip ───────────────────────────────────────
            if (_unreadCount > 0 && _loadState == _LoadState.loaded)
              _buildUnreadBadge(),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 20),
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
                if (_unreadCount > 0 && _loadState == _LoadState.loaded)
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
          if (_unreadCount > 0 && _loadState == _LoadState.loaded)
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
          if (_loadState == _LoadState.loading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
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
              'Tienes $_unreadCount notificaciones nuevas desde tu ultima visita.',
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_loadState) {
      case _LoadState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case _LoadState.error:
        return _buildError();

      case _LoadState.loaded:
        if (_notifications.isEmpty) {
          return _buildEmpty();
        }
        return _buildList();

      case _LoadState.initial:
        return const Center(
          child: CircularProgressIndicator(),
        );
    }
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.colors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: context.colors.primaryDeep,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Error al cargar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'No se pudieron cargar las notificaciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarNotificaciones,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _cargarNotificaciones,
      color: context.colors.primary,
      child: ListView.builder(
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
    );
  }

  Widget _buildNotifCard(int index) {
    final notif = _notifications[index];

    return Dismissible(
      key: Key('notif_${notif.id}'),
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
        onTap: () => _onNotificacionTap(notif, index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notif.leida
                ? context.colors.card
                : context.colors.primaryLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notif.leida
                  ? Colors.transparent
                  : context.colors.primaryMid.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: notif.leida
                    ? Colors.black.withValues(alpha: 0.04)
                    : context.colors.primary.withValues(alpha: 0.1),
                blurRadius: notif.leida ? 8 : 16,
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
                  color: _iconBg(notif.tipo, notif.leida),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconData(notif.tipo),
                  color: _iconColor(notif.tipo),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getTitle(notif.tipo),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notif.leida
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notif.leida)
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
                      notif.mensajeLimpio,
                      style: TextStyle(
                        fontSize: 13,
                        color: notif.leida
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
                          tiempoTranscurrido(notif.creadoEn),
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textHint,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _tagBg(notif.tipo),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notif.tipo.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _iconColor(notif.tipo),
                              letterSpacing: 0.5,
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
            'Cuando tengas actividad nueva\naparecera aqui.',
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

  // ── HELPERS ────────────────────────────────────────────────────────────────

  String _getTitle(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.invitacionGrupo:
        return 'Invitacion a grupo';
      case TipoNotificacion.invitacionAceptada:
        return 'Invitacion aceptada';
      case TipoNotificacion.eliminadoGrupo:
        return 'Eliminado del grupo';
      case TipoNotificacion.grupoEliminado:
        return 'Grupo eliminado';
      case TipoNotificacion.solicitudUnion:
        return 'Solicitud de unión';
      case TipoNotificacion.solicitudAceptada:
        return 'Solicitud aceptada';
      case TipoNotificacion.solicitudRechazada:
        return 'Solicitud rechazada';
      case TipoNotificacion.nuevoAdmin:
        return '¡Nuevo rol en el grupo!';
      case TipoNotificacion.nuevoRetoGrupo:
        return 'Nuevo reto disponible';
      case TipoNotificacion.nuevaActividadGrupo:
        return 'Nueva actividad en el grupo';
      case TipoNotificacion.nuevaFotoGrupo:
        return 'Nueva foto en la galería';
      case TipoNotificacion.otros:
        return 'Notificacion';
    }
  }

  IconData _iconData(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.invitacionGrupo:
      case TipoNotificacion.invitacionAceptada:
      case TipoNotificacion.solicitudUnion:
      case TipoNotificacion.solicitudAceptada:
        return Icons.group_add_rounded;
      case TipoNotificacion.eliminadoGrupo:
      case TipoNotificacion.grupoEliminado:
      case TipoNotificacion.solicitudRechazada:
        return Icons.group_remove_rounded;
      case TipoNotificacion.nuevoAdmin:
        return Icons.shield_rounded;
      case TipoNotificacion.nuevoRetoGrupo:
        return Icons.flag_rounded;
      case TipoNotificacion.nuevaActividadGrupo:
        return Icons.directions_run_rounded;
      case TipoNotificacion.nuevaFotoGrupo:
        return Icons.photo_library_rounded;
      case TipoNotificacion.otros:
        return Icons.notifications_rounded;
    }
  }

  Color _iconColor(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.invitacionGrupo:
      case TipoNotificacion.solicitudUnion:
        return const Color(0xFF2196F3); // Azul
      case TipoNotificacion.invitacionAceptada:
      case TipoNotificacion.solicitudAceptada:
        return const Color(0xFF4CAF50); // Verde
      case TipoNotificacion.eliminadoGrupo:
      case TipoNotificacion.solicitudRechazada:
        return const Color(0xFFF44336); // Rojo
      case TipoNotificacion.grupoEliminado:
        return const Color(0xFFFF9800); // Naranja
      case TipoNotificacion.nuevoAdmin:
        return const Color(0xFF9C27B0); // Púrpura
      case TipoNotificacion.nuevoRetoGrupo:
        return const Color(0xFFFF9800); // Naranja
      case TipoNotificacion.nuevaActividadGrupo:
        return const Color(0xFF00BCD4); // Cian
      case TipoNotificacion.nuevaFotoGrupo:
        return const Color(0xFF9C27B0); // Púrpura
      case TipoNotificacion.otros:
        return context.colors.textHint; // Gris
    }
  }

  Color _iconBg(TipoNotificacion tipo, bool isRead) {
    final base = _iconColor(tipo);
    return base.withValues(alpha: isRead ? 0.08 : 0.18);
  }

  Color _tagBg(TipoNotificacion tipo) => _iconColor(tipo).withValues(alpha: 0.12);
}