import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/widgets/error_view.dart';
import 'package:raff_app/core/widgets/loading_view.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';
import 'package:raff_app/features/cart/presentation/widgets/cart_empty_view.dart';
import 'package:raff_app/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:raff_app/features/cart/presentation/widgets/cart_shipping_banner.dart';
import 'package:raff_app/features/cart/presentation/widgets/cart_summary_section.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _showRemovedSnackBar(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.removedFromCart,
            style: tt.bodyMedium!.copyWith(
              color: cs.onInverseSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: cs.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.status == CartStatus.loading && state.items.isEmpty) {
          return const Scaffold(body: LoadingView());
        }

        if (state.status == CartStatus.failure &&
            state.items.isEmpty &&
            state.failure != null) {
          return Scaffold(
            body: ErrorView(
              message: state.failure!.message(context),
              onRetry: () => context.read<CartCubit>().loadCart(),
            ),
          );
        }

        final items = state.items;

        return Scaffold(
          bottomNavigationBar: items.isEmpty
              ? null
              : Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(top: BorderSide(color: cs.outlineVariant)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.totalLabel,
                            style: tt.bodySmall!.copyWith(
                              fontSize: 11.5,
                              color: cs.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                          const Gap(2),
                          Text(
                            '${state.total.toStringAsFixed(0)} ${l10n.currencySar}',
                            style: tt.headlineMedium!.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => context.push(AppRoutes.checkout),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.inverseSurface,
                              foregroundColor: cs.onInverseSurface,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              l10n.checkoutButton,
                              style: tt.labelLarge!.copyWith(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: cs.onInverseSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.navCart,
                        style: tt.headlineMedium!.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (items.isNotEmpty)
                        Text(
                          '${state.totalItemsCount} ${l10n.pieceUnit}',
                          style: tt.bodySmall!.copyWith(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: items.isEmpty
                      ? const CartEmptyView()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                          children: [
                            CartShippingBanner(
                              hasFreeShipping: state.hasFreeShipping,
                              remainingAmount: state.remainingForFreeShipping,
                              progress: state.freeShippingProgress,
                            ),
                            const Gap(8),
                            ...List.generate(items.length, (index) {
                              final item = items[index];
                              return Column(
                                children: [
                                  CartItemTile(
                                    item: item,
                                    onTap: () => context.push(
                                      AppRoutes.productDetails,
                                      extra: item.product.id,
                                    ),
                                    onIncrement: () => context
                                        .read<CartCubit>()
                                        .incrementQuantity(item.product.id),
                                    onDecrement: () {
                                      final willRemove = item.quantity <= 1;
                                      context
                                          .read<CartCubit>()
                                          .decrementQuantity(item.product.id);
                                      if (willRemove) {
                                        _showRemovedSnackBar(context);
                                      }
                                    },
                                    onRemove: () {
                                      context.read<CartCubit>().removeFromCart(
                                        item.product.id,
                                      );
                                      _showRemovedSnackBar(context);
                                    },
                                  ),
                                  Divider(height: 1, color: cs.outlineVariant),
                                ],
                              );
                            }),
                            const Gap(18),
                            CartSummarySection(
                              state: state,
                              promoController: _promoController,
                              onApplyPromo: () {
                                FocusScope.of(context).unfocus();
                                context.read<CartCubit>().applyPromoCode(
                                  _promoController.text,
                                );
                              },
                              onRemovePromo: () {
                                _promoController.clear();
                                context.read<CartCubit>().removePromoCode();
                              },
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
