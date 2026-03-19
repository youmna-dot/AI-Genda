import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Purple 
  static const Color primary        = Color(0xFF7C5CBF);
  static const Color primaryDark    = Color(0xFF5B3A9E);
  static const Color primaryLight   = Color(0xFF8B6FD4);
  static const Color primaryDeep    = Color(0xFF4A2D8A);
  static const Color primaryGlow    = Color(0xFF6C3FC8);
  static const Color primarySoft    = Color(0xFFAB8EE0);
  static const Color primaryPale    = Color(0xFFEDE6FF);
  static const Color primaryLoading = Color(0xFFAA99D9);
  static const Color primaryLoading2= Color(0xFF8870B8);

  //  Teal Accent
  static const Color teal           = Color(0xFF3ECFCF);

  // Text Colors
  static const Color textDark       = Color(0xFF1E0F5C);
  static const Color textMedium     = Color(0xFF5A5480);
  static const Color textLight      = Color(0xFF8A84A3);
  static const Color textHint       = Color(0xFFBBB8CC);

  // Background Colors
  static const Color bgMain         = Color(0xFFF0EEF8);
  static const Color bgLight        = Color(0xFFF5F3FF);
  static const Color bgCard         = Color(0xFFF7F5FF);
  static const Color bgWhite        = Colors.white;
  static const Color bgDisabled     = Color(0xFFEFEEF5);

  //  Border Colors 
  static const Color border         = Color(0xFFE8E4F5);
  static const Color borderFocus    = Color(0xFF7C5CBF);

  // Status Colors 
  static const Color error          = Color(0xFFE74C3C);
  static const Color errorBg        = Color(0xFFFFEEEE);
  static const Color errorBorder    = Color(0xFFFFCDD2);
  static const Color success        = Color(0xFF2E7D32);
  static const Color successBg      = Color(0xFFE8FFF0);
  static const Color successBorder  = Color(0xFFA5D6B0);
  static const Color green          = Color(0xFF4CAF50);
  static const Color red            = Color(0xFFE53935);
  static const Color redBg          = Color(0xFFFFEBEE);
  static const Color redBorder      = Color(0xFFFFCDD2);

  //  Gradient Shortcuts 
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
  );

  static const LinearGradient primaryGradientLoading = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFAA99D9), Color(0xFF8870B8)],
  );
}