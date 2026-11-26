import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class CheckoutOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? aside;
  final bool selected;
  final VoidCallback onTap;

  const CheckoutOptionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.aside,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.ink;
    final sunken = isDark ? AppColors.darkSunken : AppColors.sunken;
    final lineStrong = isDark ? AppColors.darkLineStrong : AppColors.lineStrong;
    final muted = isDark ? AppColors.darkMuted : AppColors.muted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? ink : lineStrong),
          boxShadow: selected ? [BoxShadow(color: ink, spreadRadius: 1)] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? ink : lineStrong,
                  width: 2,
                ),
              ),
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.all(3),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ink,
                        ),
                      ),
                    )
                  : null,
            ),
            const Gap(12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: sunken,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: cs.onSurface),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.bodyMedium!.copyWith(fontSize: 15, height: 1.45),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: tt.bodySmall!.copyWith(
                        fontSize: 15,
                        height: 1.45,
                        color: muted,
                      ),
                    ),
                ],
              ),
            ),
            if (aside != null) ...[
              const Gap(12),
              Text(
                aside!,
                style: tt.bodySmall!.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
