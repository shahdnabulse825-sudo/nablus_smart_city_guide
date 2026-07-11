import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../services/auth_service.dart';
import '../../services/feedback_service.dart';
import '../../theme/app_typography.dart';

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

final List<NotificationItem> _visitorNotifications = [
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
    bodyEn:
        '"Al-Bait Al-Nabulsi Restaurant" was added to featured restaurants.',
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

Map<String, IconData> _feedbackIcon = {
  'issue': Icons.report_problem_outlined,
  'suggestion': Icons.lightbulb_outline,
  'question': Icons.help_outline,
};

Map<String, Color> _feedbackColor = {
  'issue': Color(0xFFE85D5D),
  'suggestion': Color(0xFF22C55E),
  'question': Color(0xFF3B82F6),
};

Map<String, String> _feedbackLabelAr = {
  'issue': 'بلاغ',
  'suggestion': 'اقتراح',
  'question': 'استفسار',
};
Map<String, String> _feedbackLabelEn = {
  'issue': 'Report',
  'suggestion': 'Suggestion',
  'question': 'Question',
};

int get visitorUnreadCount =>
    _visitorNotifications.where((n) => !n.read).length;

String _relativeTime(DateTime time, bool arabic) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return arabic ? 'الآن' : 'Just now';
  if (diff.inMinutes < 60) {
    return arabic ? 'قبل ${diff.inMinutes} دقيقة' : '${diff.inMinutes} min ago';
  }
  if (diff.inHours < 24) {
    return arabic ? 'قبل ${diff.inHours} ساعة' : '${diff.inHours} hours ago';
  }
  return arabic ? 'قبل ${diff.inDays} يوم' : '${diff.inDays} days ago';
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final isAdmin = AuthService.instance.isAdmin;
    final feedbackList = isAdmin ? FeedbackService.instance.getAll() : <FeedbackMessage>[];
    final unreadCount = isAdmin
        ? feedbackList.where((f) => !f.read).length
        : _visitorNotifications.where((n) => !n.read).length;

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
                          child: Icon(Icons.notifications_rounded, color: Colors.white, size: 16),
                        ),
                        SizedBox(width: 10),
                        Text(
                          isAdmin
                              ? app.t('رسائل الزوار', 'Visitor Messages')
                              : app.t('الإشعارات', 'Notifications'),
                          textDirection: app.dir,
                          style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 16),
                        ),
                        Spacer(),
                        if (unreadCount > 0)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              if (isAdmin) {
                                await FeedbackService.instance.markAllRead();
                              } else {
                                for (final n in _visitorNotifications) {
                                  n.read = true;
                                }
                              }
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                app.t('تعليم الكل كمقروء', 'Mark all as read'),
                                style: AppTypography.label(AppColors.primary),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: isAdmin
                        ? (feedbackList.isEmpty
                            ? _emptyState(app)
                            : ListView.separated(
                                padding: EdgeInsets.all(16),
                                itemCount: feedbackList.length,
                                separatorBuilder: (_, _) => SizedBox(height: 10),
                                itemBuilder: (context, i) =>
                                    _feedbackTile(app, feedbackList[i]),
                              ))
                        : ListView.separated(
                            padding: EdgeInsets.all(16),
                            itemCount: _visitorNotifications.length,
                            separatorBuilder: (_, _) => SizedBox(height: 10),
                            itemBuilder: (context, i) =>
                                _visitorTile(app, _visitorNotifications[i]),
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

  Widget _emptyState(AppState app) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, color: AppColors.textGrey, size: 40),
          SizedBox(height: 12),
          Text(app.t('ما في رسائل من الزوار بعد', 'No visitor messages yet'),
              style: TextStyle(color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _feedbackTile(AppState app, FeedbackMessage f) {
    final color = _feedbackColor[f.type] ?? AppColors.primary;
    final icon = _feedbackIcon[f.type] ?? Icons.mail_outline;
    final typeLabel = app.isArabic ? _feedbackLabelAr[f.type] : _feedbackLabelEn[f.type];
    return AppCard(
      padding: EdgeInsets.all(12),
      color: f.read ? AppColors.cardDark : AppColors.primary.withValues(alpha: 0.08),
      border: Border.all(
          color: f.read ? AppColors.borderColor : AppColors.primary.withValues(alpha: 0.4)),
      onTap: () async {
        await FeedbackService.instance.markRead(f.key);
        if (!mounted) return;
        setState(() {});
        _showFeedbackDetail(app, f);
      },
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    if (!f.read) ...[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text('$typeLabel — ${f.name}',
                          textDirection: app.dir,
                          style: AppTypography.label(AppColors.textWhite).copyWith(fontSize: 13)),
                    ),
                  ],
                ),
                if (f.relatedPlace != null) ...[
                  SizedBox(height: 2),
                  Text(app.t('بخصوص: ${f.relatedPlace}', 'Regarding: ${f.relatedPlace}'),
                      textDirection: app.dir,
                      style: AppTypography.caption(AppColors.primary)),
                ],
                SizedBox(height: 4),
                Text(f.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: app.dir,
                    textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                    style: AppTypography.body(AppColors.textGrey).copyWith(fontSize: 12)),
                SizedBox(height: 6),
                Text(_relativeTime(f.createdAt, app.isArabic),
                    style: AppTypography.caption(AppColors.textGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDetail(AppState app, FeedbackMessage f) {
    final typeLabel = app.isArabic ? _feedbackLabelAr[f.type] : _feedbackLabelEn[f.type];
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: app.dir,
        child: AlertDialog(
          backgroundColor: AppColors.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('$typeLabel — ${f.name}',
              textDirection: app.dir,
              style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (f.email.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(f.email, style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ),
              if (f.relatedPlace != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(app.t('بخصوص: ${f.relatedPlace}', 'Regarding: ${f.relatedPlace}'),
                      textDirection: app.dir,
                      style: TextStyle(color: AppColors.primary, fontSize: 12)),
                ),
              Text(f.message,
                  textDirection: app.dir,
                  textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(color: AppColors.textWhite, fontSize: 13, height: 1.5)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FeedbackService.instance.delete(f.key);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text(app.t('حذف', 'Delete'), style: TextStyle(color: AppColors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(app.t('إغلاق', 'Close'), style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visitorTile(AppState app, NotificationItem n) {
    final title = app.isArabic ? n.titleAr : n.titleEn;
    final body = app.isArabic ? n.bodyAr : n.bodyEn;
    final time = app.isArabic ? n.timeAr : n.timeEn;
    return AppCard(
      padding: EdgeInsets.all(12),
      color: n.read ? AppColors.cardDark : AppColors.primary.withValues(alpha: 0.08),
      border: Border.all(
          color: n.read ? AppColors.borderColor : AppColors.primary.withValues(alpha: 0.4)),
      onTap: () => setState(() => n.read = true),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [n.color, n.color.withValues(alpha: 0.7)]),
              shape: BoxShape.circle,
            ),
            child: Icon(n.icon, color: Colors.white, size: 18),
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
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(title,
                          textDirection: app.dir,
                          style: AppTypography.label(AppColors.textWhite).copyWith(fontSize: 13)),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(body,
                    textDirection: app.dir,
                    textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                    style: AppTypography.body(AppColors.textGrey).copyWith(fontSize: 12)),
                SizedBox(height: 6),
                Text(time, style: AppTypography.caption(AppColors.textGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
