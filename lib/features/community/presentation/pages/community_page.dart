import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/eventos_service.dart';
import '../../services/usuarios_service.dart';
import '../../domain/models/evento_model.dart';
import '../../../../core/config/api_config.dart';
import 'event_edit_page.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _skeletonController;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _pulseAnimation;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  bool _isRefreshing = false;

  // ─── Estado de eventos ────────────────────────────────────────────────────
  List<EventoModel> _eventos = [];
  bool _eventosLoading = true;
  String _eventosError = '';

  // ─── Estado de Comunidad (Estadísticas) ──────────────────────────────────
  Map<String, int> _stats = {'grupos': 0, 'runners': 0, 'eventos': 0};
  bool _statsLoading = true;

  String? _userRol;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _headerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _skeletonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _skeletonController, curve: Curves.easeInOut),
    );
    _skeletonController.repeat(reverse: true);
    _animationController.forward();
    _loadRolYEventos();
  }

  Future<void> _handleRefresh() async {
    if (mounted) setState(() => _isRefreshing = true);
    await _loadRolYEventos();
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _loadRolYEventos() async {
    final rol = await ApiConfig.getUserRol();
    if (mounted) setState(() => _userRol = rol);
    await Future.wait([
      _fetchEventos(),
      _fetchStats(),
    ]);
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await UsuariosService.getCommunityStats();
      if (mounted) setState(() { _stats = stats; _statsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  Future<void> _fetchEventos() async {
    try {
      final lista = await EventosService.getEventos();
      if (mounted) setState(() { _eventos = lista; _eventosLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _eventosError = e.toString(); _eventosLoading = false; });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _skeletonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: context.colors.primaryDeep,
            backgroundColor: context.colors.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(),
                  FadeTransition(
                    opacity: _contentAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_contentAnimation),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _isRefreshing
                          ? _buildCommunitySkeleton(context)
                          : Column(
                              children: [
                                const SizedBox(height: 24),
                                _buildQuickActions(),
                                const SizedBox(height: 32),
                                _buildEventsSection(),
                                const SizedBox(height: 32),
                                _buildNearbyRunners(),
                                const SizedBox(height: 40),
                              ],
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colors.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 30,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      context.colors.primaryDeepWithAlpha(0.05),
                      context.colors.primaryDeepWithAlpha(0.01),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      context.colors.primaryDeepWithAlpha(0.04),
                      context.colors.primaryDeepWithAlpha(0.01),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: context.colors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.groups_rounded,
                            color: context.colors.primaryDeepWithAlpha(0.8),
                            size: 22,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/notifications'),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: context.colors.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: context.colors.primaryDeepWithAlpha(
                                      0.8,
                                    ),
                                    size: 22,
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF6B6B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comunidad',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Conecta con runners cerca de ti',
                      style: TextStyle(
                        fontSize: 15,
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.2,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.colors.primaryDeepWithAlpha(0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildHeaderStat(
                            _statsLoading ? '...' : _stats['grupos'].toString(),
                            'Grupos',
                            Icons.groups_rounded,
                          ),
                          _buildHeaderDivider(),
                          _buildHeaderStat(
                            _statsLoading ? '...' : _stats['runners']! > 1000 ? '${(_stats['runners']! / 1000).toStringAsFixed(1)}k' : _stats['runners'].toString(),
                            'Runners',
                            Icons.directions_run_rounded,
                          ),
                          _buildHeaderDivider(),
                          _buildHeaderStat(
                            _statsLoading ? '...' : _stats['eventos'].toString(),
                            'Eventos',
                            Icons.event_rounded,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: context.colors.primaryDeepWithAlpha(0.7), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderDivider() {
    return Container(
      width: 1,
      height: 40,
      color: context.colors.primaryDeepWithAlpha(0.1),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration(BuildContext context, {Color? accentColor}) {
    return BoxDecoration(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: (accentColor ?? context.colors.primaryDeep).withValues(
          alpha: 0.10,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // QUICK ACTIONS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.person_rounded,
            iconColor: context.colors.primaryDeep,
            iconBgColor: context.colors.primaryLight,
            label: 'Ver Runners',
            onTap: () => context.push('/community/runners'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.group_add_rounded,
            iconColor: context.colors.primaryDeep,
            iconBgColor: context.colors.primaryLight,
            label: 'Ver Grupos',
            onTap: () => context.push('/community/groups'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.person_add_rounded,
            iconColor: context.colors.primaryDeep,
            iconBgColor: context.colors.primaryLight,
            label: 'Invitar Amigos',
            onTap: () => _showShareBottomSheet(context),
          ),
        ),
      ],
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    final c = context.colors;
    const inviteLink = 'https://runn.app/invite';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: Stack(
              children: [
                // Decorative Background Elements (Cohesive with Header)
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          c.primaryDeep.withValues(alpha: 0.08),
                          c.primaryDeep.withValues(alpha: 0.01),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: -40,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          c.primary.withValues(alpha: 0.06),
                          c.primary.withValues(alpha: 0.01),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: c.textSecondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Compartir enlace',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: c.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: c.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.share_rounded,
                              size: 16,
                              color: c.primaryDeep,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Social Icons Row
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildShareAppIcon(
                              context,
                              'WhatsApp',
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/WhatsApp.svg/1024px-WhatsApp.svg.png',
                              () async {
                                Navigator.pop(context);
                                final url = Uri.parse(
                                  'whatsapp://send?text=${Uri.encodeComponent("¡Únete a Runn! $inviteLink")}',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  Share.share('¡Únete a Runn! $inviteLink');
                                }
                              },
                            ),
                            _buildShareAppIcon(
                              context,
                              'Facebook',
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_%282019%29.png/1024px-Facebook_Logo_%282019%29.png',
                              () async {
                                Navigator.pop(context);
                                final url = Uri.parse(
                                  'https://www.facebook.com/sharer/sharer.php?u=$inviteLink',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  Share.share('¡Únete a Runn! $inviteLink');
                                }
                              },
                            ),
                            _buildShareAppIcon(
                              context,
                              'Messenger',
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Facebook_Messenger_logo_2020.svg/1024px-Facebook_Messenger_logo_2020.svg.png',
                              () async {
                                Navigator.pop(context);
                                final url = Uri.parse(
                                  'fb-messenger://share?link=$inviteLink',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  Share.share('¡Únete a Runn! $inviteLink');
                                }
                              },
                            ),
                            _buildShareAppIcon(
                              context,
                              'Telegram',
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Telegram_logo.svg/1024px-Telegram_logo.svg.png',
                              () async {
                                Navigator.pop(context);
                                final url = Uri.parse(
                                  'tg://msg?text=${Uri.encodeComponent("¡Únete a Runn! $inviteLink")}',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  Share.share('¡Únete a Runn! $inviteLink');
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: c.textSecondary.withValues(alpha: 0.08),
                      ),
                      const SizedBox(height: 12),

                      // Action List
                      _buildShareActionItem(
                        context,
                        Icons.content_copy_rounded,
                        'Copiar vínculo',
                        () {
                          Clipboard.setData(const ClipboardData(text: inviteLink));
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  const Text(
                                      'Vínculo copiado al portapapeles'),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: c.primaryDeep,
                            ),
                          );
                        },
                      ),
                      _buildShareActionItem(
                        context,
                        Icons.ios_share_rounded,
                        'Abrir más opciones',
                        () {
                          Navigator.pop(context);
                          Share.share('¡Únete a Runn! $inviteLink');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareAppIcon(
    BuildContext context,
    String label,
    String imageUrl,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: context.colors.primaryLight,
                    child: Icon(Icons.share_rounded, color: context.colors.primaryDeep),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareActionItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: c.primaryDeep,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: c.textSecondary.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: iconColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 28,
              height: 20,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // NEWS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildEventsSection() {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.event_available_rounded, size: 20, color: c.primary),
                const SizedBox(width: 6),
                const Text(
                  'Eventos próximos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (_userRol == 'admin')
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const EventEditPage()),
                  );
                  // Si se creó un evento, recargamos la lista
                  if (result == true && mounted) {
                    setState(() { _eventosLoading = true; _eventosError = ''; });
                    await _fetchEventos();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: c.primaryDeep,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Crear',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (_eventosLoading)
          const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_eventosError.isNotEmpty)
          SizedBox(
            height: 240,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy_rounded, size: 36, color: c.primaryDeepWithAlpha(0.3)),
                  const SizedBox(height: 8),
                  Text('No se pudieron cargar eventos',
                      style: TextStyle(color: c.textHint, fontSize: 13)),
                  TextButton(
                    onPressed: () {
                      setState(() { _eventosLoading = true; _eventosError = ''; });
                      _fetchEventos();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        else if (_eventos.isEmpty)
          SizedBox(
            height: 240,
            child: Center(
              child: Text(
                'No hay eventos próximos',
                style: TextStyle(color: c.textHint, fontSize: 14),
              ),
            ),
          )
        else
          SizedBox(
            height: 240,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              scrollDirection: Axis.horizontal,
              itemCount: _eventos.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _buildEventItem(_eventos[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEventItem(EventoModel evento) {
    final c = context.colors;
    return GestureDetector(
      onTap: () => context.pushNamed(
        'event_detail',
        pathParameters: {'eventId': evento.id},
      ),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.primaryDeepWithAlpha(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            children: [
              // Imagen o placeholder
              Positioned.fill(
                child: evento.fotoUrl != null && evento.fotoUrl!.isNotEmpty
                    ? Image.network(
                        evento.fotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: c.primaryLight,
                          child: Icon(Icons.event_rounded, size: 48, color: c.primaryDeepWithAlpha(0.3)),
                        ),
                      )
                    : Container(
                        color: c.primaryLight,
                        child: Icon(Icons.event_rounded, size: 48, color: c.primaryDeepWithAlpha(0.3)),
                      ),
              ),
              // Gradiente oscuro
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),
              // Chips de estado (Precio / Lista de espera)
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: evento.esPago ? Colors.blue.withValues(alpha: 0.9) : Colors.green.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        evento.esPago ? 'De pago \$${evento.precio.toInt()}' : 'Gratuito',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (evento.cupoDisponible == 0) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Lista de espera',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Contenido
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.primaryDeep.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        evento.fechaFormateada,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      evento.titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (evento.lugar != null && evento.lugar!.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: Colors.white.withValues(alpha: 0.8), size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              evento.lugar!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.people_alt_rounded,
                            color: Colors.white.withValues(alpha: 0.8), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${evento.participantesConfirmados} participantes',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (evento.cupoDisponible != null) ...[
                          const Spacer(),
                          Text(
                            evento.cupoDisponible == 0
                                ? 'Cupo lleno'
                                : '${evento.cupoDisponible} lugares',
                            style: TextStyle(
                              color: evento.cupoDisponible == 0
                                  ? Colors.orangeAccent
                                  : Colors.greenAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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

  // ──────────────────────────────────────────────────────────────────────────
  // NEARBY RUNNERS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildNearbyRunners() {
    final rivals = [
      {
        'id': '1',
        'name': 'María González',
        'level': 12,
        'challenges': 5,
        'territoriesLost': 2,
      },
      {
        'id': '2',
        'name': 'Carlos Ruiz',
        'level': 9,
        'challenges': 3,
        'territoriesLost': 1,
      },
      {
        'id': '3',
        'name': 'Ana Martínez',
        'level': 15,
        'challenges': 7,
        'territoriesLost': 4,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bolt_rounded, size: 20, color: context.colors.primary),
            const SizedBox(width: 6),
            Text(
              'Rivales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...rivals.map(
          (rival) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => context.pushNamed(
                'rival_details',
                pathParameters: {'userId': rival['id'] as String},
                extra: rival,
              ),
              borderRadius: BorderRadius.circular(20),
              child: _buildRivalItem(rival, context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRivalItem(Map<String, dynamic> rival, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE8698A).withValues(alpha: 0.15),
                      const Color(0xFFE8698A).withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: context.colors.primaryDeepWithAlpha(0.7),
                  size: 26,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB84D), Color(0xFFFF9F1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.colors.surface,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '${rival['level']}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => context.pushNamed(
                      'profile_others_runners',
                      pathParameters: {'userId': rival['id'] as String},
                    ),
                    child: Text(
                      rival['name'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                        letterSpacing: -0.2,
                        decoration: TextDecoration.none,
                        decorationColor: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Te ha retado: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${rival['challenges']} veces',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.primaryDeep,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Territorios quitados: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${rival['territoriesLost']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.primaryDeep,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: context.colors.textPrimary.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SKELETON
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildCommunitySkeleton(BuildContext context) {
    final c = context.colors;
    return FadeTransition(
      opacity: _pulseAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Quick actions
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Events Section
          _skeletonRow(140, 20),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 260,
                  height: 180,
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              )),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Nearby Runners Section
          _skeletonRow(160, 20),
          const SizedBox(height: 16),
          Column(
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _skeletonRow(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
