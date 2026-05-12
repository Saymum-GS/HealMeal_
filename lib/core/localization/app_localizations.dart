import 'package:flutter/material.dart';

import '../constants/app_strings_bn.dart';
import '../constants/app_strings_en.dart';

class L {
  static const AppStringsEn _en = AppStringsEn();
  static const AppStringsBn _bn = AppStringsBn();

  static String str(
    BuildContext context,
    String Function(AppStringsEn) enFn,
    String Function(AppStringsBn) bnFn,
  ) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'bn') {
      return bnFn(_bn);
    }
    return enFn(_en);
  }
}

extension LocalizationExtension on BuildContext {
  bool get isBangla => Localizations.localeOf(this).languageCode == 'bn';

  String tr(String enText, String bnText) => isBangla ? bnText : enText;

  AppStrings get strings =>
      isBangla ? const AppStringsBn() : const AppStringsEn();
}

