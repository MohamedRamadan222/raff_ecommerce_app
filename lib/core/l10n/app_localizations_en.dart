// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Raff';

  @override
  String get errorNetwork => 'Check your internet connection';

  @override
  String get errorTimeout => 'Connection timed out';

  @override
  String get errorServer => 'Server error';

  @override
  String get errorUnknown => 'An unexpected error occurred';

  @override
  String get navHome => 'Home';

  @override
  String get navCategories => 'Categories';

  @override
  String get navCart => 'Cart';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navAccount => 'Account';
}
