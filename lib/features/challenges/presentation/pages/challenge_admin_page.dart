import 'package:flutter/material.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/challenges/data/models/reto_models.dart';
import 'package:runn_front/features/challenges/services/retos_service.dart';

class ChallengeAdminPage extends StatefulWidget {
  const ChallengeAdminPage({super.key});

  @override
  State<ChallengeAdminPage> createState() => _ChallengeAdminPageState();
}

class _ChallengeAdminPageState extends State<ChallengeAdminPage> {
  // Diarios
  bool _loadingDiarioHoy = true;
  bool _loadingDiarioManana = true;
  RetoDiario? _diarioHoy;
  RetoDiario? _diarioManana;
  String? _errDiarioHoy;
  String? _errDiarioManana;

  // Semanales
  bool _loadingSemanalActual = true;
  bool _loadingSemanalProxima = true;
  RetoSemanal? _semanalActual;
  RetoSemanal? _semanalProxima;
  String? _errSemanalActual;
  String? _errSemanalProxima;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  void _cargarTodo() {
    _cargarDiarioHoy();
    _cargarDiarioManana();
    _cargarSemanalActual();
    _cargarSemanalProxima();
  }

  // ─── FETCHERS ───────────────────────────────────────────────────────────────
  Future<void> _cargarDiarioHoy() async {
    setState(() { _loadingDiarioHoy = true; _errDiarioHoy = null; });
    try {
      final d = await RetosService.obtenerRetoDiarioHoy();
      if (mounted) setState(() { _diarioHoy = d.reto; _loadingDiarioHoy = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _errDiarioHoy = e.message; _loadingDiarioHoy = false; });
    } catch (_) {
      if (mounted) setState(() { _errDiarioHoy = 'Error al cargar'; _loadingDiarioHoy = false; });
    }
  }

  Future<void> _cargarDiarioManana() async {
    setState(() { _loadingDiarioManana = true; _errDiarioManana = null; });
    try {
      final d = await RetosService.obtenerRetoDiarioManana();
      if (mounted) setState(() { _diarioManana = d; _loadingDiarioManana = false; });
    } catch (_) {
      if (mounted) setState(() { _errDiarioManana = 'Error al cargar'; _loadingDiarioManana = false; });
    }
  }

  Future<void> _cargarSemanalActual() async {
    setState(() { _loadingSemanalActual = true; _errSemanalActual = null; });
    try {
      final s = await RetosService.obtenerRetoSemanalActual();
      if (mounted) setState(() { _semanalActual = s.reto; _loadingSemanalActual = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _errSemanalActual = e.message; _loadingSemanalActual = false; });
    } catch (_) {
      if (mounted) setState(() { _errSemanalActual = 'Error al cargar'; _loadingSemanalActual = false; });
    }
  }

  Future<void> _cargarSemanalProxima() async {
    setState(() { _loadingSemanalProxima = true; _errSemanalProxima = null; });
    try {
      final s = await RetosService.obtenerRetoSemanalProxima();
      if (mounted) setState(() { _semanalProxima = s; _loadingSemanalProxima = false; });
    } catch (_) {
      if (mounted) setState(() { _errSemanalProxima = 'Error al cargar'; _loadingSemanalProxima = false; });
    }
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────────
  void _snack(String msg, {bool ok = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
    ));
  }

