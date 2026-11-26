import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:raff_app/core/di/injection.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/features/account/presentation/widgets/account_tile.dart';
import 'package:raff_app/features/account/presentation/widgets/language_sheet.dart';
import 'package:raff_app/features/account/presentation/widgets/profile_header.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_state.dart';
import 'package:raff_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_state.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_state.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    // بنجيب بيانات المستخدم المخزنة محليًا بعد تسجيل الدخول.
    // لو داخل كضيف الـ user بيبقى null وبنعرض "ضيف".
    final user = sl<AuthLocalDataSource>().getCacheUser();
    final fullName = user == null
        ? ''
        : '${user.firstName} ${user.lastName}'.trim();
    final displayName = fullName.isNotEmpty
        ? fullName
        : (user?.username.isNotEmpty ?? false)
        ? user!.username
        : l10n.guestUser;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            SizedBox(
              height: 64,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.navAccount,
                  style: tt.titleLarge!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ProfileHeader(
              name: displayName,
              phone: user?.phone,
              onEditTap: () => _showComingSoon(context),
            ),
            const Gap(12),
            const _StatsRow(),
            const Gap(24),

            _GroupLabel(text: l10n.myAccount),
            const Gap(8),
            const _AccountTiles(),
            const Gap(24),

            _GroupLabel(text: l10n.preferences),
            const Gap(8),
            const _PreferencesCard(),
            const Gap(24),

            _GroupLabel(text: l10n.support),
            const Gap(8),
            _TilesCard(
              children: [
                AccountTile(
                  icon: Icons.help_outline_rounded,
                  title: l10n.helpCenter,
                  onTap: () => _showComingSoon(context),
                ),
                AccountTile(
                  icon: Icons.shield_outlined,
                  title: l10n.privacyPolicy,
                  onTap: () => _showComingSoon(context),
                ),
                AccountTile(
                  icon: Icons.logout_rounded,
                  title: l10n.logout,
                  isDanger: true,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
            const Gap(24),

            Center(
              child: Text(
                '${l10n.appVersion} 1.0.0',
                style: tt.bodySmall!.copyWith(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // clearUser بتمسح بيانات المستخدم وبتعلّم إنه مش مسجل دخول،
    // وبعدها السبلاش هيوجهه لشاشة اللوجين في المرة الجاية.
    await sl<AuthLocalDataSource>().clearUser();
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final digits = NumberFormat('#,##0', l10n.localeName);

    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, ordersState) {
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favoritesState) {
            return Row(
              children: [
                _StatBox(
                  value: digits.format(ordersState.orders.length),
                  label: l10n.statOrders,
                  onTap: () => context.push(AppRoutes.orders),
                ),
                const Gap(12),
                _StatBox(
                  value: digits.format(favoritesState.favorites.length),
                  label: l10n.statFavorites,
                  onTap: () => context.go(AppRoutes.favorites),
                ),
                const Gap(12),
                _StatBox(
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

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatBox({required this.value, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: tt.titleLarge!.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: tt.bodySmall!.copyWith(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;

  const _GroupLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: tt.bodySmall!.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _AccountTiles extends StatelessWidget {
  const _AccountTiles();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final digits = NumberFormat('#,##0', l10n.localeName);

    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, ordersState) {
        return BlocBuilder<AddressesCubit, AddressesState>(
          builder: (context, addressesState) {
            final onTheWay = ordersState.currentOrders.length;
            return _TilesCard(
              children: [
                AccountTile(
                  icon: Icons.inventory_2_outlined,
                  title: l10n.myOrders,
                  subtitle: onTheWay > 0 ? l10n.ordersOnTheWay(onTheWay) : null,
                  onTap: () => context.push(AppRoutes.orders),
                ),
                AccountTile(
                  icon: Icons.location_on_outlined,
                  title: l10n.addresses,
                  subtitle: l10n.savedCount(
                    digits.format(addressesState.addresses.length),
                  ),
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

class _TilesCard extends StatelessWidget {
  final List<Widget> children;

  const _TilesCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, color: cs.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final isArabic = settingsState.locale.languageCode == 'ar';
        final isDark = settingsState.themeMode == ThemeMode.dark;

        return _TilesCard(
          children: [
            AccountTile(
              icon: Icons.language_rounded,
              title: l10n.language,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isArabic ? l10n.arabic : l10n.english,
                    style: tt.bodyMedium!.copyWith(
                      fontSize: 14,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const Gap(4),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
              onTap: () => LanguageSheet.show(context),
            ),
            AccountTile(
              icon: Icons.dark_mode_outlined,
              title: l10n.darkMode,
              trailing: _DesignSwitch(
                value: isDark,
                onChanged: (value) => context.read<SettingsCubit>().changeTheme(
                  value ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
              onTap: () => context.read<SettingsCubit>().changeTheme(
                isDark ? ThemeMode.light : ThemeMode.dark,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DesignSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DesignSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value
              ? (isDark ? AppColors.darkInk : AppColors.ink)
              : (isDark ? AppColors.darkLineStrong : AppColors.lineStrong),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: value
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? (isDark ? AppColors.darkPaper : AppColors.paper)
                  : Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
