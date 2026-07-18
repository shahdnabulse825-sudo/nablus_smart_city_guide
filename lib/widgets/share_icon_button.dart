import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';

/// زر مشاركة حقيقي (يفتح قائمة المشاركة الفعلية لنظام التشغيل)، بنفس تصميم
/// أزرار الإجراءات الدائرية (اتصال/خريطة/مفضلة) المستخدمة بكل شاشات التفاصيل.
class ShareIconButton extends StatelessWidget {
  final String shareText;
  final String labelAr;
  final String labelEn;
  final bool isArabic;
  const ShareIconButton({
    super.key,
    required this.shareText,
    required this.isArabic,
    this.labelAr = 'المشاركة',
    this.labelEn = 'Share',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Share.share(shareText),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.cardDark2, shape: BoxShape.circle),
            child: Icon(Icons.share, size: 16, color: AppColors.primary),
          ),
          SizedBox(height: 4),
          Text(
            isArabic ? labelAr : labelEn,
            style: TextStyle(color: AppColors.textGrey, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
