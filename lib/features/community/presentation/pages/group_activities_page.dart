import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/grupos_service.dart';
import '../../domain/models/grupo_model.dart';
import '../../../../core/services/http_client.dart';

/// Estados locales por actividad durante la sesión
enum _EstadoActividad { libre, participando, completado }

class GroupActivitiesPage extends StatefulWidget {
  final String grupoId;
  final String? miRol;

  const GroupActivitiesPage({super.key, required this.grupoId, this.miRol});

  @override
  State<GroupActivitiesPage> createState() => _GroupActivitiesPageState();
}

class _GroupActivitiesPageState extends State<GroupActivitiesPage> {
  List<GrupoActividad> _actividades = [];
  bool _isLoading = true;
  bool _isActing = false;
  bool _soyMiembro = false;
  final Map<String, _EstadoActividad> _estados = {};

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
      setState(() { _actividades = detalle.actividades; _soyMiembro = detalle.soyMiembro; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _participar(GrupoActividad actividad) async {
    if (_isActing) return;
    setState(() => _isActing = true);
    try {
      await GruposService.participarActividad(widget.grupoId, actividad.id);
      if (mounted) setState(() { _estados[actividad.id] = _EstadoActividad.participando; });
    } on ApiException catch (e) {
      if (e.message.toLowerCase().contains('ya estás participando')) {
        if (mounted) setState(() { _estados[actividad.id] = _EstadoActividad.participando; });
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

  Future<void> _completar(GrupoActividad actividad) async {
    if (_isActing) return;
    setState(() => _isActing = true);
    try {
      await GruposService.completarActividad(widget.grupoId, actividad.id);
      if (mounted) setState(() { _estados[actividad.id] = _EstadoActividad.completado; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Actividad completada! 🎉'), backgroundColor: Color(0xFF34C759)));
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

  void _mostrarFormCrear() {
    final c = context.colors;
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final lugarCtrl = TextEditingController();
    String tipoSeleccionado = 'senderismo';
    DateTime? fecha;
    TimeOfDay? hora;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          height: MediaQuery.of(ctx).size.height * 0.9,
          decoration: BoxDecoration(color: c.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: c.primaryDeepWithAlpha(0.2), borderRadius: BorderRadius.circular(2))),
            Padding(padding: const EdgeInsets.all(20),
              child: Text('Nueva Actividad', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.textPrimary))),
            Divider(height: 1, color: c.primaryDeepWithAlpha(0.1)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _inputField(c, tituloCtrl, 'Título de la actividad *', Icons.directions_run_rounded),
                  const SizedBox(height: 12),
                  _inputField(c, descCtrl, 'Descripción (opcional)', Icons.description_rounded, maxLines: 2),
                  const SizedBox(height: 12),
                  _inputField(c, lugarCtrl, 'Lugar (opcional)', Icons.place_rounded),
                  const SizedBox(height: 16),
                  Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _tipoBtn(c, 'senderismo', '🥾 Senderismo', tipoSeleccionado, (v) => setModal(() => tipoSeleccionado = v))),
                    const SizedBox(width: 10),
                    Expanded(child: _tipoBtn(c, 'correr', '👟 Correr', tipoSeleccionado, (v) => setModal(() => tipoSeleccionado = v))),
                  ]),
                  const SizedBox(height: 16),
                  _dateButton(c, 'Fecha', fecha, () async {
                    final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                    if (d != null) setModal(() => fecha = d);
                  }),
                  const SizedBox(height: 8),
                  _timeButton(c, 'Hora', hora, () async {
                    final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                    if (t != null) setModal(() => hora = t);
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
                          final horaStr = hora != null
                              ? '${hora!.hour.toString().padLeft(2, '0')}:${hora!.minute.toString().padLeft(2, '0')}'
                              : null;
                          await GruposService.crearActividad(
                            grupoId: widget.grupoId,
                            titulo: tituloCtrl.text.trim(),
                            descripcion: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                            tipo: tipoSeleccionado,
                            lugar: lugarCtrl.text.trim().isNotEmpty ? lugarCtrl.text.trim() : null,
                            fecha: fecha?.toIso8601String(),
                            hora: horaStr,
                          );
                          if (mounted) await _load();
                        } catch (_) {}
                        if (mounted) setState(() => _isActing = false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: c.primaryDeep, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('Crear Actividad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _tipoBtn(dynamic c, String value, String label, String current, Function(String) onTap) {
    final sel = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: sel ? c.primaryDeepWithAlpha(0.1) : c.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? c.primaryDeep : c.primaryDeepWithAlpha(0.08), width: sel ? 1.5 : 1)),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: sel ? c.primaryDeep : c.textPrimary), textAlign: TextAlign.center),
      ),
    );
  }

  Widget _inputField(dynamic c, TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.primaryDeepWithAlpha(0.07))),
      child: TextField(controller: ctrl, maxLines: maxLines, style: TextStyle(color: c.textPrimary),
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

  Widget _timeButton(dynamic c, String label, TimeOfDay? time, VoidCallback onTap) {
    final texto = time != null ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}' : 'Seleccionar';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.primaryDeepWithAlpha(0.07))),
        child: Row(children: [
          Icon(Icons.access_time_rounded, color: c.primaryDeep, size: 18), const SizedBox(width: 10),
          Text('$label: $texto', style: TextStyle(color: time != null ? c.textPrimary : c.textHint, fontWeight: FontWeight.w500)),
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
        title: Text('Actividades', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: Icon(Icons.leaderboard_rounded, color: c.primaryDeep),
            tooltip: 'Ver ranking',
            onPressed: () => context.pushNamed('group_ranking', pathParameters: {'grupoId': widget.grupoId, 'tipo': 'actividades'}),
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: c.primaryDeepWithAlpha(0.08), height: 1)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : _actividades.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.directions_run_rounded, size: 64, color: c.primaryDeepWithAlpha(0.2)),
                  const SizedBox(height: 16),
                  Text('No hay actividades aún', style: TextStyle(color: c.textHint, fontSize: 16, fontWeight: FontWeight.w600)),
                ]))
              : Stack(children: [
                  ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _actividades.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _buildActividadCard(c, _actividades[i]),
                  ),
                  if (_isActing) Container(color: Colors.black.withValues(alpha: 0.3), child: const Center(child: CircularProgressIndicator())),
                ]),
      floatingActionButton: _esAdmin
          ? FloatingActionButton.extended(
              onPressed: _mostrarFormCrear,
              backgroundColor: c.primaryDeep,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Nueva Actividad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildActividadCard(dynamic c, GrupoActividad a) {
    final estado = _estados[a.id] ?? _EstadoActividad.libre;
    final tipoIcon = a.tipo == 'correr' ? Icons.directions_run_rounded : Icons.terrain_rounded;
    final tipoColor = a.tipo == 'correr' ? c.primaryDeep : const Color(0xFF7ED957);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.primaryDeepWithAlpha(0.07))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: tipoColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(tipoIcon, color: tipoColor, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.titulo, style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary, fontSize: 15)),
            if (a.lugar != null)
              Row(children: [Icon(Icons.place_rounded, size: 12, color: c.textHint), const SizedBox(width: 4), Text(a.lugar!, style: TextStyle(fontSize: 12, color: c.textSecondary))]),
          ])),
        ]),
        if (a.descripcion != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(a.descripcion!, style: TextStyle(fontSize: 13, color: c.textSecondary, height: 1.4))),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: [
          if (a.fecha != null) _tag(c, '📅 ${a.fechaFmt}'),
          if (a.horaFmt.isNotEmpty) _tag(c, '🕐 ${a.horaFmt}'),
          _tag(c, '${a.participantes} participantes'),
        ]),
        const SizedBox(height: 12),
        // ── Botones según estado ──────────────────────────────
        if (_soyMiembro)
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (estado == _EstadoActividad.libre)
              ElevatedButton.icon(
                onPressed: _isActing ? null : () => _participar(a),
                icon: const Icon(Icons.directions_run_rounded, size: 16, color: Colors.white),
                label: const Text('Participar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: c.primaryDeep, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              )
            else if (estado == _EstadoActividad.participando)
              ElevatedButton.icon(
                onPressed: _isActing ? null : () => _completar(a),
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
