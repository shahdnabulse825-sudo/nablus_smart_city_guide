import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors

/// هيكل عام لصفحات المعلومات الثابتة (من نحن، سياسة الخصوصية، الشروط، الأسئلة الشائعة).
class InfoScaffold extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  final IconData icon;
  final Widget child;

  InfoScaffold({
    super.key,
    required this.titleAr,
    required this.titleEn,
    required this.icon,
    required this.child,
  });

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
                        Icon(icon, color: AppColors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(app.t(titleAr, titleEn),
                            textDirection: app.dir,
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 720),
                        child: child,
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
}

/// عنوان فرعي + فقرة نصية داخل صفحة معلومات.
class InfoSection extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  const InfoSection({
    super.key,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Padding(
      padding: EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(app.t(titleAr, titleEn),
              textDirection: app.dir,
              style: TextStyle(
                  color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(app.t(bodyAr, bodyEn),
              textDirection: app.dir,
              textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.7)),
        ],
      ),
    );
  }
}
