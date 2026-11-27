import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/di/injection.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/session/session_cleaner.dart';
import 'package:raff_app/core/session/session_cubit.dart';
import 'package:raff_app/core/session/session_state.dart';
import 'package:raff_app/features/account/presentation/widgets/account_tile.dart';
import 'package:raff_app/features/account/presentation/widgets/account_tiles.dart';
import 'package:raff_app/features/account/presentation/widgets/group_label.dart';
import 'package:raff_app/features/account/presentation/widgets/preferences_card.dart';
import 'package:raff_app/features/account/presentation/widgets/profile_header.dart';
import 'package:raff_app/features/account/presentation/widgets/stats_row.dart';
import 'package:raff_app/features/account/presentation/widgets/tiles_card.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_cubit.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    // الـ SessionCubit هو المصدر الوحيد لبيانات المستخدم الحالي.
    // لو داخل كضيف الـ user بيبقى null وبنعرض "ضيف".
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, session) {
        final user = session.user;
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
                const StatsRow(),
                const Gap(24),

                GroupLabel(text: l10n.myAccount),
                const Gap(8),
                const AccountTiles(),
                const Gap(24),

                GroupLabel(text: l10n.preferences),
                const Gap(8),
                const PreferencesCard(),
                const Gap(24),

                GroupLabel(text: l10n.support),
                const Gap(8),
                TilesCard(
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
      },
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

    // نمسح كل بيانات المستخدم المحلية، وبعدها نصفّر الـ cubits ونحدّث
    // الجلسة عشان الـ router يوجّه لشاشة تسجيل الدخول.
    await sl<SessionCleaner>().clearAll();
    if (!context.mounted) return;

    context.read<CartCubit>().reset();
    context.read<FavoritesCubit>().reset();
    context.read<AddressesCubit>().reset();
    context.read<NotificationsCubit>().reset();
    context.read<OrdersCubit>().reset();
    context.read<SessionCubit>().clear();

    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }
}
