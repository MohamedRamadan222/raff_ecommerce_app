import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/di/injection.dart';
import 'package:raff_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/widgets/app_app_bar.dart';
import 'package:raff_app/core/widgets/app_button.dart';
import 'package:raff_app/core/widgets/app_text_field.dart';
import 'package:raff_app/core/widgets/dashed_add_button.dart';
import 'package:raff_app/core/widgets/empty_view.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_state.dart';
import 'package:raff_app/features/addresses/presentation/widgets/address_card.dart';
import 'package:raff_app/features/addresses/presentation/widgets/address_form_sheet.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';
import 'package:raff_app/features/checkout/presentation/utils/checkout_totals.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_option_card.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_stepper.dart';
import 'package:raff_app/features/checkout/presentation/widgets/order_summary_section.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_cubit.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الـ checkout بيستخدم الـ AddressesCubit العام من main.dart
    return const _CheckoutView();
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
            appBar: AppAppBar(title: l10n.checkoutTitle, showBackButton: true),
            body: EmptyView(
              title: l10n.emptyCartTitle,
              subtitle: l10n.emptyCartSubtitle,
              icon: Icons.shopping_bag_outlined,
              buttonText: l10n.startShopping,
              onAction: () => context.go(AppRoutes.home),
            ),
          );
        }

        final totals = CheckoutTotals.from(
          cartState,
          deliveryMethod: _deliveryMethod,
          paymentMethod: _paymentMethod,
        );

        final isLastStep = _step == 3;

        return Scaffold(
          appBar: AppAppBar(title: l10n.checkoutTitle, showBackButton: true),
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
      0 => _AddressStep(
        selectedId: _selectedAddressId,
        onSelect: (id) => setState(() => _selectedAddressId = id),
      ),
      1 => _DeliveryStep(
        method: _deliveryMethod,
        noteController: _noteController,
        cartState: cartState,
        onSelect: (m) => setState(() => _deliveryMethod = m),
      ),
      2 => _PaymentStep(
        method: _paymentMethod,
        total: totals.subtotal - totals.discount + totals.shippingFee,
        onSelect: (m) => setState(() => _paymentMethod = m),
      ),
      _ => _ReviewStep(
        cartState: cartState,
        totals: totals,
        addressId: _selectedAddressId,
        deliveryMethod: _deliveryMethod,
        paymentMethod: _paymentMethod,
        onJumpToStep: (step) => setState(() => _step = step),
      ),
    };
  }

  void _onPrimaryTap(
    BuildContext context,
    CartState cartState,
    CheckoutTotals totals,
  ) {
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

    _placeOrder(context, cartState, totals);
  }

  void _placeOrder(
    BuildContext context,
    CartState cartState,
    CheckoutTotals totals,
  ) {
    final addressesState = context.read<AddressesCubit>().state;
    final address = addressesState.addresses.firstWhere(
      (a) => a.id == _selectedAddressId,
      orElse: () => addressesState.defaultAddress!,
    );

    final order = OrderEntity(
      id: 'RF-${DateTime.now().millisecondsSinceEpoch % 100000}',
      items: cartState.items
          .map(
            (item) => OrderItemEntity(
              productId: item.product.id,
              title: item.product.title,
              thumbnail: item.product.thumbnail,
              price: item.product.price,
              quantity: item.quantity,
            ),
          )
          .toList(),
      subtotal: totals.subtotal,
      discount: totals.discount,
      shippingFee: totals.shippingFee,
      codFee: totals.codFee,
      total: totals.total,
      promoCode: cartState.appliedPromoCode,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
      addressLabel: addressLabelText(context.l10n, address.label),
      addressFull: address.fullAddress,
      deliveryMethod: _deliveryMethod,
      paymentMethod: _paymentMethod,
      courierNote: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    // الترتيب مهم: نحفظ الطلب الأول، وبعدها نفضي السلة
    context.read<OrdersCubit>().placeOrder(order);
    context.read<NotificationsCubit>().addNotification(
      NotificationEntity(
        id: 'notif-${order.id}',
        type: NotificationType.orderPlaced,
        orderId: order.id,
        createdAt: DateTime.now(),
      ),
    );
    context.read<CartCubit>().clearCart();
    context.go(AppRoutes.orderConfirmation, extra: order);
  }
}

