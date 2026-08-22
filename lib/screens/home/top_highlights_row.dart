import 'package:flutter/material.dart';
import 'home_screen.dart'; // لإعادة استخدام AppState و AppColors و SectionHeader
import '../../widgets/themed_image.dart';
import '../../widgets/responsive.dart';
import '../../theme/app_typography.dart';
import '../../services/favorites_service.dart';
import '../events/events_data.dart';
import '../events/events_screen.dart';
import '../news/news_screen.dart';
import '../places/all_places_screen.dart';
import '../common/detail_screen.dart';

/// صف الأبرز أسفل بطاقات الطقس/الزوار/الوقت مباشرة — ثلاثة أعمدة جنب بعض
/// على الديسكتوب (الأماكن الأكثر زيارة / فعاليات قادمة / آخر الأخبار)،
/// وتتراص عموديًا على الموبايل. مأخوذ عن تصميم مرجعي زوّده المستخدم.
class TopHighlightsRow extends StatelessWidget {
  const TopHighlightsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final mostVisitedColumn = _MostVisitedColumn();
    final eventColumn = _UpcomingEventColumn();
    final newsColumn = _LatestNewsColumn();

    final mobile = isMobile(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                mostVisitedColumn,
                SizedBox(height: 24),
                eventColumn,
                SizedBox(height: 24),
                newsColumn,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: mostVisitedColumn),
                SizedBox(width: 16),
                Expanded(child: eventColumn),
                SizedBox(width: 16),
                Expanded(child: newsColumn),
              ],
            ),
    );
  }
}

// ==================== عمود: الأماكن الأكثر زيارة ====================
class _MostVisitedColumn extends StatefulWidget {
  const _MostVisitedColumn();

  @override
  State<_MostVisitedColumn> createState() => _MostVisitedColumnState();
}

class _MostVisitedColumnState extends State<_MostVisitedColumn> {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final places = List.of(allPlaces)
      ..sort((a, b) => b.reviews.compareTo(a.reviews));
    final top = places.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SectionHeader(
          titleAr: 'الأماكن الأكثر زيارة',
          titleEn: 'Most Visited Places',
          onViewAll: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AllPlacesScreen(
                titleAr: 'الأماكن الأكثر زيارة',
                titleEn: 'Most Visited Places',
                sortMode: PlacesSortMode.trending,
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: top
              .map(
                (p) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: _MostVisitedThumb(place: p),
                  ),
                ),
              )
              .toList(),
        ),
        if (top.isEmpty)
          Text(
            app.t('ما في أماكن بعد', 'No places yet'),
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
      ],
    );
  }
}

class _MostVisitedThumb extends StatefulWidget {
  final UniversalPlace place;
  const _MostVisitedThumb({required this.place});

  @override
  State<_MostVisitedThumb> createState() => _MostVisitedThumbState();
}

class _MostVisitedThumbState extends State<_MostVisitedThumb> {
  @override
  Widget build(BuildContext context) {
    final p = widget.place;
    final favorited = FavoritesService.instance.isFavorite(p.nameEn);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            titleAr: p.nameAr,
            titleEn: p.nameEn,
            subtitleAr: p.typeAr,
            subtitleEn: p.typeEn,
            rating: p.rating,
            localAsset: p.image.isEmpty ? null : p.image,
            customImageBase64: p.customImageBase64,
            placeType: p.categoryKey,
            apiId: p.apiId,
            ownerEmail: p.ownerEmail,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.maxWidth;
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: SizedBox(
              width: side,
              height: side,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ThemedImage(
                    query: p.photoQuery,
                    fallbackSeed: p.nameEn,
                    localAsset: p.image.isEmpty ? null : p.image,
                    customImageBase64: p.customImageBase64,
                    fallbackIcon: p.icon,
                    fallbackColor: p.color,
                    height: side,
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        await FavoritesService.instance.toggleFavorite(
                          p.nameEn,
                        );
                        if (mounted) setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          favorited ? Icons.favorite : Icons.favorite_border,
                          size: 13,
                          color: favorited ? AppColors.red : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== عمود: فعاليات قادمة ====================
class _UpcomingEventColumn extends StatelessWidget {
  const _UpcomingEventColumn();

  @override
  Widget build(BuildContext context) {
    final event = eventsData.first;
    final app = AppState.instance;
    final shownTitle = app.isArabic ? event.titleAr : event.titleEn;
    final shownVenue = app.isArabic ? event.venueAr : event.venueEn;
    final shownMonth = app.isArabic ? event.monthAr : event.monthEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SectionHeader(
          titleAr: 'فعاليات قادمة',
          titleEn: 'Upcoming Events',
          onViewAll: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => EventsScreen())),
        ),
        SizedBox(height: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                titleAr: event.titleAr,
                titleEn: event.titleEn,
                subtitleAr: event.venueAr,
                subtitleEn: event.venueEn,
                descriptionAr: event.aboutAr,
                descriptionEn: event.aboutEn,
                extraInfo: '${event.day} $shownMonth',
                customImageBase64: event.customImageBase64,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: AppColors.cardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    ThemedImage(
                      query: event.photoQuery,
                      fallbackSeed: event.titleEn,
                      customImageBase64: event.customImageBase64,
                      fallbackIcon: event.icon,
                      fallbackColor: event.color,
                      height: 110,
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: event.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Icon(event.icon, color: Colors.white, size: 15),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        shownTitle,
                        textDirection: app.dir,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(
                          AppColors.textWhite,
                        ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            '${event.day} $shownMonth',
                            style: AppTypography.caption(AppColors.textGrey),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: AppColors.purpleLight,
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(
                            child: Text(
                              shownVenue,
                              textDirection: app.dir,
                              textAlign: app.isArabic
                                  ? TextAlign.right
                                  : TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption(
                                AppColors.textGrey,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.place_rounded,
                            size: 12,
                            color: AppColors.purpleLight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== عمود: آخر الأخبار ====================
class _LatestNewsColumn extends StatelessWidget {
  const _LatestNewsColumn();

  static const _item = {
    'titleAr': 'افتتاح مشروع تطوير السوق القديم',
    'titleEn': 'Old Market Development Project Launched',
    'dateAr': '20 أغسطس 2026',
    'dateEn': 'August 20, 2026',
    'photoQuery': 'old market renovation street',
  };

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final shownTitle = app.isArabic ? _item['titleAr']! : _item['titleEn']!;
    final shownDate = app.isArabic ? _item['dateAr']! : _item['dateEn']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SectionHeader(
          titleAr: 'آخر الأخبار',
          titleEn: 'Latest News',
          onViewAll: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => NewsScreen())),
        ),
        SizedBox(height: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                titleAr: _item['titleAr']!,
                titleEn: _item['titleEn']!,
                extraInfo: shownDate,
              ),
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: ThemedImage(
                      query: _item['photoQuery']!,
                      fallbackSeed: _item['titleEn']!,
                      height: 64,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        shownTitle,
                        textDirection: app.dir,
                        textAlign: app.isArabic
                            ? TextAlign.right
                            : TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(
                          AppColors.textWhite,
                        ).copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 6),
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            shownDate,
                            style: AppTypography.caption(AppColors.textGrey),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: AppColors.textGrey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
