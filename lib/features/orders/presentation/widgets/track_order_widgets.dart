import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/utils/app_formatters.dart';
import 'package:raff_app/core/widgets/app_image_cache.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/domain/value_objects/order_status_policy.dart';
import 'package:raff_app/features/orders/presentation/widgets/order_status_badge.dart';

class TrackOrderEtaCard extends StatelessWidget {
  final OrderEntity order;

  const TrackOrderEtaCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final stageIndex = OrderStatusPolicy.stageIndexOf(order.status);
    final delivered = order.status == OrderStatus.delivered;
    final deliveredAt = OrderStatusPolicy.stageTime(
      order.createdAt,
      OrderStatusPolicy.stageIndexOf(OrderStatus.delivered),
    );
    final dateFormat = AppFormatters.dateMedium(l10n.localeName);

    // كارت داكن بنفس ألوان الـ hero في الديزاين (مش بيتغير مع الثيم)
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: AppColors.hero,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivered ? l10n.deliveredOn : l10n.eta,
                          style: tt.bodySmall!.copyWith(
                            fontSize: 12,
                            color: AppColors.heroInk.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          delivered
                              ? dateFormat.format(deliveredAt)
                              : l10n.etaValue,
                          style: tt.titleLarge!.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.heroInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      delivered
                          ? Icons.check_rounded
                          : Icons.local_shipping_outlined,
                      size: 26,
                      color: AppColors.heroInk,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(
                value: stageIndex / (OrderStatusPolicy.stages.length - 1),
                minHeight: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFCFD6C1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackOrderItemsSection extends StatelessWidget {
  final OrderEntity order;

  const TrackOrderItemsSection({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.itemsLabel,
          style: tt.titleMedium!.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(8),
        for (final item in order.items) ...[
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: item.thumbnail,
                  cacheManager: AppImageCache.manager,
                  memCacheWidth: 140,
                  maxWidthDiskCache: 140,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    width: 44,
                    height: 44,
                    color: cs.surfaceContainerHighest,
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyMedium!.copyWith(fontSize: 14),
                    ),
                    Text(
                      '× ${item.quantity}',
                      style: tt.bodySmall!.copyWith(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Text(
                '${item.totalPrice.toStringAsFixed(0)} ${l10n.currencySar}',
                style: tt.bodyMedium!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(10),
        ],
      ],
    );
  }
}

class TrackOrderShipToSection extends StatelessWidget {
  final OrderEntity order;

  const TrackOrderShipToSection({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.shipTo,
          style: tt.titleMedium!.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkAccent
                    : AppColors.accent,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.addressLabel,
                      style: tt.bodyMedium!.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      order.addressFull,
                      style: tt.bodySmall!.copyWith(
                        fontSize: 13,
                        height: 1.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TrackOrderCancelledView extends StatelessWidget {
  final OrderEntity order;

  const TrackOrderCancelledView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel_outlined, size: 64, color: cs.error),
            const Gap(12),
            OrderStatusBadge(status: order.status),
            const Gap(12),
            Text(
              order.id,
              textDirection: TextDirection.ltr,
              style: tt.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
