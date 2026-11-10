import 'package:flutter/material.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = isDark ? AppColors.darkInk : AppColors.ink;

    return Center(child: CircularProgressIndicator(color: color));
  }
}
