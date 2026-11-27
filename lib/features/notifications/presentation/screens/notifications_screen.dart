import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/utils/app_formatters.dart';
import 'package:raff_app/core/widgets/app_app_bar.dart';
import 'package:raff_app/core/widgets/empty_view.dart';
import 'package:raff_app/core/widgets/error_view.dart';
import 'package:raff_app/core/widgets/loading_view.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // The app-scoped cubit survives logout; reload after a reset or first use.
    context.read<NotificationsCubit>().ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppAppBar(
        title: l10n.notifications,
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
          switch (state) {
            case NotificationsInitial():
            case NotificationsLoading():
              return const LoadingView();

            case NotificationsFailure(:final failure):
              return ErrorView(
                message: failure.message(context),
                onRetry: () =>
                    context.read<NotificationsCubit>().loadNotifications(),
              );

            case final NotificationsSuccess success:
              if (success.notifications.isEmpty) {
                return EmptyView(
                  title: l10n.emptyNotificationsTitle,
                  subtitle: l10n.emptyNotificationsSubtitle,
                  icon: Icons.notifications_none_rounded,
                );
              }

              final today = success.todayNotifications;
              final earlier = success.earlierNotifications;

              final entries = <Object>[
                if (today.isNotEmpty) ...[
                  l10n.todayLabel,
                  const _SpacerEntry(8),
                  for (final n in today) ...[n, const _SpacerEntry(12)],
                  const _SpacerEntry(12),
                ],
                if (earlier.isNotEmpty) ...[
                  l10n.earlierLabel,
                  const _SpacerEntry(8),
                  for (final n in earlier) ...[n, const _SpacerEntry(12)],
                ],
              ];

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return switch (entry) {
                    String label => _GroupLabel(text: label),
                    NotificationEntity notification => _NotificationTile(
                      key: ValueKey(notification.id),
                      notification: notification,
                    ),
                    _SpacerEntry spacer => Gap(spacer.height),
                    _ => const SizedBox.shrink(),
                  };
                },
              );
          }
        },
      ),
    );
  }
}

class _SpacerEntry {
  final double height;

  const _SpacerEntry(this.height);
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

  const _NotificationTile({super.key, required this.notification});

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

    final timeFormat = AppFormatters.timeShort(l10n.localeName);
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
      context.push(AppRoutes.trackOrderFor(orderId));
    }
  }
}
