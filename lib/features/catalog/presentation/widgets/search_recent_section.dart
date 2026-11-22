import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/l10n/app_localizations.dart';

class SearchRecentSection extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  const SearchRecentSection({
    super.key,
    required this.searches,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentSearches,
              style: tt.titleMedium!.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: onClear,
              child: Text(
                l10n.clear,
                style: tt.bodySmall!.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searches.map((query) {
            return InkWell(
              onTap: () => onSelect(query),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 15,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                    const Gap(6),
                    Text(
                      query,
                      style: tt.bodySmall!.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const Gap(24),
      ],
    );
  }
}
