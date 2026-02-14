import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFD32F2F); // Emergency Red
  static const Color background = Color(0xFFF8F9FA);
  static const Color dark = Color(0xFF212121);
  static const Color lightGrey = Color(0xFFE0E0E0);
}

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.dark,
  );

  static const subHeading = TextStyle(fontSize: 14, color: Colors.grey);

  static TextStyle? get body => null;
}
