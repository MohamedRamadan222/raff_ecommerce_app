import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/widgets/app_app_bar.dart';
import 'package:raff_app/core/widgets/empty_view.dart';
import 'package:raff_app/core/widgets/error_view.dart';
import 'package:raff_app/core/widgets/loading_view.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_state.dart';
import 'package:raff_app/features/orders/presentation/widgets/track_order_timeline.dart';
import 'package:raff_app/features/orders/presentation/widgets/track_order_widgets.dart';

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen>
    with WidgetsBindingObserver {
  static const _pollInterval = Duration(seconds: 30);

  Timer? _refreshTimer;
  String? _orderId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final ordersCubit = context.read<OrdersCubit>();
    ordersCubit.ensureLoaded();
    ordersCubit.refreshStatuses();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPolling());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderId = GoRouterState.of(context).pathParameters['id'];
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncPolling();
    } else {
      _stopPolling();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  bool get _isAppActive {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    return lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  bool get _isRouteVisible => ModalRoute.of(context)?.isCurrent == true;

  bool get _canPoll {
    if (!_isAppActive || !_isRouteVisible) return false;

    final order = _trackedOrder;
    if (order == null) return true;
    return order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled;
  }

  OrderEntity? get _trackedOrder {
    final orderId = _orderId;
    if (orderId == null) return null;
    return context.read<OrdersCubit>().state.orderById(orderId);
  }

  void _syncPolling() {
    if (!mounted) return;
    if (!_isAppActive) {
      _stopPolling();
      return;
    }
    // Keep the timer alive while the route is covered so it resumes without
    // depending on a rebuild; ticks skip work until the route is visible.
    _refreshTimer ??= Timer.periodic(_pollInterval, (_) => _onPollTick());
  }

  void _stopPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _onPollTick() {
    if (!mounted) return;
    // App backgrounded: stop. Route covered: keep the timer but skip work.
    if (!_isAppActive) {
      _stopPolling();
      return;
    }
    if (!_canPoll) return;

    // تحديث مشتق من الذاكرة فقط — مفيش قراءة كاملة من Hive ولا loading.
    context.read<OrdersCubit>().refreshStatuses();

    final order = _trackedOrder;
    if (order != null &&
        (order.status == OrderStatus.delivered ||
            order.status == OrderStatus.cancelled)) {
      _stopPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // الراوت ممكن يرجع current بعد pop؛ نزامن الـ polling مع كل rebuild.
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPolling());

    return BlocListener<OrdersCubit, OrdersState>(
      listenWhen: (_, state) {
        final orderId = _orderId;
        if (orderId == null) return false;
        final order = state.orderById(orderId);
        return order != null &&
            (order.status == OrderStatus.delivered ||
                order.status == OrderStatus.cancelled);
      },
      listener: (_, _) => _stopPolling(),
      child: Scaffold(
        appBar: AppAppBar(title: l10n.trackOrder, subtitle: _orderId),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            switch (state) {
              case OrdersInitial():
              case OrdersLoading():
                return const LoadingView();

              case OrdersFailure(failure: final failure):
                return ErrorView(
                  message: failure.message(context),
                  onRetry: () => context.read<OrdersCubit>().loadOrders(),
                );

              case final OrdersSuccess success:
                final orderId = _orderId;
                final order = orderId == null
                    ? null
                    : success.orderById(orderId);

                if (order == null) {
                  return EmptyView(
                    title: l10n.orderNotFound,
                    icon: Icons.search_off_rounded,
                  );
                }

                if (order.status == OrderStatus.cancelled) {
                  return TrackOrderCancelledView(order: order);
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    TrackOrderEtaCard(order: order),
                    const Gap(24),
                    TrackOrderTimeline(order: order),
                    const Gap(32),
                    TrackOrderItemsSection(order: order),
                    const Gap(32),
                    TrackOrderShipToSection(order: order),
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}
