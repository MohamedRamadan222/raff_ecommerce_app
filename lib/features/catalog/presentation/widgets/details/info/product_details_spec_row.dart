import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProductDetailsSpecRow extends StatelessWidget {
  final String label;
  final String value;

  const ProductDetailsSpecRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: tt.bodySmall!.copyWith(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const Gap(16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodyMedium!.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
