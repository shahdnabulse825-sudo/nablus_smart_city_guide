import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'local_db_service.dart';

/// خدمة حسابات بسيطة ومحلية بالكامل (بدون سيرفر).
/// كلمات المرور تُخزَّن مُشفّرة بـ SHA-256 (مو نص عادي)، بس هذا حماية أساسية بس،
/// مش بمستوى تطبيقات حقيقية فيها سيرفر خاص بالمصادقة.
class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  String? currentUserEmail;
  String? currentUserName;
  bool isGuest = false;
  bool isAdmin = false;

  String _hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// يرجّع null لو نجح التسجيل، أو رسالة خطأ عربية لو فيه مشكلة
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (name.trim().isEmpty) return 'الرجاء إدخال الاسم';
    if (!_isValidEmail(cleanEmail)) return 'صيغة البريد الإلكتروني غير صحيحة';
    if (password.length < 6) return 'كلمة المرور لازم تكون 6 أحرف على الأقل';

    final entries = LocalDbService.instance.getAll('users');
    final exists = entries.any((e) => e.value['email'] == cleanEmail);
    if (exists) return 'هذا البريد الإلكتروني مسجّل مسبقًا';

    await LocalDbService.instance.add('users', {
      'name': name.trim(),
      'email': cleanEmail,
      'passwordHash': _hash(password),
    });

    currentUserEmail = cleanEmail;
    currentUserName = name.trim();
    await LocalDbService.instance.saveSession({'type': 'user', 'email': cleanEmail});
    return null;
  }

  /// يرجّع null لو نجح الدخول، أو رسالة خطأ عربية لو فيه مشكلة
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني وكلمة المرور';
    }

    final entries = LocalDbService.instance.getAll('users');
    final match = entries.where((e) => e.value['email'] == cleanEmail).toList();

    if (match.isEmpty) return 'لا يوجد حساب بهذا البريد الإلكتروني';

    final storedHash = match.first.value['passwordHash'];
    if (storedHash != _hash(password)) return 'كلمة المرور غير صحيحة';

    currentUserEmail = cleanEmail;
    currentUserName = match.first.value['name'];
    await LocalDbService.instance.saveSession({'type': 'user', 'email': cleanEmail});
    return null;
  }

  /// دخول كزائر بدون حساب (بس بيتذكر التطبيق إنك كنتِ زائرة بعد تحديث الصفحة)
  Future<void> continueAsGuest() async {
    isGuest = true;
    await LocalDbService.instance.saveSession({'type': 'guest'});
  }

  /// دخول كأدمن (يُستدعى بعد التحقق من بيانات الأدمن بشاشة تسجيل الدخول)
  Future<void> loginAsAdmin() async {
    isAdmin = true;
    await LocalDbService.instance.saveSession({'type': 'admin'});
  }

  /// تُستدعى مرة وحدة عند بدء التطبيق: تسترجع آخر جلسة دخول محفوظة (لو موجودة)
  /// حتى ما يرجع المستخدم لشاشة تسجيل الدخول بعد كل تحديث للصفحة.
  /// بعد استدعائها، افحصي isAdmin / isGuest / isLoggedIn / hasRestoredSession لتحديد شاشة البداية.
  void restoreSession() {
    final session = LocalDbService.instance.loadSession();
    if (session == null) return;

    switch (session['type']) {
      case 'admin':
        isAdmin = true;
        break;
      case 'guest':
        isGuest = true;
        break;
      case 'user':
        final email = session['email'] as String?;
        if (email == null) return;
        final entries = LocalDbService.instance.getAll('users');
        final match = entries.where((e) => e.value['email'] == email).toList();
        if (match.isEmpty) return; // الحساب انحذف أو تغيّر، رجّعيها لتسجيل الدخول
        currentUserEmail = email;
        currentUserName = match.first.value['name'];
        break;
    }
  }

  /// هل فيه جلسة محفوظة صالحة (مستخدم، زائر، أو أدمن)؟ تُستخدم بـ main.dart لتحديد شاشة البداية
  bool get hasRestoredSession => isLoggedIn || isGuest || isAdmin;

  Future<void> logout() async {
    currentUserEmail = null;
    currentUserName = null;
    isGuest = false;
    isAdmin = false;
    await LocalDbService.instance.clearSession();
  }

  /// يتحقق من وجود حساب بهذا البريد (يُستخدم بخطوة "نسيت كلمة السر")
  bool emailExists(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final entries = LocalDbService.instance.getAll('users');
    return entries.any((e) => e.value['email'] == cleanEmail);
  }

  /// يرجّع null لو نجح تغيير كلمة المرور، أو رسالة خطأ عربية لو فيه مشكلة
  Future<String?> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!_isValidEmail(cleanEmail)) return 'صيغة البريد الإلكتروني غير صحيحة';
    if (newPassword.length < 6) return 'كلمة المرور لازم تكون 6 أحرف على الأقل';

    final entries = LocalDbService.instance.getAll('users');
    final match = entries.where((e) => e.value['email'] == cleanEmail).toList();
    if (match.isEmpty) return 'لا يوجد حساب بهذا البريد الإلكتروني';

    final updated = Map<String, dynamic>.from(match.first.value);
    updated['passwordHash'] = _hash(newPassword);
    await LocalDbService.instance.update('users', match.first.key, updated);
    return null;
  }

  bool get isLoggedIn => currentUserEmail != null;
}