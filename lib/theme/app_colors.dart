import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart' show AppState;

/// لوحة ألوان دليل نابلس الذكي — هوية "Modern Heritage": كحلي داكن مستوحى من
/// ليالي البلدة القديمة، مع لمسات ذهبية من حجر نابلس وأخرى زيتونية هادئة.
/// هاي هي المرجعية الوحيدة للألوان بكل المشروع؛ [AppColors] بالشاشة الرئيسية
/// بيصدّرها فقط حتى يضل كل استيراد قديم شغال بدون أي تعديل.
class AppColors {
  static bool get _dark => AppState.instance.isDark;

  // ---------- خلفيات وأسطح (تتغيّر حسب الوضع الليلي/النهاري) ----------
  // بالوضع الليلي: كحلي عميق نقي (بدون أي ميل بنفسجي/سماوي نيون) — طلب صريح
  // بالحفاظ على هوية "كحلي + برتقالي" بدون Cyber/Aurora.
  static Color get bgDark =>
      _dark ? const Color(0xFF08131F) : const Color(0xFFF8F6F2);
  static Color get cardDark => _dark ? const Color(0xFF121D2D) : Colors.white;
  static Color get cardDark2 =>
      _dark ? const Color(0xFF16304D) : const Color(0xFFF0ECE4);
  static Color get sidebarDark =>
      _dark ? const Color(0xFF0E1A2B) : Colors.white;
  static Color get borderColor =>
      _dark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAE3D8);

  // ---------- ألوان الهوية (ثابتة بكل الأحوال) ----------
  static const purple = Color(0xFF6C5CE7);
  static const purpleLight = Color(0xFF8B7CF6);
  static const primary = Color(
    0xFFF6A623,
  ); // كهرماني فاخر (Amber) — بديل الذهبي الباهت
  static const primaryDark = Color(0xFFD6890F); // للحالة المضغوطة/الظل
  static const orange = Color(0xFFF7C24A); // بداية تدرّج الأزرار
  static const coral = Color(0xFFF47A3A); // نهاية تدرّج الأزرار
  static const teal = Color(0xFF2A9D8F); // زيتوني هادئ
  static const gold = Color(0xFFF4B942); // ذهبي فاتح (Accent/تقييمات)
  static const green = Color(0xFF22C55E);
  static const red = Color(0xFFEF4444); // أحمر دلالي (خطر/حذف)
  static const blue = Color(0xFF3B82F6); // أزرق (تصنيف الفنادق)
  static const skyBlue = Color(0xFF0EA5E9); // سماوي (تصنيف المواصلات)
  static const vividOrange = Color(0xFFF97316); // برتقالي حي (تصنيف المطاعم)

  /// تدرّج أزرار الهوية: كهرماني فاتح ← برتقالي دافئ — بدون أي وقفة بنفسجية
  static const primaryGradient = [orange, coral];

  static Color get textWhite =>
      _dark ? const Color(0xFFF7F9FC) : const Color(0xFF181B26);
  static Color get textGrey =>
      _dark ? const Color(0xFFAEB8C7) : const Color(0xFF6B7280);

  /// ظل ثنائي الطبقة موحّد للبطاقات — طبقة قريبة ناعمة + طبقة محيطة بعيدة
  /// وخفيفة جدًا، حتى تبان البطاقات "عائمة" فوق الخلفية بدل مسطّحة. الطبقة
  /// البعيدة مطابقة تمامًا لمواصفة 0 12px 40px rgba(0,0,0,.35) بالوضع الليلي.
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: (_dark ? Colors.black : const Color(0xFF9B7A4A)).withValues(
        alpha: _dark ? 0.18 : 0.08,
      ),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: (_dark ? Colors.black : const Color(0xFF9B7A4A)).withValues(
        alpha: _dark ? 0.35 : 0.05,
      ),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.28),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
