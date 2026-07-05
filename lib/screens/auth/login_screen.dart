import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // 👈 المسار الصحيح تماماً بناءً على مجلدات مشروعك

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum AuthMode { login, register, forgotPassword }
enum UserRole { user, admin }

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  AuthMode _currentMode = AuthMode.login;
  UserRole _selectedRole = UserRole.user;
  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isPasswordVisible = false;

  void _switchMode(AuthMode mode) {
    setState(() {
      _currentMode = mode;
      _formKey.currentState?.reset();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6C5CE7);
    final accentColor = const Color(0xFFFF7675);
    final textColor = const Color(0xFF2D3436);

    String titleText = 'تسجيل الدخول';
    String subtitleText = _selectedRole == UserRole.admin 
        ? 'لوحة تحكم المسؤولين وإدارة النظام' 
        : 'مرحباً بك مجدداً في دليلك الذكي';
    String confirmButtonText = 'دخول';

    if (_currentMode == AuthMode.register) {
      titleText = 'إنشاء حساب جديد';
      subtitleText = 'انضم إلينا واستكشف معالم المدينة بذكاء';
      confirmButtonText = 'تسجيل الحساب';
    } else if (_currentMode == AuthMode.forgotPassword) {
      titleText = 'استعادة كلمة المرور';
      subtitleText = 'أدخل بريدك الإلكتروني لإرسال رابط إعادة التعيين';
      confirmButtonText = 'إرسال الرابط';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withValues(alpha: 0.08),
                    const Color(0xFFF4F6FC),
                    accentColor.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.06),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.explore_rounded, color: primaryColor, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'دَلِيلْ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      
                      Text(
                        titleText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitleText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withValues(alpha: 0.6),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 30),

                      if (_currentMode != AuthMode.register) ...[
                        _buildRoleSelector(primaryColor),
                        const SizedBox(height: 25),
                      ],

                      if (_currentMode == AuthMode.register) ...[
                        _buildInputField(
                          controller: _nameController,
                          hint: 'الاسم الكامل',
                          icon: Icons.person_outline_rounded,
                          validator: (value) => value!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                        ),
                        const SizedBox(height: 18),
                      ],

                      _buildInputField(
                        controller: _emailController,
                        hint: _selectedRole == UserRole.admin ? 'بريد المسؤول الإلكتروني' : 'البريد الإلكتروني',
                        icon: _selectedRole == UserRole.admin ? Icons.admin_panel_settings_outlined : Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => !value!.contains('@') ? 'البريد الإلكتروني غير صالح' : null,
                      ),
                      
                      if (_currentMode != AuthMode.forgotPassword) ...[
                        const SizedBox(height: 18),
                        _buildInputField(
                          controller: _passwordController,
                          hint: 'كلمة المرور',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible, 
                          onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible), 
                          validator: (value) => value!.length < 6 ? 'كلمة المرور قصيرة جداً' : null,
                        ),
                      ],

                      if (_currentMode == AuthMode.register) ...[
                        const SizedBox(height: 18),
                        _buildInputField(
                          controller: _confirmPasswordController,
                          hint: 'تأكيد كلمة المرور',
                          icon: Icons.lock_clock_outlined,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          validator: (value) => value != _passwordController.text ? 'كلمات المرور غير متطابقة' : null,
                        ),
                      ],

                      if (_currentMode == AuthMode.login)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => _switchMode(AuthMode.forgotPassword),
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: accentColor, 
                                fontFamily: 'Tajawal', 
                                fontSize: 12, 
                                fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 25),

                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: _selectedRole == UserRole.admin 
                                ? [const Color(0xFF2D3436), const Color(0xFF636E72)] 
                                : [primaryColor, primaryColor.withValues(alpha: 0.8)]
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_selectedRole == UserRole.admin ? Colors.black : primaryColor).withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (_selectedRole == UserRole.admin) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم تسجيل دخول المسؤول بنجاح', style: TextStyle(fontFamily: 'Tajawal'))),
                                );
                              } else {
                                // التوجيه الفوري إلى الشاشة الرئيسية الفخمة
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            confirmButtonText,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_selectedRole != UserRole.admin)
                        _buildBottomRow(primaryColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector(Color primaryColor) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = UserRole.admin),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedRole == UserRole.admin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedRole == UserRole.admin 
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] 
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_rounded, 
                      size: 16, 
                      color: _selectedRole == UserRole.admin ? const Color(0xFF2D3436) : Colors.grey
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'مسؤول النظام',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        fontWeight: _selectedRole == UserRole.admin ? FontWeight.bold : FontWeight.normal,
                        color: _selectedRole == UserRole.admin ? const Color(0xFF2D3436) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = UserRole.user),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedRole == UserRole.user ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedRole == UserRole.user 
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] 
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_rounded, 
                      size: 16, 
                      color: _selectedRole == UserRole.user ? primaryColor : Colors.grey
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'مستخدم عادي',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        fontWeight: _selectedRole == UserRole.user ? FontWeight.bold : FontWeight.normal,
                        color: _selectedRole == UserRole.user ? primaryColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      validator: validator,
      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: isPassword 
            ? InkWell(
                onTap: onToggleVisibility,
                borderRadius: BorderRadius.circular(50),
                child: Icon(
                  isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  size: 20,
                  color: Colors.grey,
                ),
              )
            : null,
        suffixIcon: Icon(icon, size: 20, color: const Color(0xFF6C5CE7).withValues(alpha: 0.6)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.03), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBottomRow(Color primaryColor) {
    if (_currentMode == AuthMode.login) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('ليس لديك حساب؟ ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Colors.grey)),
          TextButton(
            onPressed: () => _switchMode(AuthMode.register),
            child: Text('أنشئ حساباً الآن', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    } else if (_currentMode == AuthMode.register) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('لديك حساب بالفعل? ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Colors.grey)),
          TextButton(
            onPressed: () => _switchMode(AuthMode.login),
            child: Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    } else {
      return TextButton(
        onPressed: () => _switchMode(AuthMode.login),
        child: Text('العودة لتسجيل الدخول', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: primaryColor, fontWeight: FontWeight.bold)),
      );
    }
  }
}