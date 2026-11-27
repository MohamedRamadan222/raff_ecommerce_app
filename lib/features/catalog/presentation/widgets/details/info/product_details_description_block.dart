import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';

class ProductDetailsDescriptionBlock extends StatelessWidget {
  final String description;
  final bool isEnglish;

  const ProductDetailsDescriptionBlock({
    super.key,
    required this.description,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aboutProduct,
          style: tt.titleMedium!.copyWith(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(8),
        Text(
          description,
          textDirection: isEnglish ? TextDirection.ltr : null,
          textAlign: isEnglish ? TextAlign.end : TextAlign.start,
          style: tt.bodyMedium!.copyWith(
            fontSize: 13.5,
            height: 1.55,
            color: cs.onSurface.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}
