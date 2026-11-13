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

  @override
  String get splashTagline => 'Everything your home needs, on one shelf';

  @override
  String get splashTapToContinue => 'Tap to continue';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbNext => 'Next';

  @override
  String get onbStart => 'Get started';

  @override
  String get onbGuest => 'Browse as guest';

  @override
  String get onb1Title => 'Pieces that make a home';

  @override
  String get onb1Body =>
      'Ceramics, wood and linen from local makers, chosen to last you for years.';

  @override
  String get onb2Title => 'Delivered to your door';

  @override
  String get onb2Body =>
      'We deliver in 2-4 business days, free on orders over SAR 200.';

  @override
  String get onb3Title => 'Hassle-free returns';

  @override
  String get onb3Body =>
      'Piece not right? Return it within 14 days for a full refund.';
}
