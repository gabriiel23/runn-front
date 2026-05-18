import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/eventos_service.dart';
import '../../domain/models/evento_model.dart';
import 'route_picker_page.dart';
import '../../../../core/services/http_client.dart';

/// Pantalla para Crear o Editar un evento. Solo accesible para admin.
class EventEditPage extends StatefulWidget {
  final String? eventId;
  final EventoModel? evento;

  const EventEditPage({super.key, this.eventId, this.evento});

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _placeCtrl;
  late TextEditingController _distanceCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _timeCtrl;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  bool _esPago = false;
  late TextEditingController _precioCtrl;
  late TextEditingController _limiteParticipantesCtrl;
  late TextEditingController _limiteListaEsperaCtrl;

  // Nueva foto seleccionada (si el admin la cambia)
  XFile? _newPhotoFile;
  Uint8List? _newPhotoBytes;
  
  List<LatLng> _routePoints = [];
  List<String> _indicaciones = [];
  List<Map<String, String>> _cuentasBancarias = [];
  final TextEditingController _indicacionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.evento;

    _titleCtrl = TextEditingController(text: e?.titulo);
    _descCtrl = TextEditingController(text: e?.descripcion ?? '');
    _placeCtrl = TextEditingController(text: e?.lugar ?? '');
    _distanceCtrl = TextEditingController(
      text: e?.distanciaKm?.toString() ?? '',
    );

    _selectedDate = e?.fecha;
    _dateCtrl = TextEditingController(text: e != null ? e.fechaFormateada : '');

    _selectedTime = e?.hora != null
        ? TimeOfDay(hour: e!.hora!.hour, minute: e.hora!.minute)
        : null;
    _timeCtrl = TextEditingController(text: e != null ? e.horaFormateada : '');

    _esPago = e?.esPago ?? false;
    _precioCtrl = TextEditingController(
      text: e != null && e.precio > 0 ? e.precio.toString() : '',
    );
    _limiteParticipantesCtrl = TextEditingController(
      text: e?.limiteParticipantes?.toString() ?? '',
    );
    _limiteListaEsperaCtrl = TextEditingController(
      text: e?.limiteListaEspera?.toString() ?? '',
    );

    if (e?.puntoInicio != null && e?.puntoFin != null) {
      _routePoints.add(LatLng(e!.puntoInicio!['lat'], e.puntoInicio!['lng']));
      if (e.waypoints != null && e.waypoints!.isNotEmpty) {
        final sortedList = List.from(e.waypoints!);
        sortedList.sort((a, b) => (a['orden'] as int).compareTo(b['orden'] as int));
        for (var wp in sortedList) {
          _routePoints.add(LatLng(wp['lat'], wp['lng']));
        }
      }
      _routePoints.add(LatLng(e.puntoFin!['lat'], e.puntoFin!['lng']));
    }

