import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raff_app/core/theme/app_theme.dart';
import 'package:raff_app/core/widgets/empty_view.dart';
import 'package:raff_app/core/widgets/error_view.dart';
import 'package:raff_app/features/cart/presentation/widgets/cart_shipping_banner.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_option_card.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_stepper.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/presentation/widgets/order_status_badge.dart';

import '../helpers/pump_app.dart';

void main() {
  group('OrderStatusBadge', () {
    testWidgets('shows the english text for each status', (tester) async {
      const expected = {
        OrderStatus.placed: 'Order placed',
        OrderStatus.delivered: 'Delivered',
        OrderStatus.cancelled: 'Cancelled',
      };

      for (final entry in expected.entries) {
        await tester.pumpApp(OrderStatusBadge(status: entry.key));
        expect(find.text(entry.value), findsOneWidget);
      }
    });

    testWidgets('shows arabic text when the locale is arabic', (tester) async {
      await tester.pumpApp(
        const OrderStatusBadge(status: OrderStatus.cancelled),
        locale: const Locale('ar'),
      );

      expect(find.text('Cancelled'), findsNothing);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('works in dark theme', (tester) async {
      await tester.pumpApp(
        const OrderStatusBadge(status: OrderStatus.delivered),
        theme: AppTheme.darkTheme,
      );

      expect(find.text('Delivered'), findsOneWidget);
    });
  });

  group('CheckoutStepper', () {
    testWidgets('shows all the labels', (tester) async {
      await tester.pumpApp(
        const CheckoutStepper(currentStep: 1, labels: ['A', 'B', 'C', 'D']),
      );

      for (final label in ['A', 'B', 'C', 'D']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('finished steps show a check and the rest show numbers', (
      tester,
    ) async {
      await tester.pumpApp(
        const CheckoutStepper(currentStep: 2, labels: ['A', 'B', 'C', 'D']),
      );

      expect(find.byIcon(Icons.check), findsNWidgets(2));
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });
  });

  group('CheckoutOptionCard', () {
    testWidgets('shows the texts and calls onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        CheckoutOptionCard(
          icon: Icons.local_shipping_outlined,
          title: 'Express',
          subtitle: 'Tomorrow',
          aside: '35',
          selected: true,
          onTap: () => taps++,
        ),
      );

      expect(find.text('Express'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('35'), findsOneWidget);

      await tester.tap(find.text('Express'));
      expect(taps, 1);
    });
  });

  group('CartShippingBanner', () {
    testWidgets('shows the remaining amount before free shipping', (
      tester,
    ) async {
      await tester.pumpApp(
        const CartShippingBanner(
          hasFreeShipping: false,
          remainingAmount: 60,
          progress: 0.7,
        ),
      );

      expect(find.textContaining('60'), findsOneWidget);
    });

    testWidgets('shows the unlocked message at free shipping', (tester) async {
      await tester.pumpApp(
        const CartShippingBanner(
          hasFreeShipping: true,
          remainingAmount: 0,
          progress: 1,
        ),
      );

      expect(find.textContaining('0'), findsNothing);
    });
  });

  group('EmptyView and ErrorView', () {
    testWidgets('EmptyView shows its action button only when given an action', (
      tester,
    ) async {
      var pressed = false;
      await tester.pumpApp(
        EmptyView(
          title: 'Nothing here',
          subtitle: 'Add something',
          buttonText: 'Go',
          onAction: () => pressed = true,
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      await tester.tap(find.text('Go'));
      expect(pressed, isTrue);

      await tester.pumpApp(const EmptyView(title: 'Nothing here'));
      expect(find.text('Go'), findsNothing);
    });

    testWidgets('ErrorView shows the message and the retry button', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpApp(
        ErrorView(message: 'Failed', onRetry: () => retried = true),
      );

      expect(find.text('Failed'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('ErrorView hides the retry button without onRetry', (
      tester,
    ) async {
      await tester.pumpApp(const ErrorView(message: 'Failed'));

      expect(find.text('Retry'), findsNothing);
    });
  });
}
