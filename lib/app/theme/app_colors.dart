import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00D09C);
  static const Color primaryDark = Color(0xFF00B584);
  static const Color primaryLight = Color(0xFF34E5B8);

  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFF57C00);

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);

  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);

  // Updated gradient colors to match the image
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D09C), Color(0xFF34E5B8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Onboarding gradient
  static const LinearGradient onboardingGradient = LinearGradient(
    colors: [Color(0xFF00D09C), Color(0xFF34E5B8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
