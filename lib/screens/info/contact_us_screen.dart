import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../services/feedback_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_typography.dart';

/// شاشة تواصل حقيقية: أي رسالة تُرسل هون بتوصل فعليًا كإشعار عند الأدمن.
class ContactUsScreen extends StatefulWidget {
  final String? relatedPlaceAr;
  final String? relatedPlaceEn;
  const ContactUsScreen({super.key, this.relatedPlaceAr, this.relatedPlaceEn});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  String type = 'question';
  bool sending = false;
  bool sent = false;

  @override
  void initState() {
    super.initState();
    final auth = AuthService.instance;
    if (auth.currentUserName != null) nameController.text = auth.currentUserName!;
    if (auth.currentUserEmail != null) emailController.text = auth.currentUserEmail!;
    if (widget.relatedPlaceEn != null) type = 'issue';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final app = AppState.instance;
    if (nameController.text.trim().isEmpty || messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.t('الرجاء تعبئة الاسم والرسالة', 'Please fill in your name and message'))),
      );
      return;
    }
    setState(() => sending = true);
    await FeedbackService.instance.submit(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      type: type,
      message: messageController.text.trim(),
      relatedPlace: app.isArabic ? widget.relatedPlaceAr : (widget.relatedPlaceEn ?? widget.relatedPlaceAr),
    );
    if (!mounted) return;
    setState(() {
      sending = false;
      sent = true;
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
                          child: Icon(Icons.headset_mic_rounded, color: Colors.white, size: 16),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(app.t('تواصل معنا', 'Contact Us'),
                              textDirection: app.dir,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 480),
                          child: sent ? _successView(app) : _formView(app),
                        ),
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

  Widget _successView(AppState app) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle_rounded, color: AppColors.green, size: 44),
        ),
        SizedBox(height: 20),
        Text(app.t('تم إرسال رسالتك بنجاح!', 'Your message was sent successfully!'),
            textAlign: TextAlign.center,
            textDirection: app.dir,
            style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 16)),
        SizedBox(height: 6),
        Text(
            app.t('راح يوصل فريقنا ويتابع معك قريبًا.',
                'Our team will receive it and follow up with you soon.'),
            textAlign: TextAlign.center,
            textDirection: app.dir,
            style: AppTypography.body(AppColors.textGrey).copyWith(fontSize: 13)),
        SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppColors.glowShadow,
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: Text(app.t('العودة', 'Back'), style: AppTypography.title(Colors.white).copyWith(fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _formView(AppState app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.relatedPlaceAr != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
                app.t('بخصوص: ${widget.relatedPlaceAr}',
                    'Regarding: ${widget.relatedPlaceEn ?? widget.relatedPlaceAr}'),
                textDirection: app.dir,
                style: AppTypography.caption(AppColors.primary).copyWith(fontSize: 12)),
          ),
          SizedBox(height: 16),
        ],
        Text(app.t('نوع الرسالة', 'Message type'),
            textDirection: app.dir, style: AppTypography.caption(AppColors.textGrey)),
        SizedBox(height: 8),
        Row(
          children: [
            _typeChip('question', Icons.help_outline_rounded, app.t('استفسار', 'Question')),
            SizedBox(width: 8),
            _typeChip('suggestion', Icons.lightbulb_outline_rounded, app.t('اقتراح', 'Suggestion')),
            SizedBox(width: 8),
            _typeChip('issue', Icons.report_problem_outlined, app.t('بلاغ', 'Report')),
          ],
        ),
        SizedBox(height: 18),
        Text(app.t('الاسم', 'Name'),
            textDirection: app.dir, style: AppTypography.caption(AppColors.textGrey)),
        SizedBox(height: 6),
        _field(controller: nameController),
        SizedBox(height: 14),
        Text(app.t('البريد الإلكتروني (اختياري)', 'Email (optional)'),
            textDirection: app.dir, style: AppTypography.caption(AppColors.textGrey)),
        SizedBox(height: 6),
        _field(controller: emailController),
        SizedBox(height: 14),
        Text(app.t('رسالتك', 'Your message'),
            textDirection: app.dir, style: AppTypography.caption(AppColors.textGrey)),
        SizedBox(height: 6),
        _field(controller: messageController, maxLines: 5),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppColors.glowShadow,
            ),
            child: ElevatedButton(
              onPressed: sending ? null : _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: sending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(app.t('إرسال', 'Send'), style: AppTypography.title(Colors.white).copyWith(fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _typeChip(String value, IconData icon, String label) {
    final selected = type == value;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => type = value),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? LinearGradient(colors: AppColors.primaryGradient) : null,
            color: selected ? null : AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: selected ? Colors.transparent : AppColors.borderColor),
            boxShadow: selected ? AppColors.glowShadow : null,
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: selected ? Colors.white : AppColors.textGrey),
              SizedBox(height: 4),
              Text(label,
                  style: AppTypography.caption(selected ? Colors.white : AppColors.textWhite)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({required TextEditingController controller, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTypography.body(AppColors.textWhite),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }
}
