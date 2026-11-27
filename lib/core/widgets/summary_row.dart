import 'package:flutter/material.dart';

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;
  final Color? valueColor;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final style = tt.bodyMedium!.copyWith(fontSize: 14);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
        ),
        Text(
          value,
          style: style.copyWith(
            fontWeight: emphasized
                ? FontWeight.w700
                : (valueColor != null ? FontWeight.w500 : style.fontWeight),
            color: valueColor ?? (emphasized ? cs.onSurface : null),
          ),
        ),
      ],
    );
  }
}
