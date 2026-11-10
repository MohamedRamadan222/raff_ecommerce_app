import 'package:flutter/material.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const FavoriteButton({
    super.key,
    this.isFavorite = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.darkDanger : AppColors.danger;
    final inActiveColor = isDark
        ? AppColors.darkInkSecondary
        : AppColors.inkSecondary;
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      iconSize: 20,

      onPressed: onTap,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? activeColor : inActiveColor,
      ),
    );
  }
}
