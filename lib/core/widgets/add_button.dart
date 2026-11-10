import 'package:flutter/material.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? AppColors.darkInk : AppColors.ink;
    final iconColor = isDark ? AppColors.darkOnInk : AppColors.onInk;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(Icons.add, size: 20, color: iconColor),
      ),
    );
  }
}
