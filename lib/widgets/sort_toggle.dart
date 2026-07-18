import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// زر تبديل ترتيب النتائج، يدور بين عدة أوضاع ترتيب (تقييم/عدد مراجعات/سعر،
/// وأبجدي) — بلابل قابلة للتخصيص حسب كل شاشة عبر labelsAr/labelsEn.
class SortToggle extends StatelessWidget {
  final int activeIndex;
  final List<String> labelsAr;
  final List<String> labelsEn;
  final bool isArabic;
  final ValueChanged<int> onChanged;

  const SortToggle({
    super.key,
    required this.activeIndex,
    required this.labelsAr,
    required this.labelsEn,
    required this.isArabic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labels = isArabic ? labelsAr : labelsEn;
    final label = labels[activeIndex % labels.length];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged((activeIndex + 1) % labels.length),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: AppColors.textWhite, fontSize: 12)),
            SizedBox(width: 6),
            Icon(Icons.swap_vert, size: 16, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
