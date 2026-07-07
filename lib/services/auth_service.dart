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
    return null;
  }

  void logout() {
    currentUserEmail = null;
    currentUserName = null;
  }

  bool get isLoggedIn => currentUserEmail != null;
}