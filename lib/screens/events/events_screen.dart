import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../common/detail_screen.dart';
import 'events_data.dart';
import '../../theme/app_typography.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../services/api_service.dart';

/// شاشة الفعاليات القادمة الكاملة بنابلس — بيانات حقيقية من قاعدة البيانات
/// المحلية/السيرفر بدل قائمة ثابتة، تمامًا متل شاشة الأخبار.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool _loaded = false;
  List<EventItem> _liveEvents = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = LocalDbService.instance;
    await db.seedIfEmpty('events', eventsData.map(eventToMap).toList());
    await ApiService.syncEvents();
    final entries = db.getAll('events');
    setState(() {
      _liveEvents = entries.map((e) => mapToEvent(e.value)).toList();
      _loaded = true;
    });
  }

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
                          child: Icon(Icons.event_rounded, color: Colors.white, size: 16),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            app.t('الفعاليات القادمة', 'Upcoming Events'),
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
                    child: !_loaded
                        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : _liveEvents.isEmpty
                        ? Center(
                            child: Text(
                              app.t('لا توجد فعاليات قادمة حاليًا', 'No upcoming events right now'),
                              style: AppTypography.body(AppColors.textGrey),
                            ),
                          )
                        : ListView.separated(
                      padding: EdgeInsets.all(20),
                      itemCount: _liveEvents.length,
                      separatorBuilder: (_, _) => SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final e = _liveEvents[i];
                        final title = app.isArabic ? e.titleAr : e.titleEn;
                        final venue = app.isArabic ? e.venueAr : e.venueEn;
                        final month = app.isArabic ? e.monthAr : e.monthEn;
                        final time = app.isArabic ? e.timeAr : e.timeEn;
                        return AppCard(
                          padding: EdgeInsets.zero,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                  titleAr: e.titleAr,
                                  titleEn: e.titleEn,
                                  subtitleAr: e.venueAr,
                                  subtitleEn: e.venueEn,
                                  descriptionAr: e.aboutAr,
                                  descriptionEn: e.aboutEn,
                                  extraInfo: '${e.day} $month • $time',
                                  customImageBase64: e.customImageBase64,
                                ),
                              ),
                            );
                          },
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
                                  customImageBase64: e.customImageBase64,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        textDirection: TextDirection.rtl,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [e.color, e.color.withValues(alpha: 0.7)],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${e.day} $month',
                                              style: AppTypography.label(Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        title,
                                        textDirection: app.dir,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 14),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        textDirection: TextDirection.rtl,
                                        children: [
                                          Icon(
                                            Icons.location_on_rounded,
                                            size: 12,
                                            color: AppColors.textGrey,
                                          ),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              venue,
                                              textDirection: app.dir,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.caption(AppColors.textGrey),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2),
                                      Row(
                                        textDirection: TextDirection.rtl,
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 12,
                                            color: AppColors.textGrey,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            time,
                                            textDirection: app.dir,
                                            style: AppTypography.caption(AppColors.textGrey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
