import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Playful Title Font (Baloo 2)
  static TextStyle heading1({Color color = AppColors.primary}) =>
      GoogleFonts.baloo2(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.2,
      );

  static TextStyle heading2({Color color = AppColors.primary}) =>
      GoogleFonts.baloo2(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      );

  static TextStyle heading3({Color color = AppColors.primary}) =>
      GoogleFonts.baloo2(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
      );

  // Modern UI Font (Poppins)
  static TextStyle subtitle1({Color color = Colors.black87}) =>
      GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle bodyBold({Color color = Colors.black87}) =>
      GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle bodyMedium({Color color = Colors.black87}) =>
      GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // Readable Parent & Report Font (Nunito)
  static TextStyle parentReport({Color color = Colors.black87}) =>
      GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle caption({Color color = Colors.grey}) => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle buttonText({Color color = Colors.white}) =>
      GoogleFonts.baloo2(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: color,
      );
}
