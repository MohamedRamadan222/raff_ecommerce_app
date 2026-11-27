import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:raff_app/core/di/injection.dart';
import 'package:raff_app/core/session/session_cleaner.dart';
import 'package:raff_app/core/session/session_cubit.dart';
import 'package:raff_app/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('raff_di_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => tempDir.path,
        );
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await sl.reset();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('the DI graph resolves session, checkout and logout services', () async {
    await setUpGetIt();

    final session = sl<SessionCubit>();
    await session.restore();

    expect(sl<SessionCleaner>(), isA<SessionCleaner>());
    expect(sl<CheckoutCubit>(), isA<CheckoutCubit>());
    expect(sl<SessionCubit>(), same(session));
  });
}
