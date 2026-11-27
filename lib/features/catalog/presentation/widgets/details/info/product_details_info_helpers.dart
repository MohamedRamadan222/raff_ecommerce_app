import 'package:flutter/material.dart';

Color productDetailsCardSurface(BuildContext context) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  return theme.brightness == Brightness.dark
      ? Color.alphaBlend(cs.onSurface.withValues(alpha: 0.05), cs.surface)
      : Color.alphaBlend(cs.outlineVariant.withValues(alpha: 0.32), cs.surface);
}

TextStyle productDetailsInfoLabelStyle(ThemeData theme) {
  return theme.textTheme.bodySmall!.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
  );
}

class ProductDetailsInfoCard extends StatelessWidget {
  final Widget child;

  const ProductDetailsInfoCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: productDetailsCardSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: child,
    );
  }
}
