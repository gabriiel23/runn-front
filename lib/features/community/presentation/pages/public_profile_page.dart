import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/usuarios_service.dart';
import '../../domain/models/usuario_community_model.dart';
import '../../../../core/services/http_client.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;
  final String viewType; // 'runner', 'participant', 'rival'
  final Map<String, dynamic>? extraData;

  const PublicProfilePage({
    super.key,
    required this.userId,
    required this.viewType,
    this.extraData,
  });

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  UsuarioCommunityModel? _usuario;
  bool _isLoading = true;
  String _errorMsg = '';
  bool _isFollowLoading = false;
  List<Map<String, String>> _mediaItems = [];

  @override
  void initState() {
    super.initState();
    _loadPerfil();
  }

  Future<void> _loadPerfil() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    try {
      final results = await Future.wait([
        UsuariosService.getUsuarioPerfil(widget.userId),
        UsuariosService.getUsuarioMedia(widget.userId),
      ]);
      if (mounted) {
        setState(() {
          _usuario = results[0] as UsuarioCommunityModel;
          _mediaItems = results[1] as List<Map<String, String>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (_usuario == null || _isFollowLoading) return;
    setState(() => _isFollowLoading = true);

    try {
      if (_usuario!.yoLoSigo) {
        await UsuariosService.dejarDeSeguir(widget.userId);
        setState(() {
          _usuario = _usuario!.copyWith(
            yoLoSigo: false,
            seguidores: _usuario!.seguidores - 1,
          );
        });
      } else {
        await UsuariosService.seguirUsuario(widget.userId);
        setState(() {
          _usuario = _usuario!.copyWith(
            yoLoSigo: true,
            seguidores: _usuario!.seguidores + 1,
          );
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
    } finally {
      if (mounted) setState(() => _isFollowLoading = false);
    }
  }

  String _getAppBarTitle() {
    switch (widget.viewType) {
      case 'participant':
        return 'Perfil del Participante';
      case 'rival':
        return 'Detalles del Rival';
      case 'runner':
      default:
        return 'Perfil del Runner';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
          _getAppBarTitle(),
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: _buildBody(context, c),
    );
  }

  Widget _buildBody(BuildContext context, dynamic c) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    if (_errorMsg.isNotEmpty || _usuario == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_rounded,
                size: 64, color: c.primaryDeepWithAlpha(0.3)),
            const SizedBox(height: 16),
            Text('No se pudo cargar el perfil',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary)),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: _loadPerfil, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    final u = _usuario!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildProfileHeader(u, context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 28),
                if (widget.viewType == 'rival') ...[
                  _buildRivalExtraSections(context),
                  const SizedBox(height: 28),
                ],
                _buildBadgesSection(context),
                const SizedBox(height: 28),
                _buildStatisticsSection(context, u),
                const SizedBox(height: 28),
                _buildMultimediaSection(context),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UsuarioCommunityModel u, BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: c.card,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.primaryDeepWithAlpha(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: c.primaryLight,
              backgroundImage: u.avatarUrl != null && u.avatarUrl!.isNotEmpty
                  ? NetworkImage(u.avatarUrl!)
                  : null,
              child: u.avatarUrl == null || u.avatarUrl!.isEmpty
                  ? Icon(Icons.person_rounded,
                      size: 46, color: c.primaryDeepWithAlpha(0.7))
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            u.nombre,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.5),
          ),
          if (u.biografia != null && u.biografia!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                u.biografia!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: c.textSecondary,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
          if (u.ciudad != null && u.ciudad!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_rounded,
                    size: 13, color: c.primaryDeepWithAlpha(0.5)),
                const SizedBox(width: 4),
                Text(u.ciudad!,
                    style: TextStyle(fontSize: 13, color: c.textSecondary)),
              ],
            ),
          ],
          const SizedBox(height: 8),
          if (u.nivel != null && u.nivel!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB84D).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFFFB84D).withValues(alpha: 0.25)),
              ),
              child: Text(
                u.nivel!,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFCC8400)),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('Siguiendo',
                      style: TextStyle(color: c.textHint, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('${u.seguidos}',
                      style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 48),
              Column(
                children: [
                  Text('Seguidores',
                      style: TextStyle(color: c.textHint, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('${u.seguidores}',
                      style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _isFollowLoading ? null : _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    u.yoLoSigo ? c.primaryDeepWithAlpha(0.1) : c.primaryDeep,
                foregroundColor: u.yoLoSigo ? c.primaryDeep : Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: u.yoLoSigo
                      ? BorderSide(color: c.primaryDeepWithAlpha(0.3))
                      : BorderSide.none,
                ),
              ),
              child: _isFollowLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      u.yoLoSigo ? 'Siguiendo ✓' : 'Seguir',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // INSIGNIAS
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildBadgesSection(BuildContext context) {
    final c = context.colors;
    const previewBadges = [
      {
        'icon': Icons.directions_run_rounded,
        'color': Color(0xFFE8698A),
        'title': 'Primer paso',
      },
      {
        'icon': Icons.emoji_events_rounded,
        'color': Color(0xFFFFB84D),
        'title': 'Conquistador',
      },
      {
        'icon': Icons.bolt_rounded,
        'color': Color(0xFF7ED957),
        'title': 'Velocista',
      },
      {
        'icon': Icons.explore_rounded,
        'color': Color(0xFF56CCF2),
        'title': 'Explorador',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Insignias',
          'Ver más',
          () {},
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: previewBadges.map((b) {
            final color = b['color'] as Color;
            final icon = b['icon'] as IconData;
            final title = b['title'] as String;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ESTADÍSTICAS
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildStatisticsSection(BuildContext context, UsuarioCommunityModel u) {
    final c = context.colors;
    final previewStats = [
      {
        'label': 'Total km',
        'value': '–',
        'unit': 'km',
        'icon': Icons.route_rounded,
        'color': c.primaryDeep,
      },
      {
        'label': 'Velocidad máx.',
        'value': '–',
        'unit': 'km/h',
        'icon': Icons.speed_rounded,
        'color': const Color(0xFFE8698A),
      },
      {
        'label': 'Ritmo promedio',
        'value': '–',
        'unit': 'min/km',
        'icon': Icons.timer_rounded,
        'color': const Color(0xFF7ED957),
      },
      {
        'label': 'Carreras',
        'value': '–',
        'unit': 'total',
        'icon': Icons.flag_rounded,
        'color': const Color(0xFFFFB84D),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Estadísticas',
          'Ver más',
          () {},
        ),
        const SizedBox(height: 16),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 74,
          ),
          children: previewStats.map((s) {
            final color = s['color'] as Color;
            final icon = s['icon'] as IconData;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${s['value']} ${s['unit']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          s['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: c.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // RIVAL EXTRA (from RivalDetailsPage mocked data)
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildRivalExtraSections(BuildContext context) {
    final c = context.colors;
    final int challenges = widget.extraData?['challenges'] as int? ?? 0;
    final int territoriesLost = widget.extraData?['territoriesLost'] as int? ?? 0;

    final detailedChallenges = List.generate(
      challenges > 0 ? challenges : 3,
      (index) => {
        'date': '1${index + 1} Mar 2024',
        'type': 'Carrera 5K',
        'location': 'Parque Metropolitano',
        'result': index % 2 == 0 ? 'Perdiste' : 'Ganaste',
      },
    );

    final detailedTerritories = List.generate(
      territoriesLost > 0 ? territoriesLost : 2,
      (index) => {
        'date': '0${index + 5} Mar 2024',
        'location': index == 0 ? 'Centro Histórico' : 'La Carolina',
        'timeTaken': '14:32',
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Retos Recientes',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.4)),
        const SizedBox(height: 16),
        ...detailedChallenges
            .map((challenge) => _buildChallengeItem(challenge, context)),
        const SizedBox(height: 32),
        Text('Territorios Quitados',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.4)),
        const SizedBox(height: 16),
        ...detailedTerritories
            .map((territory) => _buildTerritoryItem(territory, context)),
      ],
    );
  }

  Widget _buildChallengeItem(Map<String, String> challenge, BuildContext context) {
    final c = context.colors;
    final isWin = challenge['result'] == 'Ganaste';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.primaryDeepWithAlpha(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.directions_run_rounded, color: c.primaryDeep),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['type']!,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary),
                ),
                Text(
                  '${challenge['location']} • ${challenge['date']}',
                  style: TextStyle(fontSize: 13, color: c.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            challenge['result']!,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isWin ? const Color(0xFF7ED957) : const Color(0xFFFF6B6B)),
          ),
        ],
      ),
    );
  }

  Widget _buildTerritoryItem(Map<String, String> territory, BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flag_rounded, color: Color(0xFFFF6B6B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  territory['location']!,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary),
                ),
                Text(
                  territory['date']!,
                  style: TextStyle(fontSize: 13, color: c.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Perdido',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary),
              ),
              Text(
                territory['timeTaken']!,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF6B6B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // MULTIMEDIA
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildMultimediaSection(BuildContext context) {
    final c = context.colors;
    final preview = _mediaItems.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Multimedia', 'Ver todo', () {
          context.pushNamed('rival_multimedia',
              pathParameters: {'userId': widget.userId});
        }),
        const SizedBox(height: 16),
        if (preview.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Sin fotos',
                style: TextStyle(color: c.textHint, fontSize: 13),
              ),
            ),
          )
        else
          SizedBox(
            height: 110,
            child: Row(
              children: [
                for (int i = 0; i < preview.length; i++) ...[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        preview[i]['url']!,
                        fit: BoxFit.cover,
                        height: 110,
                        errorBuilder: (_, __, ___) => Container(
                          color: c.primaryDeepWithAlpha(0.1),
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: c.textHint,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (i < preview.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String actionLabel,
    VoidCallback onTap,
  ) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.primaryDeepWithAlpha(0.9),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: c.primaryDeepWithAlpha(0.9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
