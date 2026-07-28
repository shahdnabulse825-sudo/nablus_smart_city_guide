import 'local_db_service.dart';
import 'auth_service.dart';
import 'api_service.dart';

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
    // سجل زيارات كامل (append-only، مش عداد بيتحدّث) — عشان شاشة "سجل الزيارات"
    // تقدر تعرض كل زيارة لحالها بترتيبها الزمني، مش بس آخر مرة زرتِ فيها كل مكان.
    await LocalDbService.instance.add('visit_log', {
      'nameEn': nameEn,
      'scope': _scope,
      'viewedAt': DateTime.now().toIso8601String(),
    });
    // لو حساب حقيقي متزامن، ابعتي الزيارة عالسيرفر بالخلفية بدون انتظار
    final token = AuthService.instance.userToken;
    if (token != null) {
      ApiService.pushPlaceView(token, nameEn);
    }
  }

  /// سجل الزيارات الكامل للمستخدم الحالي، الأحدث أولًا — كل زيارة سطر لحالها
  /// (بعكس getRecentlyViewedNames اللي بترجع كل مكان مرة وحدة بس).
  List<Map<String, dynamic>> getVisitHistory({int limit = 100}) {
    final entries = LocalDbService.instance
        .getAll('visit_log')
        .where((e) => e.value['scope'] == _scope)
        .map((e) => e.value)
        .toList()
      ..sort((a, b) => (b['viewedAt'] ?? '').compareTo(a['viewedAt'] ?? ''));
    return entries.take(limit).toList();
  }

  /// تسحب سجل الزيارات من أجهزة/جلسات ثانية عالسيرفر وتدمجه محليًا (بدون حذف
  /// شي محلي) — الدمج بدقّة الدقيقة الواحدة (مش الثانية بالضبط) لأنه وقت
  /// الحفظ المحلي ووقت وصول نفس الحدث للسيرفر مش متطابقين تمامًا.
  Future<void> syncWithServer() async {
    final token = AuthService.instance.userToken;
    if (token == null) return;
    final remote = await ApiService.fetchPlaceViews(token, limit: 200);
    if (remote == null) return;

    String minuteKey(String nameEn, String iso) {
      final minute = iso.length >= 16 ? iso.substring(0, 16) : iso; // yyyy-MM-ddTHH:mm
      return '$nameEn|$minute';
    }

    final localKeys = getVisitHistory(limit: 1000)
        .map((e) => minuteKey(e['nameEn'] as String, e['viewedAt'] as String))
        .toSet();

    for (final row in remote) {
      final name = row['nameEn'] as String?;
      final viewedAt = row['viewedAt'] as String?;
      if (name == null || viewedAt == null) continue;
      if (localKeys.contains(minuteKey(name, viewedAt))) continue;
      await LocalDbService.instance.add('visit_log', {
        'nameEn': name,
        'scope': _scope,
        'viewedAt': viewedAt,
      });
    }
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
