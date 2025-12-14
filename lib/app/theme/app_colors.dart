import 'package:flutter/material.dart';

class AppColors {
  // ============ PRIMARY COLORS (Electric Fitness) ============
  static const Color primary = Color(0xFF00E676); // Electric Green
  static const Color primaryDark = Color(0xFF00B248);
  static const Color primaryLight = Color(0xFF66FFA6);

  // ============ SECONDARY COLORS ============
  static const Color secondary = Color(0xFF2979FF); // Electric Blue
  static const Color secondaryDark = Color(0xFF004ECB);
  static const Color secondaryLight = Color(0xFF75A7FF);

  // ============ ACCENT COLORS ============
  static const Color accent = Color(0xFFFF4081); // Hot Pink
  static const Color accentLight = Color(0xFFFF80AB);

  // ============ NEUTRAL COLORS ============
  static const Color background = Color(0xFFF5F7FA); // Very light blue-grey
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFFFFFF);
  
  // Dark Mode Neutrals
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  // ============ TEXT COLORS ============
  static const Color textPrimary = Color(0xFF1A1A1A); // Almost Black
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textTertiary = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFFCCCCCC);

  // ============ BORDER & DIVIDER ============
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE0E0E0);

  // ============ STATUS COLORS ============
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFFB9F6CA);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFD50000);
  static const Color errorLight = Color(0xFFFF8A80);
  static const Color info = Color(0xFF00B0FF);
  static const Color infoLight = Color(0xFF80D8FF);

  // ============ MUSCLE GROUP COLORS ============
  static const Map<String, Color> muscleColors = {
    'chest': Color(0xFFF44336), // Red
    'back': Color(0xFF2196F3), // Blue
    'shoulders': Color(0xFF9C27B0), // Purple
    'biceps': Color(0xFF4CAF50), // Green
    'triceps': Color(0xFFFF9800), // Orange
    'forearms': Color(0xFFFFEB3B), // Yellow
    'legs': Color(0xFFE91E63), // Pink
    'glutes': Color(0xFF00BCD4), // Cyan
    'core': Color(0xFF673AB7), // Deep Purple
    'cardio': Color(0xFFFF5252), // Red Accent
    'full_body': Color(0xFF00E676), // Primary Green
  };

  // ============ CATEGORY COLORS ============
  static const Color cardioRed = Color(0xFFFF5252);
  static const Color strengthBlue = Color(0xFF448AFF);
  static const Color yogaPurple = Color(0xFFAA00FF);
  static const Color hiitOrange = Color(0xFFFF6D00);
  static const Color flexibilityGreen = Color(0xFF00C853);

  // ============ GRADIENTS ============
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF00B248)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF448AFF), Color(0xFF2962FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF9100), Color(0xFFFF6D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFFE040FB), Color(0xFFAA00FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient workoutHeaderGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ DIFFICULTY LEVEL COLORS ============
  static const Color beginnerGreen = Color(0xFF00C853);
  static const Color intermediateOrange = Color(0xFFFFAB00);
  static const Color advancedRed = Color(0xFFD50000);

  // ============ SHADOW COLORS ============
  static const Color shadowColor = Color(0x1A000000); // Softer shadow
  static const Color shadowColorDark = Color(0x4D000000);

  // ============ HELPFUL GETTERS ============

  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner': return beginnerGreen;
      case 'intermediate': return intermediateOrange;
      case 'advanced': return advancedRed;
      default: return primary;
    }
  }

  static Color getMuscleColor(String? muscle) {
    if (muscle == null) return primary;
    return muscleColors[muscle.toLowerCase()] ?? primary;
  }

  static Color getCategoryColor(String? category) {
    if (category == null) return primary;
    final cat = category.toLowerCase();
    if (cat.contains('cardio')) return cardioRed;
    if (cat.contains('strength')) return strengthBlue;
    if (cat.contains('yoga')) return yogaPurple;
    if (cat.contains('hiit')) return hiitOrange;
    if (cat.contains('flexibility')) return flexibilityGreen;
    return primary;
  }
}
  // ============ THEMES & VARIANTS ============

  /// Dark mode versions (if needed in future)

