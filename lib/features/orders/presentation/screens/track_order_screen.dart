import 'dart:async';

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

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().loadOrders();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) context.read<OrdersCubit>().loadOrders();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final orderId = GoRouterState.of(context).pathParameters['id'];

    return Scaffold(
      appBar: AppAppBar(
        title: l10n.trackOrder,
        subtitle: orderId,
        showBackButton: true,
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          final order = orderId == null ? null : state.orderById(orderId);

          if (order == null) {
            return EmptyView(
              title: l10n.orderNotFound,
              icon: Icons.search_off_rounded,
            );
          }

          if (order.status == OrderStatus.cancelled) {
            return _CancelledView(order: order);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _EtaCard(order: order),
              const Gap(24),
              _Timeline(order: order),
              const Gap(32),
              _ItemsSection(order: order),
              const Gap(32),
              _ShipToSection(order: order),
            ],
          );
        },
      ),
    );
  }
}

const _stages = [
  OrderStatus.placed,
  OrderStatus.confirmed,
  OrderStatus.shipped,
  OrderStatus.outForDelivery,
  OrderStatus.delivered,
];

int _stageIndexOf(OrderEntity order) => _stages.indexOf(order.status);

/// وقت كل مرحلة في المحاكاة (نفس أرقام _refreshStatuses في OrdersCubit)
DateTime _stageTime(OrderEntity order, int stageIndex) {
  final offsets = [
    Duration.zero,
    const Duration(seconds: 30),
    const Duration(minutes: 2),
    const Duration(minutes: 5),
    const Duration(minutes: 10),
  ];
  return order.createdAt.add(offsets[stageIndex]);
}

class _EtaCard extends StatelessWidget {
  final OrderEntity order;

  const _EtaCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final stageIndex = _stageIndexOf(order);
    final delivered = order.status == OrderStatus.delivered;
    final dateFormat = intl.DateFormat.yMMMd(l10n.localeName);

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
                              ? dateFormat.format(_stageTime(order, 4))
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
                value: stageIndex / (_stages.length - 1),
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

class _Timeline extends StatelessWidget {
  final OrderEntity order;

  const _Timeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timeFormat = intl.DateFormat.jm(l10n.localeName);

    final current = _stageIndexOf(order);

    return Column(
      children: [
        for (var i = 0; i < _stages.length; i++)
          _TimelineTile(
            title: orderStatusText(l10n, _stages[i]),
            subtitle: i <= current
                ? timeFormat.format(_stageTime(order, i))
                : l10n.pendingLabel,
            isDone: i < current,
            isCurrent: i == current,
            isLast: i == _stages.length - 1,
          ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  const _TimelineTile({
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

class _ItemsSection extends StatelessWidget {
  final OrderEntity order;

  const _ItemsSection({required this.order});

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

class _ShipToSection extends StatelessWidget {
  final OrderEntity order;

  const _ShipToSection({required this.order});

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

class _CancelledView extends StatelessWidget {
  final OrderEntity order;

  const _CancelledView({required this.order});

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
