import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'local_db_service.dart';
import 'api_service.dart';

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
  String? adminToken; // JWT حقيقي من السيرفر — لازم لأي عملية إضافة/تعديل/حذف بلوحة الأدمن
  String? userToken; // JWT حقيقي من السيرفر لحساب مستخدم عادي (favorites/feedback sync...)
  // ثلاث اشتراكات منفصلة (à la carte) بالمساعد الذكي — كل وحدة تُشترى لحالها
  // (يُحدَّثوا من السيرفر، افتراضيًا false).
  bool premiumText = false; // أسئلة نصية غير محدودة (وبيفتح كمان حد مخطط الرحلة وراوي الجولات)
  bool premiumVoice = false; // استماع صوتي غير محدود
  bool premiumPriority = false; // النموذج الأقوى بكل الأسئلة

  String _hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  Map<String, dynamic>? _findLocalUser(String cleanEmail) {
    final entries = LocalDbService.instance.getAll('users');
    final match = entries.where((e) => e.value['email'] == cleanEmail).toList();
    return match.isEmpty ? null : match.first.value;
  }

  Future<void> _applyServerSession(Map<String, dynamic> result, String fallbackEmail) async {
    final email = (result['email'] as String?) ?? fallbackEmail;
    currentUserEmail = email;
    currentUserName = result['name'] as String?;
    userToken = result['token'] as String?;
    await LocalDbService.instance.saveSession({
      'type': 'user',
      'email': email,
      'name': currentUserName,
      'token': userToken,
    });
    await refreshPremiumStatus();
  }

  /// يجيب حالة الاشتراكات الثلاثة الحقيقية من السيرفر ويحدّثها — يتجاهل الفشل
  /// بصمت (سيرفر مقفول/بدون إنترنت) ويبقي آخر قيمة معروفة كما هي.
  Future<void> refreshPremiumStatus() async {
    final token = userToken;
    if (token == null) return;
    final status = await ApiService.getSubscriptionStatus(token);
    if (status != null) {
      premiumText = status['premiumText'] as bool? ?? false;
      premiumVoice = status['premiumVoice'] as bool? ?? false;
      premiumPriority = status['premiumPriority'] as bool? ?? false;
    }
  }

  /// يعدّل اسم/بريد/كلمة مرور حساب المستخدم الحالي (لازم يكون مسجّل دخول
  /// بحساب حقيقي، أي [userToken] موجود). يرجّع null لو نجح، أو رسالة خطأ لو فشل.
  Future<String?> updateProfile({
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    final token = userToken;
    if (token == null) return 'لازم تسجّل دخول بحساب حقيقي حتى تقدر تعدّل بياناتك';
    final result = await ApiService.updateProfile(
      token: token,
      name: name,
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (result['ok'] == true) {
      await _applyServerSession(result, email ?? currentUserEmail ?? '');
      return null;
    }
    if (result['unreachable'] == true) {
      return 'تعذّر الوصول للسيرفر — تأكد إنه شغال (npm run dev)';
    }
    return result['error'] as String? ?? 'فشل تعديل الحساب';
  }

  /// يرجّع null لو نجح التسجيل، أو رسالة خطأ عربية لو فيه مشكلة.
  /// بيحاول التسجيل عالسيرفر الحقيقي أول شي (حتى الحساب يصير قابل للمزامنة بين
  /// الأجهزة)؛ لو تعذّر الوصول للسيرفر بس (مو رفض حقيقي زي بريد مكرر) بيرجع
  /// لتسجيل محلي بدون إنترنت زي ما كان قبل.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (name.trim().isEmpty) return 'الرجاء إدخال الاسم';
    if (!_isValidEmail(cleanEmail)) return 'صيغة البريد الإلكتروني غير صحيحة';
    if (password.length < 6) return 'كلمة المرور لازم تكون 6 أحرف على الأقل';

    final serverResult = await ApiService.userRegister(name.trim(), cleanEmail, password);
    if (serverResult['ok'] == true) {
      await _applyServerSession(serverResult, cleanEmail);
      return null;
    }
    if (serverResult['unreachable'] != true) {
      return serverResult['error'] as String? ?? 'فشل التسجيل';
    }

    // السيرفر مش شغال — رجّعيها لحساب محلي بدون إنترنت زي ما كان قبل.
    final exists = _findLocalUser(cleanEmail) != null;
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

  /// يرجّع null لو نجح الدخول، أو رسالة خطأ عربية لو فيه مشكلة.
  /// بيحاول الدخول عالسيرفر أول شي. لو السيرفر رفض لأنه ما لقاش الحساب (لأنه حساب
  /// قديم اتسجّل زمان محليًا بس قبل ما يصير عنا حسابات حقيقية)، وبيانات الدخول
  /// مطابقة لحساب محلي موجود، بنسجّلها تلقائيًا عالسيرفر بنفس بياناتها بدل ما
  /// تعلق — هاي "هجرة" الحساب القديم للسيرفر بشكل شفّاف بدون ما تحس فيها.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني وكلمة المرور';
    }

    final serverResult = await ApiService.userLogin(cleanEmail, password);
    if (serverResult['ok'] == true) {
      await _applyServerSession(serverResult, cleanEmail);
      return null;
    }

    if (serverResult['unreachable'] == true) {
      // السيرفر مش شغال — دخول محلي احتياطي زي ما كان قبل.
      final localUser = _findLocalUser(cleanEmail);
      if (localUser == null) return 'لا يوجد حساب بهذا البريد الإلكتروني';
      if (localUser['passwordHash'] != _hash(password)) return 'كلمة المرور غير صحيحة';
      currentUserEmail = cleanEmail;
      currentUserName = localUser['name'] as String?;
      await LocalDbService.instance.saveSession({'type': 'user', 'email': cleanEmail});
      return null;
    }

    // السيرفر شغال بس رفض الدخول — جرّب هجرة حساب محلي قديم بنفس البيانات لو موجود.
    final localUser = _findLocalUser(cleanEmail);
    if (localUser != null && localUser['passwordHash'] == _hash(password)) {
      final migrated = await ApiService.userRegister(
        localUser['name'] as String? ?? '',
        cleanEmail,
        password,
      );
      if (migrated['ok'] == true) {
        await _applyServerSession(migrated, cleanEmail);
        return null;
      }
    }
    return serverResult['error'] as String? ?? 'فشل الدخول';
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

  /// دخول أدمن حقيقي عبر السيرفر — يجيب توكن JWT حقيقي لازم لأي عملية كتابة
  /// (إضافة/تعديل/حذف) بلوحة الأدمن. يرجّع null لو نجح، أو رسالة خطأ عربية.
  Future<String?> loginAsAdminReal(String username, String password) async {
    final token = await ApiService.adminLogin(username, password);
    if (token == null) {
      return 'تعذّر تسجيل الدخول — تأكد إنه السيرفر شغال (npm run dev) وإنه اسم المستخدم وكلمة المرور صح';
    }
    isAdmin = true;
    adminToken = token;
    await LocalDbService.instance.saveSession({'type': 'admin', 'token': token});
    return null;
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
        adminToken = session['token'] as String?;
        break;
      case 'guest':
        isGuest = true;
        break;
      case 'user':
        final email = session['email'] as String?;
        if (email == null) return;
        final token = session['token'] as String?;
        if (token != null) {
          // جلسة حساب حقيقي (سيرفر) — الاسم/التوكن محفوظين بالجلسة نفسها،
          // ما في داعي لسجل محلي بصندوق 'users' أصلًا.
          currentUserEmail = email;
          currentUserName = session['name'] as String?;
          userToken = token;
          refreshPremiumStatus(); // غير منتظرة عمدًا — restoreSession متزامنة، بتحدّث isPremium بالخلفية
          break;
        }
        // جلسة قديمة محلية بالكامل (من قبل ما صار عنا حسابات سيرفر حقيقية)
        final localUser = _findLocalUser(email);
        if (localUser == null) return; // الحساب انحذف أو تغيّر، رجّعيها لتسجيل الدخول
        currentUserEmail = email;
        currentUserName = localUser['name'] as String?;
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
    adminToken = null;
    userToken = null;
    premiumText = false;
    premiumVoice = false;
    premiumPriority = false;
    await LocalDbService.instance.clearSession();
  }

  /// يتحقق من وجود حساب بهذا البريد (يُستخدم بخطوة "نسيت كلمة السر") — بتفحص
  /// السيرفر أول شي، وبترجع لفحص محلي لو تعذّر الوصول له.
  Future<bool> emailExists(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    final serverExists = await ApiService.checkEmailExists(cleanEmail);
    if (serverExists != null) return serverExists;
    return _findLocalUser(cleanEmail) != null;
  }

  /// يرجّع null لو نجح تغيير كلمة المرور، أو رسالة خطأ عربية لو فيه مشكلة.
  /// بيحاول عالسيرفر أول شي؛ لو الحساب محلي بس قديم (مش موجود عالسيرفر) بيرجع
  /// لتحديث النسخة المحلية.
  Future<String?> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!_isValidEmail(cleanEmail)) return 'صيغة البريد الإلكتروني غير صحيحة';
    if (newPassword.length < 6) return 'كلمة المرور لازم تكون 6 أحرف على الأقل';

    final serverResult = await ApiService.resetPasswordServer(cleanEmail, newPassword);
    if (serverResult['ok'] == true) return null;

    final localUser = _findLocalUser(cleanEmail);
    if (localUser == null) {
      return serverResult['unreachable'] == true
          ? 'لا يوجد حساب بهذا البريد الإلكتروني'
          : (serverResult['error'] as String? ?? 'فشلت العملية');
    }
    final entries = LocalDbService.instance.getAll('users');
    final key = entries.firstWhere((e) => e.value['email'] == cleanEmail).key;
    final updated = Map<String, dynamic>.from(localUser);
    updated['passwordHash'] = _hash(newPassword);
    await LocalDbService.instance.update('users', key, updated);
    return null;
  }

  bool get isLoggedIn => currentUserEmail != null;
}