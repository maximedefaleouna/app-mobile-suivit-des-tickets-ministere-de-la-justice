import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF006743);
  static const Color primaryDarkGreen = Color(0xFF004d33);
  static const Color primaryLightGreen = Color(0xFF008a5c);

  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF1976D2);
  static const Color secondaryOrange = Color(0xFFFFA726);
  static const Color secondaryRed = Color(0xFFE53935);

  // Status Colors
  static const Color statusOuvert = Color(0xFF4CAF50);
  static const Color statusEnCours = Color(0xFFFFA726);
  static const Color statusResolu = Color(0xFF2196F3);
  static const Color statusFerme = Color(0xFF9E9E9E);

  // Priority Colors
  static const Color priorityBasse = Color(0xFF4CAF50);
  static const Color priorityMoyenne = Color(0xFFFFA726);
  static const Color priorityHaute = Color(0xFFFF5722);
  static const Color priorityUrgente = Color(0xFFD32F2F);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, primaryDarkGreen],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
  );
}
