import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../common/detail_screen.dart';
import 'events_data.dart';

/// شاشة الفعاليات القادمة الكاملة بنابلس.
class EventsScreen extends StatelessWidget {
  EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
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
                          child: Icon(Icons.arrow_back, color: AppColors.textWhite),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.event, color: AppColors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(app.t('الفعاليات القادمة', 'Upcoming Events'),
                            textDirection: app.dir,
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.all(20),
                      itemCount: eventsData.length,
                      separatorBuilder: (_, __) => SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final e = eventsData[i];
                        final title = app.isArabic ? e.titleAr : e.titleEn;
                        final venue = app.isArabic ? e.venueAr : e.venueEn;
                        final month = app.isArabic ? e.monthAr : e.monthEn;
                        final time = app.isArabic ? e.timeAr : e.timeEn;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                titleAr: e.titleAr,
                                titleEn: e.titleEn,
                                subtitleAr: e.venueAr,
                                subtitleEn: e.venueEn,
                                descriptionAr: e.aboutAr,
                                descriptionEn: e.aboutEn,
                                extraInfo: '${e.day} $month • $time',
                              ),
                            ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 130,
                                  height: 130,
                                  child: ThemedImage(
                                    query: e.photoQuery,
                                    fallbackSeed: e.titleEn,
                                    height: 130,
                                    fallbackIcon: e.icon,
                                    fallbackColor: e.color,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          textDirection: TextDirection.rtl,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: e.color,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text('${e.day} $month',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(title,
                                            textDirection: app.dir,
                                            style: TextStyle(
                                                color: AppColors.textWhite,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 4),
                                        Row(
                                          textDirection: TextDirection.rtl,
                                          children: [
                                            Icon(Icons.location_on,
                                                size: 12, color: AppColors.textGrey),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(venue,
                                                  textDirection: app.dir,
                                                  style: TextStyle(
                                                      color: AppColors.textGrey, fontSize: 11)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2),
                                        Row(
                                          textDirection: TextDirection.rtl,
                                          children: [
                                            Icon(Icons.access_time,
                                                size: 12, color: AppColors.textGrey),
                                            SizedBox(width: 4),
                                            Text(time,
                                                textDirection: app.dir,
                                                style: TextStyle(
                                                    color: AppColors.textGrey, fontSize: 11)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
