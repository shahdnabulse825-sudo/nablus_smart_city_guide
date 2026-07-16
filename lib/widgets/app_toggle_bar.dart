import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart' show AppState;
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// كبسولة موحّدة لزري تبديل اللغة (عربي/EN) والوضع الليلي/النهاري معًا —
/// شكل واحد متّسق يُستخدم بكل شاشات التطبيق بدل التطبيقات المتفرقة القديمة.
class AppToggleBar extends StatelessWidget {
  const AppToggleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.cardDark2,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            onTap: () => app.toggleTheme(),
            tooltip: app.t(
              'تبديل الوضع الليلي/النهاري',
              'Toggle dark/light mode',
            ),
            child: Icon(
              app.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 16,
              color: AppColors.textWhite,
            ),
          ),
          Container(width: 1, height: 18, color: AppColors.borderColor),
          _Segment(
            onTap: () => app.toggleLanguage(),
            tooltip: app.t('تبديل اللغة', 'Switch language'),
            child: Text(
              app.isArabic ? 'AR' : 'EN',
              style: AppTypography.label(AppColors.textWhite).copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final String tooltip;
  const _Segment({
    required this.onTap,
    required this.child,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 34,
          height: 30,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
