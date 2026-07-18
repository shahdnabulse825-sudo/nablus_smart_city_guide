import 'local_db_service.dart';
import 'auth_service.dart';

/// تتبّع الأماكن اللي زارها/شافها المستخدم (لكل مستخدم على حدة، أو كزائر)، حتى
/// نقدر نبني "الأكثر مشاهدة" و"موصى لك" بناءً على سلوك حقيقي بدل بيانات ثابتة.
/// نفس نمط favorites_service.dart بالضبط، بس بنخزّن عدد المشاهدات مش وجود/عدم وجود بس.
class RecentActivityService {
  RecentActivityService._internal();
  static final RecentActivityService instance = RecentActivityService._internal();

  String get _scope => AuthService.instance.currentUserEmail ?? 'guest';

  String _key(String nameEn) => '$_scope|$nameEn';

  Future<void> recordView(String nameEn) async {
    final k = _key(nameEn);
    final existing = LocalDbService.instance.get('activity', k);
    final viewCount = (existing?['viewCount'] as int?) ?? 0;
    await LocalDbService.instance.update('activity', k, {
      'nameEn': nameEn,
      'scope': _scope,
      'viewCount': viewCount + 1,
      'lastViewedAt': DateTime.now().toIso8601String(),
    });
  }

  List<Map<String, dynamic>> _scopedEntries() {
    return LocalDbService.instance
        .getAll('activity')
        .where((e) => e.value['scope'] == _scope)
        .map((e) => e.value)
        .toList();
  }

  /// أحدث الأماكن اللي زارها المستخدم، الأحدث أولًا
  List<String> getRecentlyViewedNames({int limit = 10}) {
    final entries = _scopedEntries()
      ..sort((a, b) => (b['lastViewedAt'] ?? '').compareTo(a['lastViewedAt'] ?? ''));
    return entries.map((e) => e['nameEn'] as String).take(limit).toList();
  }

  /// الأماكن الأكثر مشاهدة (لكل المستخدمين/الزوار مجتمعين، مش بس المستخدم الحالي —
  /// إشارة "الأكثر رواجًا" أدق لما تكون على مستوى الجهاز كله مش مقسّمة لكل حساب)
  List<String> getMostViewedNames({int limit = 10}) {
    final entries = LocalDbService.instance.getAll('activity').map((e) => e.value).toList()
      ..sort((a, b) => ((b['viewCount'] ?? 0) as int).compareTo((a['viewCount'] ?? 0) as int));
    return entries.map((e) => e['nameEn'] as String).take(limit).toList();
  }

  int viewCountFor(String nameEn) {
    final entry = LocalDbService.instance.get('activity', _key(nameEn));
    return (entry?['viewCount'] as int?) ?? 0;
  }
}
