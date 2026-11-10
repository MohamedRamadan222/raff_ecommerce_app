import 'package:flutter/material.dart';
import 'package:raff_app/core/theme/app_colors.dart';

import 'app_button.dart';

class EmptyView extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onAction;

  const EmptyView({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined, // أيقونة افتراضية
    this.buttonText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkInk : AppColors.ink;
    final subtitleColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: subtitleColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: textColor, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: subtitleColor),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppButton(onPressed: onAction!, label: buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
