import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a broadcast stream (such as a Cubit's) to GoRouter's
/// [ChangeNotifier]-based refresh mechanism.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
