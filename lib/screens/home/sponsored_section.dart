import 'package:flutter/material.dart';
import 'home_screen.dart'; // لإعادة استخدام AppState و AppColors
import 'promotion_data.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../widgets/themed_image.dart';
import '../../widgets/responsive.dart';
import '../../theme/app_typography.dart';

/// قسم "عروض وإعلانات" — عروض حقيقية لمحلات موجودة بالتطبيق (خصم، توصيل مجاني،
/// كود خصم...) ينشرها الأدمن من لوحة التحكم، بفترة صلاحية اختيارية. القسم ما
/// بيظهر أصلاً لو ما في عروض سارية حاليًا.
class SponsoredSection extends StatelessWidget {
  const SponsoredSection({super.key});

  List<PromotionData> _livePromotions() => LocalDbService.instance
      .getAll('promotions')
      .map((e) => mapToPromotion(e.value))
      .toList();

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final promotions = _livePromotions();
    if (promotions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Text('📢', style: const TextStyle(fontSize: 18)),
              SizedBox(width: 6),
              Text(
                app.t('عروض وإعلانات', 'Deals & Offers'),
                textDirection: app.dir,
                style: AppTypography.headline(
                  AppColors.textWhite,
                ).copyWith(fontSize: 18),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: app.isArabic,
              itemCount: promotions.length,
              separatorBuilder: (_, _) => SizedBox(width: 12),
              itemBuilder: (context, i) =>
                  _PromoCard(promo: promotions[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final PromotionData promo;
  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final title = app.isArabic ? promo.titleAr : promo.titleEn;
    final placeName = app.isArabic ? promo.placeNameAr : promo.placeNameEn;

    return GestureDetector(
      onTap: () => _showPromoDetails(context),
      child: SizedBox(
        width: isMobile(context) ? 170 : 200,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            boxShadow: AppColors.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ThemedImage(
                    query: 'shop discount sale',
                    fallbackSeed: promo.titleEn,
                    height: 110,
                    customImageBase64: promo.customImageBase64,
                    serverImageUrl: promo.serverImageUrl,
                    fallbackIcon: PromotionData.icon,
                    fallbackColor: AppColors.primary,
                  ),
                  Positioned(
                    top: 8,
                    right: app.isArabic ? null : 8,
                    left: app.isArabic ? 8 : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primaryGradient),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        app.t('إعلان', 'Ad'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      textDirection: app.dir,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(
                        AppColors.textWhite,
                      ).copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    if (placeName.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        placeName,
                        textDirection: app.dir,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption(AppColors.textGrey),
                      ),
                    ],
                    if (promo.discountCode.isNotEmpty) ...[
                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.confirmation_number_outlined,
                                size: 11, color: AppColors.primary),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                promo.discountCode,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPromoDetails(BuildContext context) {
    final app = AppState.instance;
    final title = app.isArabic ? promo.titleAr : promo.titleEn;
    final description = app.isArabic ? promo.descriptionAr : promo.descriptionEn;
    final placeName = app.isArabic ? promo.placeNameAr : promo.placeNameEn;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) => Directionality(
        textDirection: app.dir,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: AppTypography.headline(AppColors.textWhite),
                ),
                if (placeName.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(placeName, style: AppTypography.body(AppColors.primary)),
                ],
                if (description.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(description, style: AppTypography.body(AppColors.textGrey)),
                ],
                if (promo.discountCode.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(
                      promo.discountCode,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
