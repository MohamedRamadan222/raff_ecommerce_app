import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/utils/app_formatters.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/domain/value_objects/order_status_policy.dart';
import 'package:raff_app/features/orders/presentation/widgets/order_status_badge.dart';

class TrackOrderTimeline extends StatelessWidget {
  final OrderEntity order;

  const TrackOrderTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timeFormat = AppFormatters.timeShort(l10n.localeName);

    final current = OrderStatusPolicy.stageIndexOf(order.status);

    return Column(
      children: [
        for (var i = 0; i < OrderStatusPolicy.stages.length; i++)
          TrackOrderTimelineTile(
            title: orderStatusText(l10n, OrderStatusPolicy.stages[i]),
            subtitle: i <= current
                ? timeFormat.format(
                    OrderStatusPolicy.stageTime(order.createdAt, i),
                  )
                : l10n.pendingLabel,
            isDone: i < current,
            isCurrent: i == current,
            isLast: i == OrderStatusPolicy.stages.length - 1,
          ),
      ],
    );
  }
}

class TrackOrderTimelineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  const TrackOrderTimelineTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = isDone || isCurrent;
    final ink = isDark ? AppColors.darkInk : AppColors.ink;
    final onInk = isDark ? AppColors.darkOnInk : AppColors.onInk;
    final lineStrong = isDark ? AppColors.darkLineStrong : AppColors.lineStrong;
    final paper = isDark ? AppColors.darkPaper : AppColors.paper;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? ink : paper,
                  border: Border.all(
                    color: active ? ink : lineStrong,
                    width: 2,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: isDark
                                ? AppColors.darkAccentSoft
                                : AppColors.accentSoft,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: active
                    ? Icon(Icons.check, size: 12, color: onInk)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: isDone ? ink : lineStrong),
                ),
            ],
          ),
          const Gap(16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.bodyMedium!.copyWith(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      color: active ? cs.onSurface : cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: tt.bodySmall!.copyWith(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
