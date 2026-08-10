import 'package:flutter/material.dart';
import 'home_screen.dart'; // لإعادة استخدام AppState و AppColors
import 'quick_info_section.dart';
import '../nearby/nearby_places_screen.dart';
import '../restaurants/restaurants_screen.dart';
import '../transport/transport_screen.dart';
import '../weather/weather_screen.dart';
import '../ai_assistant/day_planner_screen.dart';
import '../attractions/tour_narrator_screen.dart';
import '../subscription/premium_screen.dart';
import '../../widgets/responsive.dart';

/// صف إجراءات سريعة أفقي أسفل شريط البحث — اختصارات لأكثر الأشياء استخدامًا
/// (أقرب مكان، أفضل مطعم، أوقات الصلاة، تكسي، طوارئ، طقس) بدل ما يضطر
/// المستخدم يتنقل بين أقسام كتير للوصول لها.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.near_me_rounded,
        color: AppColors.blue,
        labelAr: 'أقرب مكان',
        labelEn: 'Nearby',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => NearbyPlacesScreen())),
      ),
      _QuickAction(
        icon: Icons.restaurant_rounded,
        color: AppColors.vividOrange,
        labelAr: 'أفضل مطعم',
        labelEn: 'Top Food',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => RestaurantsScreen())),
      ),
      _QuickAction(
        icon: Icons.mosque_rounded,
        color: AppColors.teal,
        labelAr: 'أوقات الصلاة',
        labelEn: 'Prayer',
        onTap: () => showPrayerTimesSheet(context),
      ),
      _QuickAction(
        icon: Icons.local_taxi_rounded,
        color: AppColors.skyBlue,
        labelAr: 'اطلب تكسي',
        labelEn: 'Taxi',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => TransportScreen())),
      ),
      _QuickAction(
        icon: Icons.emergency_rounded,
        color: AppColors.red,
        labelAr: 'الطوارئ',
        labelEn: 'Emergency',
        onTap: () => showEmergencySheet(context),
      ),
      _QuickAction(
        icon: Icons.wb_sunny_rounded,
        color: AppColors.gold,
        labelAr: 'الطقس',
        labelEn: 'Weather',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => WeatherScreen())),
      ),
      _QuickAction(
        icon: Icons.explore_rounded,
        color: AppColors.purple,
        labelAr: 'خطط يومك',
        labelEn: 'Plan Day',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => DayPlannerScreen())),
      ),
      _QuickAction(
        icon: Icons.auto_stories_rounded,
        color: AppColors.coral,
        labelAr: 'راوي الجولات',
        labelEn: 'Tour Narrator',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => TourNarratorScreen())),
      ),
      _QuickAction(
        icon: Icons.workspace_premium_rounded,
        color: AppColors.gold,
        labelAr: 'بريميوم',
        labelEn: 'Premium',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const PremiumScreen())),
      ),
    ];
    if (!isMobile(context)) {
      // بعرض الديسكتوب الأيقونات الستة بتضل مرتاحة بعرض الصفحة، فبنوسّطها
      // بدل ما تتلزّق على جهة واحدة وتخلي فراغ فاضي جنبها.
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final a in actions) ...[a, SizedBox(width: 22)],
          ]..removeLast(),
        ),
      );
    }
    return SizedBox(
      height: 92,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
        scrollDirection: Axis.horizontal,
        children: [
          for (final a in actions) ...[a, SizedBox(width: 14)],
        ],
      ),
    );
  }
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String labelAr;
  final String labelEn;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.labelAr,
    required this.labelEn,
    required this.onTap,
  });

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _hovering ? 1.06 : 1.0,
          child: SizedBox(
            width: 74,
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 24),
                ),
                SizedBox(height: 6),
                Text(
                  app.t(widget.labelAr, widget.labelEn),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: app.dir,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
