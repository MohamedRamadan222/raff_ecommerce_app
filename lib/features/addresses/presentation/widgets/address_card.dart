import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';

String addressLabelText(AppLocalizations l10n, AddressLabel label) {
  return switch (label) {
    AddressLabel.home => l10n.labelHome,
    AddressLabel.work => l10n.labelWork,
    AddressLabel.other => l10n.labelOther,
  };
}

IconData addressLabelIcon(AddressLabel label) {
  return switch (label) {
    AddressLabel.home => Icons.home_outlined,
    AddressLabel.work => Icons.work_outline_rounded,
    AddressLabel.other => Icons.location_on_outlined,
  };
}

class AddressCard extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onSetDefaultTap;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEditTap,
    required this.onDeleteTap,
    required this.onSetDefaultTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.ink;
    final line = isDark ? AppColors.darkLine : AppColors.line;
    final accent = isDark ? AppColors.darkAccent : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: address.isDefault ? ink : line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(addressLabelIcon(address.label), size: 18, color: ink),
              const Gap(8),
              Text(
                addressLabelText(l10n, address.label),
                style: tt.bodyMedium!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (address.isDefault) ...[
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: line),
                  ),
                  child: Text(
                    l10n.defaultBadge,
                    style: tt.labelSmall!.copyWith(
                      fontSize: 11,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              _MiniIconButton(
                icon: Icons.edit_outlined,
                color: cs.onSurfaceVariant,
                onTap: onEditTap,
              ),
              _MiniIconButton(
                icon: Icons.delete_outline_rounded,
                color: cs.error,
                onTap: onDeleteTap,
              ),
            ],
          ),
          const Gap(8),
          Text(
            address.fullAddress,
            style: tt.bodyMedium!.copyWith(fontSize: 14, height: 1.5),
          ),
          const Gap(8),
          Text(
            address.phone,
            textDirection: TextDirection.ltr,
            style: tt.bodySmall!.copyWith(
              fontSize: 13,
              color: cs.onSurfaceVariant,
            ),
          ),
          if (!address.isDefault) ...[
            const Gap(8),
            GestureDetector(
              onTap: onSetDefaultTap,
              child: Text(
                l10n.setAsDefault,
                style: tt.bodySmall!.copyWith(
                  fontSize: 13,
                  color: accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MiniIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
