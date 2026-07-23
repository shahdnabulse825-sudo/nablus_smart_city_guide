import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart' show AppState, AppColors;
import '../theme/app_spacing.dart';

/// كبسة "الأقرب لموقعي" الموحّدة — نفس الشكل بكل شاشات القوائم بالتطبيق
/// (مطاعم، فنادق، صيدليات، معالم، تسوق، مواصلات، صحة...). بتعرض دائرة تحميل
/// وقت تحديد الموقع، وتتلوّن باللون الأساسي وقت التفعيل.
class NearestToMeChip extends StatelessWidget {
  final bool active;
  final bool loading;
  final VoidCallback onTap;
  const NearestToMeChip({
    super.key,
    required this.active,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.cardDark2,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: active ? Colors.transparent : AppColors.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: 11,
                height: 11,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: active ? Colors.white : AppColors.primary,
                ),
              )
            else
              Text('📍', style: TextStyle(fontSize: 11)),
            SizedBox(width: 5),
            Text(
              app.t('الأقرب لموقعي', 'Nearest to Me'),
              textDirection: app.dir,
              style: TextStyle(
                color: active ? Colors.white : AppColors.textWhite,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
