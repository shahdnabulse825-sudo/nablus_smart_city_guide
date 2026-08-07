import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../screens/home/home_screen.dart' show AppState;

/// حاوية بتأثير زجاجي خفيف (Glassmorphism) — تُستخدم للبطاقات البارزة
/// (بطاقات الإحصائيات بالأعلى، بطاقات الشريط الجانبي) حتى تبان أخف وأعمق
/// من بطاقة داكنة عادية، بما يناسب هوية "Modern Heritage" الجديدة.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.radius = AppRadius.lg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppState.instance.isDark;
    // بالوضع الليلي: زجاج كحلي دافئ (rgba(18,29,45,.72)) بدل تظليل أبيض خافت
    // جدًا — إحساس "بطاقة زجاجية على خلفية كحلية" بدل رمادي عائم بلا هوية.
    final glassColor = dark
        ? const Color(0xFF121D2D).withValues(alpha: 0.72)
        : Colors.black.withValues(alpha: 0.5);
    final borderTint = dark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.6);
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderTint),
            boxShadow: AppColors.cardShadow,
          ),
          child: child,
        ),
      ),
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
