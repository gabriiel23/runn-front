import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/grupos_service.dart';
import '../../domain/models/grupo_model.dart';
import '../../../../core/services/http_client.dart';

/// Estados locales por reto durante la sesión
enum _EstadoReto { libre, participando, completado }

class GroupChallengesPage extends StatefulWidget {
  final String grupoId;
  final String? miRol;

  const GroupChallengesPage({super.key, required this.grupoId, this.miRol});

  @override
  State<GroupChallengesPage> createState() => _GroupChallengesPageState();
}

class _GroupChallengesPageState extends State<GroupChallengesPage> {
  List<GrupoReto> _retos = [];
  bool _isLoading = true;
  bool _isActing = false;
  bool _soyMiembro = false;
  // Mapa de estado local por retoId
  final Map<String, _EstadoReto> _estados = {};

  bool get _esAdmin => widget.miRol == 'admin' || widget.miRol == 'creador';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final detalle = await GruposService.getGrupoDetalle(widget.grupoId);
      if (!mounted) return;
      setState(() { _retos = detalle.retos; _soyMiembro = detalle.soyMiembro; _isLoading = false; });
      // Inicializar estados: el backend no devuelve si el usuario ya participa,
      // así que los empezamos todos en 'libre'. El usuario verá la transición
      // al tocar el botón por primera vez.
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _participar(GrupoReto reto) async {
    if (_isActing) return;
    setState(() => _isActing = true);
    try {
      await GruposService.participarReto(widget.grupoId, reto.id);
      // 200 → está participando ahora
      if (mounted) setState(() { _estados[reto.id] = _EstadoReto.participando; });
    } on ApiException catch (e) {
      // 400 "ya estás participando" → también pasar a estado participando
      if (e.message.toLowerCase().contains('ya estás participando')) {
        if (mounted) setState(() { _estados[reto.id] = _EstadoReto.participando; });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFFF3B30)));
        }
      }
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  Future<void> _completar(GrupoReto reto) async {
    if (_isActing) return;
    setState(() => _isActing = true);
    try {
      await GruposService.completarReto(widget.grupoId, reto.id);
      if (mounted) setState(() { _estados[reto.id] = _EstadoReto.completado; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Reto completado! 🎉'), backgroundColor: Color(0xFF34C759)));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFFF3B30)));
      }
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  void _mostrarFormCrearReto() {
    final c = context.colors;
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final kmCtrl = TextEditingController();
    DateTime? fechaInicio;
    DateTime? fechaFin;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(color: c.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: c.primaryDeepWithAlpha(0.2), borderRadius: BorderRadius.circular(2))),
              Padding(padding: const EdgeInsets.all(20),
                child: Text('Nuevo Reto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.textPrimary))),
              Divider(height: 1, color: c.primaryDeepWithAlpha(0.1)),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _inputField(c, tituloCtrl, 'Título del reto *', Icons.flag_rounded),
                    const SizedBox(height: 12),
                    _inputField(c, descCtrl, 'Descripción (opcional)', Icons.description_rounded, maxLines: 3),
                    const SizedBox(height: 12),
                    _inputField(c, kmCtrl, 'Distancia en km (opcional)', Icons.directions_run_rounded, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _dateButton(c, 'Fecha inicio', fechaInicio, () async {
                      final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                      if (d != null) setModal(() => fechaInicio = d);
                    }),
                    const SizedBox(height: 8),
                    _dateButton(c, 'Fecha fin', fechaFin, () async {
                      final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                      if (d != null) setModal(() => fechaFin = d);
                    }),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (tituloCtrl.text.trim().isEmpty) return;
                          Navigator.pop(ctx);
                          setState(() => _isActing = true);
                          try {
                            await GruposService.crearReto(
                              grupoId: widget.grupoId,
                              titulo: tituloCtrl.text.trim(),
                              descripcion: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                              distanciaKm: kmCtrl.text.trim().isNotEmpty ? kmCtrl.text.trim() : null,
                              fechaInicio: fechaInicio?.toIso8601String(),
                              fechaFin: fechaFin?.toIso8601String(),
                            );
                            if (mounted) await _load();
                          } catch (_) {}
                          if (mounted) setState(() => _isActing = false);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: c.primaryDeep, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: const Text('Crear Reto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(dynamic c, TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.primaryDeepWithAlpha(0.07))),
      child: TextField(controller: ctrl, maxLines: maxLines, keyboardType: keyboardType, style: TextStyle(color: c.textPrimary),
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: c.textHint), prefixIcon: Icon(icon, color: c.primaryDeep, size: 20), border: InputBorder.none, contentPadding: const EdgeInsets.all(14)),
      ),
    );
  }

  Widget _dateButton(dynamic c, String label, DateTime? date, VoidCallback onTap) {
    final texto = date != null ? '${date.day}/${date.month}/${date.year}' : 'Seleccionar';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.primaryDeepWithAlpha(0.07))),
        child: Row(children: [
          Icon(Icons.calendar_today_rounded, color: c.primaryDeep, size: 18), const SizedBox(width: 10),
          Text('$label: $texto', style: TextStyle(color: date != null ? c.textPrimary : c.textHint, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary), onPressed: () => context.pop()),
        title: Text('Retos del grupo', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: Icon(Icons.leaderboard_rounded, color: c.primaryDeep),
            tooltip: 'Ver ranking',
            onPressed: () => context.pushNamed('group_ranking', pathParameters: {'grupoId': widget.grupoId, 'tipo': 'retos'}),
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: c.primaryDeepWithAlpha(0.08), height: 1)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : _retos.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.flag_rounded, size: 64, color: c.primaryDeepWithAlpha(0.2)),
                  const SizedBox(height: 16),
                  Text('No hay retos aún', style: TextStyle(color: c.textHint, fontSize: 16, fontWeight: FontWeight.w600)),
                ]))
              : Stack(children: [
                  ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _retos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _buildRetoCard(c, _retos[i]),
                  ),
                  if (_isActing) Container(color: Colors.black.withValues(alpha: 0.3), child: const Center(child: CircularProgressIndicator())),
                ]),
      floatingActionButton: _esAdmin
          ? FloatingActionButton.extended(
              onPressed: _mostrarFormCrearReto,
              backgroundColor: c.primaryDeep,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Nuevo Reto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildRetoCard(dynamic c, GrupoReto reto) {
    final estado = _estados[reto.id] ?? _EstadoReto.libre;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.primaryDeepWithAlpha(0.07))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: c.primaryDeepWithAlpha(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.flag_rounded, color: c.primaryDeep, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(reto.titulo, style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary, fontSize: 15)),
            if (reto.distanciaKm != null)
              Text('${reto.distanciaKm} km', style: TextStyle(fontSize: 12, color: c.primaryDeep, fontWeight: FontWeight.w600)),
          ])),
        ]),
        if (reto.descripcion != null)
          Padding(padding: const EdgeInsets.only(top: 8), child: Text(reto.descripcion!, style: TextStyle(fontSize: 13, color: c.textSecondary, height: 1.4))),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: [
          if (reto.fechaInicio != null) _tag(c, '📅 ${reto.fechaInicioFmt}'),
          if (reto.fechaFin != null) _tag(c, '🏁 ${reto.fechaFinFmt}'),
          _tag(c, '${reto.participantes} participantes'),
        ]),
        const SizedBox(height: 12),
        // ── Botones según estado ──────────────────────────────────
        if (_soyMiembro)
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (estado == _EstadoReto.libre)
              ElevatedButton.icon(
                onPressed: _isActing ? null : () => _participar(reto),
                icon: const Icon(Icons.directions_run_rounded, size: 16, color: Colors.white),
                label: const Text('Participar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: c.primaryDeep, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              )
            else if (estado == _EstadoReto.participando)
              ElevatedButton.icon(
                onPressed: _isActing ? null : () => _completar(reto),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
                label: const Text('Completar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF34C759), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF34C759).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF34C759)),
                  SizedBox(width: 6),
                  Text('Completado ✅', style: TextStyle(color: Color(0xFF34C759), fontWeight: FontWeight.w700, fontSize: 13)),
                ]),
              ),
          ]),
      ]),
    );
  }

  Widget _tag(dynamic c, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.primaryDeepWithAlpha(0.07), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 11, color: c.textSecondary, fontWeight: FontWeight.w500)),
    );
  }
}
