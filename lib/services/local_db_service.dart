import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

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
    'category_images',
    'users',
    'session',
    'favorites',
    'feedback',
    'activity',
    'search_log',
    'visit_log',
    'ai_chat',
    'checkpoints',
    'traffic_alerts',
    'promotions',
    'settings',
  ];

  final Map<String, Box> _boxes = {};

  /// تُستدعى مرة وحدة بأول تشغيل للتطبيق (بـ main.dart) قبل runApp
  ///
  /// بتخزّن ملفات Hive بمجلد بيانات التطبيق (%LOCALAPPDATA%) بدل مجلد
  /// المستندات الافتراضي — على أجهزة الويندوز اللي فيها OneDrive بيربط مجلد
  /// المستندات بالمزامنة السحابية، وهاد كان بيسبب قفل ملفات (.hivec) عشوائي
  /// أثناء كتابة Hive وبيكرش التطبيق. بننقل أي بيانات قديمة موجودة بالمكان
  /// القديم أول مرة حتى ما نخسرها.
  Future<void> init() async {
    if (kIsWeb) {
      // على الويب: path_provider ما إله تنفيذ حقيقي (لا يوجد نظام ملفات)،
      // Hive بيستخدم IndexedDB بالمتصفح تلقائيًا بدون أي مسار.
      await Hive.initFlutter();
    } else {
      final newDir = await getApplicationSupportDirectory();
      await _migrateFromOldLocation(newDir.path);
      Hive.init(newDir.path);
    }
    for (final name in boxNames) {
      _boxes[name] = await Hive.openBox(name);
    }
  }

  Future<void> _migrateFromOldLocation(String newDirPath) async {
    try {
      final oldDir = await getApplicationDocumentsDirectory();
      if (oldDir.path == newDirPath) return;
      for (final name in boxNames) {
        final oldFile = File('${oldDir.path}${Platform.pathSeparator}$name.hive');
        final newFile = File('$newDirPath${Platform.pathSeparator}$name.hive');
        if (await oldFile.exists() && !await newFile.exists()) {
          await oldFile.copy(newFile.path);
          final oldLock = File('${oldDir.path}${Platform.pathSeparator}$name.lock');
          if (await oldLock.exists()) {
            await oldLock.copy('$newDirPath${Platform.pathSeparator}$name.lock');
          }
        }
      }
    } catch (_) {
      // لو فشلت الهجرة (مثلاً أول تشغيل ما في بيانات قديمة أصلاً) بنكمل عادي
      // بصناديق فاضية وبترجع تتعبى من مزامنة السيرفر.
    }
  }

  /// حالة تعليق مكان (تحت الصيانة) لو موجودة وسارية — بتفحص مباشرة صندوق [boxName]
  /// المحلي (متزامن أصلًا مع السيرفر) عن عنصر بنفس [apiId]. تُستخدم من كل شاشة
  /// بتعرض تفاصيل مكان (سواء الشاشة العامة [DetailScreen] أو أي بانل تفاصيل
  /// مخصّص بشاشة قسم معيّن) حتى تُظهر شارة "معلّق للصيانة" بشكل موحّد.
  ({DateTime? until, String reason})? suspensionStatus(
    String boxName,
    String? apiId,
  ) {
    if (apiId == null) return null;
    for (final entry in getAll(boxName)) {
      if (entry.value['apiId'] != apiId) continue;
      final raw = entry.value['suspendedUntil'];
      final until = (raw is String && raw.isNotEmpty)
          ? DateTime.tryParse(raw)
          : null;
      if (until == null || !until.isAfter(DateTime.now())) return null;
      return (
        until: until,
        reason: (entry.value['suspendReason'] as String?) ?? '',
      );
    }
    return null;
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

  /// تعبئة/تحديث صندوق بحيث تنضاف عناصر seedData الجديدة وتتحدّث القديمة منها
  /// (صورة/هاتف/ساعات...) — بس بدون حذف أي شي موجود بالصندوق وغير موجود بـ seedData.
  /// هاي مهمة لأنها نفس الدالة اللي بتُستخدم لدمج ردّ الـ API (اللي ممكن يكون جزئي
  /// أو مؤقتًا أقل من بيانات الكود) — حذف تلقائي هون كان رح يمسح عناصر صحيحة موجودة
  /// محليًا بس مش راجعة بالردّ الحالي. للحذف الفعلي حسب بيانات الكود استخدم [syncSeedExact].
  ///
  /// [key] هو الحقل المستخدم لمطابقة العنصر الموجود محليًا بعنصر seedData الجديد
  /// (افتراضيًا 'nameEn' لأغلب الأقسام) — الأخبار والفعاليات ما إلها 'nameEn'
  /// (عندها 'titleEn' بدل)، فلازم تمرّري key: 'titleEn' إلها، وإلا المطابقة دايمًا
  /// بتفشل وبينضاف نسخة جديدة مكررة من كل عنصر بكل مزامنة بدل ما يتحدّث الموجود.
  Future<void> syncSeed(
    String boxName,
    List<Map<String, dynamic>> seedData, {
    String key = 'nameEn',
  }) async {
    final box = _box(boxName);
    final existing = getAll(boxName);
    final byName = {
      for (final e in existing)
        if ((e.value[key] as String?)?.isNotEmpty == true) e.value[key]: e,
    };
    for (final item in seedData) {
      final keyValue = item[key] as String?;
      final match = keyValue == null ? null : byName[keyValue];
      if (match == null) {
        await box.add(Map<String, dynamic>.from(item));
      } else if (!_mapsEqual(match.value, item)) {
        await box.put(match.key, Map<String, dynamic>.from(item));
      }
    }
  }

  /// زي [syncSeed] بالضبط (إضافة/تحديث)، وبالإضافة إلها بتحذف من الصندوق أي عنصر
  /// موجود محليًا وغير موجود بـ seedData — تُستخدم فقط لما seedData يكون المصدر
  /// الكامل والموثوق (قائمة الكود الثابتة بـ category_data.dart)، مش ردّ API جزئي.
  Future<void> syncSeedExact(
    String boxName,
    List<Map<String, dynamic>> seedData,
  ) async {
    await syncSeed(boxName, seedData);
    final box = _box(boxName);
    final currentNames = {
      for (final item in seedData)
        if ((item['nameEn'] as String?)?.isNotEmpty == true) item['nameEn'] as String,
    };
    for (final entry in getAll(boxName)) {
      final nameEn = entry.value['nameEn'] as String?;
      if (nameEn != null && nameEn.isNotEmpty && !currentNames.contains(nameEn)) {
        await box.delete(entry.key);
      }
    }
  }

  /// تحذف أي نسخ مكررة من صندوق (بتحافظ على أول نسخة بس لكل قيمة [key]) — تُستخدم
  /// مرة وحدة عند بدء التطبيق لتنظيف تكرار قديم نتج عن خلل بمطابقة المزامنة (كانت
  /// [syncSeed] تطابق دايمًا بحقل 'nameEn' حتى للأخبار/الفعاليات اللي إلها 'titleEn'
  /// بدل، فكل مزامنة كانت تضيف نسخة جديدة بدل ما تحدّث الموجودة).
  Future<void> dedupeByKey(String boxName, String key) async {
    final box = _box(boxName);
    final seen = <String>{};
    final toDelete = <dynamic>[];
    for (final k in box.keys) {
      final value = box.get(k);
      if (value is! Map) continue;
      final keyValue = value[key] as String?;
      if (keyValue == null || keyValue.isEmpty) continue;
      if (seen.contains(keyValue)) {
        toDelete.add(k);
      } else {
        seen.add(keyValue);
      }
    }
    for (final k in toDelete) {
      await box.delete(k);
    }
  }

  /// تحذف من صندوق معيّن أي عنصر اسمه (nameEn) موجود بمجموعة أسماء متروكة —
  /// تُستخدم لتنظيف بيانات وهمية/قديمة استُبدلت بمحتوى حقيقي، بدون التأثير
  /// على عناصر أخرى (مثل عناصر أضافها الأدمن عبر السيرفر) بعكس [syncSeedExact].
  Future<void> purgeByName(String boxName, Set<String> namesEn) async {
    if (namesEn.isEmpty) return;
    final box = _box(boxName);
    for (final entry in getAll(boxName)) {
      final nameEn = entry.value['nameEn'] as String?;
      if (nameEn != null && namesEn.contains(nameEn)) {
        await box.delete(entry.key);
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

  /// بترجع المفتاح المتولّد تلقائيًا للعنصر المُضاف (لازم لأي تعديل/حذف لاحق عليه)
  Future<dynamic> add(String boxName, Map<String, dynamic> item) {
    return _box(boxName).add(item);
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

  Future<void> clearBox(String boxName) async {
    await _box(boxName).clear();
  }

  /// حذف كل شي وإعادة التعبئة من جديد (لو حاب ترجع للبيانات الافتراضية)
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

  // ---------- إعدادات بسيطة عامة (تفضيلات واجهة، زي إخفاء شريط الأخبار) ----------
  bool getBoolSetting(String key, {bool defaultValue = false}) {
    final v = _box('settings').get(key);
    return v is bool ? v : defaultValue;
  }

  Future<void> setBoolSetting(String key, bool value) async {
    await _box('settings').put(key, value);
  }
}