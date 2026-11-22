import 'package:flutter/material.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class HomeBannerCarousel extends StatelessWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onShopNowTap;

  const HomeBannerCarousel({
    super.key,
    required this.controller,
    required this.onPageChanged,
    required this.onShopNowTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final banners = [
      (tag: l10n.banner1Tag, title: l10n.banner1Title),
      (tag: l10n.banner2Tag, title: l10n.banner2Title),
    ];

    return SizedBox(
      height: 176,
      child: PageView.builder(
        controller: controller,
        padEnds: false,
        onPageChanged: onPageChanged,
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final item = banners[index];
          return Padding(
            padding: EdgeInsetsDirectional.only(
              start: index == 0 ? 20 : 12,
              end: index == banners.length - 1 ? 20 : 0,
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.hero,
                borderRadius: BorderRadius.circular(18),
                gradient: RadialGradient(
                  center: const Alignment(-0.35, -0.2),
                  radius: 0.95,
                  colors: [
                    AppColors.darkLineStrong.withValues(alpha: 0.55),
                    AppColors.hero,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.tag,
                          style: tt.bodySmall!.copyWith(
                            color: AppColors.heroSecondary.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                        Text(
                          item.title,
                          style: tt.headlineMedium!.copyWith(
                            fontSize: 19,
                            height: 1.25,
                            fontWeight: FontWeight.bold,
                            color: AppColors.heroInk,
                          ),
                        ),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: onShopNowTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.heroInk,
                              foregroundColor: AppColors.hero,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              l10n.shopNow,
                              style: tt.labelMedium!.copyWith(
                                color: AppColors.hero,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    flex: 6,
                    child: Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: _BannerShelfIllustration(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BannerShelfIllustration extends StatelessWidget {
  const _BannerShelfIllustration();

  Widget _piece(double w, double h, Color color, {double radius = 2}) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      height: 62,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _piece(155, 7, AppColors.darkLineStrong, radius: 4),
          Positioned(
            bottom: 7,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _piece(24, 6, AppColors.heroSecondary),
                    const SizedBox(height: 1),
                    _piece(26, 7, AppColors.muted),
                    const SizedBox(height: 1),
                    _piece(25, 7, AppColors.darkInkSecondary),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.darkStar,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                          bottom: Radius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 18,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.heroInk,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(child: _piece(10, 8, AppColors.muted)),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.heroInk,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(6),
                          bottom: Radius.circular(2),
                        ),
                      ),
                    ),
                    Container(width: 3, height: 14, color: AppColors.muted),
                    _piece(14, 3, AppColors.muted),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
