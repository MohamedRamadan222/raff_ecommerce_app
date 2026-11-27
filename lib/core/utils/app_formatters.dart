import 'package:intl/intl.dart';

/// Shared [DateFormat] and [NumberFormat] instances cached per locale.
class AppFormatters {
  AppFormatters._();

  static final Map<String, DateFormat> _dateMediumCache = {};
  static final Map<String, DateFormat> _timeShortCache = {};
  static final Map<String, NumberFormat> _numberCache = {};

  static DateFormat dateMedium(String locale) =>
      _dateMediumCache.putIfAbsent(locale, () => DateFormat.yMMMd(locale));

  static DateFormat timeShort(String locale) =>
      _timeShortCache.putIfAbsent(locale, () => DateFormat.jm(locale));

  static NumberFormat number(String locale) =>
      _numberCache.putIfAbsent(locale, () => NumberFormat('#,##0', locale));
}
