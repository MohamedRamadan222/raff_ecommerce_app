import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.darkInk : AppColors.ink;

    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new, color: iconColor, size: 20),
      onPressed:
          onPressed ??
          () {
            if (context.canPop()) {
              context.pop();
            }
          },
    );
  }
}
