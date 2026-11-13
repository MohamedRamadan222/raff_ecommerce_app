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

  @override
  String get splashTagline => 'كل ما يحتاجه بيتك، على رفّ واحد';

  @override
  String get splashTapToContinue => 'اضغط للمتابعة';

  @override
  String get onbSkip => 'تخطَّ';

  @override
  String get onbNext => 'التالي';

  @override
  String get onbStart => 'ابدأ الآن';

  @override
  String get onbGuest => 'تصفّح كضيف';

  @override
  String get onb1Title => 'قطع تصنع البيت';

  @override
  String get onb1Body =>
      'فخار وخشب وكتّان من صنّاع محليين، مختارة بعناية لتعيش معك سنوات.';

  @override
  String get onb2Title => 'توصيل إلى بابك';

  @override
  String get onb2Body =>
      'نوصل طلبك خلال ٢-٤ أيام عمل، ومجانًا للطلبات فوق ٢٠٠ ر.س.';

  @override
  String get onb3Title => 'إرجاع بلا تعقيد';

  @override
  String get onb3Body =>
      'لم تناسبك القطعة؟ أرجعها خلال ١٤ يومًا واسترد المبلغ كاملًا.';
}
