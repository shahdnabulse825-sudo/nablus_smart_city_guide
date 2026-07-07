import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../admin/admin_screen.dart';
import '../../services/auth_service.dart';
import 'sign_up_screen.dart';

/// ⚠️ بيانات الأدمن الافتراضية (محلية بالكامل، بدون سيرفر):
/// اسم المستخدم: admin
/// كلمة المرور: admin123
/// غيّريهم من هون لو حابة.
const String kAdminUsername = 'admin';
const String kAdminPassword = 'admin123';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

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
    await Future.delayed(Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => isLoading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
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
    await Future.delayed(Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => isLoading = false);

    if (user == kAdminUsername && pass == kAdminPassword) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AdminHomeScreen()),
      );
    } else {
      final app = AppState.instance;
      setState(() {
        errorMessage =
            app.t('اسم المستخدم أو كلمة المرور غير صحيحة', 'Incorrect username or password');
      });
    }
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
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20),
                        // ==== الشعار ====
                        Center(
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.purple, AppColors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blue.withOpacity(0.35),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(Icons.location_city, color: Colors.white, size: 40),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(app.t('دليل نابلس الذكي', 'Nablus Smart Guide'),
                            textAlign: TextAlign.center,
                            textDirection: app.dir,
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text(
                            app.t('أهلاً فيك! اختاري كيف بدك تدخلي',
                                'Welcome! Choose how you want to sign in'),
                            textAlign: TextAlign.center,
                            textDirection: app.dir,
                            style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                        SizedBox(height: 32),

                        // ==== تبويبات: مستخدم عادي / أدمن ====
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _tabButton(
                                  label: app.t('مستخدم عادي', 'Regular User'),
                                  icon: Icons.person,
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
                                  icon: Icons.admin_panel_settings,
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
                        SizedBox(height: 24),

                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: isAdminTab ? _adminForm(app) : _userForm(app),
                        ),

                        if (errorMessage != null) ...[
                          SizedBox(height: 14),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.red.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.red.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: AppColors.red, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(errorMessage!,
                                      textDirection: app.dir,
                                      style: TextStyle(color: AppColors.red, fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 24),
                        Center(
                          child: Text(
                              app.t('© 2025 دليل نابلس الذكي', '© 2025 Nablus Smart Guide'),
                              style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tabButton(
      {required String label,
      required IconData icon,
      required bool active,
      required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : AppColors.textGrey),
            SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: active ? Colors.white : AppColors.textGrey,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal)),
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
            Text(app.t('تسجيل الدخول', 'Sign In'),
                textDirection: app.dir,
                style: TextStyle(
                    color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 6),
        Text(
            app.t('سجّلي دخولك بالبريد الإلكتروني وكلمة المرور',
                'Sign in with your email and password'),
            textDirection: app.dir,
            style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
        SizedBox(height: 18),
        Text(app.t('البريد الإلكتروني', 'Email'),
            textDirection: app.dir, style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
        SizedBox(height: 6),
        _textField(
          controller: userEmailController,
          hint: 'example@email.com',
          icon: Icons.email_outlined,
        ),
        SizedBox(height: 16),
        Text(app.t('كلمة المرور', 'Password'),
            textDirection: app.dir, style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
        SizedBox(height: 6),
        _textField(
          controller: userPasswordController,
          hint: '••••••••',
          icon: Icons.lock_outline,
          obscure: obscureUserPassword,
          suffixIcon: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => obscureUserPassword = !obscureUserPassword),
            child: Icon(
                obscureUserPassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textGrey,
                size: 18),
          ),
        ),
        SizedBox(height: 22),
        _submitButton(
          label: app.t('دخول', 'Sign In'),
          onPressed: _loginAsUser,
        ),
        SizedBox(height: 14),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SignUpScreen()),
              );
            },
            child: Text(app.t('ليس عندك حساب؟ إنشاء حساب جديد', "Don't have an account? Sign up"),
                style: TextStyle(color: AppColors.blue, fontSize: 12)),
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.borderColor)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(app.t('أو', 'or'),
                  style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: Icon(Icons.person_outline, size: 16, color: AppColors.textWhite),
            label: Text(app.t('متابعة كزائر', 'Continue as Guest'),
                style: TextStyle(color: AppColors.textWhite, fontSize: 12)),
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
            Icon(Icons.admin_panel_settings, color: AppColors.blue, size: 18),
            SizedBox(width: 8),
            Text(app.t('دخول لوحة الإدارة', 'Admin Panel Login'),
                textDirection: app.dir,
                style: TextStyle(
                    color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 6),
        Text(app.t('لإدارة المطاعم، الفنادق، الأخبار وكل بيانات التطبيق', 'To manage restaurants, hotels, news and all app data'),
            textDirection: app.dir,
            style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
        SizedBox(height: 18),
        Text(app.t('اسم المستخدم', 'Username'),
            textDirection: app.dir, style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
        SizedBox(height: 6),
        _textField(
          controller: adminUserController,
          hint: 'admin',
          icon: Icons.person_outline,
        ),
        SizedBox(height: 16),
        Text(app.t('كلمة المرور', 'Password'),
            textDirection: app.dir, style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
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
                size: 18),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: AppColors.textWhite),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 18),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.6)),
        ),
      ),
    );
  }

  Widget _submitButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}