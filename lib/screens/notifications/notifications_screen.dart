import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors

class NotificationItem {
  final IconData icon;
  final Color color;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final String timeAr;
  final String timeEn;
  bool read;

  NotificationItem({
    required this.icon,
    required this.color,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.timeAr,
    required this.timeEn,
    this.read = false,
  });
}

final List<NotificationItem> _notifications = [
  NotificationItem(
    icon: Icons.event,
    color: Color(0xFF6C5CE7),
    titleAr: 'فعالية جديدة قريبًا',
    titleEn: 'New upcoming event',
    bodyAr: 'مهرجان التسوق السنوي يبدأ يوم 15 يونيو في مركز المدينة.',
    bodyEn: 'The Annual Shopping Festival starts June 15 at City Center.',
    timeAr: 'قبل ساعة',
    timeEn: '1 hour ago',
  ),
  NotificationItem(
    icon: Icons.restaurant,
    color: Color(0xFFE85D5D),
    titleAr: 'مكان جديد أُضيف',
    titleEn: 'New place added',
    bodyAr: 'انضم "مطعم البيت النابلسي" إلى قائمة المطاعم المميزة.',
    bodyEn: '"Al-Bait Al-Nabulsi Restaurant" was added to featured restaurants.',
    timeAr: 'قبل 3 ساعات',
    timeEn: '3 hours ago',
    read: true,
  ),
  NotificationItem(
    icon: Icons.local_offer,
    color: Color(0xFF22C55E),
    titleAr: 'عرض خاص',
    titleEn: 'Special offer',
    bodyAr: 'خصم 20% على الإقامة في فندق قصر نابلس هذا الأسبوع.',
    bodyEn: '20% discount on stays at Nablus Palace Hotel this week.',
    timeAr: 'أمس',
    timeEn: 'Yesterday',
  ),
  NotificationItem(
    icon: Icons.article,
    color: Color(0xFF3B82F6),
    titleAr: 'خبر جديد',
    titleEn: 'News update',
    bodyAr: 'نابلس تستضيف المؤتمر السياحي الدولي الأسبوع القادم.',
    bodyEn: 'Nablus hosts the International Tourism Conference next week.',
    timeAr: 'قبل يومين',
    timeEn: '2 days ago',
    read: true,
  ),
  NotificationItem(
    icon: Icons.wb_sunny,
    color: Color(0xFFF5A623),
    titleAr: 'تنبيه الطقس',
    titleEn: 'Weather alert',
    bodyAr: 'أجواء مشمسة ومعتدلة اليوم، مناسبة لزيارة البلدة القديمة.',
    bodyEn: 'Sunny, mild weather today — a good day to visit the Old City.',
    timeAr: 'قبل يومين',
    timeEn: '2 days ago',
    read: true,
  ),
];

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final unreadCount = _notifications.where((n) => !n.read).length;
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
                        Icon(Icons.notifications, color: AppColors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(app.t('الإشعارات', 'Notifications'),
                            textDirection: app.dir,
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Spacer(),
                        if (unreadCount > 0)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() {
                              for (final n in _notifications) {
                                n.read = true;
                              }
                            }),
                            child: Text(app.t('تعليم الكل كمقروء', 'Mark all as read'),
                                style: TextStyle(color: AppColors.blue, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final n = _notifications[i];
                        final title = app.isArabic ? n.titleAr : n.titleEn;
                        final body = app.isArabic ? n.bodyAr : n.bodyEn;
                        final time = app.isArabic ? n.timeAr : n.timeEn;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => n.read = true),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: n.read ? AppColors.cardDark : AppColors.blue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: n.read ? AppColors.borderColor : AppColors.blue.withOpacity(0.4)),
                            ),
                            child: Row(
                              textDirection: TextDirection.rtl,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: n.color.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(n.icon, color: n.color, size: 18),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        textDirection: TextDirection.rtl,
                                        children: [
                                          if (!n.read) ...[
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                  color: AppColors.blue, shape: BoxShape.circle),
                                            ),
                                            SizedBox(width: 6),
                                          ],
                                          Expanded(
                                            child: Text(title,
                                                textDirection: app.dir,
                                                style: TextStyle(
                                                    color: AppColors.textWhite,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(body,
                                          textDirection: app.dir,
                                          textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                                          style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                      SizedBox(height: 6),
                                      Text(time,
                                          style: TextStyle(color: AppColors.textGrey, fontSize: 10)),
                                    ],
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