class _StepTitle extends StatelessWidget {
  final String text;

  const _StepTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge!
            .copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AddressStep extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _AddressStep({required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<AddressesCubit, AddressesState>(
      builder: (context, state) {
        if (state.addresses.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(8),
              EmptyView(
                title: l10n.emptyAddressesTitle,
                subtitle: l10n.emptyAddressesSubtitle,
                icon: Icons.location_on_outlined,
                buttonText: l10n.addAddress,
                onAction: () => AddressFormSheet.show(context),
              ),
            ],
          );
        }

        // لو لسه مختارش، بنختار الافتراضي تلقائيًا — مرة واحدة بس
        final selected = selectedId ?? state.defaultAddress?.id;
        if (selectedId == null && selected != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onSelect(selected);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepTitle(l10n.whereDeliver),
            for (final address in state.addresses) ...[
              CheckoutOptionCard(
                icon: addressLabelIcon(address.label),
                title: addressLabelText(l10n, address.label),
                subtitle: address.fullAddress,
                selected: selected == address.id,
                onTap: () => onSelect(address.id),
              ),
              const Gap(12),
            ],
            DashedAddButton(
              label: l10n.addAddress,
              onTap: () => AddressFormSheet.show(context),
            ),
          ],
        );
      },
    );
  }
}

class _DeliveryStep extends StatelessWidget {
  final String method;
  final TextEditingController noteController;
  final CartState cartState;
  final ValueChanged<String> onSelect;

  const _DeliveryStep({
    required this.method,
    required this.noteController,
    required this.cartState,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final standardPrice = cartState.hasFreeShipping
        ? l10n.freeLabel
        : '${CartState.standardShippingFee.toStringAsFixed(0)} ${l10n.currencySar}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(l10n.howDeliver),
        CheckoutOptionCard(
          icon: Icons.local_shipping_outlined,
          title: l10n.deliveryStandard,
          subtitle: l10n.deliveryStandardSub,
          aside: standardPrice,
          selected: method == 'standard',
          onTap: () => onSelect('standard'),
        ),
        const Gap(12),
        CheckoutOptionCard(
          icon: Icons.bolt_rounded,
          title: l10n.deliveryExpress,
          subtitle: l10n.deliveryExpressSub,
          aside:
              '${CheckoutTotals.expressFee.toStringAsFixed(0)} ${l10n.currencySar}',
          selected: method == 'express',
          onTap: () => onSelect('express'),
        ),
        const Gap(12),
        CheckoutOptionCard(
          icon: Icons.storefront_outlined,
          title: l10n.deliveryPickup,
          subtitle: l10n.deliveryPickupSub,
          aside: l10n.freeLabel,
          selected: method == 'pickup',
          onTap: () => onSelect('pickup'),
        ),
        const Gap(12),
        AppTextField(
          label: l10n.courierNote,
          hint: l10n.courierNoteHint,
          controller: noteController,
        ),
      ],
    );
  }
}

/// خطوة ٣: طريقة الدفع — اختيار UI للتعلم، ومفيش فلوس حقيقية بتتحرك
class _PaymentStep extends StatelessWidget {
  final String method;
  final double total;
  final ValueChanged<String> onSelect;

