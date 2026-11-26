import 'package:flutter/material.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class CheckoutStepper extends StatelessWidget {
  final int currentStep;
  final List<String> labels;

  const CheckoutStepper({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.ink;
    final onInk = isDark ? AppColors.darkOnInk : AppColors.onInk;
    final paper = isDark ? AppColors.darkPaper : AppColors.paper;
    final lineStrong = isDark ? AppColors.darkLineStrong : AppColors.lineStrong;
    final muted = isDark ? AppColors.darkMuted : AppColors.muted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) => Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    if (i > 0)
                      PositionedDirectional(
                        top: 13,
                        start: -box.maxWidth / 2,
                        width: box.maxWidth,
                        height: 2,
                        child: ColoredBox(
                          color: i <= currentStep ? ink : lineStrong,
                        ),
                      ),
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < currentStep ? ink : paper,
                            border: Border.all(
                              color: i <= currentStep ? ink : lineStrong,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: i < currentStep
                                ? Icon(Icons.check, size: 14, color: onInk)
                                : Text(
                                    '${i + 1}',
                                    style: tt.labelSmall!.copyWith(
                                      fontSize: 12,
                                      height: 1,
                                      fontWeight: FontWeight.w600,
                                      color: i == currentStep ? ink : muted,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          labels[i],
                          textAlign: TextAlign.center,
                          style: tt.labelSmall!.copyWith(
                            fontSize: 12,
                            color: i == currentStep ? cs.onSurface : muted,
                            fontWeight: i == currentStep
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
