import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../services/auth_service.dart';
import '../../theme/app_typography.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final app = AppState.instance;
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = app.t(
          'كلمتا المرور غير متطابقتين',
          'Passwords do not match',
        );
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final error = await AuthService.instance.register(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (error == null) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
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
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: Stack(
              children: [
                Positioned(
                  top: -110,
                  left: -90,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.of(context).maybePop(),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.cardDark,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.borderColor),
                                ),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: AppColors.textWhite,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        Center(
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.primaryGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              boxShadow: AppColors.glowShadow,
                            ),
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          app.t('إنشاء حساب جديد', 'Create New Account'),
                          textAlign: TextAlign.center,
                          textDirection: app.dir,
                          style: AppTypography.headline(AppColors.textWhite)
                              .copyWith(fontSize: 22),
                        ),
                        SizedBox(height: 6),
                        Text(
                          app.t(
                            'عبّي بياناتك حتى تقدري تحفظي مفضلاتك',
                            'Fill in your details to save your favorites',
                          ),
                          textAlign: TextAlign.center,
                          textDirection: app.dir,
                          style: AppTypography.body(AppColors.textGrey),
                        ),
                        SizedBox(height: 28),
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.borderColor),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                app.t('الاسم الكامل', 'Full Name'),
                                textDirection: app.dir,
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 6),
                              _field(
                                controller: nameController,
                                hint: app.t(
                                  'مثلاً: أحمد محمد',
                                  'e.g. Ahmad Mohammad',
                                ),
                                icon: Icons.person_outline,
                              ),
                              SizedBox(height: 16),
                              Text(
                                app.t('البريد الإلكتروني', 'Email'),
                                textDirection: app.dir,
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 6),
                              _field(
                                controller: emailController,
                                hint: 'example@email.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(height: 16),
                              Text(
                                app.t('كلمة المرور', 'Password'),
                                textDirection: app.dir,
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 6),
                              _field(
                                controller: passwordController,
                                hint: app.t(
                                  '6 أحرف على الأقل',
                                  'At least 6 characters',
                                ),
                                icon: Icons.lock_outline,
                                obscure: obscurePassword,
                                suffix: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(
                                    () => obscurePassword = !obscurePassword,
                                  ),
                                  child: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textGrey,
                                    size: 18,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                app.t('تأكيد كلمة المرور', 'Confirm Password'),
                                textDirection: app.dir,
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 6),
                              _field(
                                controller: confirmPasswordController,
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscure: obscureConfirm,
                                suffix: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(
                                    () => obscureConfirm = !obscureConfirm,
                                  ),
                                  child: Icon(
                                    obscureConfirm
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textGrey,
                                    size: 18,
                                  ),
                                ),
                              ),
                              SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: AppColors.primaryGradient,
                                    ),
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    boxShadow: isLoading ? null : AppColors.glowShadow,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _submit,
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
                                        : Text(
                                            app.t(
                                              'إنشاء الحساب',
                                              'Create Account',
                                            ),
                                            style: AppTypography.title(Colors.white),
                                          ),
                                  ),
                                ),
                              ),
                            ],
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
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.red.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.red,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    textDirection: app.dir,
                                    style: TextStyle(
                                      color: AppColors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Text(
                              app.t(
                                'عندك حساب مسبقًا؟ سجّلي الدخول',
                                'Already have an account? Sign in',
                              ),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
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
        keyboardType: keyboardType,
        style: AppTypography.body(AppColors.textWhite),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 18),
          suffixIcon: suffix,
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
}
