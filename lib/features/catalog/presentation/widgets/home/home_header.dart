import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/di/injection.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/features/auth/data/datasources/auth_local_data_source.dart';

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

    final user = sl<AuthLocalDataSource>().getCacheUser();
    final timeGreeting = DateTime.now().hour < 12
        ? l10n.goodMorning
        : l10n.goodEvening;
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(4),
              InkWell(
                onTap: () => context.push(AppRoutes.addresses),
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                    const Gap(4),
                    Flexible(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: tt.bodySmall,
                          children: [
                            TextSpan(text: '${l10n.deliverTo} '),
                            TextSpan(
                              text: l10n.selectDeliveryAddress,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onNotificationsTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 24,
                  color: cs.onSurface,
                ),
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
            ),
          ),
        ),
      ],
    );
  }
}
