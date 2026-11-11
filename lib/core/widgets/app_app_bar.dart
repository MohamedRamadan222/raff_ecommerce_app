import 'package:flutter/material.dart';
import 'package:raff_app/core/theme/app_colors.dart';

import 'app_back_button.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final Widget? customSubtitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? leading;
  final double? titleSpacing;

  const AppAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.customSubtitle,
    this.actions,
    this.showBackButton = false,
    this.leading,
    this.titleSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkPaper : AppColors.paper;
    final textColor = isDark ? AppColors.darkInk : AppColors.ink;
    final subtitleColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: titleSpacing ?? (showBackButton ? 0 : 24),
      automaticallyImplyLeading: false,
      leading: leading ?? (showBackButton ? const AppBackButton() : null),
      title: _buildTitle(context, textColor, subtitleColor),
      actions: [...?actions, const SizedBox(width: 12)],
    );
  }

  Widget? _buildTitle(
    BuildContext context,
    Color textColor,
    Color subtitleColor,
  ) {
    if (title == null) return null;

    if (subtitle == null && customSubtitle == null) {
      return Text(
        title!,
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(color: textColor, fontWeight: FontWeight.bold),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title!,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: subtitleColor, height: 1.5),
          ),
        ?customSubtitle,
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    subtitle != null || customSubtitle != null ? 66 : kToolbarHeight,
  );
}
