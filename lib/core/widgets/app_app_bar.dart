import 'package:flutter/material.dart';
import 'package:raff_app/core/theme/app_colors.dart';

import 'app_back_button.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const AppAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
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
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: const AppBackButton(),
      title: _buildTitle(context, textColor, subtitleColor),
      actions: [...?actions, const SizedBox(width: 12)],
    );
  }

  Widget _buildTitle(
    BuildContext context,
    Color textColor,
    Color subtitleColor,
  ) {
    if (subtitle == null) {
      return Text(
        title,
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(color: textColor, fontWeight: FontWeight.bold),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        Text(
          subtitle!,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: subtitleColor, height: 1.5),
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle != null ? 66 : kToolbarHeight);
}
