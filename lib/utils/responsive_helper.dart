import 'package:flutter/material.dart';
import '../constants.dart';

class ResponsiveHelper {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return getScreenWidth(context) >= 600 && getScreenWidth(context) < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return getScreenWidth(context) >= 1200;
  }

  // Responsive padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(AppSizes.spacingMedium);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(AppSizes.spacingLarge);
    } else {
      return const EdgeInsets.all(AppSizes.spacingXLarge);
    }
  }

  // Responsive card width
  static double getCardWidth(BuildContext context) {
    if (isMobile(context)) {
      return getScreenWidth(context) * 0.88;
    } else if (isTablet(context)) {
      return getScreenWidth(context) * 0.4;
    } else {
      return getScreenWidth(context) * 0.3;
    }
  }

  // Responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  // Responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  // Responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.2;
    } else {
      return baseSize * 1.4;
    }
  }
} 