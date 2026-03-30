import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../services/grupos_service.dart';
import '../../domain/models/grupo_model.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage>
    with SingleTickerProviderStateMixin {
  List<GrupoListItem> _misGrupos = [];
  List<GrupoListItem> _todosGrupos = [];
  bool _isLoading = true;
  String _errorMsg = '';
  final TextEditingController _searchController = TextEditingController();
  bool _buscando = false;
  String _searchQuery = '';

  String _modalidadSeleccionada = 'Todos';
  String _privacidadSeleccionada = 'Todos';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    try {
      final results = await Future.wait([
        GruposService.getMisGrupos(),
        GruposService.getGrupos(
          buscar: _searchQuery.isNotEmpty ? _searchQuery : null,
          modalidad: _modalidadSeleccionada,
          esPrivado: _privacidadSeleccionada == 'Todos'
              ? null
              : _privacidadSeleccionada == 'Privados',
        ),
      ]);
      if (mounted) {
        setState(() {
          _misGrupos = results[0];
          _todosGrupos = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _buscar(String query) async {
    setState(() {
      _buscando = true;
      _searchQuery = query;
    });
    await _aplicarFiltros();
  }

  Future<void> _aplicarFiltros() async {
    if (!mounted) return;
    setState(() => _buscando = true);
    try {
      final result = await GruposService.getGrupos(
        buscar: _searchQuery.isNotEmpty ? _searchQuery : null,
        modalidad: _modalidadSeleccionada,
        esPrivado: _privacidadSeleccionada == 'Todos'
            ? null
            : _privacidadSeleccionada == 'Privados',
      );
      if (mounted) {
        setState(() {
          _todosGrupos = result;
          _buscando = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _buscando = false);
      }
    }
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
          'Grupos',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: c.primaryDeepWithAlpha(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.all(4),
                indicatorPadding: EdgeInsets.zero,
                indicator: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(13),
                ),
                labelColor: c.card,
                unselectedLabelColor: c.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
                tabs: const [
                  Tab(text: 'Descubrir Grupos'),
                  Tab(text: 'Mis Grupos'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: c.primaryDeep))
          : _errorMsg.isNotEmpty
          ? _buildError(c)
          : TabBarView(
              controller: _tabController,
              children: [_buildDiscoverTab(c), _buildMyGroupsTab(c)],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/community/groups/create'),
        backgroundColor: c.primaryDeep,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.group_add_rounded, color: Colors.white),
        label: const Text(
          'Crear Grupo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverTab(dynamic c) {
    return RefreshIndicator(
      color: c.primaryDeep,
      onRefresh: _loadAll,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _buildSearchBar(c),
          _buildFiltros(c),
          if (_buscando)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(color: c.primaryDeep),
              ),
            )
          else if (_todosGrupos.isEmpty)
            _buildEmptySearch(c)
          else
            ..._todosGrupos.map((g) => _buildGroupCard(c, g)),
        ],
      ),
    );
  }

  Widget _buildMyGroupsTab(dynamic c) {
    return RefreshIndicator(
      color: c.primaryDeep,
      onRefresh: _loadAll,
      child: _misGrupos.isEmpty
          ? Center(
              child: Text(
                'No perteneces a ningún grupo aún.',
                style: TextStyle(color: c.textSecondary, fontSize: 16),
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 100, top: 16),
              children: [..._misGrupos.map((g) => _buildGroupCard(c, g))],
            ),
    );
  }

  Widget _buildFiltros(dynamic c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip(
              c,
              'Modalidad: $_modalidadSeleccionada',
              () => _mostrarFiltroModalidad(c),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              c,
              'Privacidad: $_privacidadSeleccionada',
              () => _mostrarFiltroPrivacidad(c),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(dynamic c, String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
      ),
      backgroundColor: c.primaryLight,
      side: BorderSide(color: c.primaryDeepWithAlpha(0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: onTap,
    );
  }

  void _mostrarFiltroModalidad(dynamic c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Todos', 'Social', 'Territorial'].map((opt) {
            return ListTile(
              title: Text(opt, style: TextStyle(color: c.textPrimary)),
              trailing: _modalidadSeleccionada == opt
                  ? Icon(Icons.check_rounded, color: c.primaryDeep)
                  : null,
              onTap: () {
                setState(() => _modalidadSeleccionada = opt);
                context.pop();
                _aplicarFiltros();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _mostrarFiltroPrivacidad(dynamic c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Todos', 'Públicos', 'Privados'].map((opt) {
            return ListTile(
              title: Text(opt, style: TextStyle(color: c.textPrimary)),
              trailing: _privacidadSeleccionada == opt
                  ? Icon(Icons.check_rounded, color: c.primaryDeep)
                  : null,
              onTap: () {
                setState(() => _privacidadSeleccionada = opt);
                context.pop();
                _aplicarFiltros();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildError(dynamic c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off_rounded,
            size: 64,
            color: c.primaryDeepWithAlpha(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No se pudieron cargar los grupos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadAll, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _buildSearchBar(dynamic c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.primaryDeepWithAlpha(0.08)),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: c.textPrimary),
          onChanged: (v) => _buscar(v),
          decoration: InputDecoration(
            hintText: 'Buscar grupos...',
            hintStyle: TextStyle(color: c.textHint),
            prefixIcon: Icon(Icons.search_rounded, color: c.textHint),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: c.textHint),
                    onPressed: () {
                      _searchController.clear();
                      _buscar('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearch(dynamic c) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: c.primaryDeepWithAlpha(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin resultados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: c.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(dynamic c, GrupoListItem g) {
    final isPrivado = g.esPrivado;
    final modalidadColor = g.modalidad == 'territorial'
        ? const Color(0xFF7ED957)
        : c.primaryDeep;

    return GestureDetector(
      onTap: () =>
          context.pushNamed('group_detail', pathParameters: {'grupoId': g.id}),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.primaryDeepWithAlpha(0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: g.fotoUrl != null && g.fotoUrl!.isNotEmpty
                  ? Image.network(
                      g.fotoUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _groupIconPlaceholder(c, modalidadColor),
                    )
                  : _groupIconPlaceholder(c, modalidadColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          g.nombre,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPrivado)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.lock_rounded,
                            color: c.textHint,
                            size: 14,
                          ),
                        ),
                    ],
                  ),
                  if (g.descripcion != null && g.descripcion!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        g.descripcion!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: c.textSecondary),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _chip(
                        c,
                        g.modalidad == 'territorial'
                            ? '🗺 Territorial'
                            : '👟 Social',
                        modalidadColor,
                      ),
                      const SizedBox(width: 6),
                      _chip(c, '${g.totalMiembros} miembros', c.primaryDeep),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: c.textPrimary.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupIconPlaceholder(dynamic c, Color color) {
    return Container(
      width: 64,
      height: 64,
      color: color.withValues(alpha: 0.12),
      child: Icon(
        Icons.groups_rounded,
        color: color.withValues(alpha: 0.7),
        size: 32,
      ),
    );
  }

  Widget _chip(dynamic c, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
