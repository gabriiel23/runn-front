import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class ProfileMultimediaPage extends StatefulWidget {
  const ProfileMultimediaPage({super.key});

  @override
  State<ProfileMultimediaPage> createState() => _ProfileMultimediaPageState();
}

class _ProfileMultimediaPageState extends State<ProfileMultimediaPage> {
  bool isGrid = true;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final String displayName = 'Alex Runner';

    final mockImages = [
      'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?q=80&w=500&auto=format&fit=crop',
    ];

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: c.card,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Multimedia',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildUserProfileHeader(c, displayName),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 57.0, // Height of the toggle bar
              maxHeight: 57.0,
              child: _buildToggleBar(c),
            ),
          ),
          isGrid ? _buildSliverGrid(mockImages, c) : _buildSliverList(mockImages, c),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader(dynamic c, String userName) {
    return Container(
      width: double.infinity,
      color: c.card,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF5E00), width: 2),
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: c.primaryLight,
                  child: Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: c.primaryDeepWithAlpha(0.7),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFFFF5E00),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBar(covariant dynamic c) {
    return Container(
      color: c.card,
      child: Column(
        children: [
          Divider(height: 1, color: c.textHint.withValues(alpha: 0.2)),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => isGrid = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: isGrid
                          ? const Border(
                              bottom: BorderSide(
                                  color: Color(0xFFFF5E00), width: 3),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          color: isGrid ? c.textPrimary : c.textHint,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cuadrícula',
                          style: TextStyle(
                            color: isGrid ? c.textPrimary : c.textHint,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => isGrid = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: !isGrid
                          ? const Border(
                              bottom: BorderSide(
                                  color: Color(0xFFFF5E00), width: 3),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.format_list_bulleted_rounded,
                          color: !isGrid ? c.textPrimary : c.textHint,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lista',
                          style: TextStyle(
                            color: !isGrid ? c.textPrimary : c.textHint,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverGrid(List<String> images, covariant dynamic c) {
    return SliverPadding(
      padding: const EdgeInsets.all(2),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return GestureDetector(
              onTap: () => _showFullScreenImage(context, images[index]),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: c.primaryDeepWithAlpha(0.1),
                  child: Icon(Icons.broken_image_rounded, color: c.textHint),
                ),
              ),
            );
          },
          childCount: images.length,
        ),
      ),
    );
  }

  Widget _buildSliverList(List<String> images, covariant dynamic c) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: GestureDetector(
              onTap: () => _showFullScreenImage(context, images[index]),
              child: Image.network(
                images[index],
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 250,
                  color: c.primaryDeepWithAlpha(0.1),
                  child: Icon(Icons.broken_image_rounded, color: c.textHint),
                ),
              ),
            ),
          );
        },
        childCount: images.length,
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                  onPressed: () => context.pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
