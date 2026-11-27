import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/widgets/app_image_cache.dart';
import 'package:raff_app/core/widgets/favorite_button.dart';
import 'package:raff_app/core/widgets/page_indicator.dart';

class ProductDetailsGallery extends StatefulWidget {
  final List<String> images;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;

  const ProductDetailsGallery({
    super.key,
    required this.images,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onShareTap,
  });

  @override
  State<ProductDetailsGallery> createState() => _ProductDetailsGalleryState();
}

class _ProductDetailsGalleryState extends State<ProductDetailsGallery> {
  final _controller = PageController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final galleryBg = isDark
        ? Color.alphaBlend(cs.onSurface.withValues(alpha: 0.14), cs.surface)
        : Color.alphaBlend(
            cs.outlineVariant.withValues(alpha: 0.72),
            cs.surface,
          );

    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: galleryBg,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _selectedIndex = index),
            itemBuilder: (context, index) {
              final url = images[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(32, 68, 32, 42),
                child: url.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: url,
                        cacheManager: AppImageCache.manager,
                        memCacheWidth: 900,
                        maxWidthDiskCache: 900,
                        fit: BoxFit.contain,
                        placeholder: (_, _) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        ),
                        errorWidget: (_, _, _) => Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: cs.outline,
                        ),
                      )
                    : Icon(Icons.image_outlined, size: 64, color: cs.outline),
              );
            },
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleActionButton(
                    onTap: () {
                      if (context.canPop()) context.pop();
                    },
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 2),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 17,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _CircleActionButton(
                        onTap: widget.onShareTap,
                        child: Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: cs.onSurface,
                        ),
                      ),
                      const Gap(10),
                      _CircleActionButton(
                        child: FavoriteButton(
                          isFavorite: widget.isFavorite,
                          onTap: widget.onFavoriteTap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: PageIndicator(
                itemCount: images.length,
                currentIndex: _selectedIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _CircleActionButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.78),
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}
