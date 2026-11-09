// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'رف';

  @override
  String get errorNetwork => 'تأكد من اتصالك بالإنترنت';

  @override
  String get errorTimeout => 'انتهت مهلة الاتصال';

  @override
  String get errorServer => 'خطأ من السيرفر';

  @override
  String get errorUnknown => 'حدث خطأ غير متوقع';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCategories => 'الأقسام';

  @override
  String get navCart => 'السلة';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navAccount => 'حسابي';
}
