import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../theme/app_typography.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../subscription/premium_screen.dart';

/// شاشة "خطط يومك" — نفس منطق تخطيط الرحلة الموجود بالمساعد الذكي (يسحب أماكن
/// حقيقية من قاعدة البيانات ويبني جدول زمني)، بس بواجهة مخصّصة وظاهرة للمستخدم
/// (نموذج بسيط + نتيجة منسّقة) بدل ما يحتاج يكتشف إنه لازم يكتبها بالشات.
class DayPlannerScreen extends StatefulWidget {
  const DayPlannerScreen({super.key});

  @override
  State<DayPlannerScreen> createState() => _DayPlannerScreenState();
}

class _DayPlannerScreenState extends State<DayPlannerScreen> {
  final TextEditingController _budgetController = TextEditingController();
  bool _loading = false;
  String? _result;
  String? _error;
  bool _quotaExceeded = false;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _plan() async {
    final app = AppState.instance;
    setState(() {
      _loading = true;
      _result = null;
      _error = null;
      _quotaExceeded = false;
    });

    final budget = _budgetController.text.trim();
    // بنبني الرسالة بصيغة ثابتة نعرف إنها بتفعّل كشف "تخطيط رحلة" بالباكند
    // دايمًا (مش معتمدين على المستخدم يكتب صياغة معيّنة بنفسه).
    final message = budget.isEmpty
        ? 'خطط لي يوم بنابلس'
        : 'خطط لي يوم بنابلس بميزانية $budget شيكل';

    final lang = app.isArabic ? 'ar' : 'en';
    final result = await ApiService.askAiAssistant(
      message,
      lang: lang,
      token: AuthService.instance.userToken,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['ok'] == true) {
        _result = (app.isArabic ? result['textAr'] : result['textEn']) as String?;
      } else if (result['quotaExceeded'] == true) {
        _quotaExceeded = true;
        _error = (result['error'] as String?) ??
            app.t('وصلتِ حد الاستخدام المجاني اليوم', "You've hit today's free usage limit");
      } else {
        _error = app.t(
          'تعذّر التخطيط الآن — تأكدي إنه في اتصال بالسيرفر وحاولي بعد شوي',
          'Could not plan right now — make sure the server is reachable and try again',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: AppColors.sidebarDark,
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Icon(Icons.arrow_back, color: AppColors.textWhite),
                    ),
                    SizedBox(width: 12),
                    Text(
                      app.t('خطط يومك بنابلس', 'Plan Your Day in Nablus'),
                      textDirection: app.dir,
                      style: AppTypography.title(AppColors.textWhite),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: AppColors.primaryGradient),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.explore_rounded, color: Colors.white, size: 30),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                app.t(
                                  'بنبني لك برنامج يوم كامل من أماكن حقيقية بالتطبيق (مطاعم، معالم، تسوق) مرتبة بجدول زمني منطقي.',
                                  "We'll build you a full day itinerary from real places in the app (restaurants, attractions, shopping), organized on a logical schedule.",
                                ),
                                textDirection: app.dir,
                                style: TextStyle(color: Colors.white, fontSize: 12.5, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        app.t('ميزانيتك التقريبية بالشيكل (اختياري)', 'Your rough budget in ILS (optional)'),
                        textDirection: app.dir,
                        style: AppTypography.label(AppColors.textGrey),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        textDirection: app.dir,
                        style: TextStyle(color: AppColors.textWhite),
                        decoration: InputDecoration(
                          hintText: app.t('مثلاً 100', 'e.g. 100'),
                          hintStyle: TextStyle(color: AppColors.textGrey),
                          filled: true,
                          fillColor: AppColors.cardDark,
                          prefixIcon: Icon(Icons.payments_outlined, color: AppColors.textGrey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: BorderSide(color: AppColors.borderColor),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _plan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: _loading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  app.t('خطط يومي', 'Plan My Day'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                      if (_error != null) ...[
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _error!,
                                textDirection: app.dir,
                                style: TextStyle(color: AppColors.red),
                              ),
                              if (_quotaExceeded) ...[
                                SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const PremiumScreen()),
                                  ),
                                  icon: Icon(Icons.workspace_premium_rounded, size: 18, color: AppColors.gold),
                                  label: Text(
                                    app.t('اشتركي بالبريميوم', 'Subscribe to Premium'),
                                    style: TextStyle(color: AppColors.gold),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (_result != null) ...[
                        SizedBox(height: 24),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(Icons.map_rounded, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              app.t('برنامجك اليومي', 'Your Itinerary'),
                              textDirection: app.dir,
                              style: AppTypography.headline(AppColors.textWhite).copyWith(fontSize: 17),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.borderColor),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Text(
                            _result!,
                            textDirection: app.dir,
                            style: TextStyle(color: AppColors.textWhite, fontSize: 14, height: 1.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
