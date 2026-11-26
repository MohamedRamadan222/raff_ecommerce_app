import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/widgets/app_app_bar.dart';
import 'package:raff_app/core/widgets/empty_view.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_state.dart';
import 'package:raff_app/features/orders/presentation/widgets/order_status_badge.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _showCurrent = true;

  @override
  void initState() {
    super.initState();
    // بنعيد التحميل عشان الحالات المشتقة تتحدث بآخر وقت
    context.read<OrdersCubit>().loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppAppBar(title: l10n.myOrders, showBackButton: true),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          final list = _showCurrent ? state.currentOrders : state.pastOrders;

          return Column(
            children: [
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSunken
                        : AppColors.sunken,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _TabButton(
                        label: l10n.currentTab,
                        count: state.currentOrders.length,
                        selected: _showCurrent,
                        onTap: () => setState(() => _showCurrent = true),
                      ),
                      _TabButton(
                        label: l10n.pastTab,
                        selected: !_showCurrent,
                        onTap: () => setState(() => _showCurrent = false),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(8),
              Expanded(
                child: list.isEmpty
                    ? EmptyView(
                        title: l10n.emptyOrdersTitle,
                        subtitle: l10n.emptyOrdersSubtitle,
                        icon: Icons.shopping_bag_outlined,
                        buttonText: l10n.startShopping,
                        onAction: () => context.go('/home'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const Gap(12),
                        itemBuilder: (context, index) =>
                            _OrderCard(order: list[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final digits = intl.NumberFormat('#,##0', context.l10n.localeName);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 36,
          decoration: BoxDecoration(
            color: selected ? cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x0D22221F),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: tt.bodyMedium!.copyWith(
                  fontSize: 14,
                  color: selected ? cs.onSurface : cs.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
              if (count != null) ...[
                const Gap(6),
                Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInk : AppColors.ink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    digits.format(count),
                    style: TextStyle(
                      fontSize: 11,
                      height: 1,
                      color: isDark ? AppColors.darkOnInk : AppColors.onInk,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final dateFormat = intl.DateFormat.yMMMd(l10n.localeName);

    return InkWell(
      onTap: () => context.push('/orders/${order.id}/track'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        textDirection: TextDirection.ltr,
                        style: tt.titleSmall!.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        dateFormat.format(order.createdAt),
                        style: tt.bodySmall!.copyWith(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const Gap(12),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: order.items.length,
                separatorBuilder: (_, _) => const Gap(8),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: order.items[index].thumbnail,
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
              ),
            ),
            const Gap(12),
            Divider(height: 1, color: cs.outlineVariant),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.itemsCount(order.totalItemsCount),
                  style: tt.bodySmall!.copyWith(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${intl.NumberFormat('#,##0', l10n.localeName).format(order.total.round())} ${l10n.currencySar}',
                  style: tt.titleSmall!.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
