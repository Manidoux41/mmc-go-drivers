import 'package:flutter/material.dart';

class AppColors {
  // Primary: Bleu MMC (extracted from pin/truck)
  static const Color primaryBlue = Color(0xFF0D47A1);
  
  // Secondary: Vert MMC (extracted from map roads)
  static const Color secondaryGreen = Color(0xFF2E7D32);
  
  // Tertiary: Jaune MMC (extracted from taxi)
  static const Color tertiaryYellow = Color(0xFFFFD600);
  
  // Accent/Error: Orange MMC (extracted from signal icon)
  static const Color accentOrange = Color(0xFFFF5722);

  // Theme Helpers
  static ColorScheme get colorScheme => ColorScheme.fromSeed(
    seedColor: primaryBlue,
    primary: primaryBlue,
    secondary: secondaryGreen,
    tertiary: tertiaryYellow,
    error: accentOrange,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.black,
  );
}
