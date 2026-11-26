import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/widgets/app_button.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.ink;
    final onInk = isDark ? AppColors.darkOnInk : AppColors.onInk;
    final accentSoft = isDark ? AppColors.darkAccentSoft : AppColors.accentSoft;
    final line = isDark ? AppColors.darkLine : AppColors.line;

    // GoRouterState.of بيدينا الـ state بتاع الراوت الحالي من غير ما نعدل الراوتر
    final order = GoRouterState.of(context).extra as OrderEntity?;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ink,
                  boxShadow: [BoxShadow(color: accentSoft, spreadRadius: 10)],
                ),
                child: Icon(Icons.check_rounded, size: 44, color: onInk),
              ),
              const Gap(24),
              Text(
                l10n.orderPlaced,
                textAlign: TextAlign.center,
                style: tt.headlineSmall!.copyWith(
                  fontSize: 24,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                l10n.orderPlacedSub,
                textAlign: TextAlign.center,
                style: tt.bodyMedium!.copyWith(
                  fontSize: 15,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Gap(16),
              if (order != null)
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: line),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.orderNumber,
                                  style: tt.bodyMedium!.copyWith(
                                    fontSize: 14,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  order.id,
                                  textDirection: TextDirection.ltr,
                                  style: tt.bodyMedium!.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        VerticalDivider(width: 1, thickness: 1, color: line),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.eta,
                                  style: tt.bodyMedium!.copyWith(
                                    fontSize: 14,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  l10n.etaValue,
                                  style: tt.bodyMedium!.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.trackOrder,
                  onPressed: order == null
                      ? () => context.go(AppRoutes.orders)
                      // بنبني المسار بـ id الطلب: /orders/RF-12345/track
                      : () => context.push('/orders/${order.id}/track'),
                ),
              ),
              const Gap(10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n.continueShopping),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