    _indicaciones = List<String>.from(e?.indicaciones ?? []);
    if (e?.cuentasBancarias != null && e!.cuentasBancarias!.isNotEmpty) {
      _cuentasBancarias = e.cuentasBancarias!.map((c) => {
        'banco': c['banco']?.toString() ?? '',
        'numero': c['numero']?.toString() ?? '',
        'titular': c['titular']?.toString() ?? '',
        'cedula': c['cedula']?.toString() ?? '',
      }).toList();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _placeCtrl.dispose();
    _distanceCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _precioCtrl.dispose();
    _limiteParticipantesCtrl.dispose();
    _limiteListaEsperaCtrl.dispose();
    _indicacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _openRoutePicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoutePickerPage(initialPoints: _routePoints)),
    );
    if (result != null && result is List<LatLng>) {
      setState(() {
        _routePoints = result;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = _formatDateLabel(picked);
      });
    }
  }

  String _formatDateLabel(DateTime d) {
    const meses = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${d.day} de ${meses[d.month]} de ${d.year}';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        final h = picked.hour.toString().padLeft(2, '0');
        final m = picked.minute.toString().padLeft(2, '0');
        _timeCtrl.text = '$h:$m';
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes(); // Returns Uint8List
    setState(() {
      _newPhotoFile = file;
      _newPhotoBytes = bytes;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Si estamos creando, hay campos obligatorios que el form no puede tener nulos si pasa validación,
    // pero debemos asegurarnos de la fecha y hora.
    final esCreacion = widget.eventId == null;
    if (esCreacion) {
      if (_selectedDate == null) {
        _showSnackbar('Selecciona la fecha del evento');
        return;
      }
      if (_selectedTime == null) {
        _showSnackbar('Selecciona la hora del evento');
        return;
      }
      if (_placeCtrl.text.trim().isEmpty) {
        _showSnackbar('Ingresa el lugar del evento');
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final campos = <String, String>{
        'titulo': _titleCtrl.text.trim(),
        if (_descCtrl.text.trim().isNotEmpty)
          'descripcion': _descCtrl.text.trim(),
        if (_placeCtrl.text.trim().isNotEmpty) 'lugar': _placeCtrl.text.trim(),
        if (_distanceCtrl.text.trim().isNotEmpty)
          'distancia_km': _distanceCtrl.text.trim(),
        if (_selectedDate != null)
          'fecha': _selectedDate!.toIso8601String().split('T').first,
        if (_selectedTime != null)
          'hora':
              '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        'es_pago': _esPago.toString(),
        if (_esPago && _precioCtrl.text.trim().isNotEmpty)
          'precio': _precioCtrl.text.trim(),
        if (_esPago && _cuentasBancarias.isNotEmpty)
          'cuentas_bancarias': jsonEncode(_cuentasBancarias),
        if (_limiteParticipantesCtrl.text.trim().isNotEmpty)
          'limite_participantes': _limiteParticipantesCtrl.text.trim(),
        if (_limiteListaEsperaCtrl.text.trim().isNotEmpty)
          'limite_lista_espera': _limiteListaEsperaCtrl.text.trim(),
        if (_routePoints.length >= 2) ...{
          'punto_inicio': jsonEncode({'lat': _routePoints.first.latitude, 'lng': _routePoints.first.longitude, 'nombre': 'Inicio'}),
          'punto_fin': jsonEncode({'lat': _routePoints.last.latitude, 'lng': _routePoints.last.longitude, 'nombre': 'Meta'}),
          if (_routePoints.length > 2)
            'waypoints': jsonEncode(_routePoints.sublist(1, _routePoints.length - 1).asMap().entries.map((e) => {
              'lat': e.value.latitude,
              'lng': e.value.longitude,
              'orden': e.key + 1
            }).toList()),
        },
        if (_indicaciones.isNotEmpty)
          'indicaciones': jsonEncode(_indicaciones),
      };

      if (esCreacion) {
        await EventosService.crearEvento(
          campos: campos,
          fotoBytes: _newPhotoBytes,
          fotoFilename: _newPhotoFile?.name,
        );
        if (!mounted) return;
        _showSnackbar('Evento creado exitosamente 🎉', success: true);
      } else {
        await EventosService.editarEvento(
          widget.eventId!,
          campos: campos,
          fotoBytes: _newPhotoBytes,
          fotoFilename: _newPhotoFile?.name,
        );
        if (!mounted) return;
        _showSnackbar('Evento actualizado exitosamente ✅', success: true);
      }

      context.pop(true); // Retorna "true" para recargar lista o detalle
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnackbar(e.message);
    } catch (_) {
      if (!mounted) return;
      _showSnackbar('Ocurrió un error inesperado.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackbar(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success
            ? const Color(0xFF34C759)
            : const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
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
          icon: Icon(Icons.close_rounded, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.eventId == null ? 'Crear Evento' : 'Editar Evento',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.primaryDeep,
                      ),
                    )
                  : Text(
                      widget.eventId == null ? 'Crear' : 'Guardar',
                      style: TextStyle(
                        color: c.primaryDeep,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: c.primaryDeepWithAlpha(0.1), height: 1),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Foto ─────────────────────────────────────────────────────
              _buildSectionLabel(c, 'Foto del evento'),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: c.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: c.primaryDeepWithAlpha(0.12),
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _newPhotoBytes != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(_newPhotoBytes!, fit: BoxFit.cover),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Cambiar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : (widget.evento?.fotoUrl != null &&
                            widget.evento!.fotoUrl!.isNotEmpty)
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              widget.evento!.fotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPhotoPlaceholder(c),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Cambiar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : _buildPhotoPlaceholder(c),
                ),
              ),
              const SizedBox(height: 28),

              // ─── Título ────────────────────────────────────────────────────
              _buildSectionLabel(c, 'Título *'),
              const SizedBox(height: 8),
              _buildTextField(
                c: c,
                controller: _titleCtrl,
                hint: 'Ej: Carrera 10K Loja',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El título es obligatorio'
                    : null,
              ),
              const SizedBox(height: 20),

              // ─── Descripción ──────────────────────────────────────────────
              _buildSectionLabel(c, 'Descripción'),
              const SizedBox(height: 8),
              _buildTextField(
                c: c,
                controller: _descCtrl,
                hint: 'Describe el evento...',
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // ─── Fecha y Hora ─────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel(c, 'Fecha'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              c: c,
                              controller: _dateCtrl,
                              hint: 'Seleccione fecha',
                              prefixIcon: Icons.calendar_today_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel(c, 'Hora'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickTime,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              c: c,
                              controller: _timeCtrl,
                              hint: 'HH:MM',
                              prefixIcon: Icons.access_time_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Lugar ────────────────────────────────────────────────────
              _buildSectionLabel(c, 'Lugar'),
              const SizedBox(height: 8),
              _buildTextField(
                c: c,
                controller: _placeCtrl,
                hint: 'Ej: Parque Jipiro, Loja',
                prefixIcon: Icons.location_on_rounded,
              ),
              const SizedBox(height: 20),

              // ─── Distancia ────────────────────────────────────────────────
              _buildSectionLabel(c, 'Distancia (km)'),
              const SizedBox(height: 8),
              _buildTextField(
                c: c,
                controller: _distanceCtrl,
                hint: 'Ej: 10',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.straighten_rounded,
              ),
              const SizedBox(height: 20),

              // ─── Pago y Precio ──────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: c.inputFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.inputBorder, width: 1.5),
                ),
                child: SwitchListTile(
                  title: _buildSectionLabel(c, 'Evento de Pago'),
                  subtitle: Text(
                    '¿El evento requiere pago para unirse?',
                    style: TextStyle(color: c.textHint, fontSize: 13),
                  ),
                  activeThumbColor: c.primaryDeep,
                  value: _esPago,
                  onChanged: (val) => setState(() => _esPago = val),
                ),
              ),
              if (_esPago) ...[
                const SizedBox(height: 16),
                _buildSectionLabel(c, 'Precio (\$)'),
                const SizedBox(height: 8),
                _buildTextField(
                  c: c,
                  controller: _precioCtrl,
                  hint: 'Ej: 15.50',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: Icons.attach_money_rounded,
                ),
                const SizedBox(height: 20),
                _buildSectionLabel(c, 'Cuentas Bancarias para cobros'),
                const SizedBox(height: 8),
                _buildCuentasBancariasList(c),
              ],
              const SizedBox(height: 20),

              // ─── Aforo y Listas de Espera ──────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel(c, 'Límite Participantes'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          c: c,
                          controller: _limiteParticipantesCtrl,
                          hint: 'Ej: 100',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.groups_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel(c, 'Límite Cola Espera'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          c: c,
                          controller: _limiteListaEsperaCtrl,
                          hint: 'Ej: 50',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.queue_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ─── Ruta y Mapa ──────────────────────────────────────────────────
              _buildSectionLabel(c, 'Ruta del Evento'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.primaryDeepWithAlpha(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.map_rounded, color: c.primaryDeep),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _routePoints.isEmpty
                                ? 'No se ha definido ruta en el mapa.'
                                : 'Ruta definida: Inicio, Meta${_routePoints.length > 2 ? ' y ${_routePoints.length - 2} Waypoint(s)' : ''}.',
                            style: TextStyle(color: c.textPrimary, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openRoutePicker,
                        icon: const Icon(Icons.add_location_alt_rounded),
                        label: Text(_routePoints.isEmpty ? 'Trazar ruta en mapa' : 'Editar ruta'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c.primaryDeep,
                          side: BorderSide(color: c.primaryDeep),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Indicaciones para Participantes ────────────────────────
              _buildSectionLabel(c, 'Indicaciones para Participantes'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.primaryDeepWithAlpha(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _indicacionCtrl,
                            style: TextStyle(color: c.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Ej: Llegar 1 hora antes del evento',
                              hintStyle: TextStyle(color: c.textHint),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            final texto = _indicacionCtrl.text.trim();
                            if (texto.isEmpty) return;
                            setState(() {
                              _indicaciones.add(texto);
                              _indicacionCtrl.clear();
                            });
                          },
                          icon: Icon(Icons.add_circle_rounded, color: c.primaryDeep, size: 32),
                        ),
                      ],
                    ),
                    if (_indicaciones.isNotEmpty) ...
                      [const SizedBox(height: 12),
                      ..._indicaciones.asMap().entries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: c.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text('${entry.key + 1}.', style: TextStyle(color: c.primaryDeep, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(entry.value, style: TextStyle(color: c.textPrimary, fontSize: 13)),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _indicaciones.removeAt(entry.key)),
                                child: Icon(Icons.close_rounded, size: 16, color: c.textHint),
                              ),
                            ],
                          ),
                        );
                      })
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ─── Guardar ──────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primaryDeep,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.eventId == null
                              ? 'Crear Evento'
                              : 'Guardar cambios',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(dynamic c, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildPhotoPlaceholder(dynamic c) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_rounded,
          size: 40,
          color: c.primaryDeepWithAlpha(0.4),
        ),
        const SizedBox(height: 8),
        Text(
          'Toca para agregar foto',
          style: TextStyle(color: c.textHint, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required dynamic c,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 15, color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textHint, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: c.primaryDeepWithAlpha(0.5), size: 20)
            : null,
        filled: true,
        fillColor: c.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.inputBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.inputBorderFocused, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 2),
        ),
      ),
    );
  }

  Widget _buildCuentasBancariasList(dynamic c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _cuentasBancarias.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.inputFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.inputBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cuenta #${i + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: c.textPrimary)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() => _cuentasBancarias.removeAt(i));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _cuentasBancarias[i]['banco'],
                  onChanged: (val) => _cuentasBancarias[i]['banco'] = val,
                  style: TextStyle(fontSize: 14, color: c.textPrimary),
                  decoration: InputDecoration(hintText: 'Banco (ej. Pichincha)', hintStyle: TextStyle(color: c.textHint, fontSize: 13), filled: true, fillColor: c.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _cuentasBancarias[i]['numero'],
                  onChanged: (val) => _cuentasBancarias[i]['numero'] = val,
                  style: TextStyle(fontSize: 14, color: c.textPrimary),
                  decoration: InputDecoration(hintText: 'Número de Cuenta', hintStyle: TextStyle(color: c.textHint, fontSize: 13), filled: true, fillColor: c.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _cuentasBancarias[i]['titular'],
                  onChanged: (val) => _cuentasBancarias[i]['titular'] = val,
                  style: TextStyle(fontSize: 14, color: c.textPrimary),
                  decoration: InputDecoration(hintText: 'Nombre del Titular', hintStyle: TextStyle(color: c.textHint, fontSize: 13), filled: true, fillColor: c.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _cuentasBancarias[i]['cedula'],
                  onChanged: (val) => _cuentasBancarias[i]['cedula'] = val,
                  style: TextStyle(fontSize: 14, color: c.textPrimary),
                  decoration: InputDecoration(hintText: 'Cédula / RUC', hintStyle: TextStyle(color: c.textHint, fontSize: 13), filled: true, fillColor: c.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _cuentasBancarias.add({'banco': '', 'numero': '', 'titular': '', 'cedula': ''});
            });
          },
          icon: Icon(Icons.add_rounded, color: c.primaryDeep, size: 20),
          label: Text('Agregar otra cuenta', style: TextStyle(color: c.primaryDeep)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: c.primaryDeep.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
