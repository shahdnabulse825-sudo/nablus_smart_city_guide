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

  /// عنوان الـ Hero — أكبر عنصر نصي بالتطبيق
  static TextStyle display(Color color) => GoogleFonts.tajawal(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: color,
    height: 1.2,
  );

  /// عنوان قسم (التصنيفات، الأماكن المفضلة...)
  static TextStyle headline(Color color) => GoogleFonts.tajawal(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.3,
  );

  /// عنوان بطاقة
  static TextStyle title(Color color) => GoogleFonts.tajawal(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.35,
  );

  /// نص وصفي عادي
  static TextStyle body(Color color) => GoogleFonts.tajawal(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.6,
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
