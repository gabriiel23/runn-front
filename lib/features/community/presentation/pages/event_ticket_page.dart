import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/models/evento_model.dart';
import '../../services/eventos_service.dart';

class EventTicketPage extends StatefulWidget {
  final String eventId;
  const EventTicketPage({super.key, required this.eventId});

  @override
  State<EventTicketPage> createState() => _EventTicketPageState();
}

class _EventTicketPageState extends State<EventTicketPage> {
  final GlobalKey _globalKey = GlobalKey();
  EventoDetalleModel? _detalle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetalle();
  }

  Future<void> _loadDetalle() async {
    try {
      final data = await EventosService.getEvento(widget.eventId);
      setState(() {
        _detalle = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _saveTicket() async {
    if (await Permission.storage.request().isGranted || await Permission.photos.request().isGranted) {
      try {
        RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final result = await ImageGallerySaverPlus.saveImage(byteData.buffer.asUint8List(), name: "RUNN_TICKET_${widget.eventId}");
          if (mounted && result['isSuccess'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Ticket guardado en la galería 📷'),
              backgroundColor: context.colors.primaryDeep,
            ));
          }
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error guardando: $e')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Requerimos acceder a la galería para guardar tu ticket'),
          backgroundColor: Colors.orangeAccent,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Center(child: CircularProgressIndicator(color: c.primaryDeep)),
      );
    }

    if (_detalle == null || _detalle!.miCodigo == null) {
      return Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('No tienes un ticket válido para este evento.')),
      );
    }

    final evento = _detalle!.evento;
    final codigoMap = _detalle!.miCodigo!;
    final String base64Qr = codigoMap['codigo_qr'].toString().split(',').last;
    final Uint8List qrBytes = base64Decode(base64Qr);
    final String codigoAlpha = codigoMap['codigo_alfanumerico'];
    final bool usado = codigoMap['usado'] == true;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text('Tu Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: c.card,
        foregroundColor: c.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  width: 300,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: c.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'RUNN EVENT PASS',
                          style: TextStyle(color: c.primaryDeep, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        evento.titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        evento.fechaFormateada,
                        style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Image.memory(qrBytes, width: 200, height: 200),
                          ),
                          if (usado)
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(16)),
                              child: const Center(
                                child: Text('YA USADO', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          codigoAlpha,
                          style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Presenta este código en la entrada del evento.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!usado)
                ElevatedButton.icon(
                  onPressed: _saveTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primaryDeep,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Descargar a Galería', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
