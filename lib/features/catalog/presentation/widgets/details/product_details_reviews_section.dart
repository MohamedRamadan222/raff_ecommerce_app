import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class ProductDetailsReviewsSection extends StatelessWidget {
  final double rating;
  final int reviewsCount;

  const ProductDetailsReviewsSection({
    super.key,
    required this.rating,
    required this.reviewsCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final cardSurface = isDark
        ? Color.alphaBlend(cs.onSurface.withValues(alpha: 0.05), cs.surface)
        : Color.alphaBlend(
            cs.outlineVariant.withValues(alpha: 0.32),
            cs.surface,
          );

    const bars = [
      (star: 5, ratio: 0.78),
      (star: 4, ratio: 0.16),
      (star: 3, ratio: 0.04),
      (star: 2, ratio: 0.01),
      (star: 1, ratio: 0.01),
    ];

    final reviews = isAr
        ? const [
            (
              initial: 'ن',
              name: 'نورة',
              time: 'قبل أسبوع',
              stars: 5,
              comment: 'الجودة أعلى مما توقعت، والتغليف كان ممتازًا. وصلت في يومين فقط.',
            ),
            (
              initial: 'خ',
              name: 'خالد',
              time: 'قبل ٣ أسابيع',
              stars: 4,
              comment: 'اللون أفتح قليلًا من الصورة لكنه جميل جدًا في الإضاءة الطبيعية.',
            ),
          ]
        : const [
            (
              initial: 'N',
              name: 'Noura',
              time: '1 week ago',
              stars: 5,
              comment: 'Quality exceeded my expectations and packaging was great. Arrived in 2 days.',
            ),
            (
              initial: 'K',
              name: 'Khaled',
              time: '3 weeks ago',
              stars: 4,
              comment: 'Slightly lighter than the photos, yet looks wonderful in natural light.',
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.ratingsTitle,
              style: tt.titleMedium!.copyWith(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              l10n.seeAll,
              style: tt.bodySmall!.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Gap(12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: tt.headlineMedium!.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const Gap(4),
                  _StarsRow(count: rating.round()),
                  const Gap(4),
                  Text(
                    '$reviewsCount ${l10n.ratingUnit}',
                    style: tt.bodySmall!.copyWith(fontSize: 11),
                  ),
                ],
              ),
              const Gap(18),
              Expanded(
                child: Column(
                  children: bars.map((b) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 14,
                            child: Text(
                              '${b.star}',
                              style: tt.bodySmall!.copyWith(fontSize: 11),
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: b.ratio,
                                minHeight: 4.5,
                                backgroundColor: cs.outlineVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const Gap(16),

        ...List.generate(reviews.length, (index) {
          final rev = reviews[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        rev.initial,
                        style: tt.titleMedium!.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: cs.onSecondary,
                        ),
                      ),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rev.name,
                          style: tt.titleMedium!.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          rev.time,
                          style: tt.bodySmall!.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _StarsRow(count: rev.stars),
                ],
              ),
              const Gap(8),
              Text(
                rev.comment,
                style: tt.bodyMedium!.copyWith(
                  fontSize: 13,
                  height: 1.55,
                  color: cs.onSurface.withValues(alpha: 0.72),
                ),
              ),
              if (index < reviews.length - 1)
                Divider(height: 22, color: cs.outlineVariant),
            ],
          );
        }),
      ],
    );
  }
}

class _StarsRow extends StatelessWidget {
  final int count;

  const _StarsRow({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < count;
        return Icon(
          Icons.star_rounded,
          size: 13.5,
          color: filled
              ? AppColors.darkStar
              : cs.onSurface.withValues(alpha: 0.22),
        );
      }),
    );
  }
}
