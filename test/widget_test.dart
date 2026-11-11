import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:raff_app/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:raff_app/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  testWidgets('completing onboarding navigates to login', (tester) async {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => BlocProvider(
            create: (_) => OnboardingCubit(_FakeOnboardingRepository()),
            child: const OnboardingScreen(),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('Login screen')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('تخطي'), findsOneWidget);
    await tester.tap(find.text('تخطي'));
    await tester.pumpAndSettle();

    expect(find.text('Login screen'), findsOneWidget);
    expect(router.state.uri.path, '/login');
  });
}

class _FakeOnboardingRepository implements OnboardingRepository {
  bool seen = false;

  @override
  bool isOnboardingSeen() => seen;

  @override
  Future<void> setOnboardingSeen() async {
    seen = true;
  }
}
