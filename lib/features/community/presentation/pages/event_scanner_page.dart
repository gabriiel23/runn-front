import 'package:flutter/material.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/eventos_service.dart';

class EventScannerPage extends StatefulWidget {
  final String eventId;

  const EventScannerPage({super.key, required this.eventId});

  @override
  State<EventScannerPage> createState() => _EventScannerPageState();
}

class _EventScannerPageState extends State<EventScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String barcodeValue) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    // El formato del QR es: "RUNN-EVENTO:{eventoId}:{userId}:{codigoAlfanumerico}"
    // Pero el admin también puede digitar el código alfanumérico manualmente.
    // Nosotros enviaremos el valor completo o parcial al backend, y el backend sabrá qué hacer (porque busca por codigo == req.body.codigo).
    // Nota: El backend de hecho lo busca por 'codigo_alfanumerico'. En el backend dice:
    // const qrParts = codigo.split(':'); if qrParts[0]==RUNN-EVENTO -> qrParts[3] is the alfanumerico.
    
    try {
      final res = await EventosService.verificarCodigo(widget.eventId, barcodeValue);
      final status = res['status'] as String?;
      
      if (!mounted) return;
      
      IconData icon;
      Color color;
      String message;
      String title;
      
      if (status == 'valido') {
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        title = 'Acceso Permitido';
        message = 'El código es válido. Participante registrado correctamente.';
      } else if (status == 'usado') {
        icon = Icons.warning_rounded;
        color = Colors.orange;
        title = 'Código Ya Usado';
        message = 'El código fue verificado en ${res['verificado_en']}';
      } else {
        icon = Icons.error_rounded;
        color = Colors.red;
        title = 'Código Inválido';
        message = 'Este código no pertenece a un participante admitido en este evento.';
      }
      
      await _showResultModal(title, message, color, icon);
    } catch (e) {
      if (!mounted) return;
      await _showResultModal('Error de Servidor', 'No se pudo verificar: $e', Colors.red, Icons.error);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        _controller.start(); // Restart scanner
      }
    }
  }

  Future<void> _showResultModal(String title, String message, Color color, IconData icon) async {
    _controller.stop();
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: context.colors.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: color),
            const SizedBox(height: 24),
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: context.colors.textSecondary)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primaryDeep,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Comprendido, continuar 📸', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    final c = context.colors;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Ingreso Manual', style: TextStyle(fontWeight: FontWeight.bold, color: c.textPrimary)),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          maxLength: 8,
          decoration: InputDecoration(
            hintText: 'Ej. RUNN8X2',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar', style: TextStyle(color: c.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (controller.text.isNotEmpty) {
                _handleScan(controller.text.trim().toUpperCase());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: c.primaryDeep, foregroundColor: Colors.white),
            child: const Text('Verificar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Verificar Accesos', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleScan(barcode.rawValue!);
                  break; // ParseamoS el primero que detecte
                }
              }
            },
          ),
          // Scanner Overlay overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: context.colors.primaryDeep,
                borderRadius: 20,
                borderLength: 40,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          if (_isProcessing)
            Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton.icon(
        onPressed: _showManualEntryDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: context.colors.primaryDeep,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
        ),
        icon: const Icon(Icons.keyboard_rounded),
        label: const Text('Ingresar Código Alfa', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);

    rect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    path.addRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
    );

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderOffset = borderWidth / 2;
    final actualBorderLength = borderLength > cutOutSize / 2 + borderOffset ? cutOutSize / 2 + borderOffset : borderLength;
    final actualCutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: actualCutOutSize,
      height: actualCutOutSize,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)), boxPaint)
      ..restore();

    // Top left
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top + borderRadius),
      Offset(cutOutRect.left, cutOutRect.top + actualBorderLength),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left + borderRadius, cutOutRect.top),
      Offset(cutOutRect.left + actualBorderLength, cutOutRect.top),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cutOutRect.left + borderRadius, cutOutRect.top + borderRadius), radius: borderRadius),
      3.14,
      1.57,
      false,
      borderPaint,
    );

    // Top right
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.top + borderRadius),
      Offset(cutOutRect.right, cutOutRect.top + actualBorderLength),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right - borderRadius, cutOutRect.top),
      Offset(cutOutRect.right - actualBorderLength, cutOutRect.top),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cutOutRect.right - borderRadius, cutOutRect.top + borderRadius), radius: borderRadius),
      4.71,
      1.57,
      false,
      borderPaint,
    );

    // Bottom right
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.bottom - borderRadius),
      Offset(cutOutRect.right, cutOutRect.bottom - actualBorderLength),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right - borderRadius, cutOutRect.bottom),
      Offset(cutOutRect.right - actualBorderLength, cutOutRect.bottom),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cutOutRect.right - borderRadius, cutOutRect.bottom - borderRadius), radius: borderRadius),
      0,
      1.57,
      false,
      borderPaint,
    );

    // Bottom left
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.bottom - borderRadius),
      Offset(cutOutRect.left, cutOutRect.bottom - actualBorderLength),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left + borderRadius, cutOutRect.bottom),
      Offset(cutOutRect.left + actualBorderLength, cutOutRect.bottom),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cutOutRect.left + borderRadius, cutOutRect.bottom - borderRadius), radius: borderRadius),
      1.57,
      1.57,
      false,
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
