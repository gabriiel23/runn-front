import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/home/data/models/frase_model.dart';
import 'package:runn_front/features/home/services/frases_service.dart';

class AdminFrasesListPage extends StatefulWidget {
  const AdminFrasesListPage({super.key});

  @override
  State<AdminFrasesListPage> createState() => _AdminFrasesListPageState();
}

class _AdminFrasesListPageState extends State<AdminFrasesListPage> {
  bool _loading = true;
  String? _error;
  List<FraseModel> _frases = [];

  @override
  void initState() {
    super.initState();
    _cargarFrases();
  }

  Future<void> _cargarFrases() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await FrasesService.getAdminFrases();
      if (mounted) {
        setState(() {
          _frases = data;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Error al cargar las frases'; _loading = false; });
    }
  }

  void _snack(String msg, {bool ok = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
    ));
  }

  Future<void> _generarIA() async {
    setState(() => _loading = true);
    try {
      await FrasesService.generarConIA();
      _snack('Frase generada con IA ✅');
      _cargarFrases();
    } catch (e) {
      _snack('Error al generar frase', ok: false);
      setState(() => _loading = false);
    }
  }

  Future<void> _regenerarIA(String id) async {
    setState(() => _loading = true);
    try {
      await FrasesService.regenerarConIA(id);
      _snack('Frase regenerada con IA ✅');
      _cargarFrases();
    } catch (e) {
      _snack('Error al regenerar frase', ok: false);
      setState(() => _loading = false);
    }
  }

  Future<void> _eliminarFrase(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Frase'),
        content: const Text('¿Estás seguro de que deseas eliminar esta frase?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      )
    ) ?? false;

    if (!confirmar) return;

    setState(() => _loading = true);
    try {
      await FrasesService.eliminarFrase(id);
      _snack('Frase eliminada ✅');
      _cargarFrases();
    } catch (e) {
      _snack('Error al eliminar', ok: false);
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleActiva(FraseModel frase, bool activa) async {
    try {
      await FrasesService.actualizarFrase(id: frase.id, activa: activa);
      _cargarFrases();
    } catch (e) {
      _snack('Error al actualizar estado', ok: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        title: Text('Gestión de Frases', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: c.primaryDeep,
        tooltip: 'Crear manual',
        onPressed: () async {
          final reload = await context.push('/admin_frases/new');
          if (reload == true) _cargarFrases();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: _buildBody(c),
    );
  }

  Widget _buildBody(dynamic c) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: TextStyle(color: c.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _cargarFrases, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _generarIA,
              icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
              label: const Text('Generar Frase Mágicamente con IA', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primaryDeep,
                elevation: 4,
                shadowColor: c.primaryDeep.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
        if (_frases.isEmpty)
          Expanded(
            child: Center(
              child: Text('No hay frases configuradas.', style: TextStyle(color: c.textHint)),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100, top: 12, left: 16, right: 16),
              itemCount: _frases.length,
              itemBuilder: (context, index) {
        final f = _frases[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: c.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '"${f.frase}"',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    Switch(
                      value: f.activa,
                      onChanged: (v) => _toggleActiva(f, v),
                      activeThumbColor: c.primaryDeep,
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('- ${f.autor}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textSecondary)),
                    const SizedBox(width: 12),
                    if (f.generadoPorIa)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Text('✨ IA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _regenerarIA(f.id),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                      label: const Text('Regenerar'),
                      style: TextButton.styleFrom(foregroundColor: c.primaryDeep),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_rounded, size: 20, color: c.textSecondary),
                      onPressed: () async {
                        final reload = await context.push('/admin_frases/${f.id}', extra: f.toJson());
                        if (reload == true) _cargarFrases();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                      onPressed: () => _eliminarFrase(f.id),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
            ),
          ),
      ],
    );
  }
}
