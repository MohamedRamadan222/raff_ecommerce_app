import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? phone;
  final VoidCallback onEditTap;

  const ProfileHeader({
    super.key,
    required this.name,
    this.phone,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isDark
                ? AppColors.darkAccentSoft
                : AppColors.accentSoft,
            child: Text(
              name.isNotEmpty ? name.characters.first : '?',
              style: tt.titleLarge!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkAccent : AppColors.accent,
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: tt.titleMedium!.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (phone != null && phone!.isNotEmpty) ...[
                  const Gap(2),
                  // bdi بيخلي رقم التليفون يتعرض LTR صح جوه نص عربي RTL
                  Text(
                    phone!,
                    textDirection: TextDirection.ltr,
                    style: tt.bodySmall!.copyWith(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: onEditTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.edit_outlined, size: 20, color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
