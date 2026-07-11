import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// يبني الـ [ThemeData] الأساسي للتطبيق. الشاشات لسا بتستخدم [AppColors]
/// يدويًا بمعظم الأماكن (نمط قديم موروث)، بس هاد الملف بيحسّن الإعدادات
/// الافتراضية (الخط، الأزرار، الحقول...) اللي بترث منها كل الودجات تلقائيًا.
class AppTheme {
  static ThemeData dark() {
    const bg = Color(0xFF0A0E1A);
    const textColor = Color(0xFFF5F6FA);
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.orange,
      ),
      textTheme: AppTypography.textTheme(textColor),
      splashFactory: InkRipple.splashFactory,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.title(Colors.white),
        ),
      ),
      iconTheme: const IconThemeData(color: textColor),
      dividerColor: const Color(0xFF283350),
      // انتقال ناعم وموحّد بين كل الصفحات على كل المنصات، بدل الانتقال الافتراضي
      // المختلف حسب النظام — يشمل تلقائيًا كل استخدامات MaterialPageRoute بالمشروع.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
