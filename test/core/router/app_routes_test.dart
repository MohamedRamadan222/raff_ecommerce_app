import 'package:flutter_test/flutter_test.dart';
import 'package:raff_app/core/router/app_routes.dart';

void main() {
  group('order routes', () {
    test('confirmation route includes and encodes the order id', () {
      expect(
        AppRoutes.orderConfirmationFor('RF-ABC 123'),
        '/order-confirmation/RF-ABC%20123',
      );
    });

    test('track route includes and encodes the order id', () {
      expect(AppRoutes.trackOrderFor('RF/ABC'), '/orders/RF%2FABC/track');
    });

    test('route templates keep their path parameters', () {
      expect(AppRoutes.orderConfirmation, '/order-confirmation/:id');
      expect(AppRoutes.trackOrder, '/orders/:id/track');
    });
  });
}
