import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/usuarios_service.dart';
import '../../domain/models/usuario_community_model.dart';

class RunnersPage extends StatefulWidget {
  const RunnersPage({super.key});

  @override
  State<RunnersPage> createState() => _RunnersPageState();
}

class _RunnersPageState extends State<RunnersPage> {
  final _searchController = TextEditingController();
  List<UsuarioCommunityModel> _runners = [];
  bool _isLoading = true;
  String _errorMsg = '';
  Timer? _debounce;
  String _nivelSeleccionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadRunners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRunners({String? buscar}) async {
    setState(() { _isLoading = true; _errorMsg = ''; });
    try {
      final lista = await UsuariosService.getUsuarios(
        buscar: buscar ?? (_searchController.text.trim().isEmpty ? null : _searchController.text.trim()),
        nivel: _nivelSeleccionado == 'Todos' ? null : _nivelSeleccionado,
      );
      if (mounted) setState(() { _runners = lista; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMsg = e.toString(); _isLoading = false; });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadRunners(buscar: query.trim().isEmpty ? null : query.trim());
    });
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
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Runners',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchBar(c),
              ),
              _buildFiltros(c),
              const SizedBox(height: 8),
              Container(color: c.primaryDeepWithAlpha(0.1), height: 1),
            ],
          ),
        ),
      ),
      body: _buildBody(c),
    );
  }

  Widget _buildBody(dynamic c) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    if (_errorMsg.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 64, color: c.primaryDeepWithAlpha(0.3)),
              const SizedBox(height: 16),
              Text(
                'No se pudo cargar los runners',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMsg,
                style: TextStyle(fontSize: 13, color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _loadRunners(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_runners.isEmpty) return _buildEmptyState(c);

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _runners.length,
      separatorBuilder: (context, index) => Divider(
        color: c.primaryDeepWithAlpha(0.05),
        height: 1,
        indent: 24,
        endIndent: 24,
      ),
      itemBuilder: (context, index) {
        final p = _runners[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: c.primaryLight,
            backgroundImage: p.avatarUrl != null && p.avatarUrl!.isNotEmpty
                ? NetworkImage(p.avatarUrl!)
                : null,
            child: p.avatarUrl == null || p.avatarUrl!.isEmpty
                ? Icon(Icons.person_rounded, color: c.primaryDeepWithAlpha(0.7))
                : null,
          ),
          title: Text(
            p.nombre,
            style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary),
          ),
          subtitle: Text(
            [
              if (p.nivel != null && p.nivel!.isNotEmpty) p.nivel!,
              if (p.ciudad != null && p.ciudad!.isNotEmpty) p.ciudad!,
            ].join(' · '),
            style: TextStyle(color: c.textSecondary, fontSize: 13),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              context.pushNamed(
                'profile_others_runners',
                pathParameters: {'userId': p.id},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primaryDeepWithAlpha(0.1),
              foregroundColor: c.primaryDeep,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Ver perfil', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(dynamic colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primaryDeepWithAlpha(0.08)),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: 15, color: colors.textPrimary),
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre...',
          hintStyle: TextStyle(color: colors.textHint, fontWeight: FontWeight.w400),
          prefixIcon: Icon(Icons.search_rounded, color: colors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildEmptyState(dynamic colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_rounded, size: 64, color: colors.primaryDeepWithAlpha(0.3)),
          const SizedBox(height: 16),
          Text(
            'No se encontraron runners',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros(dynamic c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip(c, 'Nivel: $_nivelSeleccionado', () => _mostrarFiltroNivel(c)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(dynamic c, String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary)),
      backgroundColor: c.primaryLight,
      side: BorderSide(color: c.primaryDeepWithAlpha(0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: onTap,
    );
  }

  void _mostrarFiltroNivel(dynamic c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Todos', 'Principiante', 'Intermedio', 'Avanzado', 'Elite'].map((opt) {
            return ListTile(
              title: Text(opt, style: TextStyle(color: c.textPrimary)),
              trailing: _nivelSeleccionado == opt ? Icon(Icons.check_rounded, color: c.primaryDeep) : null,
              onTap: () {
                setState(() => _nivelSeleccionado = opt);
                context.pop();
                _loadRunners();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
