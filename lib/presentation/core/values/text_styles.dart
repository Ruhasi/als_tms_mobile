import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles();

  TextStyle get bold28 => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  TextStyle get displaySmall => GoogleFonts.playfairDisplay(
    fontSize: 36.sp,
    height: 1.1,
    fontWeight: FontWeight.w800,
    color: const Color(0xFF12151B),
  );

  TextStyle get headlineSmall => GoogleFonts.playfairDisplay(
    fontSize: 24.sp,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: const Color(0xFF12151B),
  );

  TextStyle get titleLarge => GoogleFonts.playfairDisplay(
    fontSize: 22.sp,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: const Color(0xFF12151B),
  );

  TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 16.sp,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: const Color(0xFF12151B),
  );

  TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14.sp,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF12151B),
  );

  TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12.sp,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF7B7B80),
  );

  TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 9.sp,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: const Color(0xFF7B7B80),
  );

  TextStyle get interBold12 => GoogleFonts.inter(
    fontSize: 12.sp,
    height: 1.2,
    fontWeight: FontWeight.w900,
    color: const Color(0xFF12151B),
  );
}
