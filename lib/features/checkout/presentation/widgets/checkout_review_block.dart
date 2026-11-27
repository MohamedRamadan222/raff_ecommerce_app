import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class CheckoutReviewBlock extends StatelessWidget {
  final List<Widget> rows;

  const CheckoutReviewBlock({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final line = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkLine
        : AppColors.line;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: line),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class CheckoutReviewRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? detail;
  final VoidCallback onEdit;

  const CheckoutReviewRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.detail,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.accent;
    final muted = isDark ? AppColors.darkMuted : AppColors.muted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodySmall!.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: muted,
                  ),
                ),
                Text(
                  value,
                  style: tt.bodyMedium!.copyWith(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: tt.bodySmall!.copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: muted,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                l10n.changeButton,
                style: tt.bodySmall!.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
