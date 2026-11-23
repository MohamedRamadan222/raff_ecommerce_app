import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:raff_app/features/catalog/presentation/utils/catalog_helper.dart';

class CartItemTile extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onTap;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFD6CEC2);
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(
      cleaned.length == 6 ? 'FF$cleaned' : cleaned,
      radix: 16,
    );
    return value != null ? Color(value) : const Color(0xFFD6CEC2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final product = item.product;
    final thumbBg = isDark
        ? Color.alphaBlend(cs.onSurface.withValues(alpha: 0.14), cs.surface)
        : Color.alphaBlend(
            cs.outlineVariant.withValues(alpha: 0.72),
            cs.surface,
          );

    final pillBg = isDark
        ? Color.alphaBlend(cs.onSurface.withValues(alpha: 0.08), cs.surface)
        : Color.alphaBlend(
            cs.outlineVariant.withValues(alpha: 0.45),
            cs.surface,
          );

    final subtitleText = product.brand?.isNotEmpty == true
        ? product.brand!
        : CatalogHelper.localizeCategory(context, slug: product.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 84,
              height: 84,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: thumbBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: product.thumbnail.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.thumbnail,
                      fit: BoxFit.contain,
                      errorWidget: (_, _, _) => Icon(
                        Icons.image_outlined,
                        size: 28,
                        color: cs.outline,
                      ),
                    )
                  : Icon(Icons.image_outlined, size: 28, color: cs.outline),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleMedium!.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Gap(8),
                      GestureDetector(
                        onTap: onRemove,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),

                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _parseColor(item.colorHex),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(6),
                      Flexible(
                        child: Text(
                          subtitleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall!.copyWith(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.totalPrice.toStringAsFixed(0)} ${l10n.currencySar}',
                        style: tt.titleMedium!.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 34,
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QtyAction(
                              icon: Icons.add_rounded,
                              onTap: onIncrement,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: tt.bodyMedium!.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _QtyAction(
                              icon: item.quantity <= 1
                                  ? Icons.delete_outline_rounded
                                  : Icons.remove_rounded,
                              onTap: onDecrement,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 32,
        height: 34,
        child: Icon(icon, size: 15, color: cs.onSurface.withValues(alpha: 0.8)),
      ),
    );
  }
}
