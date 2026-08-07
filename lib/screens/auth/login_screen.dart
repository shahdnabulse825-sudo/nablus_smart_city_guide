import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../admin/admin_screen.dart';
import '../../services/auth_service.dart';
import '../../services/favorites_service.dart';
import '../../services/recent_activity_service.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_toggle_bar.dart';
import '../../widgets/responsive.dart';
import '../../services/local_db_service.dart';
import 'sign_up_screen.dart';

// الأقسام يلي فيها "أماكن" فعلية (مش أخبار/فعاليات/صور تصنيفات..) — تُستخدم
// لحساب إحصائية حقيقية بلوحة الهوية بشاشة الدخول بدل رقم وهمي.
const _placeBoxNames = [
  'restaurants',
  'hotels',
  'attractions',
  'shopping',
  'transport',
  'health',
  'pharmacies',
  'education',
  'banks',
  'entertainment',
  'government',
];

int _totalPlacesCount() {
  var total = 0;
  for (final box in _placeBoxNames) {
    total += LocalDbService.instance.getAll(box).length;
  }
  return total;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAdminTab = false;

  // مستخدم عادي
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();
  bool obscureUserPassword = true;

  // أدمن
  final TextEditingController adminUserController = TextEditingController();
  final TextEditingController adminPassController = TextEditingController();
  bool obscurePassword = true;
  String? errorMessage;
  bool isLoading = false;

  @override
  void dispose() {
    userEmailController.dispose();
    userPasswordController.dispose();
    adminUserController.dispose();
    adminPassController.dispose();
    super.dispose();
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });
    await AuthService.instance.continueAsGuest();
    if (!mounted) return;
    setState(() => isLoading = false);
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  Future<void> _loginAsUser() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    final error = await AuthService.instance.login(
      email: userEmailController.text,
      password: userPasswordController.text,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (error == null) {
      if (AuthService.instance.userToken != null) {
        // بالخلفية، بدون تأخير التنقّل — تجيب مفضلة/سجل زيارات الحساب من أجهزة تانية
        FavoritesService.instance.syncWithServer();
        RecentActivityService.instance.syncWithServer();
      }
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      setState(() => errorMessage = error);
    }
  }

  Future<void> _loginAsAdmin() async {
    final user = adminUserController.text.trim();
    final pass = adminPassController.text.trim();
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    final error = await AuthService.instance.loginAsAdminReal(user, pass);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (error == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AdminHomeScreen()),
      );
    } else {
      setState(() => errorMessage = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final showBrandPanel = !isMobile(context);
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: Row(
              children: [
                // ==== لوحة الهوية (شاشات واسعة بس) — نفس مبدأ صفحات الدخول
                // الحديثة: توضيح مرئي كبير + شارات مزايا عائمة بدل نص جاف ====
                if (showBrandPanel) Expanded(flex: 5, child: _brandPanel(app)),
                Expanded(
                  flex: showBrandPanel ? 4 : 1,
                  child: _formPanel(app),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// لوحة الهوية اليسرى: تدرّج ألوان التطبيق الدافئ + شارات مزايا حقيقية
  /// (خريطة تفاعلية، مساعد ذكي، مكان حقيقية) بدل زخرفة عامة بدون معنى.
  Widget _brandPanel(AppState app) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: _blobCircle(220, Colors.white.withValues(alpha: 0.10)),
          ),
          Positioned(
            bottom: -80,
            right: -40,
            child: _blobCircle(260, Colors.black.withValues(alpha: 0.10)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(44, 44, 44, 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.asset(
                        'assets/images/branding/logo_icon.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'NabliGo',
                      style: AppTypography.title(
                        Colors.white,
                      ).copyWith(fontSize: 20, letterSpacing: 0.5),
                    ),
                  ],
                ),
                SizedBox(height: 28),
                // ==== إحصائيات حقيقية (مش أرقام وهمية) — عدد الأماكن الفعلي
                // بقاعدة البيانات المحلية، وعدد الزوار الحقيقي من السيرفر ====
                Row(
                  children: [
                    _statChip(
                      app,
                      icon: Icons.place_rounded,
                      value: '${_totalPlacesCount()}+',
                      labelAr: 'مكان موثّق',
                      labelEn: 'listed places',
                    ),
                    SizedBox(width: 12),
                    if (app.visitorCount != null)
                      _statChip(
                        app,
                        icon: Icons.groups_rounded,
                        value: '${app.visitorCount}',
                        labelAr: 'زائر للتطبيق',
                        labelEn: 'app visitors',
                      ),
                  ],
                ),
                Spacer(),
                _featureBadge(
                  app,
                  icon: Icons.map_rounded,
                  textAr: 'خريطة تفاعلية حقيقية للمدينة',
                  textEn: 'A real interactive city map',
                  alignEnd: false,
                ),
                SizedBox(height: 12),
                _featureBadge(
                  app,
                  icon: Icons.smart_toy_rounded,
                  textAr: 'مساعد ذكي يجاوب بالعربي',
                  textEn: 'AI assistant that answers in Arabic',
                  alignEnd: true,
                ),
                SizedBox(height: 12),
                _featureBadge(
                  app,
                  icon: Icons.storefront_rounded,
                  textAr: 'مئات الأماكن الحقيقية الموثّقة',
                  textEn: 'Hundreds of real, verified places',
                  alignEnd: false,
                ),
                SizedBox(height: 12),
                _featureBadge(
                  app,
                  icon: Icons.language_rounded,
                  textAr: 'دعم كامل بالعربي والإنجليزي',
                  textEn: 'Full Arabic & English support',
                  alignEnd: true,
                ),
                SizedBox(height: 36),
                Text(
                  app.t('اكتشف نابلس بسهولة', 'Discover Nablus with ease'),
                  textDirection: app.dir,
                  style: AppTypography.display(
                    Colors.white,
                  ).copyWith(fontSize: 30),
                ),
                SizedBox(height: 8),
                Text(
                  app.t(
                    'من أول لحظة بتفتح التطبيق، لحد ما توصل لباب المكان — كلنا وياك خطوة بخطوة.',
                    'From the moment you open the app to the moment you arrive — we\'re with you every step.',
                  ),
                  textDirection: app.dir,
                  style: AppTypography.body(
                    Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(
    AppState app, {
    required IconData icon,
    required String value,
    required String labelAr,
    required String labelEn,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: app.dir,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTypography.title(
                  Colors.white,
                ).copyWith(fontSize: 15),
              ),
              Text(
                app.t(labelAr, labelEn),
                style: AppTypography.caption(
                  Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _blobCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _featureBadge(
    AppState app, {
    required IconData icon,
    required String textAr,
    required String textEn,
    required bool alignEnd,
  }) {
    return Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: app.dir,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            SizedBox(width: 8),
            Text(
              app.t(textAr, textEn),
              textDirection: app.dir,
              style: AppTypography.label(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// لوحة النموذج اليمنى: نفس منطق تسجيل الدخول بالضبط (تبويبات مستخدم/أدمن،
  /// الحقول، رسالة الخطأ) بس بمساحتها الخاصة بدل صندوق واحد بنص الشاشة.
  Widget _formPanel(AppState app) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [AppToggleBar()],
                ),
                SizedBox(height: 20),
                Text(
                  app.t('أهلًا فيك 👋', 'Welcome back 👋'),
                  textDirection: app.dir,
                  style: AppTypography.display(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 25),
                ),
                SizedBox(height: 6),
                Text(
                  app.t(
                    'سجّل دخولك للمتابعة لدليل نابلس الذكي',
                    'Sign in to continue to Nablus Smart Guide',
                  ),
                  textDirection: app.dir,
                  style: AppTypography.body(AppColors.textGrey),
                ),
                SizedBox(height: 28),

                // ==== تبويبات: مستخدم عادي / أدمن ====
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _tabButton(
                          label: app.t('مستخدم عادي', 'Regular User'),
                          icon: Icons.person_rounded,
                          active: !isAdminTab,
                          onTap: () => setState(() {
                            isAdminTab = false;
                            errorMessage = null;
                          }),
                        ),
                      ),
                      Expanded(
                        child: _tabButton(
                          label: app.t('أدمن', 'Admin'),
                          icon: Icons.admin_panel_settings_rounded,
                          active: isAdminTab,
                          onTap: () => setState(() {
                            isAdminTab = true;
                            errorMessage = null;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Container(
                    key: ValueKey(isAdminTab),
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.borderColor),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: isAdminTab ? _adminForm(app) : _userForm(app),
                  ),
                ),

                if (errorMessage != null) ...[
                  SizedBox(height: 14),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: AppColors.red.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.red,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            textDirection: app.dir,
                            style: AppTypography.label(
                              AppColors.red,
                            ).copyWith(fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 24),
                Center(
                  child: Text(
                    '© 2026 NabliGo',
                    style: AppTypography.caption(AppColors.textGrey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(colors: AppColors.primaryGradient)
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: active ? AppColors.glowShadow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? Colors.white : AppColors.textGrey,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.label(
                active ? Colors.white : AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userForm(AppState app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.login, color: AppColors.gold, size: 18),
            SizedBox(width: 8),
            Text(
              app.t('تسجيل الدخول', 'Sign In'),
              textDirection: app.dir,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          app.t(
            'سجّل دخولك بالبريد الإلكتروني وكلمة المرور',
            'Sign in with your email and password',
          ),
          textDirection: app.dir,
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        SizedBox(height: 18),
        Text(
          app.t('البريد الإلكتروني', 'Email'),
          textDirection: app.dir,
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        SizedBox(height: 6),
        _textField(
          controller: userEmailController,
          hint: 'example@email.com',
          icon: Icons.email_outlined,
        ),
        SizedBox(height: 16),
        Text(
          app.t('كلمة المرور', 'Password'),
          textDirection: app.dir,
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        SizedBox(height: 6),
        _textField(
          controller: userPasswordController,
          hint: '••••••••',
          icon: Icons.lock_outline,
          obscure: obscureUserPassword,
          suffixIcon: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                setState(() => obscureUserPassword = !obscureUserPassword),
            child: Icon(
              obscureUserPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textGrey,
              size: 18,
            ),
          ),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showForgotPasswordDialog(context),
            child: Text(
              app.t('نسيت كلمة السر؟', 'Forgot password?'),
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
        ),
        SizedBox(height: 12),
        _submitButton(label: app.t('دخول', 'Sign In'), onPressed: _loginAsUser),
        SizedBox(height: 14),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => SignUpScreen()));
            },
            child: Text(
              app.t(
                'ليس عندك حساب؟ إنشاء حساب جديد',
                "Don't have an account? Sign up",
              ),
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.borderColor)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                app.t('أو', 'or'),
                style: TextStyle(color: AppColors.textGrey, fontSize: 11),
              ),
            ),
            Expanded(child: Divider(color: AppColors.borderColor)),
          ],
        ),
        SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : _continueAsGuest,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: AppColors.borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(
              Icons.person_outline,
              size: 16,
              color: AppColors.textWhite,
            ),
            label: Text(
              app.t('متابعة كزائر', 'Continue as Guest'),
              style: TextStyle(color: AppColors.textWhite, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _adminForm(AppState app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.admin_panel_settings,
              color: AppColors.primary,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              app.t('دخول لوحة الإدارة', 'Admin Panel Login'),
              textDirection: app.dir,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          app.t(
            'لإدارة المطاعم، الفنادق، الأخبار وكل بيانات التطبيق',
            'To manage restaurants, hotels, news and all app data',
          ),
          textDirection: app.dir,
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        SizedBox(height: 18),
        Text(
          app.t('اسم المستخدم', 'Username'),
          textDirection: app.dir,
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        SizedBox(height: 6),
        _textField(
          controller: adminUserController,
          hint: 'admin',
          icon: Icons.person_outline,
        ),
        SizedBox(height: 16),
        Text(
          app.t('كلمة المرور', 'Password'),
          textDirection: app.dir,
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        SizedBox(height: 6),
        _textField(
          controller: adminPassController,
          hint: '••••••••',
          icon: Icons.lock_outline,
          obscure: obscurePassword,
          suffixIcon: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => obscurePassword = !obscurePassword),
            child: Icon(
              obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textGrey,
              size: 18,
            ),
          ),
        ),
        SizedBox(height: 22),
        _submitButton(
          label: app.t('دخول كأدمن', 'Sign in as Admin'),
          onPressed: _loginAsAdmin,
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark2,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: AppTypography.body(AppColors.textWhite),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 18),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
          hintText: hint,
          hintStyle: AppTypography.body(
            AppColors.textGrey.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _submitButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: isLoading ? null : AppColors.glowShadow,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(label, style: AppTypography.title(Colors.white)),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => _ForgotPasswordDialog());
  }
}

/// حوار "نسيت كلمة السر": خطوة 1 التحقق من البريد، خطوة 2 تعيين كلمة مرور جديدة.
/// كل شي محلي بالكامل (بدون إرسال بريد فعلي) لأن التطبيق ما إله سيرفر مصادقة.
class _ForgotPasswordDialog extends StatefulWidget {
  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool emailVerified = false;
  bool isLoading = false;
  String? error;
  String? success;

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    final app = AppState.instance;
    setState(() {
      error = null;
      isLoading = true;
    });
    await Future.delayed(Duration(milliseconds: 300));
    if (!mounted) return;
    final exists = await AuthService.instance.emailExists(emailController.text);
    setState(() {
      isLoading = false;
      if (exists) {
        emailVerified = true;
      } else {
        error = app.t(
          'لا يوجد حساب بهذا البريد الإلكتروني',
          'No account found with this email',
        );
      }
    });
  }

  Future<void> _submitNewPassword() async {
    final app = AppState.instance;
    if (newPasswordController.text != confirmPasswordController.text) {
      setState(
        () => error = app.t(
          'كلمتا المرور غير متطابقتين',
          "Passwords don't match",
        ),
      );
      return;
    }
    setState(() {
      error = null;
      isLoading = true;
    });
    final result = await AuthService.instance.resetPassword(
      email: emailController.text,
      newPassword: newPasswordController.text,
    );
    if (!mounted) return;
    setState(() {
      isLoading = false;
      if (result == null) {
        success = app.t(
          'تم تغيير كلمة المرور بنجاح!',
          'Password changed successfully!',
        );
      } else {
        error = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Directionality(
      textDirection: app.dir,
      child: AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock_reset, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              app.t('نسيت كلمة السر', 'Forgot Password'),
              textDirection: app.dir,
              style: TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 320,
          child: success != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.green, size: 40),
                    SizedBox(height: 12),
                    Text(
                      success!,
                      textAlign: TextAlign.center,
                      textDirection: app.dir,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      emailVerified
                          ? app.t(
                              'أدخل كلمة مرور جديدة لحسابك',
                              'Enter a new password for your account',
                            )
                          : app.t(
                              'أدخل بريدك الإلكتروني للتحقق من حسابك',
                              'Enter your email to verify your account',
                            ),
                      textDirection: app.dir,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                    SizedBox(height: 16),
                    if (!emailVerified)
                      _dialogField(
                        controller: emailController,
                        hint: 'example@email.com',
                        icon: Icons.email_outlined,
                      )
                    else ...[
                      _dialogField(
                        controller: newPasswordController,
                        hint: app.t('كلمة مرور جديدة', 'New password'),
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),
                      SizedBox(height: 12),
                      _dialogField(
                        controller: confirmPasswordController,
                        hint: app.t('تأكيد كلمة المرور', 'Confirm password'),
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),
                    ],
                    if (error != null) ...[
                      SizedBox(height: 12),
                      Text(
                        error!,
                        textDirection: app.dir,
                        style: TextStyle(color: AppColors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
        ),
        actions: success != null
            ? [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    app.t('حسنًا', 'OK'),
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    app.t('إلغاء', 'Cancel'),
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : (emailVerified ? _submitNewPassword : _verifyEmail),
                  child: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Text(
                          emailVerified
                              ? app.t('حفظ', 'Save')
                              : app.t('متابعة', 'Continue'),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: AppColors.textWhite),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textGrey.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
