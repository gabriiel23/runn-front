import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';
import '../../data/models/community_runners_data.dart';

class RunnersPage extends StatefulWidget {
  const RunnersPage({super.key});

  @override
  State<RunnersPage> createState() => _RunnersPageState();
}

class _RunnersPageState extends State<RunnersPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredRunners = [];

  @override
  void initState() {
    super.initState();
    _filteredRunners = communityRunners;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRunners(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRunners = communityRunners;
      } else {
        _filteredRunners =
            communityRunners
                .where(
                  (r) =>
                      r['name'].toString().toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      r['level'].toString().toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      }
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
          'Runners en tu zona',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchBar(c),
              ),
              Container(color: c.primaryDeepWithAlpha(0.1), height: 1),
            ],
          ),
        ),
      ),
      body:
          _filteredRunners.isEmpty
              ? _buildEmptyState(c)
              : ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _filteredRunners.length,
                separatorBuilder:
                    (context, index) => Divider(
                      color: c.primaryDeepWithAlpha(0.05),
                      height: 1,
                      indent: 24,
                      endIndent: 24,
                    ),
                itemBuilder: (context, index) {
                  final p = _filteredRunners[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: c.primaryLight,
                      child: Icon(
                        Icons.person_rounded,
                        color: c.primaryDeepWithAlpha(0.7),
                      ),
                    ),
                    title: Text(
                      p['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      p['level'] as String,
                      style: TextStyle(color: c.textSecondary, fontSize: 13),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        context.pushNamed(
                          'rival_profile',
                          pathParameters: {'userId': p['id'] as String},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primaryDeepWithAlpha(0.1),
                        foregroundColor: c.primaryDeep,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text(
                        'Ver perfil',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildSearchBar(colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primaryDeepWithAlpha(0.08)),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: 15, color: colors.textPrimary),
        onChanged: _filterRunners,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o nivel...',
          hintStyle: TextStyle(
            color: colors.textHint,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: colors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off_rounded,
            size: 64,
            color: colors.primaryDeepWithAlpha(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron runners',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
