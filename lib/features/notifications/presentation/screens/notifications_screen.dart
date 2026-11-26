import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/widgets/app_app_bar.dart';
import 'package:raff_app/core/widgets/empty_view.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppAppBar(
        title: l10n.notifications,
        showBackButton: true,
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () =>
                    context.read<NotificationsCubit>().markAllRead(),
                child: Text(l10n.markAllRead),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.notifications.isEmpty) {
            return EmptyView(
              title: l10n.emptyNotificationsTitle,
              subtitle: l10n.emptyNotificationsSubtitle,
              icon: Icons.notifications_none_rounded,
            );
          }

          final today = state.todayNotifications;
          final earlier = state.earlierNotifications;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              if (today.isNotEmpty) ...[
                _GroupLabel(text: l10n.todayLabel),
                const Gap(8),
                for (final n in today) ...[
                  _NotificationTile(notification: n),
                  const Gap(12),
                ],
                const Gap(12),
              ],
              if (earlier.isNotEmpty) ...[
                _GroupLabel(text: l10n.earlierLabel),
                const Gap(8),
                for (final n in earlier) ...[
                  _NotificationTile(notification: n),
                  const Gap(12),
                ],
              ],
            ],
          );
        },
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

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !notification.isRead;

    // النصوص بتتولد من نوع الإشعار بالترجمة — مش مخزنة في التخزين
    final (icon, title, body) = switch (notification.type) {
      NotificationType.orderPlaced => (
        Icons.inventory_2_outlined,
        l10n.notifOrderPlacedTitle,
        l10n.notifOrderPlacedBody,
      ),
      NotificationType.promo => (
        Icons.local_offer_outlined,
        l10n.notifPromoTitle,
        l10n.notifPromoBody,
      ),
      NotificationType.general => (
        Icons.notifications_none_rounded,
        l10n.notifications,
        '',
      ),
    };

    final timeFormat = intl.DateFormat.jm(l10n.localeName);
    final accent = isDark ? AppColors.darkAccent : AppColors.accent;

    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread
              ? (isDark ? AppColors.darkAccentSoft : AppColors.accentSoft)
              : cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? Colors.transparent : cs.outlineVariant,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Icon(icon, size: 20, color: accent),
            ),
            const Gap(12),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.bodyMedium!.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    if (body.isNotEmpty) ...[
                      const Gap(2),
                      Text(
                        body,
                        style: tt.bodySmall!.copyWith(
                          fontSize: 13,
                          height: 1.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const Gap(4),
                    Text(
                      timeFormat.format(notification.createdAt),
                      style: tt.bodySmall!.copyWith(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isUnread)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    context.read<NotificationsCubit>().markRead(notification.id);
    final orderId = notification.orderId;
    if (orderId != null) {
      context.push('/orders/$orderId/track');
    }
  }
}
