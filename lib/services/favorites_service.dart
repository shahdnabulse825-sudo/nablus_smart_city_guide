import 'local_db_service.dart';
import 'auth_service.dart';

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
    if (LocalDbService.instance.get('favorites', k) != null) {
      await LocalDbService.instance.delete('favorites', k);
    } else {
      await LocalDbService.instance.update('favorites', k, {
        'nameEn': nameEn,
        'scope': _scope,
        'addedAt': DateTime.now().toIso8601String(),
      });
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
}
