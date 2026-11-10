import 'package:flutter/material.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class PageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const PageIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = isDark ? AppColors.darkInk : AppColors.ink;
    final inactiveColor = isDark
        ? AppColors.darkLineStrong
        : AppColors.lineStrong;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsetsDirectional.only(end: 6.0),
          width: isActive ? 24.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
