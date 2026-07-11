import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../theme/app_typography.dart';

/// هيكل عام لصفحات المعلومات الثابتة (من نحن، سياسة الخصوصية، الشروط، الأسئلة الشائعة).
class InfoScaffold extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  final IconData icon;
  final Widget child;

  const InfoScaffold({
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.sidebarDark, AppColors.cardDark2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
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
                          child: Icon(icon, color: Colors.white, size: 16),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            app.t(titleAr, titleEn),
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
      padding: EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    app.t(titleAr, titleEn),
                    textDirection: app.dir,
                    style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              app.t(bodyAr, bodyEn),
              textDirection: app.dir,
              textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
              style: AppTypography.body(AppColors.textGrey).copyWith(fontSize: 13, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
