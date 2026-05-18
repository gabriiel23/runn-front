import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../domain/models/evento_model.dart';
import '../../services/eventos_service.dart';

class EventPaymentPage extends StatefulWidget {
  final EventoModel evento;

  const EventPaymentPage({super.key, required this.evento});

  @override
  State<EventPaymentPage> createState() => _EventPaymentPageState();
}

class _EventPaymentPageState extends State<EventPaymentPage> {
  XFile? _receiptFile;
  Uint8List? _receiptBytes;
  bool _isSaving = false;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compresión sugerida
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _receiptFile = file;
      _receiptBytes = bytes;
    });
  }

  Future<void> _submitPayment() async {
    if (_receiptBytes == null || _receiptFile == null) {
      _showSnackbar('Debes subir un comprobante de pago');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await EventosService.unirseEventoPago(
        widget.evento.id,
        comprobanteBytes: _receiptBytes!,
        comprobanteFilename: _receiptFile!.name,
      );
      if (!mounted) return;
      _showSnackbar('Comprobante enviado. El administrador lo revisará pronto.', success: true);
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      _showSnackbar(e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackbar(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cuentas = widget.evento.cuentasBancarias ?? [];

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('Validación de Pago', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: c.bg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.primaryDeep.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.primaryDeep.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_available_rounded, color: c.primaryDeep, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Inscripción a:', style: TextStyle(color: c.textHint, fontSize: 13)),
                        Text(widget.evento.titulo, style: TextStyle(color: c.primaryDeep, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Text('\$${widget.evento.precio.toStringAsFixed(2)}', style: TextStyle(color: c.primaryDeep, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('1. Realiza la transferencia', style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Deposita a cualquiera de las siguientes cuentas bancarias y guarda el comprobante o captura de pantalla.', style: TextStyle(color: c.textHint, fontSize: 14)),
            const SizedBox(height: 16),

            if (cuentas.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text('El administrador no registró cuentas bancarias. Contactalo directamente.', style: TextStyle(color: c.textHint), textAlign: TextAlign.center)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cuentas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cuenta = cuentas[index] as Map<String, dynamic>;
                  return _buildCuentaCard(c, cuenta);
                },
              ),

            const SizedBox(height: 32),

            Text('2. Sube el comprobante', style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Asegúrate de que la fecha, monto y número de referencia se vean claramente.', style: TextStyle(color: c.textHint, fontSize: 14)),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: c.inputFill,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _receiptBytes == null ? c.inputBorder : c.primaryDeep, width: 2),
                ),
                child: _receiptBytes == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded, size: 50, color: c.primaryDeep.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text('Toca aquí para seleccionar', style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w600)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(_receiptBytes!, fit: BoxFit.cover, width: double.infinity),
                      ),
              ),
            ),
            if (_receiptBytes != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _pickPhoto,
                  icon: Icon(Icons.refresh_rounded, size: 16, color: c.textSecondary),
                  label: Text('Cambiar foto', style: TextStyle(color: c.textSecondary)),
                ),
              ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primaryDeep,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Enviar a Validación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCuentaCard(dynamic c, Map<String, dynamic> cuenta) {
    final banco = cuenta['banco'] ?? 'Banco Desconocido';
    final numero = cuenta['numero'] ?? '';
    final titular = cuenta['titular'] ?? '';
    final cedula = cuenta['cedula'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_rounded, color: c.textSecondary, size: 20),
              const SizedBox(width: 8),
              Text(banco.toString(), style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          _buildRowInfo(c, 'Titular', titular.toString()),
          const SizedBox(height: 8),
          _buildRowInfo(c, 'Identificación', cedula.toString()),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Número de cuenta', style: TextStyle(color: c.textHint, fontSize: 12)),
                  Text(numero.toString(), style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1)),
                ],
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: numero.toString()));
                  _showSnackbar('Número copiado al portapapeles', success: true);
                },
                icon: Icon(Icons.copy_rounded, color: c.primaryDeep, size: 20),
                tooltip: 'Copiar número',
                style: IconButton.styleFrom(backgroundColor: c.primaryDeep.withValues(alpha: 0.1)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRowInfo(dynamic c, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: c.textHint, fontSize: 13)),
        Text(value, style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
