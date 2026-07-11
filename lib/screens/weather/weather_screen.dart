import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../services/weather_service.dart';
import '../../theme/app_typography.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  static const _dayNamesAr = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  static const _dayNamesEn = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final weather = app.weather;
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
                            gradient: LinearGradient(colors: [AppColors.gold, AppColors.primary]),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 16),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(app.t('طقس نابلس اليوم', "Today's Weather in Nablus"),
                              textDirection: app.dir,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 16)),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => app.fetchWeather(),
                          child: Icon(Icons.refresh_rounded, color: AppColors.textWhite, size: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: app.weatherLoading
                        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : weather == null
                            ? _errorState(app)
                            : SingleChildScrollView(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _heroCard(app, weather),
                                    SizedBox(height: 20),
                                    _statsRow(app, weather),
                                    SizedBox(height: 24),
                                    Text(app.t('توقعات 7 أيام', '7-Day Forecast'),
                                        textDirection: app.dir,
                                        style: AppTypography.headline(AppColors.textWhite).copyWith(fontSize: 16)),
                                    SizedBox(height: 12),
                                    ...weather.daily.map((d) => _dailyRow(app, d)),
                                  ],
                                ),
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

  Widget _errorState(AppState app) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: AppColors.textGrey, size: 40),
          SizedBox(height: 12),
          Text(app.t('تعذر تحميل بيانات الطقس', 'Failed to load weather data'),
              style: TextStyle(color: AppColors.textGrey)),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => app.fetchWeather(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            icon: Icon(Icons.refresh, size: 16, color: Colors.white),
            label: Text(app.t('إعادة المحاولة', 'Retry'),
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(AppState app, WeatherData weather) {
    final cond = weatherConditionFor(weather.weatherCode);
    final desc = app.isArabic ? cond.descriptionAr : cond.descriptionEn;
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.purple, AppColors.primary, AppColors.coral],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppColors.glowShadow,
      ),
      child: Row(
        children: [
          Icon(cond.icon, color: Colors.white, size: 56),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${weather.temperature.round()}°C',
                    style: AppTypography.display(Colors.white).copyWith(fontSize: 40)),
                Text(desc,
                    textDirection: app.dir,
                    style: AppTypography.body(Colors.white).copyWith(fontSize: 14)),
                SizedBox(height: 4),
                Text(
                    app.t('يشعر وكأنها ${weather.feelsLike.round()}°C',
                        'Feels like ${weather.feelsLike.round()}°C'),
                    textDirection: app.dir,
                    style: AppTypography.caption(Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(AppState app, WeatherData weather) {
    return Row(
      children: [
        Expanded(
          child: _statTile(app, Icons.water_drop, AppColors.teal,
              app.t('الرطوبة', 'Humidity'), '${weather.humidity}%'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _statTile(app, Icons.air, AppColors.primary, app.t('الرياح', 'Wind'),
              '${weather.windSpeed.round()} كم/س'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _statTile(app, Icons.wb_twilight, AppColors.gold, app.t('الغروب', 'Sunset'),
              DateFormat('hh:mm a').format(weather.sunset)),
        ),
      ],
    );
  }

  Widget _statTile(AppState app, IconData icon, Color color, String label, String value) {
    return AppCard(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 6),
          Text(value, style: AppTypography.label(AppColors.textWhite).copyWith(fontSize: 13)),
          SizedBox(height: 2),
          Text(label,
              textDirection: app.dir,
              style: AppTypography.caption(AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _dailyRow(AppState app, DailyForecast d) {
    final cond = weatherConditionFor(d.weatherCode);
    final dayIndex = d.date.weekday - 1;
    final dayName = app.isArabic ? _dayNamesAr[dayIndex] : _dayNamesEn[dayIndex];
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            SizedBox(
              width: 60,
              child: Text(dayName,
                  textDirection: app.dir,
                  style: AppTypography.label(AppColors.textWhite)),
            ),
            Icon(cond.icon, color: AppColors.gold, size: 18),
            Spacer(),
            Text('${d.minTemp.round()}°',
                style: AppTypography.body(AppColors.textGrey).copyWith(fontSize: 12)),
            SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: 0.6,
                  backgroundColor: AppColors.borderColor,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 4,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text('${d.maxTemp.round()}°',
                style: AppTypography.label(AppColors.textWhite).copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
