import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../map/map_screen.dart';

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
  final String image;
  final String? locationAr; // اسم الشارع/الحي الفعلي (يُستخدم لتحديد الموقع على الخريطة فقط)
  final String? locationEn;

  DetailScreen({
    super.key,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.rating,
    this.extraInfo,
    this.image = 'assets/images/nablus_bg.jpeg',
    this.locationAr,
    this.locationEn,
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
                      Image.asset(
                        image,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          height: 260,
                          color: AppColors.cardDark2,
                          child: Icon(Icons.image, color: AppColors.textGrey, size: 50),
                        ),
                      ),
                      Container(
                        height: 260,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
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
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                            child: Icon(Icons.arrow_back, color: Colors.white, size: 18),
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
                            Text(title,
                                textDirection: app.dir,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            if (subtitle.isNotEmpty)
                              Text(subtitle,
                                  textDirection: app.dir,
                                  style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                                  child: Text(extraInfo!,
                                      style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                ),
                              if (rating != null)
                                Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star, size: 13, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text('$rating',
                                          style: TextStyle(color: Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        SizedBox(height: 16),
                        Text(app.t('نبذة', 'Overview'),
                            textDirection: app.dir,
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(description,
                            textDirection: app.dir,
                            textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                            style: TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.7)),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final point = resolveMapPoint(
                                nameAr: titleAr,
                                nameEn: titleEn,
                                locationAr: locationAr ?? subtitleAr ?? '',
                                locationEn: locationEn ?? subtitleEn ?? '',
                              );
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  focusPoint: point,
                                  focusNameAr: titleAr,
                                  focusNameEn: titleEn,
                                  focusCategoryAr: subtitleAr,
                                  focusCategoryEn: subtitleEn,
                                  focusRating: rating,
                                ),
                              ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: Icon(Icons.map, size: 16, color: Colors.white),
                            label: Text(app.t('عرض على الخريطة', 'Show on Map'),
                                style: TextStyle(color: Colors.white)),
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