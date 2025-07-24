import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double iPhoneWidth = 430.0; // iPhone 16 Pro Max width
  static const double iPhoneHeight = 932.0; // iPhone 16 Pro Max height

  static double getScaledWidth(BuildContext context, double pixels) {
    return MediaQuery.of(context).size.width * (pixels / iPhoneWidth);
  }

  static double getScaledHeight(BuildContext context, double pixels) {
    return MediaQuery.of(context).size.height * (pixels / iPhoneHeight);
  }

  static double getFontSize(BuildContext context, double size) {
    double scaleFactor = MediaQuery.of(context).size.width / iPhoneWidth;
    return size * scaleFactor;
  }

  static EdgeInsets getScaledPadding(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) {
    double widthScale = MediaQuery.of(context).size.width / iPhoneWidth;
    double heightScale = MediaQuery.of(context).size.height / iPhoneHeight;

    return EdgeInsets.fromLTRB(
      (left > 0 ? left : horizontal) * widthScale,
      (top > 0 ? top : vertical) * heightScale,
      (right > 0 ? right : horizontal) * widthScale,
      (bottom > 0 ? bottom : vertical) * heightScale,
    );
  }

  static double getScaledIconSize(BuildContext context, double size) {
    double scaleFactor = MediaQuery.of(context).size.width / iPhoneWidth;
    return size * scaleFactor;
  }

  static BorderRadius getScaledBorderRadius(
    BuildContext context,
    double radius,
  ) {
    double scaleFactor = MediaQuery.of(context).size.width / iPhoneWidth;
    return BorderRadius.circular(radius * scaleFactor);
  }
}
