import 'package:flutter/material.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText; // نص الزرار الجانبي (مثلاً: عرض الكل)
  final VoidCallback? onActionTap;
  final Widget? trailing; // لو حبيت تحط أيقونة مخصوصة بدل النص والسهم

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkInk : AppColors.ink;
    // لون الزرار الجانبي بنخليه باهت شوية عشان ميسرقش العين من العنوان
    final actionColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. العنوان الرئيسي
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        // 2. الجزء الجانبي (حسب اللي هتبعته ليه)
        if (trailing != null)
          trailing!
        else if (actionText != null && onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionText!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: actionColor,
                  ),
                ),
                const SizedBox(width: 4),
                // السهم (Directional عشان يقلب مع العربي والإنجليزي)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: actionColor,
                  // يقلب اتجاهه بناءً على لغة التطبيق
                  textDirection: Directionality.of(context) == TextDirection.rtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
              ],
            ),
          ),
      ],
    );
  }
}