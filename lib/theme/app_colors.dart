import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart' show AppState;

/// لوحة ألوان دليل نابلس الذكي — هوية "غروب نابلس الدافئ": كهرماني ← برتقالي ← مرجاني،
/// مستوحاة من حجر البلدة القديمة الذهبي وغروب الشمس فوق جبل جرزيم.
/// هاي هي المرجعية الوحيدة للألوان بكل المشروع؛ [AppColors] بالشاشة الرئيسية
/// بيصدّرها فقط حتى يضل كل استيراد قديم شغال بدون أي تعديل.
class AppColors {
  static bool get _dark => AppState.instance.isDark;

  // ---------- خلفيات وأسطح (تتغيّر حسب الوضع الليلي/النهاري) ----------
  static Color get bgDark =>
      _dark ? const Color(0xFF0A0E1A) : const Color(0xFFF8F6F2);
  static Color get cardDark =>
      _dark ? const Color(0xFF141C30) : Colors.white;
  static Color get cardDark2 =>
      _dark ? const Color(0xFF1C2740) : const Color(0xFFF0ECE4);
  static Color get sidebarDark =>
      _dark ? const Color(0xFF0D1424) : Colors.white;
  static Color get borderColor =>
      _dark ? const Color(0xFF283350) : const Color(0xFFEAE3D8);

  // ---------- ألوان الهوية (ثابتة بكل الأحوال) ----------
  static const purple = Color(0xFF6C5CE7);
  static const purpleLight = Color(0xFF8B7CF6);
  static const primary = Color(0xFFF5A623); // كهرماني نابلسي
  static const primaryDark = Color(0xFFD98A0E); // للحالة المضغوطة/الظل
  static const orange = Color(0xFFF97316); // برتقالي غروب
  static const coral = Color(0xFFEF6F53); // مرجاني دافئ (زخرفي)
  static const teal = Color(0xFF14B8A6);
  static const gold = Color(0xFFFBBF24); // ذهبي التقييمات (نجوم)
  static const green = Color(0xFF22C55E);
  static const red = Color(0xFFEF4444); // أحمر دلالي (خطر/حذف)

  /// تدرّج الهوية الدافئ: كهرماني ← برتقالي ← مرجاني — للشعارات والعناصر البارزة
  static const primaryGradient = [primary, orange, coral];

  static Color get textWhite =>
      _dark ? const Color(0xFFF5F6FA) : const Color(0xFF181B26);
  static Color get textGrey =>
      _dark ? const Color(0xFF98A2B8) : const Color(0xFF6B7280);

  /// ظل خفيف موحّد للبطاقات (يتكيّف قوته مع الوضع الليلي/النهاري)
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: (_dark ? Colors.black : const Color(0xFF9B7A4A))
          .withValues(alpha: _dark ? 0.35 : 0.10),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.35),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
