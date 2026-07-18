import 'package:hive_flutter/hive_flutter.dart';

/// خدمة قاعدة بيانات محلية (على الجهاز فقط، بدون إنترنت وبدون تسجيل حساب)
/// كل تصنيف (مطاعم، فنادق، سياحة، تسوق، مواصلات، صحة، صيدليات، أخبار) إله "صندوق" خاص فيه.
/// كل عنصر مخزّن كـ Map عادي (بدون الحاجة لأي كود توليد إضافي).
class LocalDbService {
  LocalDbService._internal();
  static final LocalDbService instance = LocalDbService._internal();

  static const boxNames = [
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
    'news',
    'events',
    'users',
    'session',
    'favorites',
    'feedback',
    'activity',
    'search_log',
  ];

  final Map<String, Box> _boxes = {};

  /// تُستدعى مرة وحدة بأول تشغيل للتطبيق (بـ main.dart) قبل runApp
  Future<void> init() async {
    await Hive.initFlutter();
    for (final name in boxNames) {
      _boxes[name] = await Hive.openBox(name);
    }
  }

  Box _box(String boxName) {
    final box = _boxes[boxName];
    if (box == null) {
      throw Exception('صندوق البيانات "$boxName" غير مُهيّأ. تأكد من استدعاء init() بـ main.dart');
    }
    return box;
  }

  /// تعبئة صندوق ببيانات ابتدائية لو كان فاضي (أول مرة بس)
  Future<void> seedIfEmpty(String boxName, List<Map<String, dynamic>> seedData) async {
    final box = _box(boxName);
    if (box.isEmpty) {
      for (final item in seedData) {
        await box.add(Map<String, dynamic>.from(item));
      }
    }
  }

  /// تعبئة/تحديث صندوق بحيث تضل بيانات الكود (seedData) هي المرجع دائمًا:
  /// - لو العنصر مش موجود (حسب nameEn) بيتضاف.
  /// - لو موجود بس بيانات قديمة مخزّنة عنده (صورة/هاتف/ساعات...) بتختلف عن الكود، بيتحدّث تلقائيًا.
  /// هيك تعديلات الكود (زي إضافة صورة أو تصحيح رقم هاتف) بتوصل للتطبيق فورًا بدون مسح بيانات التطبيق يدويًا.
  Future<void> syncSeed(String boxName, List<Map<String, dynamic>> seedData) async {
    final box = _box(boxName);
    final existing = getAll(boxName);
    final byName = {
      for (final e in existing)
        if ((e.value['nameEn'] as String?)?.isNotEmpty == true) e.value['nameEn']: e,
    };
    for (final item in seedData) {
      final nameEn = item['nameEn'] as String?;
      final match = nameEn == null ? null : byName[nameEn];
      if (match == null) {
        await box.add(Map<String, dynamic>.from(item));
      } else if (!_mapsEqual(match.value, item)) {
        await box.put(match.key, Map<String, dynamic>.from(item));
      }
    }
  }

  bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    final keys = {...a.keys, ...b.keys};
    for (final k in keys) {
      final av = a[k];
      final bv = b[k];
      if (av is List && bv is List) {
        if (av.length != bv.length || !av.every((e) => bv.contains(e))) return false;
      } else if (av != bv) {
        return false;
      }
    }
    return true;
  }

  /// يرجع كل العناصر بصندوق معيّن مع مفاتيحها (المفتاح لازم للتعديل والحذف)
  List<MapEntry<dynamic, Map<String, dynamic>>> getAll(String boxName) {
    final box = _box(boxName);
    return box.keys
        .map((k) => MapEntry(k, Map<String, dynamic>.from(box.get(k) as Map)))
        .toList();
  }

  Future<void> add(String boxName, Map<String, dynamic> item) async {
    await _box(boxName).add(item);
  }

  Future<void> update(String boxName, dynamic key, Map<String, dynamic> item) async {
    await _box(boxName).put(key, item);
  }

  /// يرجع عنصر واحد بمفتاحه مباشرة (أو null لو مش موجود)
  Map<String, dynamic>? get(String boxName, dynamic key) {
    final raw = _box(boxName).get(key);
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<void> delete(String boxName, dynamic key) async {
    await _box(boxName).delete(key);
  }

  /// حذف كل شي وإعادة التعبئة من جديد (لو حابة ترجعي للبيانات الافتراضية)
  Future<void> resetToSeed(String boxName, List<Map<String, dynamic>> seedData) async {
    final box = _box(boxName);
    await box.clear();
    for (final item in seedData) {
      await box.add(Map<String, dynamic>.from(item));
    }
  }

  // ---------- جلسة الدخول الحالية (حتى ما يرجع المستخدم لشاشة تسجيل الدخول بعد تحديث الصفحة) ----------
  Future<void> saveSession(Map<String, dynamic> data) async {
    await _box('session').put('current', data);
  }

  Map<String, dynamic>? loadSession() {
    final raw = _box('session').get('current');
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<void> clearSession() async {
    await _box('session').delete('current');
  }
}