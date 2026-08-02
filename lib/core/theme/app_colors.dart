import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Secondary Palette
  static const Color primary = Color(0xFF5B5FEF); // Deep Magical Blue/Purple
  static const Color primaryLight = Color(0xFF7A7EFF);
  static const Color secondary = Color(0xFF00C2FF); // Cyan Sky
  static const Color accent = Color(0xFFFFB703); // Gold Stars / Coins
  static const Color success = Color(0xFF34D399); // XP Emerald Green
  static const Color danger = Color(0xFFEF4444); // Radiant Coral
  static const Color purpleMagic = Color(0xFF9D4EDD);

  // Background & Surface Tokens
  static const Color bgLight = Color(0xFFF7F9FC);
  static const Color cardLight = Colors.white;
  static const Color bgDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);

  // Glassmorphism Overlay Colors
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x66FFFFFF);
  static const Color glassDark = Color(0x4D0F172A);
  static const Color glassBorderDark = Color(0x3364748B);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF5B5FEF), Color(0xFF00C2FF), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coinGradient = LinearGradient(
    colors: [Color(0xFFFFB703), Color(0xFFFF8800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient xpGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF059669)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9D4EDD), Color(0xFF5B5FEF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x3300C2FF), Color(0x335B5FEF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00C2FF), Color(0xFF0085FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
