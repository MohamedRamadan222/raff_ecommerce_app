import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/utils/app_formatters.dart';
import 'package:raff_app/features/account/presentation/widgets/stat_box.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_state.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final digits = AppFormatters.number(l10n.localeName);

    return BlocSelector<OrdersCubit, OrdersState, int>(
      selector: (state) => state.orders.length,
      builder: (context, ordersCount) {
        return BlocSelector<FavoritesCubit, FavoritesState, int>(
          selector: (state) => state.favorites.length,
          builder: (context, favoritesCount) {
            return Row(
              children: [
                StatBox(
                  value: digits.format(ordersCount),
                  label: l10n.statOrders,
                  onTap: () => context.push(AppRoutes.orders),
                ),
                const Gap(12),
                StatBox(
                  value: digits.format(favoritesCount),
                  label: l10n.statFavorites,
                  onTap: () => context.go(AppRoutes.favorites),
                ),
                const Gap(12),
                StatBox(
                  value: digits.format(0),
                  label: l10n.statPoints,
                  onTap: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(l10n.pointsMsg)));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
