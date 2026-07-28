import 'local_db_service.dart';
import 'auth_service.dart';
import 'api_service.dart';

/// خدمة أماكن مفضّلة حقيقية ومحفوظة (بدل قائمة وهمية بتتصفّر مع أي تنقّل).
/// نستخدم الاسم الإنجليزي للمكان كمعرّف مستقر (بسيط وكافي لحجم بيانات هذا التطبيق)،
/// ونحفظها لكل مستخدم على حدة (أو كزائرة لو ما فيه حساب).
class FavoritesService {
  FavoritesService._internal();
  static final FavoritesService instance = FavoritesService._internal();

  String get _scope => AuthService.instance.currentUserEmail ?? 'guest';

  String _key(String nameEn) => '$_scope|$nameEn';

  bool isFavorite(String nameEn) {
    return LocalDbService.instance.get('favorites', _key(nameEn)) != null;
  }

  Future<void> toggleFavorite(String nameEn) async {
    final k = _key(nameEn);
    final wasFavorite = LocalDbService.instance.get('favorites', k) != null;
    if (wasFavorite) {
      await LocalDbService.instance.delete('favorites', k);
    } else {
      await LocalDbService.instance.update('favorites', k, {
        'nameEn': nameEn,
        'scope': _scope,
        'addedAt': DateTime.now().toIso8601String(),
      });
    }
    // لو حساب حقيقي متزامن، ابعتي التغيير عالسيرفر بالخلفية (بدون ما توقّفي
    // التفاعل بانتظار الشبكة — التخزين المحلي أصلًا صار فورًا فوق).
    final token = AuthService.instance.userToken;
    if (token != null) {
      if (wasFavorite) {
        ApiService.pushFavoriteRemove(token, nameEn);
      } else {
        ApiService.pushFavoriteAdd(token, nameEn);
      }
    }
  }

  /// كل أسماء الأماكن المفضّلة (إنجليزي) للمستخدم الحالي، بترتيب الإضافة الأحدث أولًا
  List<String> getFavoriteNames() {
    final entries = LocalDbService.instance.getAll('favorites')
      ..sort((a, b) => (b.value['addedAt'] ?? '').compareTo(a.value['addedAt'] ?? ''));
    return entries
        .where((e) => e.value['scope'] == _scope)
        .map((e) => e.value['nameEn'] as String)
        .toList();
  }

  /// تسحب مفضلة الحساب من السيرفر وتدمجها محليًا (دمج تراكمي فقط، ما بتحذف
  /// شي محلي)، وبترفع أي مفضلة محلية وصلت قبل ما يتزامن الحساب (مثلاً أُضيفت
  /// وقت ما كان السيرفر مقفول). تُستدعى بعد تسجيل الدخول وعند بداية التطبيق.
  Future<void> syncWithServer() async {
    final token = AuthService.instance.userToken;
    if (token == null) return;
    final remote = await ApiService.fetchFavorites(token);
    if (remote == null) return;

    final localNames = getFavoriteNames().toSet();
    for (final row in remote) {
      final name = row['nameEn'] as String?;
      final createdAt = row['createdAt'] as String?;
      if (name == null || localNames.contains(name)) continue;
      await LocalDbService.instance.update('favorites', _key(name), {
        'nameEn': name,
        'scope': _scope,
        'addedAt': createdAt ?? DateTime.now().toIso8601String(),
      });
    }

    final remoteNames = remote.map((r) => r['nameEn'] as String?).whereType<String>().toSet();
    for (final name in localNames) {
      if (!remoteNames.contains(name)) {
        ApiService.pushFavoriteAdd(token, name);
      }
    }
  }
}
