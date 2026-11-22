import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/widgets/favorite_button.dart';
import 'package:raff_app/core/widgets/page_indicator.dart';

class ProductDetailsGallery extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final bool isFavorite;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;

  const ProductDetailsGallery({
    super.key,
    required this.images,
    required this.selectedIndex,
    required this.isFavorite,
    required this.onPageChanged,
    required this.onFavoriteTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
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
          // صور المنتج
          PageView.builder(
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final url = images[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(32, 68, 32, 42),
                child: url.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: url,
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

          // الأزرار العلوية (رجوع + مشاركة + مفضلة)
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
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 17,
                      color: cs.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      _CircleActionButton(
                        onTap: onShareTap,
                        child: Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: cs.onSurface,
                        ),
                      ),
                      const Gap(10),
                      _CircleActionButton(
                        child: FavoriteButton(
                          isFavorite: isFavorite,
                          onTap: onFavoriteTap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // مؤشر النقاط السفلي
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: PageIndicator(
                itemCount: images.length,
                currentIndex: selectedIndex,
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