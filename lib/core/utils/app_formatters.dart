import 'package:intl/intl.dart';

class AppFormatters {
  static String taka(num value, {int decimals = 0}) {
    final formatter = NumberFormat.currency(
      locale: 'en',
      symbol: '\u09F3',
      decimalDigits: decimals,
    );
    return formatter.format(value);
  }

  static String shortDate(DateTime date, {String locale = 'en'}) =>
      DateFormat('dd/MM/yyyy', locale).format(date);

  static String longDate(DateTime date, {String locale = 'en'}) =>
      DateFormat('dd MMM yyyy', locale).format(date);

  static String compactDateTime(DateTime date, {String locale = 'en'}) =>
      DateFormat('dd MMM yyyy \u2022 hh:mm a', locale).format(date);

  static String compactTime(DateTime date, {String locale = 'en'}) =>
      DateFormat('hh:mm a', locale).format(date);

  static String percent(num value) => '${value.round()}%';

  static String formatPhone(String phone) {
    if (phone.startsWith('+880')) return phone;
    if (phone.startsWith('0')) return '+88$phone';
    return '+880$phone';
  }
}
