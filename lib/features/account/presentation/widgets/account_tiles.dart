import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/utils/app_formatters.dart';
import 'package:raff_app/features/account/presentation/widgets/account_tile.dart';
import 'package:raff_app/features/account/presentation/widgets/tiles_card.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_state.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_state.dart';

class AccountTiles extends StatelessWidget {
  const AccountTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final digits = AppFormatters.number(l10n.localeName);

    return BlocSelector<OrdersCubit, OrdersState, int>(
      selector: (state) => state.currentOrders.length,
      builder: (context, currentOrdersCount) {
        return BlocSelector<AddressesCubit, AddressesState, int>(
          selector: (state) => state.addresses.length,
          builder: (context, addressesCount) {
            return TilesCard(
              children: [
                AccountTile(
                  icon: Icons.inventory_2_outlined,
                  title: l10n.myOrders,
                  subtitle: currentOrdersCount > 0
                      ? l10n.ordersOnTheWay(currentOrdersCount)
                      : null,
                  onTap: () => context.push(AppRoutes.orders),
                ),
                AccountTile(
                  icon: Icons.location_on_outlined,
                  title: l10n.addresses,
                  subtitle: l10n.savedCount(digits.format(addressesCount)),
                  onTap: () => context.push(AppRoutes.addresses),
                ),
                AccountTile(
                  icon: Icons.credit_card_outlined,
                  title: l10n.paymentMethods,
                  subtitle: l10n.paymentMethodsSubtitle,
                  onTap: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
                  },
                ),
                AccountTile(
                  icon: Icons.notifications_none_rounded,
                  title: l10n.notifications,
                  onTap: () => context.push(AppRoutes.notifications),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
