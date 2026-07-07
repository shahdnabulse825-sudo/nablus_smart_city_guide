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
    'news',
    'users',
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
}