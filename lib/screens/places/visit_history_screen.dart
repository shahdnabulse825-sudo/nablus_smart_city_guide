import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../../widgets/empty_state.dart';
import '../common/detail_screen.dart';
import '../../theme/app_typography.dart';
import '../../services/recent_activity_service.dart';
import 'all_places_screen.dart' show allPlaces;

/// شاشة "سجل الزيارات" — كل مكان زرتِه، بترتيب زمني (الأحدث أولًا)، متزامنة
/// بين الأجهزة لو كان الحساب حقيقي (RecentActivityService.syncWithServer).
class VisitHistoryScreen extends StatelessWidget {
  const VisitHistoryScreen({super.key});

  String _relativeTime(AppState app, DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return app.t('الآن', 'just now');
    if (diff.inMinutes < 60) {
      return app.t('قبل ${diff.inMinutes} د', '${diff.inMinutes}m ago');
    }
    if (diff.inHours < 24) {
      return app.t('قبل ${diff.inHours} س', '${diff.inHours}h ago');
    }
    return app.t('قبل ${diff.inDays} يوم', '${diff.inDays}d ago');
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final history = RecentActivityService.instance.getVisitHistory();
        final byName = {for (final p in allPlaces) p.nameEn: p};
        final rows = history
            .map((e) => (place: byName[e['nameEn'] as String], viewedAt: e['viewedAt'] as String))
            .where((r) => r.place != null)
            .toList();

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    color: AppColors.sidebarDark,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppColors.cardDark, shape: BoxShape.circle),
                            child: Icon(Icons.arrow_back_rounded, color: AppColors.textWhite, size: 18),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.primaryGradient),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(Icons.history_rounded, color: Colors.white, size: 16),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            app.t('سجل الزيارات', 'Visit History'),
                            textDirection: app.dir,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: rows.isEmpty
                        ? Center(
                            child: EmptyState(
                              icon: Icons.history_rounded,
                              titleAr: 'ما في زيارات لسا',
                              titleEn: 'No visits yet',
                              subtitleAr: 'الأماكن اللي بتفتحيها رح تظهر هون',
                              subtitleEn: 'Places you open will show up here',
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.all(16),
                            itemCount: rows.length,
                            separatorBuilder: (_, _) => SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final row = rows[i];
                              final p = row.place!;
                              final viewedAt = DateTime.tryParse(row.viewedAt);
                              return AppCard(
                                padding: EdgeInsets.all(10),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                      titleAr: p.nameAr,
                                      titleEn: p.nameEn,
                                      subtitleAr: p.typeAr,
                                      subtitleEn: p.typeEn,
                                      descriptionAr: p.aboutAr,
                                      descriptionEn: p.aboutEn,
                                      rating: p.rating,
                                      locationAr: p.locationAr,
                                      locationEn: p.locationEn,
                                      customImageBase64: p.customImageBase64,
                                      localAsset: p.image,
                                      placeType: p.categoryKey,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                      child: SizedBox(
                                        width: 52,
                                        height: 52,
                                        child: ThemedImage(
                                          query: p.photoQuery,
                                          localAsset: p.image,
                                          customImageBase64: p.customImageBase64,
                                          fallbackSeed: p.nameEn,
                                          fallbackIcon: p.icon,
                                          fallbackColor: p.color,
                                          height: 52,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            app.t(p.nameAr, p.nameEn),
                                            textDirection: app.dir,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.body(
                                              AppColors.textWhite,
                                            ).copyWith(fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            app.t(p.typeAr, p.typeEn),
                                            textDirection: app.dir,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (viewedAt != null)
                                      Text(
                                        _relativeTime(app, viewedAt),
                                        style: TextStyle(color: AppColors.textGrey, fontSize: 10),
                                      ),
                                  ],
                                ),
                              );
                            },
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
