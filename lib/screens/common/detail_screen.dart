import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../map/map_screen.dart';
import '../../widgets/themed_image.dart';
import '../info/contact_us_screen.dart';
import '../../theme/app_typography.dart';

/// شاشة تفاصيل عامة تُستخدم لأي كرت (مكان مفضل، خبر، فعالية...) عند الضغط عليه.
/// كل الحقول اختيارية ما عدا العنوان، فتقدر تستخدمها لأي نوع محتوى.
class DetailScreen extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  final String? subtitleAr;
  final String? subtitleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double? rating;
  final String? extraInfo; // مثل التاريخ أو السعر أو الوقت
  final String?
  locationAr; // اسم الشارع/الحي الفعلي (يُستخدم لتحديد الموقع على الخريطة فقط)
  final String? locationEn;
  final String? customImageBase64; // صورة رفعها الأدمن يدويًا لهذا العنصر تحديدًا

  const DetailScreen({
    super.key,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.rating,
    this.extraInfo,
    this.locationAr,
    this.locationEn,
    this.customImageBase64,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final title = app.isArabic ? titleAr : titleEn;
        final subtitle = app.isArabic ? (subtitleAr ?? '') : (subtitleEn ?? '');
        final description = app.isArabic
            ? (descriptionAr ??
                  'لا يوجد وصف تفصيلي لهذا المحتوى بعد. يمكن إضافة المزيد من المعلومات هنا لاحقًا.')
            : (descriptionEn ??
                  'No detailed description available yet. More information can be added here later.');

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      ThemedImage(
                        query: guessPhotoQuery(subtitleAr ?? '', titleAr),
                        fallbackSeed: titleEn,
                        height: 260,
                        customImageBase64: customImageBase64,
                      ),
                      Container(
                        height: 260,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 44,
                        left: 16,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              title,
                              textDirection: app.dir,
                              style: AppTypography.display(Colors.white).copyWith(fontSize: 24),
                            ),
                            if (subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                textDirection: app.dir,
                                style: AppTypography.body(Colors.white70),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (rating != null || extraInfo != null)
                          Row(
                            children: [
                              if (extraInfo != null)
                                Expanded(
                                  child: Text(
                                    extraInfo!,
                                    style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (rating != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: AppColors.primaryGradient),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '$rating',
                                        style: AppTypography.label(Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        SizedBox(height: 16),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: AppColors.primaryGradient),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              app.t('نبذة', 'Overview'),
                              textDirection: app.dir,
                              style: AppTypography.headline(AppColors.textWhite).copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          description,
                          textDirection: app.dir,
                          textAlign: app.isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: AppTypography.body(AppColors.textGrey).copyWith(fontSize: 13),
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: AppColors.primaryGradient),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: AppColors.glowShadow,
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final point = resolveMapPoint(
                                  nameAr: titleAr,
                                  nameEn: titleEn,
                                  locationAr: locationAr ?? subtitleAr ?? '',
                                  locationEn: locationEn ?? subtitleEn ?? '',
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MapScreen(
                                      focusPoint: point,
                                      focusNameAr: titleAr,
                                      focusNameEn: titleEn,
                                      focusCategoryAr: subtitleAr,
                                      focusCategoryEn: subtitleEn,
                                      focusRating: rating,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                              icon: Icon(
                                Icons.map_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                app.t('عرض على الخريطة', 'Show on Map'),
                                style: AppTypography.title(Colors.white).copyWith(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ContactUsScreen(
                                    relatedPlaceAr: titleAr,
                                    relatedPlaceEn: titleEn,
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.borderColor),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            icon: Icon(
                              Icons.report_problem_outlined,
                              size: 16,
                              color: AppColors.textWhite,
                            ),
                            label: Text(
                              app.t('أبلغي عن مشكلة بهذا المكان', 'Report an issue with this place'),
                              style: AppTypography.label(AppColors.textWhite).copyWith(fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
