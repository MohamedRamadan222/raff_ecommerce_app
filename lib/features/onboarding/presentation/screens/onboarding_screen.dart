import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/page_indicator.dart';
import '../../domain/entities/onboarding_item.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  // استبدل النصوص ومسارات الصور بمحتوى تطبيقك
  final List<OnboardingItem> _items = const [
    OnboardingItem(
      title: 'اكتشف منتجاتك بسهولة',
      description: 'تصفح آلاف المنتجات المصنفة بعناية وبأفضل الأسعار.',
      assetPath: 'assets/images/onboarding_1.png',
    ),
    OnboardingItem(
      title: 'توصيل سريع وآمن',
      description: 'تتبع طلبك لحظة بلحظة حتى يصل إلى باب منزلك.',
      assetPath: 'assets/images/onboarding_2.png',
    ),
    OnboardingItem(
      title: 'طرق دفع مرنة',
      description: 'اختر وسيلة الدفع المناسبة لك بكل أمان وسهولة.',
      assetPath: 'assets/images/onboarding_3.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed(OnboardingCubit cubit, int currentIndex) {
    if (currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      cubit.completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (prev, curr) => !prev.isCompleted && curr.isCompleted,
      listener: (context, state) {
        // التوجيه إلى شاشة تسجيل الدخول بعد الحفظ المحلي
        context.go(AppRoutes.login);
      },
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();
        final isLastPage = state.currentIndex == _items.length - 1;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // زر التخطي
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: isLastPage ? null : cubit.completeOnboarding,
                      child: Text(
                        isLastPage ? '' : 'تخطي',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),

                  // محتوى الصفحات
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _items.length,
                      onPageChanged: cubit.onPageChanged,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: item.assetPath.isNotEmpty
                                  ? Image.asset(
                                      item.assetPath,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => Icon(
                                        _iconForPage(index),
                                        size: 120,
                                        color: theme.colorScheme.primary,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                          ],
                        );
                      },
                    ),
                  ),

                  // المؤشر الجاهز من Phase 2
                  PageIndicator(
                    itemCount: _items.length,
                    currentIndex: state.currentIndex,
                  ),
                  const SizedBox(height: 24),

                  // زر التالي / ابدأ الآن
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () =>
                          _onNextPressed(cubit, state.currentIndex),
                      child: Text(isLastPage ? 'ابدأ الآن' : 'التالي'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _iconForPage(int index) {
    return switch (index) {
      0 => Icons.shopping_bag_outlined,
      1 => Icons.local_shipping_outlined,
      _ => Icons.payment_outlined,
    };
  }
}
