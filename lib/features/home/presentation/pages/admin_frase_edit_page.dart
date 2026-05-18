import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/services/http_client.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:runn_front/features/home/services/frases_service.dart';

class AdminFraseEditPage extends StatefulWidget {
  final String fraseId;
  final Map<String, dynamic>? fraseData;

  const AdminFraseEditPage({super.key, required this.fraseId, this.fraseData});

  @override
  State<AdminFraseEditPage> createState() => _AdminFraseEditPageState();
}

class _AdminFraseEditPageState extends State<AdminFraseEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fraseCtrl;
  late TextEditingController _autorCtrl;
  
  bool _activa = true;
  bool _guardando = false;

  bool get _isNew => widget.fraseId == 'new';

  @override
  void initState() {
    super.initState();
    _fraseCtrl = TextEditingController(text: widget.fraseData?['frase'] ?? '');
    _autorCtrl = TextEditingController(text: widget.fraseData?['autor'] ?? '');
    _activa = widget.fraseData?['activa'] ?? true;
  }

  @override
  void dispose() {
    _fraseCtrl.dispose();
    _autorCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool ok = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
    ));
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _guardando = true);
    
    try {
      if (_isNew) {
        await FrasesService.crearFraseManual(
          frase: _fraseCtrl.text.trim(),
          autor: _autorCtrl.text.trim(),
        );
        _snack('Frase creada correctamente ✅');
      } else {
        await FrasesService.actualizarFrase(
          id: widget.fraseId,
          frase: _fraseCtrl.text.trim(),
          autor: _autorCtrl.text.trim(),
          activa: _activa
        );
        _snack('Frase actualizada correctamente ✅');
      }
      if (mounted) context.pop(true);
    } on ApiException catch (e) {
      _snack(e.message, ok: false);
    } catch (_) {
      _snack('Ocurrió un error', ok: false);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        title: Text(_isNew ? 'Nueva Frase' : 'Editar Frase', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contenido de la frase *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textSecondary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fraseCtrl,
                maxLines: 3,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: c.card,
                  hintText: 'Escribe una frase inspiradora',
                  hintStyle: TextStyle(color: c.textHint),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa la frase' : null,
              ),
              const SizedBox(height: 24),
              
              Text('Autor *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textSecondary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _autorCtrl,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: c.card,
                  hintText: 'Ej: RUNN, Confucio, etc.',
                  hintStyle: TextStyle(color: c.textHint),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el autor' : null,
              ),
              const SizedBox(height: 32),
              
              if (!_isNew)
                SwitchListTile(
                  title: Text('Frase Activa', style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)),
                  subtitle: Text('Visible en el carrusel del home', style: TextStyle(color: c.textSecondary)),
                  value: _activa,
                  activeThumbColor: c.primaryDeep,
                  onChanged: (v) => setState(() => _activa = v),
                  contentPadding: EdgeInsets.zero,
                ),
                
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primaryDeep,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Guardar Frase', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
