import 'local_db_service.dart';

/// يسجّل كلمات البحث اللي بيكتبها المستخدمين (على مستوى الجهاز كله، بدون ربط
/// بحساب معيّن) حتى نقدر نعرض "عمليات بحث رائجة" باقتراحات جاهزة بشاشة الاستكشاف.
class SearchLogService {
  SearchLogService._internal();
  static final SearchLogService instance = SearchLogService._internal();

  String _normalize(String query) =>
      query.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  Future<void> logSearch(String rawQuery) async {
    final term = _normalize(rawQuery);
    if (term.length < 2) return;
    final existing = LocalDbService.instance.get('search_log', term);
    final count = (existing?['count'] as int?) ?? 0;
    await LocalDbService.instance.update('search_log', term, {
      'term': term,
      'count': count + 1,
      'lastSearchedAt': DateTime.now().toIso8601String(),
    });
  }

  List<String> getTopSearchTerms({int limit = 10}) {
    final entries = LocalDbService.instance.getAll('search_log').map((e) => e.value).toList()
      ..sort((a, b) => ((b['count'] ?? 0) as int).compareTo((a['count'] ?? 0) as int));
    return entries.map((e) => e['term'] as String).take(limit).toList();
  }
}
