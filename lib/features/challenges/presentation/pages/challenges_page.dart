import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/config/api_config.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/challenges/data/models/reto_models.dart';
import 'package:runn_front/features/challenges/services/retos_service.dart';
import 'package:runn_front/features/notifications/services/notificaciones_notifier.dart';
import 'package:runn_front/features/notifications/presentation/widgets/notification_bell.dart';

// ─── COLORES DE NIVEL ─────────────────────────────────────────────────────────
const Map<String, Color> _nivelColor = {
  'sin_nivel': Color(0xFF9E9E9E),
  'bronce':    Color(0xFFCD7F32),
  'plata':     Color(0xFFC0C0C0),
  'oro':       Color(0xFFFFD700),
  'diamante':  Color(0xFF00BFFF),
};
const Map<String, String> _nivelLabel = {
  'sin_nivel': 'Sin nivel',
  'bronce':    'Bronce',
  'plata':     'Plata',
  'oro':       'Oro',
  'diamante':  'Diamante',
};
const Map<String, String> _nivelEmoji = {
  'sin_nivel': '🔘',
  'bronce':    '🥉',
  'plata':     '🥈',
  'oro':       '🥇',
  'diamante':  '💎',
};

// ─── PÁGINA PRINCIPAL ─────────────────────────────────────────────────────────

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // State
  bool _loadingDiario = true;
  bool _loadingSemanal = true;
  bool _loadingInsignias = true;
  String? _errorDiario;
  String? _errorSemanal;
  String? _errorInsignias;
  RetoDiarioConParticipacion? _diario;
  RetoSemanalConParticipacion? _semanal;
  RachaModel? _racha;
  InsigniasResponse? _insignias;
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _cargarTodo();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarTodo() async {
    _cargarDiario();
    _cargarSemanal();
    _cargarInsignias();
    NotificacionesNotifier.instance.fetchUnreadCount();
    final rol = await ApiConfig.getUserRol();
    if (mounted) setState(() => _esAdmin = rol == 'admin');
  }

  Future<void> _cargarDiario() async {
    if (mounted) setState(() { _loadingDiario = true; _errorDiario = null; });
    try {
      final d = await RetosService.obtenerRetoDiarioHoy();
      if (mounted) setState(() { _diario = d; _loadingDiario = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _errorDiario = e.message; _loadingDiario = false; });
    } catch (_) {
      if (mounted) setState(() { _errorDiario = 'Error al cargar el reto'; _loadingDiario = false; });
    }
  }

  Future<void> _cargarSemanal() async {
    if (mounted) setState(() { _loadingSemanal = true; _errorSemanal = null; });
    try {
      final results = await Future.wait([
        RetosService.obtenerRetoSemanalActual(),
        RetosService.obtenerRacha(),
      ]);
      if (mounted) {
        setState(() {
          _semanal = results[0] as RetoSemanalConParticipacion;
          _racha   = results[1] as RachaModel;
          _loadingSemanal = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _errorSemanal = e.message; _loadingSemanal = false; });
    } catch (_) {
      if (mounted) setState(() { _errorSemanal = 'Error al cargar'; _loadingSemanal = false; });
    }
  }

  Future<void> _cargarInsignias() async {
    if (mounted) setState(() { _loadingInsignias = true; _errorInsignias = null; });
    try {
      final ins = await RetosService.obtenerInsignias();
      if (mounted) setState(() { _insignias = ins; _loadingInsignias = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _errorInsignias = e.message; _loadingInsignias = false; });
    } catch (_) {
      if (mounted) setState(() { _errorInsignias = 'Error al cargar insignias'; _loadingInsignias = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: NestedScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(child: _buildHeader(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
        body: FadeTransition(
          opacity: _fadeAnim,
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _TabHoy(
                loading: _loadingDiario,
                error: _errorDiario,
                data: _diario,
                esAdmin: _esAdmin,
                onRefresh: _cargarDiario,
              ),
              _TabSemanal(
                loading: _loadingSemanal,
                error: _errorSemanal,
                semanal: _semanal,
                racha: _racha,
                esAdmin: _esAdmin,
                onRefresh: _cargarSemanal,
              ),
              _TabInsignias(
                loading: _loadingInsignias,
                error: _errorInsignias,
                data: _insignias,
                onRefresh: _cargarInsignias,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.card,
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
            top: -20,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    c.primaryDeepWithAlpha(0.05),
                    c.primaryDeepWithAlpha(0.01),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    c.primaryDeepWithAlpha(0.04),
                    c.primaryDeepWithAlpha(0.01),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
                          color: c.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: c.primaryDeepWithAlpha(0.8),
                          size: 22,
                        ),
                      ),
                      const NotificationBell(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Retos',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Supera tus límites cada día',
                    style: TextStyle(
                      fontSize: 15,
                      color: c.textSecondary,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                      height: 1.4,
                    ),
                  ),
                  if (_esAdmin) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => context.pushNamed('challenge_admin'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: c.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: c.primaryDeep.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune_rounded, color: c.primaryDeep, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Gestionar retos',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: c.primaryDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: c.primaryDeepWithAlpha(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabCtrl,
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      padding: const EdgeInsets.all(4),
                      indicatorPadding: EdgeInsets.zero,
                      indicator: BoxDecoration(
                        color: c.primary,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      labelColor: c.card,
                      unselectedLabelColor: c.textSecondary,
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                      tabs: const [
                        Tab(text: 'Hoy'),
                        Tab(text: 'Esta semana'),
                        Tab(text: 'Insignias'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 1 — HOY
// ═══════════════════════════════════════════════════════════════════════════════

class _TabHoy extends StatelessWidget {
  final bool loading;
  final String? error;
  final RetoDiarioConParticipacion? data;
  final bool esAdmin;
  final VoidCallback onRefresh;

  const _TabHoy({required this.loading, this.error, this.data, required this.esAdmin, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return _ErrorView(msg: error!, onRetry: onRefresh);
    if (data == null) return const Center(child: Text('Sin datos'));

    final reto = data!.reto;
    final part = data!.participacion;
    final progress = reto.valorObjetivo > 0
        ? (part.progresoActual / reto.valorObjetivo).clamp(0.0, 1.0)
        : 0.0;
    final pct = (progress * 100).toInt();
    final completado = part.completado;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: c.primaryDeep,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: completado
                      ? [const Color(0xFF2E7D32), const Color(0xFF388E3C)]
                      : [c.primaryDeep, c.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (completado ? const Color(0xFF2E7D32) : c.primaryDeep).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header chips
                  Row(
                    children: [
                      _chip(completado ? '✅ Completado' : '⏳ En progreso',
                          completado ? const Color(0xFF7ED957) : const Color(0xFFFFB84D)),
                      const SizedBox(width: 8),
                      if (reto.generadoPorIA)
                        _chip('✨ IA', Colors.white.withValues(alpha: 0.25)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(reto.titulo,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4)),
                  const SizedBox(height: 6),
                  if (reto.descripcion != null && reto.descripcion!.isNotEmpty)
                    Text(reto.descripcion!,
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8), height: 1.4)),
                  const SizedBox(height: 16),
                  Text(reto.objetivoFormateado,
                    style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  // Progreso
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${part.progresoActual.toStringAsFixed(part.progresoActual < 10 ? 2 : 1)} / ${reto.valorObjetivo.toStringAsFixed(0)} ${reto.unidad}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                      ),
                      Text('$pct%', style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Puntos
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                      const SizedBox(width: 6),
                      Text('+${reto.puntosRecompensa} puntos al completar',
                        style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (completado) ...[
                    const SizedBox(height: 14),
                    const Center(child: Text('🎉 ¡Reto completado! ¡Increíble!',
                      style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700))),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Ver historial
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.pushNamed('challenge_daily_history'),
                icon: Icon(Icons.history_rounded, color: c.primaryDeep),
                label: Text('Ver historial de retos diarios', style: TextStyle(color: c.primaryDeep, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: c.primaryDeepWithAlpha(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 2 — ESTA SEMANA
// ═══════════════════════════════════════════════════════════════════════════════

class _TabSemanal extends StatelessWidget {
  final bool loading;
  final String? error;
  final RetoSemanalConParticipacion? semanal;
  final RachaModel? racha;
  final bool esAdmin;
  final VoidCallback onRefresh;

  const _TabSemanal({
    required this.loading, this.error, this.semanal, this.racha,
    required this.esAdmin, required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return _ErrorView(msg: error!, onRetry: onRefresh);

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: c.primaryDeep,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (semanal != null) _buildRetoSemanal(context, c, semanal!),
            const SizedBox(height: 24),
            if (racha != null) _buildRacha(context, c, racha!),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.pushNamed('challenge_weekly_history'),
                icon: Icon(Icons.history_rounded, color: c.primaryDeep),
                label: Text('Ver historial semanal', style: TextStyle(color: c.primaryDeep, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: c.primaryDeepWithAlpha(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetoSemanal(BuildContext context, dynamic c, RetoSemanalConParticipacion data) {
    final reto = data.reto;
    final part = data.participacion;
    final progress = reto.valorObjetivo > 0
        ? (part.progresoActual / reto.valorObjetivo).clamp(0.0, 1.0)
        : 0.0;
    final pct = (progress * 100).toInt();
    final completado = part.completado;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: completado
              ? [const Color(0xFF2E7D32), const Color(0xFF388E3C)]
              : [c.primaryDeep, c.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: c.primaryDeepWithAlpha(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _chipWhite(completado ? '✅ Completado' : '📅 ${reto.periodoFormateado}'),
              const SizedBox(width: 8),
              if (reto.generadoPorIA) _chipWhite('✨ IA'),
            ],
          ),
          const SizedBox(height: 14),
          Text(reto.titulo,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4)),
          const SizedBox(height: 6),
          if (reto.descripcion != null && reto.descripcion!.isNotEmpty)
            Text(reto.descripcion!, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8), height: 1.4)),
          const SizedBox(height: 16),
          Text(reto.objetivoFormateado,
            style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${part.progresoActual.toStringAsFixed(2)} / ${reto.valorObjetivo.toStringAsFixed(0)} ${reto.unidad}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              Text('$pct%', style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
              const SizedBox(width: 6),
              Text('+${reto.puntosRecompensa} puntos al completar',
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRacha(BuildContext context, dynamic c, RachaModel racha) {
    final color = _nivelColor[racha.nivelActual] ?? Colors.grey;
    final label = _nivelLabel[racha.nivelActual] ?? racha.nivelActual;
    final emoji = _nivelEmoji[racha.nivelActual] ?? '🔘';
    final esDiamante = racha.nivelActual == 'diamante';
    final prox = racha.proximoNivel;
    final proxProgress = prox != null
        ? (racha.semanasAcumuladas / prox.semanasNecesarias).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🔥 Racha Semanal', style: TextStyle(fontSize: 14, color: c.textHint, letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
                  Text('${racha.semanasAcumuladas} semanas acumuladas', style: TextStyle(fontSize: 12, color: c.textSecondary)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${racha.rachaActual}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
                  Text('racha actual', style: TextStyle(fontSize: 11, color: c.textHint)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (esDiamante)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('¡Nivel máximo alcanzado! 💎',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
                ],
              ),
            )
          else if (prox != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: proxProgress,
                minHeight: 8,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Te faltan ${prox.semanasRestantes} semanas para alcanzar el nivel ${_nivelLabel[prox.nivel] ?? prox.nivel}',
              style: TextStyle(fontSize: 12, color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chipWhite(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 3 — INSIGNIAS
// ═══════════════════════════════════════════════════════════════════════════════

class _TabInsignias extends StatelessWidget {
  final bool loading;
  final String? error;
  final InsigniasResponse? data;
  final VoidCallback onRefresh;

  const _TabInsignias({required this.loading, this.error, this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return _ErrorView(msg: error!, onRetry: onRefresh);
    if (data == null) return const Center(child: Text('Sin datos'));

    final desbloqueadas = data!.insignias.where((i) => i.desbloqueada).toList()
      ..sort((a, b) => a.kmRequeridos.compareTo(b.kmRequeridos));
    final bloqueadas = data!.insignias.where((i) => !i.desbloqueada).toList()
      ..sort((a, b) => a.kmRequeridos.compareTo(b.kmRequeridos));

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: c.primaryDeep,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total km
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c.primaryDeep, c.primaryDark]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: c.primaryDeepWithAlpha(0.3), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                children: [
                  const Text('🏃 Has corrido en total', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    '${data!.kmTotales.toStringAsFixed(2)} km',
                    style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (desbloqueadas.isNotEmpty) ...[
              Text('✅ Desbloqueadas (${desbloqueadas.length})',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary)),
              const SizedBox(height: 12),
              ...desbloqueadas.map((ins) => _InsigniaCard(ins: ins, desbloqueada: true)),
              const SizedBox(height: 20),
            ],

            if (bloqueadas.isNotEmpty) ...[
              Text('🔒 Por desbloquear (${bloqueadas.length})',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary)),
              const SizedBox(height: 12),
              ...bloqueadas.map((ins) => _InsigniaCard(ins: ins, desbloqueada: false)),
            ],

            if (desbloqueadas.isEmpty && bloqueadas.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Text('🏅', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text('¡Sigue corriendo para desbloquear insignias!',
                        style: TextStyle(fontSize: 14, color: c.textSecondary), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InsigniaCard extends StatelessWidget {
  final InsigniaDistancia ins;
  final bool desbloqueada;

  const _InsigniaCard({required this.ins, required this.desbloqueada});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = desbloqueada
        ? (_nivelColor[ins.nivel] ?? c.primaryDeep)
        : c.textHint;
    final iconData = desbloqueada ? Icons.emoji_events_rounded : Icons.lock_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: desbloqueada ? 0.3 : 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: desbloqueada ? 0.15 : 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(ins.nombre,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: desbloqueada ? c.textPrimary : c.textSecondary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${ins.kmRequeridos.toStringAsFixed(0)} km',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                    ),
                  ],
                ),
                if (ins.descripcion != null && ins.descripcion!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(ins.descripcion!, style: TextStyle(fontSize: 12, color: c.textHint), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                const SizedBox(height: 6),
                if (desbloqueada && ins.ganadoEn != null)
                  Text('Ganada: ${ins.ganadoEnFmt}', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600))
                else if (!desbloqueada) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ins.progreso / 100,
                      minHeight: 5,
                      backgroundColor: c.textHint.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text('Te faltan ${ins.kmFaltantes}', style: TextStyle(fontSize: 11, color: c.textHint)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HELPERS COMPARTIDOS ──────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;

  const _ErrorView({required this.msg, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(msg, style: TextStyle(color: c.textSecondary, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: c.primaryDeep),
              child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
