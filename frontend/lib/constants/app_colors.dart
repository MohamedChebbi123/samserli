import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7FD8);
  static const Color primaryLight = Color(0xFF5BA3E8);
  static const Color primaryDark = Color(0xFF1E5FB8);
  
  static const Color secondary = Color(0xFF00A699);
  
  static const Color background = Color(0xFFF7F7F7);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF717171);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textDark = Color(0xFF1A1A1A);
  
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);
  
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textLightDark = Color(0xFF757575);
  static const Color textDarkDark = Color(0xFFE0E0E0);
  
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  


  static Color shadow = Colors.black.withOpacity(0.05);
  static Color shadowMedium = Colors.black.withOpacity(0.1);
  static Color shadowDark = Colors.black.withOpacity(0.15);
  
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);
  
  static Color textPrimaryWithOpacity(double opacity) =>
      textPrimary.withOpacity(opacity);
  
  static Color surfaceWithOpacity(double opacity) =>
      surface.withOpacity(opacity);
  

  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
