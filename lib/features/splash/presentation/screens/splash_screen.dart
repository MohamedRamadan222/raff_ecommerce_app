import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/shelf_illustration.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final w = MediaQuery.sizeOf(context).width;

    return BlocProvider(
      create: (_) {
        final cubit = sl<SplashCubit>();
        Future.delayed(const Duration(milliseconds: 1500), () {
          cubit.determineDestination();
        });
        return cubit;
      },
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is NavigateToOnboarding) context.go('/onboarding');
          if (state is NavigateToLogin) context.go('/login');
          if (state is NavigateToHome) context.go('/home');
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'رَفّ',
                            style: tt.headlineLarge!.copyWith(
                              fontFamily: 'ReemKufi',
                              fontSize: (w * 0.26).clamp(72.0, 120.0),
                              height: 1.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'R a f f',
                            style: tt.bodySmall!.copyWith(
                              letterSpacing: 10,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: w * 0.04),
                          Text(
                            l10n.splashTagline,
                            style: tt.bodyMedium!.copyWith(
                              fontSize: (w * 0.038).clamp(14.0, 18.0),
                            ),
                          ),
                          SizedBox(height: w * 0.1),
                          const ShelfIllustration(),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
