import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// تسلسل نصوص موحّد باستخدام خط Tajawal الحديث بكل أوزانه (بدل الوزن الواحد
/// المرفق سابقًا اللي كان يعتمد على "Bold" اصطناعي من الريندرر).
class AppTypography {
  static TextTheme textTheme(Color baseColor) =>
      GoogleFonts.tajawalTextTheme().apply(
        bodyColor: baseColor,
        displayColor: baseColor,
      );

  static TextStyle display(Color color) => GoogleFonts.tajawal(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: color,
    height: 1.25,
  );

  static TextStyle headline(Color color) => GoogleFonts.tajawal(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.3,
  );

  static TextStyle title(Color color) => GoogleFonts.tajawal(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle body(Color color) => GoogleFonts.tajawal(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.55,
  );

  static TextStyle label(Color color) => GoogleFonts.tajawal(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle caption(Color color) => GoogleFonts.tajawal(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: color,
  );
}
