import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/theme/app_theme.dart';

/// بيلف الـ widget في MaterialApp فيه الثيم والترجمة زي التطبيق الحقيقي.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget child, {
    Locale locale = const Locale('en'),
    ThemeData? theme,
  }) {
    return pumpWidget(
      MaterialApp(
        locale: locale,
        theme: theme ?? AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }
}
