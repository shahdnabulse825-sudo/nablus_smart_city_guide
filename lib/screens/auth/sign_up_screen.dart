import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

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
        errorMessage = app.t('كلمتا المرور غير متطابقتين', 'Passwords do not match');
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
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
                        Row(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.of(context).maybePop(),
                              child: Icon(Icons.arrow_back, color: AppColors.textWhite),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.purple, AppColors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.person_add_alt_1, color: Colors.white, size: 34),
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(app.t('إنشاء حساب جديد', 'Create New Account'),
                            textAlign: TextAlign.center,
                            textDirection: app.dir,
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text(
                            app.t('عبّي بياناتك حتى تقدري تحفظي مفضلاتك',
                                'Fill in your details to save your favorites'),
                            textAlign: TextAlign.center,
                            textDirection: app.dir,
                            style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                        SizedBox(height: 28),
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(app.t('الاسم الكامل', 'Full Name'),
                                  textDirection: app.dir,
                                  style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                              SizedBox(height: 6),
                              _field(
                                  controller: nameController,
                                  hint: app.t('مثلاً: أحمد محمد', 'e.g. Ahmad Mohammad'),
                                  icon: Icons.person_outline),
                              SizedBox(height: 16),
                              Text(app.t('البريد الإلكتروني', 'Email'),
                                  textDirection: app.dir,
                                  style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                              SizedBox(height: 6),
                              _field(
                                  controller: emailController,
                                  hint: 'example@email.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress),
                              SizedBox(height: 16),
                              Text(app.t('كلمة المرور', 'Password'),
                                  textDirection: app.dir,
                                  style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                              SizedBox(height: 6),
                              _field(
                                controller: passwordController,
                                hint: app.t('6 أحرف على الأقل', 'At least 6 characters'),
                                icon: Icons.lock_outline,
                                obscure: obscurePassword,
                                suffix: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      setState(() => obscurePassword = !obscurePassword),
                                  child: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.textGrey,
                                      size: 18),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(app.t('تأكيد كلمة المرور', 'Confirm Password'),
                                  textDirection: app.dir,
                                  style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                              SizedBox(height: 6),
                              _field(
                                controller: confirmPasswordController,
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscure: obscureConfirm,
                                suffix: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      setState(() => obscureConfirm = !obscureConfirm),
                                  child: Icon(
                                      obscureConfirm
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.textGrey,
                                      size: 18),
                                ),
                              ),
                              SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.blue,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2, color: Colors.white))
                                      : Text(app.t('إنشاء الحساب', 'Create Account'),
                                          style: TextStyle(
                                              color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
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
                        SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Text(
                                app.t('عندك حساب مسبقًا؟ سجّلي الدخول',
                                    'Already have an account? Sign in'),
                                style: TextStyle(color: AppColors.blue, fontSize: 12)),
                          ),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: TextStyle(color: AppColors.textWhite),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 18),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.6)),
        ),
      ),
    );
  }
}