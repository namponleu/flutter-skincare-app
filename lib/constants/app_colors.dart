import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color brand = Color(0xFFFF1694); // --c-brand: #ff1694
  static const Color brandLight = Color(
    0xACFF1692,
  ); // --c-brand-light: #ff1692ac
  static const Color brandDark = Color(0xFFE11594); // --c-brand-dark: #e11594

  // Text Colors
  static const Color textGray = Color(0xFF403247); // --text-gray: #403247

  // Base Colors
  static const Color white = Color(0xFFFFFFFF); // --c-white: #fff

  // Helper colors (for consistency)
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.white;

  // Legacy color mappings (for gradual migration)
  @Deprecated('Use AppColors.brand instead')
  static const Color primaryGreen = Color(0xFF2E7D32);

  @Deprecated('Use AppColors.brandDark instead')
  static const Color primaryBrown = Color(0xFF482F2B);
}
