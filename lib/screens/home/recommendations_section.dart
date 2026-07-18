import 'package:flutter/material.dart';
import 'home_screen.dart'; // لإعادة استخدام AppState و AppColors و PlaceCard/PlaceCardRow/SectionHeader
import '../places/all_places_screen.dart';
import '../../services/recommendation_service.dart';
import '../../services/favorites_service.dart';
import '../../widgets/responsive.dart';

/// أقسام توصيات حقيقية مبنية على سلوك المستخدم (مفضلة + مشاهدات)، محل قسم
/// "الأكثر زيارة/أحدث الأماكن" القديم اللي كان بيانات ثابتة مش حقيقية.
class RecommendationsSection extends StatelessWidget {
  const RecommendationsSection({super.key});

  Widget _column(
    BuildContext context, {
    required String titleAr,
    required String titleEn,
    required String emoji,
    required List<UniversalPlace> places,
    required PlacesSortMode sortMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SectionHeader(
          titleAr: titleAr,
          titleEn: titleEn,
          emoji: emoji,
          onViewAll: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  AllPlacesScreen(titleAr: titleAr, titleEn: titleEn, sortMode: sortMode),
            ),
          ),
        ),
        SizedBox(height: 12),
        PlaceCardRow(
          cards: places
              .map(
                (p) => PlaceCard(
                  title: p.nameAr,
                  subtitle: p.typeAr,
                  titleEn: p.nameEn,
                  subtitleEn: p.typeEn,
                  rating: p.rating,
                  favorited: FavoritesService.instance.isFavorite(p.nameEn),
                  image: p.image,
                  customImageBase64: p.customImageBase64,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3 بطاقات لكل قسم بالصفحة الرئيسية (نفس عدد بطاقات القسم القديم)، حتى ما
    // تنعصر البطاقات بعرض ضيق جدًا وقت ما تكون الأقسام التلاتة ظاهرة مع بعض
    // بشاشات الديسكتوب. "عرض الكل" بكل قسم بيعرض قائمة كاملة بدون هالتحديد.
    final trending = RecommendationService.trendingToday(limit: 3);
    final recommended = RecommendationService.recommendedForYou(
      limit: 3,
      exclude: trending.map((p) => p.nameEn).toSet(),
    );
    final interests = RecommendationService.basedOnYourInterests(
      limit: 3,
      exclude: {...trending.map((p) => p.nameEn), ...recommended.map((p) => p.nameEn)},
    );

    final columns = [
      _column(
        context,
        titleAr: 'رائج اليوم',
        titleEn: 'Trending Today',
        emoji: '🔥',
        places: trending,
        sortMode: PlacesSortMode.trending,
      ),
      _column(
        context,
        titleAr: 'موصى لك',
        titleEn: 'Recommended For You',
        emoji: '✨',
        places: recommended,
        sortMode: PlacesSortMode.recommended,
      ),
      if (interests.isNotEmpty)
        _column(
          context,
          titleAr: 'بناءً على اهتماماتك',
          titleEn: 'Based On Your Interests',
          emoji: '🎯',
          places: interests,
          sortMode: PlacesSortMode.interests,
        ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: isMobile(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in columns) ...[c, SizedBox(height: 20)],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in columns) ...[
                  Expanded(child: c),
                  if (c != columns.last) SizedBox(width: 16),
                ],
              ],
            ),
    );
  }
}
