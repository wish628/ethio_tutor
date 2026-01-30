import 'package:flutter/material.dart';

/// Ethiopian-inspired color palette
class AppColors {
  // Ethiopian flag colors
  static const Color ethiopianGreen = Color(0xFF009639);
  static const Color ethiopianYellow = Color(0xFFFCDC04);
  static const Color ethiopianRed = Color(0xFFDA031E);
  
  // Primary colors
  static const Color primary = ethiopianGreen;
  static const Color primaryLight = Color(0xFF00C14C);
  static const Color primaryDark = Color(0xFF006B28);
  
  // Accent colors
  static const Color accent = Color(0xFFFFD700); // Gold for achievements
  static const Color accentLight = Color(0xFFFFE555);
  
  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = ethiopianYellow;
  static const Color error = ethiopianRed;
  static const Color info = Color(0xFF2196F3);
  
  // Background gradients
  static const List<Color> backgroundGradientLight = [
    Color(0xFFFAFAFA),
    Color(0xFFF5F5F5),
  ];
  
  static const List<Color> backgroundGradientDark = [
    Color(0xFF1A1A1A),
    Color(0xFF2D2D2D),
  ];
  
  // Card colors
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF2C2C2C);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Colors.white;
  
  // Progress colors (gradient)
  static const List<Color> progressGradient = [
    ethiopianGreen,
    Color(0xFF00C14C),
    ethiopianYellow,
  ];
  
  // Achievement badge colors
  static const Color achievementGold = Color(0xFFFFD700);
  static const Color achievementSilver = Color(0xFFC0C0C0);
  static const Color achievementBronze = Color(0xFFCD7F32);
  static const Color achievementLocked = Color(0xFF9E9E9E);
}
