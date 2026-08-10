import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../theme/app_typography.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'fake_payment_screen.dart';

/// شاشة "الاشتراك المميز" — ثلاث اشتراكات منفصلة (à la carte) للمساعد الذكي،
/// كل وحدة تُشترى لحالها بسعرها: أسئلة نصية غير محدودة (بيفتح كمان حد مخطط
/// الرحلة وراوي الجولات لأنهم بيستخدموا نفس الحصة)، استماع صوتي غير محدود،
/// وأولوية استجابة (نموذج أقوى بكل الأسئلة). الدفع نفسه وهمي بالكامل (شاشة
/// FakePaymentScreen) لأنه ما في بوابة دفع حقيقية بهذا المشروع الأكاديمي.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _loading = true;
  Map<String, dynamic>? _status;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final token = AuthService.instance.userToken;
    if (token == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final status = await ApiService.getSubscriptionStatus(token);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _status = status;
    });
    if (status != null) {
      AuthService.instance.premiumText = status['premiumText'] as bool? ?? false;
      AuthService.instance.premiumVoice = status['premiumVoice'] as bool? ?? false;
      AuthService.instance.premiumPriority = status['premiumPriority'] as bool? ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final loggedIn = AuthService.instance.userToken != null;
    final textUsed = _status?['textUsedToday'] as int? ?? 0;
    final textLimit = _status?['textLimit'] as int? ?? 10;
    final voiceUsed = _status?['voiceUsedToday'] as int? ?? 0;
    final voiceLimit = _status?['voiceLimit'] as int? ?? 3;
    final prices = (_status?['prices'] as Map?)?.cast<String, dynamic>();

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
                      app.t('الاشتراك المميز', 'Premium Subscription'),
                      textDirection: app.dir,
                      style: AppTypography.title(AppColors.textWhite),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: !loggedIn
                    ? _GuestNotice(app: app)
                    : _loading
                        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : SingleChildScrollView(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  app.t(
                                    'اختاري الميزة اللي بدك تفتحيها بدون حد — كل وحدة اشتراك منفصل بسعرها الخاص.',
                                    'Pick the feature you want unlocked — each is a separate subscription with its own price.',
                                  ),
                                  textDirection: app.dir,
                                  style: TextStyle(color: AppColors.textGrey, fontSize: 12.5, height: 1.6),
                                ),
                                SizedBox(height: 18),
                                _FeatureCard(
                                  app: app,
                                  icon: Icons.chat_bubble_rounded,
                                  color: AppColors.blue,
                                  titleAr: 'أسئلة نصية غير محدودة',
                                  titleEn: 'Unlimited text questions',
                                  descAr:
                                      'بدون حد الـ$textLimit أسئلة اليومي — وبيفتح كمان استخدام غير محدود لمخطط الرحلة وراوي الجولات (بتستخدم نفس الحصة).',
                                  descEn:
                                      'No more daily limit of $textLimit questions — also unlocks unlimited use of the day planner and tour narrator (they share the same quota).',
                                  price: (prices?['text'] as num?) ?? 20,
                                  active: AuthService.instance.premiumText,
                                  usageLabel: app.t('$textUsed/$textLimit اليوم', '$textUsed/$textLimit today'),
                                  featureKey: 'text',
                                  onChanged: _refresh,
                                ),
                                SizedBox(height: 14),
                                _FeatureCard(
                                  app: app,
                                  icon: Icons.volume_up_rounded,
                                  color: AppColors.teal,
                                  titleAr: 'استماع صوتي غير محدود',
                                  titleEn: 'Unlimited voice playback',
                                  descAr: 'بدون حد الـ$voiceLimit استماعات اليومي لقصص راوي الجولات.',
                                  descEn: 'No more daily limit of $voiceLimit listens for tour narrator stories.',
                                  price: (prices?['voice'] as num?) ?? 30,
                                  active: AuthService.instance.premiumVoice,
                                  usageLabel: app.t('$voiceUsed/$voiceLimit اليوم', '$voiceUsed/$voiceLimit today'),
                                  featureKey: 'voice',
                                  onChanged: _refresh,
                                ),
                                SizedBox(height: 14),
                                _FeatureCard(
                                  app: app,
                                  icon: Icons.bolt_rounded,
                                  color: AppColors.gold,
                                  titleAr: 'أولوية الاستجابة',
                                  titleEn: 'Response priority',
                                  descAr: 'كل أسئلتك بتترد عليها بالنموذج الأقوى (مش بس تخطيط الرحلة والرواية).',
                                  descEn: 'All your questions get answered by the stronger model (not just trip planning and narration).',
                                  price: (prices?['priority'] as num?) ?? 25,
                                  active: AuthService.instance.premiumPriority,
                                  usageLabel: null,
                                  featureKey: 'priority',
                                  onChanged: _refresh,
                                ),
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

class _GuestNotice extends StatelessWidget {
  final AppState app;
  const _GuestNotice({required this.app});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, color: AppColors.textGrey, size: 42),
            SizedBox(height: 14),
            Text(
              app.t(
                'سجّلي دخول بحساب حقيقي حتى تقدري تشتركي بالبريميوم وتتبعي استخدامك',
                'Log in with a real account to subscribe to Premium and track your usage',
              ),
              textAlign: TextAlign.center,
              textDirection: app.dir,
              style: TextStyle(color: AppColors.textGrey, fontSize: 13.5, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final AppState app;
  final IconData icon;
  final Color color;
  final String titleAr;
  final String titleEn;
  final String descAr;
  final String descEn;
  final num price;
  final bool active;
  final String? usageLabel;
  final String featureKey;
  final VoidCallback onChanged;

  const _FeatureCard({
    required this.app,
    required this.icon,
    required this.color,
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
    required this.price,
    required this.active,
    required this.usageLabel,
    required this.featureKey,
    required this.onChanged,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _actionLoading = false;

  Future<void> _subscribe() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => FakePaymentScreen(
          featureKey: widget.featureKey,
          titleAr: widget.titleAr,
          titleEn: widget.titleEn,
          price: widget.price,
        ),
      ),
    );
    if (result == true) widget.onChanged();
  }

  Future<void> _cancel() async {
    final token = AuthService.instance.userToken;
    if (token == null) return;
    setState(() => _actionLoading = true);
    final result = await ApiService.cancelFeature(token, widget.featureKey);
    if (!mounted) return;
    setState(() => _actionLoading = false);
    if (result != null) widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: widget.active ? widget.color.withValues(alpha: 0.5) : AppColors.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.t(widget.titleAr, widget.titleEn),
                      textDirection: app.dir,
                      style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (!widget.active && widget.usageLabel != null)
                      Text(
                        widget.usageLabel!,
                        style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                      ),
                  ],
                ),
              ),
              if (widget.active)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    app.t('مفعّل ✅', 'Active ✅'),
                    style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                )
              else
                Text(
                  app.t('${widget.price} ₪/شهر', '${widget.price} ILS/mo'),
                  style: TextStyle(color: widget.color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            app.t(widget.descAr, widget.descEn),
            textDirection: app.dir,
            style: TextStyle(color: AppColors.textGrey, fontSize: 11.5, height: 1.5),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: widget.active
                ? OutlinedButton(
                    onPressed: _actionLoading ? null : _cancel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.red.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    child: _actionLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2),
                          )
                        : Text(
                            app.t('إلغاء الاشتراك', 'Cancel Subscription'),
                            style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                  )
                : ElevatedButton(
                    onPressed: _subscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    child: Text(
                      app.t('اشتركي', 'Subscribe'),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
