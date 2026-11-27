import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProductDetailsInfoTileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;

  const ProductDetailsInfoTileRow({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 19, color: cs.primary),
          const Gap(10),
          Expanded(
            child: Text(
              title,
              style: tt.bodyMedium!.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),
          Text(
            trailing,
            style: tt.bodySmall!.copyWith(
              fontSize: 11.5,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
