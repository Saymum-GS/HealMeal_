import 'package:flutter/material.dart';

class AppLayout {
  static const double compactPhone = 360;
  static const double phone = 480;
  static const double tablet = 768;
  static const double desktop = 1100;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool isCompactPhone(BuildContext context) =>
      width(context) < compactPhone;

  static bool isPhone(BuildContext context) => width(context) < phone;

  static int columnsForWidth(
    double width, {
    int compact = 2,
    int regular = 3,
    int tabletCount = 4,
    int desktopCount = 5,
  }) {
    if (width >= desktop) return desktopCount;
    if (width >= tablet) return tabletCount;
    if (width >= phone) return regular;
    return compact;
  }

  static SliverGridDelegateWithMaxCrossAxisExtent cardGrid({
    double maxCrossAxisExtent = 220,
    double mainAxisExtent = 304,
    double mainAxisSpacing = 12,
    double crossAxisSpacing = 12,
  }) {
    return SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: maxCrossAxisExtent,
      mainAxisExtent: mainAxisExtent,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
    );
  }
}
