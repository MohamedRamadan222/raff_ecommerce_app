import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/session/session_cubit.dart';
import 'package:raff_app/core/session/session_state.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_state.dart';
import 'package:raff_app/features/addresses/presentation/widgets/address_card.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_state.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onNotificationsTap;

  const HomeHeader({super.key, required this.onNotificationsTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final timeGreeting = DateTime.now().hour < 12
        ? l10n.goodMorning
        : l10n.goodEvening;

    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, session) {
        final user = session.user;
        final displayName = user != null
            ? (user.firstName.isNotEmpty ? user.firstName : user.username)
            : null;
        final greetingText = displayName != null
            ? '$timeGreeting${isAr ? '، ' : ', '}$displayName'
            : timeGreeting;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greetingText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.headlineMedium!.copyWith(
                      fontSize: 20,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  BlocBuilder<AddressesCubit, AddressesState>(
                    builder: (context, addressState) {
                      final address = addressState.defaultAddress;
                      // لو العنوان مفيهوش نص بنعرض نوعه (المنزل، العمل...) بدل سطر فاضي
                      final addressText = address == null
                          ? l10n.selectDeliveryAddress
                          : (address.shortTitle.isNotEmpty
                                ? address.shortTitle
                                : addressLabelText(l10n, address.label));

                      return InkWell(
                        onTap: () => context.push(AppRoutes.addresses),
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: cs.onSurfaceVariant,
                            ),
                            const Gap(4),
                            Flexible(
                              child: RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  style: tt.bodySmall!.copyWith(
                                    fontSize: 13,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  children: [
                                    TextSpan(text: '${l10n.deliverTo} '),
                                    TextSpan(
                                      text: addressText,
                                      style: TextStyle(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Gap(4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: cs.onSurfaceVariant,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onNotificationsTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child:
                    BlocSelector<NotificationsCubit, NotificationsState, int>(
                      selector: (state) => state.unreadCount,
                      builder: (context, unreadCount) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 24,
                              color: cs.onSurface,
                            ),
                            if (unreadCount > 0)
                              PositionedDirectional(
                                top: 2,
                                end: 2,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: cs.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}