  Future<bool> _confirmar(String msg, {bool esPeligroso = false}) async {
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(esPeligroso ? Icons.warning_amber_rounded : Icons.info_outline, 
              color: esPeligroso ? Colors.red : Colors.blue),
            const SizedBox(width: 8),
            const Text('Confirmar', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), 
            child: Text('Sí, eliminar', style: TextStyle(color: esPeligroso ? Colors.red : Colors.blue))),
        ],
      ),
    ) ?? false;
  }

  void _mostrarLoadingIA() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: ctx.colors.card, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: ctx.colors.primaryDeep),
              const SizedBox(height: 16),
              Text('La IA está creando el reto...', style: TextStyle(color: ctx.colors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── ACCIONES DIARIAS ───────────────────────────────────────────────────────
  Future<void> _generarDiarioIA({bool regenerate = false, bool isManana = false}) async {
    final retoTarget = isManana ? _diarioManana : _diarioHoy;
    if (regenerate && retoTarget != null) {
      final msg = isManana 
        ? '¿Eliminar el reto programado para mañana y generar uno nuevo con IA?'
        : '¡ADVERTENCIA! Eliminar el reto de HOY afectará a los usuarios que ya están corriendo y sumando progreso. ¿Estás absolutamente seguro de querer regenerarlo?';

      final ok = await _confirmar(msg, esPeligroso: !isManana);
      if (!ok) return;
      try {
        await RetosService.eliminarRetoDiario(retoTarget.id);
      } catch (e) {
        _snack('Error al borrar el reto para regenerar', ok: false);
        return;
      }
    }
    
    _mostrarLoadingIA();
    try {
      await RetosService.generarRetoDiarioIA(manana: isManana);
      if (mounted) Navigator.of(context, rootNavigator: true).pop(); // cerrar loading
      _snack(regenerate ? 'Reto regenerado ✅' : 'Reto generado con IA ✅');
      if (isManana) {
        _cargarDiarioManana();
      } else {
        _cargarDiarioHoy();
      }
    } on ApiException catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _snack(e.message, ok: false);
    } catch (_) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _snack('Ocurrió un error', ok: false);
    }
  }

  Future<void> _eliminarDiario({required bool isManana}) async {
    final retoTarget = isManana ? _diarioManana : _diarioHoy;
    if (retoTarget == null) return;
    
    final msg = isManana 
      ? '¿Eliminar el reto de mañana?'
      : '¡ADVERTENCIA! Borrar el reto de HOY quitará la meta a los usuarios activos. ¿Continuar?';
      
    final ok = await _confirmar(msg, esPeligroso: !isManana);
    if (!ok) return;
    try {
      await RetosService.eliminarRetoDiario(retoTarget.id);
      _snack('Reto diario eliminado');
      if (isManana) {
        _cargarDiarioManana();
      } else {
        _cargarDiarioHoy();
      }
    } on ApiException catch (e) {
      _snack(e.message, ok: false);
    }
  }

  // ─── ACCIONES SEMANALES ─────────────────────────────────────────────────────
  Future<void> _generarSemanalIA({bool regenerate = false, bool isProxima = false}) async {
    final retoTarget = isProxima ? _semanalProxima : _semanalActual;
    if (regenerate && retoTarget != null) {
      final msg = isProxima 
        ? '¿Eliminar el reto programado para la próxima semana y generar uno nuevo?'
        : '¡ADVERTENCIA! Eliminar el reto de ESTA SEMANA afectará el progreso acumulado de los usuarios. ¿Estás seguro?';

      final ok = await _confirmar(msg, esPeligroso: !isProxima);
      if (!ok) return;
      try {
        await RetosService.eliminarRetoSemanal(retoTarget.id);
      } catch (e) {
        _snack('Error al borrar el reto para regenerar', ok: false);
        return;
      }
    }
    
    _mostrarLoadingIA();
    try {
      await RetosService.generarRetoSemanalIA(proxima: isProxima);
      if (mounted) Navigator.of(context, rootNavigator: true).pop(); // cerrar loading
      _snack(regenerate ? 'Reto regenerado ✅' : 'Reto generado con IA ✅');
      if (isProxima) {
        _cargarSemanalProxima();
      } else {
        _cargarSemanalActual();
      }
    } on ApiException catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _snack(e.message, ok: false);
    } catch (_) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _snack('Ocurrió un error', ok: false);
    }
  }

  Future<void> _eliminarSemanal({required bool isProxima}) async {
    final retoTarget = isProxima ? _semanalProxima : _semanalActual;
    if (retoTarget == null) return;

    final msg = isProxima 
      ? '¿Eliminar el reto de la próxima semana?'
      : '¡ADVERTENCIA! Borrar el reto de ESTA SEMANA afectará la racha de los usuarios activos. ¿Continuar?';

    final ok = await _confirmar(msg, esPeligroso: !isProxima);
    if (!ok) return;
    try {
      await RetosService.eliminarRetoSemanal(retoTarget.id);
      _snack('Reto semanal eliminado');
      if (isProxima) {
        _cargarSemanalProxima();
      } else {
        _cargarSemanalActual();
      }
    } on ApiException catch (e) {
      _snack(e.message, ok: false);
    }
  }

  // ─── FORMULARIOS ────────────────────────────────────────────────────────────
  void _abrirFormDiario({RetoDiario? initial, bool isManana = false}) {
    DateTime? preselected;
    if (initial == null && isManana) {
      preselected = DateTime.now().add(const Duration(days: 1));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RetoForm(
        titulo: initial?.titulo,
        descripcion: initial?.descripcion,
        tipo: initial?.tipo,
        valorObjetivo: initial?.valorObjetivo,
        puntosRecompensa: initial?.puntosRecompensa,
        esDiario: true,
        defaultFecha: preselected,
        onGuardar: (data) async {
          if (initial != null) {
            await RetosService.editarRetoDiario(initial.id, data);
            _snack('Reto diario actualizado ✅');
          } else {
            await RetosService.crearRetoDiarioManual(
              titulo: data['titulo'] as String,
              descripcion: data['descripcion'] as String?,
              tipo: data['tipo'] as String,
              valorObjetivo: (data['valor_objetivo'] as num).toDouble(),
              unidad: data['unidad'] as String,
              puntosRecompensa: (data['puntos_recompensa'] as num).toInt(),
              fecha: data['fecha'] as String?,
            );
            _snack('Reto diario creado ✅');
          }
          if (isManana) {
            _cargarDiarioManana();
          } else {
            _cargarDiarioHoy();
          }
        },
      ),
    );
  }

  void _abrirFormSemanal({RetoSemanal? initial, bool isProxima = false}) {
    DateTime? preselected;
    if (initial == null && isProxima) {
      final now = DateTime.now();
      preselected = now.subtract(Duration(days: now.weekday - 1)).add(const Duration(days: 7));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RetoForm(
        titulo: initial?.titulo,
        descripcion: initial?.descripcion,
        tipo: initial?.tipo,
        valorObjetivo: initial?.valorObjetivo,
        puntosRecompensa: initial?.puntosRecompensa,
        esDiario: false,
        defaultFecha: preselected,
        onGuardar: (data) async {
          if (initial != null) {
            await RetosService.editarRetoSemanal(initial.id, data);
            _snack('Reto semanal actualizado ✅');
          } else {
            await RetosService.crearRetoSemanalManual(
              titulo: data['titulo'] as String,
              descripcion: data['descripcion'] as String?,
              tipo: data['tipo'] as String,
              valorObjetivo: (data['valor_objetivo'] as num).toDouble(),
              unidad: data['unidad'] as String,
              puntosRecompensa: (data['puntos_recompensa'] as num).toInt(),
              semanaInicio: data['semana_inicio'] as String?,
            );
            _snack('Reto semanal creado ✅');
          }
          if (isProxima) {
            _cargarSemanalProxima();
          } else {
            _cargarSemanalActual();
          }
        },
      ),
    );
  }

  // ─── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(
          backgroundColor: c.surface,
          elevation: 0,
          title: Text('Gestión de Retos', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(58),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: c.primaryDeep.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: const EdgeInsets.all(4),
                  indicatorPadding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                    color: c.primaryDeep,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: c.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                  tabs: const [
                    Tab(text: 'Diarios'),
                    Tab(text: 'Semanales'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabDiarios(c),
            _buildTabSemanales(c),
          ],
        ),
      ),
    );
  }

  Widget _buildTabDiarios(dynamic c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(c, '📅 Reto de Hoy', 
            loading: _loadingDiarioHoy, 
            reto: _diarioHoy, 
            error: _errDiarioHoy, 
            onRetry: _cargarDiarioHoy,
            onGenerarIA: () => _generarDiarioIA(),
            onRegenerarIA: () => _generarDiarioIA(regenerate: true),
            onCrearManual: () => _abrirFormDiario(),
            onEditar: (r) => _abrirFormDiario(initial: r),
            onEliminar: () => _eliminarDiario(isManana: false),
            leyendaRiesgo: '⚠️ Modificar este reto puede afectar resultados de carreras hoy.',
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          _buildSection(c, '🌅 Reto de Mañana', 
            loading: _loadingDiarioManana, 
            reto: _diarioManana, 
            error: _errDiarioManana, 
            onRetry: _cargarDiarioManana,
            onGenerarIA: () => _generarDiarioIA(isManana: true),
            onRegenerarIA: () => _generarDiarioIA(regenerate: true, isManana: true),
            onCrearManual: () => _abrirFormDiario(isManana: true),
            onEditar: (r) => _abrirFormDiario(initial: r, isManana: true),
            onEliminar: () => _eliminarDiario(isManana: true),
            leyendaRiesgo: 'Gestión libre hasta mañana 00:00.',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTabSemanales(dynamic c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(c, '📆 Esta Semana', 
            loading: _loadingSemanalActual, 
            reto: _semanalActual, 
            error: _errSemanalActual, 
            onRetry: _cargarSemanalActual,
            onGenerarIA: () => _generarSemanalIA(),
            onRegenerarIA: () => _generarSemanalIA(regenerate: true),
            onCrearManual: () => _abrirFormSemanal(),
            onEditar: (r) => _abrirFormSemanal(initial: r),
            onEliminar: () => _eliminarSemanal(isProxima: false),
            leyendaRiesgo: '⚠️ Peligro: Cambiar esto afectará las rachas de esta semana.',
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          _buildSection(c, '🚀 Próxima Semana', 
            loading: _loadingSemanalProxima, 
            reto: _semanalProxima, 
            error: _errSemanalProxima, 
            onRetry: _cargarSemanalProxima,
            onGenerarIA: () => _generarSemanalIA(isProxima: true),
            onRegenerarIA: () => _generarSemanalIA(regenerate: true, isProxima: true),
            onCrearManual: () => _abrirFormSemanal(isProxima: true),
            onEditar: (r) => _abrirFormSemanal(initial: r, isProxima: true),
            onEliminar: () => _eliminarSemanal(isProxima: true),
            leyendaRiesgo: 'Gestión libre hasta el lunes.',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(dynamic c, String titulo, {
    required bool loading, 
    required dynamic reto, 
    required String? error,
    required VoidCallback onRetry,
    required VoidCallback onGenerarIA,
    required VoidCallback onRegenerarIA,
    required VoidCallback onCrearManual,
    required Function(dynamic) onEditar,
    required VoidCallback onEliminar,
    required String leyendaRiesgo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary)),
          ],
        ),
        const SizedBox(height: 6),
        Text(leyendaRiesgo, style: TextStyle(fontSize: 12, color: leyendaRiesgo.startsWith('⚠️') ? Colors.orange[800] : c.textHint, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        if (loading)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else if (error != null)
          _errorTile(c, error, onRetry)
        else if (reto == null)
          _sinReto(c, onGenerarIA, onCrearManual)
        else
          _retoActualCard(c, reto, onRegenerarIA, onEditar, onEliminar),
      ],
    );
  }

  Widget _sinReto(dynamic c, VoidCallback onGenerarIA, VoidCallback onCrearManual) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.primaryDeepWithAlpha(0.12)),
      ),
      child: Column(
        children: [
          Text('No hay reto creado aún', style: TextStyle(color: c.textSecondary, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGenerarIA,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                  label: const Text('Generar con IA', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.primaryDeep,
                    side: BorderSide(color: c.primaryDeepWithAlpha(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCrearManual,
                  icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  label: const Text('Crear manual', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primaryDeep,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _retoActualCard(dynamic c, dynamic reto, VoidCallback onRegenerarIA, Function(dynamic) onEditar, VoidCallback onEliminar) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.primaryDeepWithAlpha(0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reto.titulo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.textPrimary)),
          const SizedBox(height: 4),
          Text(reto.objetivoFormateado, style: TextStyle(fontSize: 13, color: c.textSecondary)),
          const SizedBox(height: 4),
          Row(
            children: [
              _tag(c, '${reto.puntosRecompensa} pts', c.primaryDeep),
              const SizedBox(width: 8),
              _tag(c, reto.tipo, c.textHint),
              const SizedBox(width: 8),
              if (reto.generadoPorIA)
                _tag(c, '✨ IA', const Color(0xFF7C3AED)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRegenerarIA,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                  label: const Text('Regenerar IA', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.primaryDeep,
                    side: BorderSide(color: c.primaryDeepWithAlpha(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onEditar(reto),
                icon: Icon(Icons.edit_rounded, color: c.primaryDeep),
                tooltip: 'Editar',
              ),
              IconButton(
                onPressed: onEliminar,
                icon: const Icon(Icons.delete_rounded, color: Color(0xFFE53935)),
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorTile(dynamic c, String msg, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(child: Text(msg, style: TextStyle(color: c.textSecondary, fontSize: 13))),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _tag(dynamic c, String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
  );
}

// ─── FORMULARIO ───────────────────────────────────────────────────────────────

class _RetoForm extends StatefulWidget {
  final String? titulo;
  final String? descripcion;
  final String? tipo;
  final double? valorObjetivo;
  final int? puntosRecompensa;
  final bool esDiario;
  final DateTime? defaultFecha;
  final Future<void> Function(Map<String, dynamic>) onGuardar;

  const _RetoForm({
    this.titulo, this.descripcion, this.tipo, this.valorObjetivo, this.puntosRecompensa,
    required this.esDiario, this.defaultFecha, required this.onGuardar,
  });

  @override
  State<_RetoForm> createState() => _RetoFormState();
}

class _RetoFormState extends State<_RetoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _valorCtrl;
  late TextEditingController _ptsCtrl;
  String _tipo = 'distancia';
  bool _guardando = false;
  DateTime? _fecha;

  static const _tiposValidos = ['distancia', 'tiempo', 'velocidad', 'calorias'];

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.titulo ?? '');
    _descCtrl   = TextEditingController(text: widget.descripcion ?? '');
    _valorCtrl  = TextEditingController(text: widget.valorObjetivo?.toStringAsFixed(0) ?? '');
    _ptsCtrl    = TextEditingController(text: (widget.puntosRecompensa ?? (widget.esDiario ? 10 : 50)).toString());
    _tipo = widget.tipo ?? 'distancia';
    _fecha = widget.defaultFecha;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose(); _descCtrl.dispose(); _valorCtrl.dispose(); _ptsCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final data = <String, dynamic>{
        'titulo': _tituloCtrl.text.trim(),
        'descripcion': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'tipo': _tipo,
        'valor_objetivo': double.parse(_valorCtrl.text),
        'unidad': unidadParaTipo(_tipo),
        'puntos_recompensa': int.parse(_ptsCtrl.text),
      };
      if (widget.esDiario && _fecha != null) data['fecha'] = _fecha!.toIso8601String().split('T')[0];
      if (!widget.esDiario && _fecha != null) data['semana_inicio'] = _fecha!.toIso8601String().split('T')[0];
      await widget.onGuardar(data);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (d != null && mounted) setState(() => _fecha = d);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 8, left: 20, right: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: c.primaryDeepWithAlpha(0.2), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(widget.titulo != null ? 'Editar reto' : 'Crear reto ${widget.esDiario ? "diario" : "semanal"}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary)),
              const SizedBox(height: 16),

              // Título
              _field('Título *', _tituloCtrl, validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
              const SizedBox(height: 12),

              // Descripción
              _field('Descripción', _descCtrl, maxLines: 2),
              const SizedBox(height: 12),

              // Tipo
              Text('Tipo *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: c.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.primaryDeepWithAlpha(0.15))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: _tiposValidos.map((t) => DropdownMenuItem(value: t, child: Text(_tipoLabel(t)))).toList(),
                onChanged: (v) { if (v != null) setState(() => _tipo = v); },
              ),
              const SizedBox(height: 4),
              Text('Unidad automática: ${unidadParaTipo(_tipo)}',
                style: TextStyle(fontSize: 11, color: c.textHint, fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),

              // Valor objetivo
              _field('Valor objetivo *', _valorCtrl,
                keyboardType: TextInputType.number,
                hint: 'ej: 5 (${unidadParaTipo(_tipo)})',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (double.tryParse(v) == null) return 'Debe ser un número';
                  return null;
                }),
              const SizedBox(height: 12),

              // Puntos
              _field('Puntos de recompensa', _ptsCtrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (int.tryParse(v) == null) return 'Debe ser entero';
                  return null;
                }),
              const SizedBox(height: 12),

              // Fecha
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.primaryDeepWithAlpha(0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 18, color: c.primaryDeep),
                      const SizedBox(width: 10),
                      Text(
                        _fecha == null
                            ? (widget.esDiario ? 'Fecha (default: hoy)' : 'Fecha inicio semana (default: lunes actual)')
                            : '${_fecha!.day}/${_fecha!.month}/${_fecha!.year}',
                        style: TextStyle(fontSize: 13, color: _fecha == null ? c.textHint : c.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primaryDeep,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _guardando
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
    String? Function(String?)? validator,
  }) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: c.card,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.primaryDeepWithAlpha(0.15))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.primaryDeepWithAlpha(0.15))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  String _tipoLabel(String t) {
    switch (t) {
      case 'distancia': return 'Distancia (km)';
      case 'tiempo':    return 'Tiempo (minutos)';
      case 'velocidad': return 'Velocidad (km/h)';
      case 'calorias':  return 'Calorías (cal)';
      default: return t;
    }
  }
}
