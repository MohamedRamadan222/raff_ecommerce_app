import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/di/injection.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/widgets/app_app_bar.dart';
import 'package:raff_app/core/widgets/app_button.dart';
import 'package:raff_app/core/widgets/empty_view.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:raff_app/features/addresses/presentation/widgets/address_card.dart';
import 'package:raff_app/features/cart/domain/value_objects/cart_pricing.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';
import 'package:raff_app/features/checkout/domain/entities/checkout_totals.dart';
import 'package:raff_app/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_address_step.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_delivery_step.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_payment_step.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_review_step.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_stepper.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_cubit.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الـ checkout بيستخدم الـ AddressesCubit العام من main.dart
    return BlocProvider(
      create: (_) => sl<CheckoutCubit>(),
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatefulWidget {
  const _CheckoutView();

  @override
  State<_CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<_CheckoutView> {
  int _step = 0;
  String? _selectedAddressId;
  String _deliveryMethod = 'standard';
  String _paymentMethod = 'cod';
  bool _isSubmitting = false;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        if (cartState.items.isEmpty) {
          return Scaffold(
            appBar: AppAppBar(title: l10n.checkoutTitle),
            body: EmptyView(
              title: l10n.emptyCartTitle,
              subtitle: l10n.emptyCartSubtitle,
              icon: Icons.shopping_bag_outlined,
              buttonText: l10n.startShopping,
              onAction: () => context.go(AppRoutes.home),
            ),
          );
        }

        final pricing = CartPricing.from(
          cartState.items,
          cartState.appliedPromoCode,
        );
        final totals = CheckoutTotals.from(
          pricing,
          deliveryMethod: _deliveryMethod,
          paymentMethod: _paymentMethod,
        );

        final isLastStep = _step == 3;

        return Scaffold(
          appBar: AppAppBar(title: l10n.checkoutTitle),
          body: Column(
            children: [
              CheckoutStepper(
                currentStep: _step,
                labels: [
                  l10n.stepAddress,
                  l10n.stepDelivery,
                  l10n.stepPayment,
                  l10n.stepReview,
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: _buildStep(context, cartState, totals),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkLine
                      : AppColors.line,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.totalLabel,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                fontSize: 17,
                                height: 1.3,
                                fontWeight: FontWeight.w400,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.darkMuted
                                    : AppColors.muted,
                              ),
                        ),
                        Text(
                          '${totals.total.toStringAsFixed(0)} ${l10n.currencySar}',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                fontSize: 17,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    Expanded(
                      child: AppButton(
                        label: isLastStep
                            ? l10n.placeOrder
                            : l10n.continueButton,
                        isLoading: _isSubmitting,
                        onPressed: () =>
                            _onPrimaryTap(context, cartState, totals),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(
    BuildContext context,
    CartState cartState,
    CheckoutTotals totals,
  ) {
    return switch (_step) {
      0 => CheckoutAddressStep(
        selectedId: _selectedAddressId,
        onSelect: (id) => setState(() => _selectedAddressId = id),
      ),
      1 => CheckoutDeliveryStep(
        method: _deliveryMethod,
        noteController: _noteController,
        cartState: cartState,
        onSelect: (m) => setState(() => _deliveryMethod = m),
      ),
      2 => CheckoutPaymentStep(
        method: _paymentMethod,
        total: totals.subtotal - totals.discount + totals.shippingFee,
        onSelect: (m) => setState(() => _paymentMethod = m),
      ),
      _ => CheckoutReviewStep(
        cartState: cartState,
        totals: totals,
        addressId: _selectedAddressId,
        deliveryMethod: _deliveryMethod,
        paymentMethod: _paymentMethod,
        onJumpToStep: (step) => setState(() => _step = step),
      ),
    };
  }

  Future<void> _onPrimaryTap(
    BuildContext context,
    CartState cartState,
    CheckoutTotals totals,
  ) async {
    final l10n = context.l10n;

    if (_step == 0 && _selectedAddressId == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.selectDeliveryAddress)));
      return;
    }

    if (_step < 3) {
      setState(() => _step++);
      return;
    }

    await _placeOrder(context, cartState, totals);
  }

  Future<void> _placeOrder(
    BuildContext context,
    CartState cartState,
    CheckoutTotals totals,
  ) async {
    if (_isSubmitting) return;

    final addressesState = context.read<AddressesCubit>().state;
    final address = addressesState.addresses.firstWhere(
      (a) => a.id == _selectedAddressId,
      orElse: () => addressesState.defaultAddress!,
    );

    setState(() => _isSubmitting = true);

    // Capture app-scoped cubits before the await so state stays consistent even
    // if the user backs out while the order is being persisted.
    final cartCubit = context.read<CartCubit>();
    final ordersCubit = context.read<OrdersCubit>();
    final notificationsCubit = context.read<NotificationsCubit>();

    final result = await context.read<CheckoutCubit>().submit(
      items: cartState.items,
      totals: totals,
      address: address,
      addressLabel: addressLabelText(context.l10n, address.label),
      deliveryMethod: _deliveryMethod,
      paymentMethod: _paymentMethod,
      courierNote: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      promoCode: cartState.appliedPromoCode,
    );

    result.fold(
      (failure) {
        if (!context.mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(failure.message(context)),
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
      (order) {
        // The checkout use case writes through the data sources; sync the
        // app-scoped cubits so badges/screens reflect the new order immediately.
        // loadCart (not reset) keeps UI and storage consistent if the cart clear
        // side effect failed after the order was saved.
        cartCubit.loadCart();
        ordersCubit.loadOrders();
        notificationsCubit.loadNotifications();
        if (context.mounted) {
          context.pushReplacement(AppRoutes.orderConfirmationFor(order.id));
        }
      },
    );
  }
}
