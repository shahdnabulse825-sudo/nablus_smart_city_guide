import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../theme/app_typography.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

/// شاشة دفع وهمية بالكامل — ما في بوابة دفع حقيقية (Stripe/PayPal) بهذا
/// المشروع الأكاديمي، فبتقبل أي بيانات بطاقة شكليًا (بس بتتحقق من صيغتها
/// كإدخال) وتفعّل ميزة الاشتراك المحددة ([featureKey]) مباشرة عبر السيرفر،
/// لغرض العرض التوضيحي فقط. كل ميزة (نص/صوت/أولوية) تُشترى لحالها بسعرها.
class FakePaymentScreen extends StatefulWidget {
  final String featureKey; // 'text' | 'voice' | 'priority'
  final String titleAr;
  final String titleEn;
  final num price;

  const FakePaymentScreen({
    super.key,
    required this.featureKey,
    required this.titleAr,
    required this.titleEn,
    required this.price,
  });

  @override
  State<FakePaymentScreen> createState() => _FakePaymentScreenState();
}

class _FakePaymentScreenState extends State<FakePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _confirmPayment() async {
    final app = AppState.instance;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final token = AuthService.instance.userToken;
    if (token == null) return;

    setState(() => _loading = true);
    final result = await ApiService.subscribeToFeature(token, widget.featureKey);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            app.t('تعذّر إتمام الاشتراك — تأكدي إنه في اتصال بالسيرفر وحاولي بعد شوي',
                'Could not complete the subscription — make sure the server is reachable and try again'),
          ),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    switch (widget.featureKey) {
      case 'text':
        AuthService.instance.premiumText = true;
        break;
      case 'voice':
        AuthService.instance.premiumVoice = true;
        break;
      case 'priority':
        AuthService.instance.premiumPriority = true;
        break;
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  String? _requiredValidator(String? v, String message) =>
      (v == null || v.trim().isEmpty) ? message : null;

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
                      app.t('تأكيد الدفع', 'Confirm Payment'),
                      textDirection: app.dir,
                      style: AppTypography.title(AppColors.textWhite),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  app.t(widget.titleAr, widget.titleEn),
                                  textDirection: app.dir,
                                  style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 13.5),
                                ),
                              ),
                              Text(
                                app.t('${widget.price} ₪ / شهريًا', '${widget.price} ILS / month'),
                                style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14),
                        Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  app.t(
                                    'هذا نموذج دفع تجريبي لأغراض العرض التوضيحي فقط — لا يوجد اتصال ببنك حقيقي، لا تُدخلي بيانات بطاقة حقيقية.',
                                    "This is a demo payment form for showcase purposes only — no real bank connection, don't enter real card details.",
                                  ),
                                  textDirection: app.dir,
                                  style: TextStyle(color: AppColors.textWhite, fontSize: 12, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.purple, AppColors.purpleLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.credit_card_rounded, color: Colors.white, size: 30),
                              SizedBox(height: 16),
                              Text(
                                _cardController.text.isEmpty
                                    ? '•••• •••• •••• ••••'
                                    : _cardController.text,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 14),
                              Text(
                                _nameController.text.isEmpty
                                    ? app.t('اسم حامل البطاقة', 'CARDHOLDER NAME')
                                    : _nameController.text.toUpperCase(),
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        _label(app.t('الاسم على البطاقة', 'Name on card')),
                        _field(
                          controller: _nameController,
                          hint: app.t('مثلاً محمد خالد', 'e.g. Mohammad Khaled'),
                          onChanged: (_) => setState(() {}),
                          validator: (v) => _requiredValidator(v, app.t('مطلوب', 'Required')),
                        ),
                        SizedBox(height: 16),
                        _label(app.t('رقم البطاقة', 'Card number')),
                        _field(
                          controller: _cardController,
                          hint: '4242 4242 4242 4242',
                          keyboardType: TextInputType.number,
                          maxLength: 19,
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            final digits = (v ?? '').replaceAll(' ', '');
                            if (digits.length < 12) return app.t('رقم بطاقة غير صحيح', 'Invalid card number');
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label(app.t('تاريخ الانتهاء', 'Expiry')),
                                  _field(
                                    controller: _expiryController,
                                    hint: 'MM/YY',
                                    keyboardType: TextInputType.number,
                                    maxLength: 5,
                                    validator: (v) => _requiredValidator(v, app.t('مطلوب', 'Required')),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('CVV'),
                                  _field(
                                    controller: _cvvController,
                                    hint: '123',
                                    keyboardType: TextInputType.number,
                                    maxLength: 4,
                                    obscureText: true,
                                    validator: (v) =>
                                        (v == null || v.length < 3) ? app.t('غير صحيح', 'Invalid') : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 28),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _confirmPayment,
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
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Text(
                                    app.t('تأكيد الدفع', 'Confirm Payment'),
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppTypography.label(AppColors.textGrey)),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        hintStyle: TextStyle(color: AppColors.textGrey),
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
      ),
    );
  }
}
