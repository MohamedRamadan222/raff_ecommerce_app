import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/page_indicator.dart';
import '../../../../core/widgets/shelf_illustration.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingCubit>(),
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is NavigateToLogin) context.go(AppRoutes.login);
          if (state is NavigateToHome) context.go(AppRoutes.home);
        },
        child: const _OnboardingView(),
      ),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  static const _count = 3;
  final _ctrl = PageController();
  int _i = 0;

  bool get _last => _i == _count - 1;

  void _go(int page) => _ctrl.animateToPage(
    page,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<OnboardingCubit>();
    final isDark = theme.brightness == Brightness.dark;

    final titles = [l10n.onb1Title, l10n.onb2Title, l10n.onb3Title];
    final bodies = [l10n.onb1Body, l10n.onb2Body, l10n.onb3Body];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_last)
                    TextButton(
                      onPressed: () => _go(_count - 1),
                      style: TextButton.styleFrom(
                        foregroundColor: cs.onSurface.withOpacity(0.6),
                      ),
                      child: Text(
                        l10n.onbSkip,
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  else
                    const SizedBox(width: 60),

                  Text(
                    'رَفّ',
                    style: tt.headlineLarge!.copyWith(
                      fontFamily: 'ReemKufi',
                      fontSize: 32,
                      height: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: _count,
                  onPageChanged: (i) => setState(() => _i = i),
                  itemBuilder: (_, __) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkLineStrong
                          : AppColors.stage,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    alignment: Alignment.center,
                    child: const ShelfIllustration(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: PageIndicator(itemCount: _count, currentIndex: _i),
                    ),
                    const SizedBox(height: 20),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: SizedBox(
                        key: ValueKey(_i),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titles[_i],
                              style: tt.headlineMedium!.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              bodies[_i],
                              style: tt.bodyMedium!.copyWith(
                                fontSize: 16,
                                color: cs.onSurface.withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    AppButton(
                      label: _last ? l10n.onbStart : l10n.onbNext,
                      onPressed: _last ? cubit.goToLogin : () => _go(_i + 1),
                    ),

                    if (_last) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: cubit.continueAsGuest,
                        style: TextButton.styleFrom(
                          foregroundColor: cs.onSurface,
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: Text(
                          l10n.onbGuest,
                          style: tt.bodyMedium!.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 64),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
