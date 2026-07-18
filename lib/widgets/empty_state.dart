import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart' show AppState, AppColors;

/// حالة "لا توجد نتائج" موحّدة بأيقونة دائرية متدرّجة اللون، بدل نص رمادي
/// عادي مكرّر بكل شاشة — تُستخدم لنتائج البحث/الفلاتر الفاضية أو لعدم وجود
/// عناصر مفضّلة بعد.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String titleAr;
  final String titleEn;
  final String? subtitleAr;
  final String? subtitleEn;

  const EmptyState({
    super.key,
    this.icon = Icons.search_off_rounded,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.18),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            app.t(titleAr, titleEn),
            textDirection: app.dir,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitleAr != null && subtitleEn != null) ...[
            const SizedBox(height: 6),
            Text(
              app.t(subtitleAr!, subtitleEn!),
              textDirection: app.dir,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
