import 'package:flutter/material.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class AppBadge extends StatelessWidget {
  final String text;

  const AppBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = isDark ? AppColors.darkInk : AppColors.ink;
    final foregroundColor = isDark ? AppColors.darkOnInk : AppColors.onInk;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 8.0,
        vertical: 1.3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: textTheme.labelSmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
