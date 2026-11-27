import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/widgets/page_indicator.dart';

class HomeBannerCarousel extends StatefulWidget {
  final VoidCallback onShopNowTap;

  const HomeBannerCarousel({super.key, required this.onShopNowTap});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  final _controller = PageController(viewportFraction: 0.90);
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final banners = [
      (tag: l10n.banner1Tag, title: l10n.banner1Title),
      (tag: l10n.banner2Tag, title: l10n.banner2Title),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 196,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final item = banners[index];
              // البانر الثاني فاتح (hero-2) في الديزاين
              final isLight = index == 1;
              final heroColor = isLight
                  ? AppColors.heroSecondary
                  : AppColors.hero;
              final textColor = isLight ? AppColors.ink : AppColors.heroInk;
              return Padding(
                padding: EdgeInsetsDirectional.only(
                  start: index == 0 ? 20 : 12,
                  end: index == banners.length - 1 ? 20 : 0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: heroColor,
                    borderRadius: BorderRadius.circular(20),
                    gradient: RadialGradient(
                      center: const Alignment(-0.35, -0.2),
                      radius: 0.95,
                      colors: [
                        isLight
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppColors.darkLineStrong.withValues(alpha: 0.55),
                        heroColor,
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
                                fontSize: 12,
                                color: textColor.withValues(alpha: 0.75),
                              ),
                            ),
                            Text(
                              item.title,
                              style: tt.headlineMedium!.copyWith(
                                fontSize: 20,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: widget.onShopNowTap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLight
                                      ? AppColors.ink
                                      : AppColors.heroInk,
                                  foregroundColor: isLight
                                      ? AppColors.heroInk
                                      : AppColors.hero,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  l10n.shopNow,
                                  style: tt.labelMedium!.copyWith(
                                    color: isLight
                                        ? AppColors.heroInk
                                        : AppColors.hero,
                                    fontWeight: FontWeight.w500,
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
        ),
        const Gap(12),
        Center(
          child: PageIndicator(
            itemCount: banners.length,
            currentIndex: _currentIndex,
          ),
        ),
      ],
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
