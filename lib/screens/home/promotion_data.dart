import 'package:flutter/material.dart';

/// عرض/إعلان حقيقي لمحل موجود بالتطبيق (خصم، توصيل مجاني، كود خصم...) ينشره
/// الأدمن — بعكس isFeatured (يظهر المحل نفسه دائمًا)، هاد إعلان بعنوان وتفاصيل
/// خاصة وفترة صلاحية اختيارية، وبيختفي تلقائيًا بعد تاريخ الانتهاء (السيرفر
/// نفسه بيرجّع بس العروض السارية حاليًا).
class PromotionData {
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String discountCode;
  final String placeNameAr;
  final String placeNameEn;
  final String categoryKey;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? customImageBase64;
  final String? serverImageUrl;
  final String? apiId;

  const PromotionData({
    required this.titleAr,
    required this.titleEn,
    this.descriptionAr = '',
    this.descriptionEn = '',
    this.discountCode = '',
    this.placeNameAr = '',
    this.placeNameEn = '',
    this.categoryKey = '',
    this.startDate,
    this.endDate,
    this.customImageBase64,
    this.serverImageUrl,
    this.apiId,
  });

  static const IconData icon = Icons.local_offer_rounded;
}
