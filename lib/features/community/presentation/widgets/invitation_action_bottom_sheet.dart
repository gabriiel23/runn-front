import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/grupos_service.dart';
import '../../domain/models/grupo_model.dart';
import '../../../../core/services/http_client.dart';

class InvitationActionBottomSheet extends StatefulWidget {
  final String grupoId;
  final String invitacionId;
  /// Llamado al terminar la acción. [accion] es 'aceptar' o 'rechazar'.
  final void Function(String accion) onHandled;

  const InvitationActionBottomSheet({
    super.key,
    required this.grupoId,
    required this.invitacionId,
    required this.onHandled,
  });

  static Future<void> show({
    required BuildContext context,
    required String grupoId,
    required String invitacionId,
    required void Function(String accion) onHandled,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InvitationActionBottomSheet(
        grupoId: grupoId,
        invitacionId: invitacionId,
        onHandled: onHandled,
      ),
    );
  }

  @override
  State<InvitationActionBottomSheet> createState() => _InvitationActionBottomSheetState();
}

class _InvitationActionBottomSheetState extends State<InvitationActionBottomSheet> {
  bool _isLoading = true;
  bool _isActing = false;
  GrupoDetalle? _grupo;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarGrupo();
  }

  Future<void> _cargarGrupo() async {
    try {
      final res = await GruposService.getGrupoDetalle(widget.grupoId);
      if (mounted) {
        setState(() {
          _grupo = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar información del grupo';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _responder(String accion) async {
    setState(() => _isActing = true);
    try {
      await GruposService.responderInvitacion(widget.invitacionId, accion);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accion == 'aceptar' ? 'Te has unido al grupo ✅' : 'Invitación rechazada ✅'),
            backgroundColor: accion == 'aceptar' ? const Color(0xFF34C759) : const Color(0xFF8E8E93),
          ),
        );
        // Notificar al padre para que elimine la notificación y refresque
        widget.onHandled(accion);
        // Si acepta, lo llevamos al detalle del grupo
        if (accion == 'aceptar') {
          context.pushNamed('group_detail',
              pathParameters: {'grupoId': widget.grupoId});
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isActing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFFF3B30)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isActing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocurrió un error inesperado'), backgroundColor: Color(0xFFFF3B30)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.primaryDeepWithAlpha(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline_rounded, color: c.textHint, size: 48),
                    const SizedBox(height: 16),
                    Text(_error!, style: TextStyle(color: c.textSecondary)),
                  ],
                ),
              ),
            )
          else ...[
            Text('Invitación a Grupo', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: c.textPrimary, letterSpacing: -0.5,
            )),
            const SizedBox(height: 24),
            
            // Info del grupo
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: c.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      image: _grupo!.grupo.fotoUrl != null && _grupo!.grupo.fotoUrl!.isNotEmpty
                          ? DecorationImage(image: NetworkImage(_grupo!.grupo.fotoUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _grupo!.grupo.fotoUrl == null || _grupo!.grupo.fotoUrl!.isEmpty
                        ? Icon(Icons.groups_rounded, color: c.primaryDeep, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _grupo!.grupo.nombre,
                          style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary,
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.people_alt_rounded, size: 14, color: c.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${_grupo!.totalMiembros} miembros',
                              style: TextStyle(fontSize: 13, color: c.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            if (_grupo!.grupo.descripcion != null && _grupo!.grupo.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _grupo!.grupo.descripcion!,
                  style: TextStyle(fontSize: 14, color: c.textSecondary, height: 1.4),
                  textAlign: TextAlign.center,
                  maxLines: 3, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Acciones
            if (_isActing)
              const Center(child: CircularProgressIndicator())
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _responder('rechazar'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: c.primaryDeepWithAlpha(0.1)),
                          ),
                          foregroundColor: c.textSecondary,
                        ),
                        child: const Text('Rechazar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _responder('aceptar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: c.primaryDeep,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
