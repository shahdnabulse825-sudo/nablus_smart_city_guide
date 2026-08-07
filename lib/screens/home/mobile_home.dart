import 'package:flutter/material.dart';
import 'home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../explore/explore_screen.dart';
import '../map/map_screen.dart';
import '../news/news_screen.dart';
import '../ai_assistant/ai_assistant_screen.dart';

/// شريط تنقل سفلي مخصّص لعرض الهاتف — بديل عن شريط التنقل العلوي المزدحم
/// (نفس فكرة تطبيقات الأندرويد الحديثة: Home / Explore / Map / News / AI).
class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final items = <_NavDest>[
      _NavDest(
        icon: Icons.home_rounded,
        labelAr: 'الرئيسية',
        labelEn: 'Home',
        active: true,
      ),
      _NavDest(
        icon: Icons.explore_rounded,
        labelAr: 'استكشف',
        labelEn: 'Explore',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => ExploreScreen())),
      ),
      _NavDest(
        icon: Icons.map_rounded,
        labelAr: 'الخريطة',
        labelEn: 'Map',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => MapScreen())),
      ),
      _NavDest(
        icon: Icons.article_rounded,
        labelAr: 'الأخبار',
        labelEn: 'News',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => NewsScreen())),
      ),
      _NavDest(
        icon: Icons.auto_awesome_rounded,
        labelAr: 'المساعد',
        labelEn: 'AI',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => AiAssistantScreen())),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.sidebarDark,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: items
                .map((d) => Expanded(child: _NavDestButton(dest: d, app: app)))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _NavDest {
  final IconData icon;
  final String labelAr;
  final String labelEn;
  final bool active;
  final VoidCallback? onTap;
  _NavDest({
    required this.icon,
    required this.labelAr,
    required this.labelEn,
    this.active = false,
    this.onTap,
  });
}

class _NavDestButton extends StatelessWidget {
  final _NavDest dest;
  final AppState app;
  const _NavDestButton({required this.dest, required this.app});

  @override
  Widget build(BuildContext context) {
    final color = dest.active ? AppColors.primary : AppColors.textGrey;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: dest.onTap,
        // لمسة لمس لا تقل عن 48dp حسب مبادئ Material 3
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(dest.icon, color: color, size: 22),
              SizedBox(height: 3),
              Text(
                app.t(dest.labelAr, dest.labelEn),
                textDirection: app.dir,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: dest.active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
