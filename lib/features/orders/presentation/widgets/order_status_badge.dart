import 'package:flutter/material.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';

String orderStatusText(AppLocalizations l10n, OrderStatus status) {
  return switch (status) {
    OrderStatus.placed => l10n.statusPlaced,
    OrderStatus.confirmed => l10n.statusConfirmed,
    OrderStatus.shipped => l10n.statusShipped,
    OrderStatus.outForDelivery => l10n.statusOut,
    OrderStatus.delivered => l10n.statusDelivered,
    OrderStatus.cancelled => l10n.statusCancelled,
  };
}

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.accent;
    final danger = isDark ? AppColors.darkDanger : AppColors.danger;

    final (bg, fg) = switch (status) {
      OrderStatus.delivered => (
        isDark ? AppColors.darkSunken : AppColors.sunken,
        isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary,
      ),
      OrderStatus.cancelled => (danger.withValues(alpha: 0.12), danger),
      _ => (isDark ? AppColors.darkAccentSoft : AppColors.accentSoft, accent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        orderStatusText(l10n, status),
        style: tt.labelSmall!.copyWith(
          fontSize: 12,
          color: fg,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