  const _PaymentStep({
    required this.method,
    required this.total,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(l10n.howPay),
        CheckoutOptionCard(
          icon: Icons.apple,
          title: 'Apple Pay',
          subtitle: l10n.payAppleSub,
          selected: method == 'apple',
          onTap: () => onSelect('apple'),
        ),
        const Gap(12),
        CheckoutOptionCard(
          icon: Icons.credit_card,
          title: l10n.payCard,
          subtitle: '•••• 4421',
          selected: method == 'card',
          onTap: () => onSelect('card'),
        ),
        if (method == 'card') ...[
          const Gap(12),
          const _BankCard(),
          const Gap(12),
          DashedAddButton(label: l10n.addCard, onTap: () {}),
        ],
        const Gap(12),
        CheckoutOptionCard(
          icon: Icons.receipt_long_outlined,
          title: l10n.paySplit,
          subtitle:
              '4 × ${(total / 4).toStringAsFixed(0)} ${l10n.currencySar} — ${l10n.paySplitSub}',
          selected: method == 'split',
          onTap: () => onSelect('split'),
        ),
        const Gap(12),
        CheckoutOptionCard(
          icon: Icons.payments_outlined,
          title: l10n.payCod,
          subtitle: l10n.payCodSub,
          aside:
              '+${CheckoutTotals.codFeeAmount.toStringAsFixed(0)} ${l10n.currencySar}',
          selected: method == 'cod',
          onTap: () => onSelect('cod'),
        ),
        const Gap(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 16, color: cs.onSurfaceVariant),
            const Gap(6),
            Text(
              l10n.securePay,
              style: tt.bodySmall!.copyWith(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BankCard extends StatelessWidget {
  const _BankCard();

  @override
  Widget build(BuildContext context) {
    const fg = Color(0xFFF2F1EC);
    // اسم صاحب الحساب الحقيقي بدل الاسم الوهمي اللي في الديزاين
    final user = sl<AuthLocalDataSource>().getCacheUser();
    final holder = user == null
        ? ''
        : '${user.firstName} ${user.lastName}'.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 152,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A3A35), Color(0xFF23231F)],
            stops: [0, 0.7],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFCDBB98), Color(0xFFA99573)],
                ),
              ),
            ),
            const Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '5241 •••• •••• 4421',
                style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(holder, style: const TextStyle(fontSize: 13, color: fg)),
                const Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '08/29',
                    style: TextStyle(fontSize: 13, color: fg),
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

class _ReviewStep extends StatelessWidget {
  final CartState cartState;
  final CheckoutTotals totals;
  final String? addressId;
  final String deliveryMethod;
  final String paymentMethod;
  final ValueChanged<int> onJumpToStep;

  const _ReviewStep({
    required this.cartState,
    required this.totals,
    required this.addressId,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.onJumpToStep,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final address = context.read<AddressesCubit>().state.addresses.firstWhere(
      (a) => a.id == addressId,
      orElse: () => context.read<AddressesCubit>().state.defaultAddress!,
    );

    final deliveryTitle = switch (deliveryMethod) {
      'express' => l10n.deliveryExpress,
      'pickup' => l10n.deliveryPickup,
      _ => l10n.deliveryStandard,
    };

    final paymentTitle = switch (paymentMethod) {
      'apple' => 'Apple Pay',
      'card' => l10n.payCard,
      'split' => l10n.paySplit,
      _ => l10n.payCod,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(l10n.reviewOrder),
        _ReviewBlock(
          rows: [
            _ReviewRow(
              icon: Icons.location_on_outlined,
              title: l10n.stepAddress,
              value: addressLabelText(l10n, address.label),
              detail: address.fullAddress,
              onEdit: () => onJumpToStep(0),
            ),
            _ReviewRow(
              icon: Icons.local_shipping_outlined,
              title: l10n.stepDelivery,
              value: deliveryTitle,
              onEdit: () => onJumpToStep(1),
            ),
            _ReviewRow(
              icon: Icons.credit_card_outlined,
              title: l10n.stepPayment,
              value: paymentTitle,
              onEdit: () => onJumpToStep(2),
            ),
          ],
        ),
        const Gap(12),
        for (final item in cartState.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: item.product.thumbnail,
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
                        item.product.title,
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
                const Gap(12),
                Text(
                  '${item.totalPrice.toStringAsFixed(0)} ${l10n.currencySar}',
                  style: tt.bodyMedium!.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        const Gap(12),
        OrderSummarySection(totals: totals),
      ],
    );
  }
}

class _ReviewBlock extends StatelessWidget {
  final List<Widget> rows;

  const _ReviewBlock({required this.rows});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final line = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkLine
        : AppColors.line;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: line),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? detail;
  final VoidCallback onEdit;

  const _ReviewRow({
    required this.icon,
    required this.title,
    required this.value,
    this.detail,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.accent;
    final muted = isDark ? AppColors.darkMuted : AppColors.muted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodySmall!.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: muted,
                  ),
                ),
                Text(
                  value,
                  style: tt.bodyMedium!.copyWith(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: tt.bodySmall!.copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: muted,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                l10n.changeButton,
                style: tt.bodySmall!.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
