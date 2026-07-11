import 'dart:convert';
import 'package:http/http.dart' as http;

/// خدمة جلب صور حقيقية مرتبطة بالموضوع من مكتبة Wikimedia Commons (مجانية بالكامل،
/// بدون أي مفتاح API). نستخدمها كمصدر أساسي موثوق للصور الحقيقية المرتبطة بالكلمة المفتاحية.
class WikimediaService {
  WikimediaService._internal();
  static final WikimediaService instance = WikimediaService._internal();

  // تخزين مؤقت بالذاكرة حتى ما نكرر نفس الطلب لنفس الكلمة أكثر من مرة
  final Map<String, String?> _cache = {};

  Future<String?> getPhotoUrl(String query) async {
    if (_cache.containsKey(query)) return _cache[query];

    try {
      final uri = Uri.parse('https://commons.wikimedia.org/w/api.php').replace(
        queryParameters: {
          'action': 'query',
          'generator': 'search',
          'gsrsearch': 'filetype:bitmap $query',
          'gsrlimit': '1',
          'gsrnamespace': '6',
          'prop': 'imageinfo',
          'iiprop': 'url',
          'iiurlwidth': '700',
          'format': 'json',
          'origin': '*',
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final pages = data['query']?['pages'] as Map<String, dynamic>?;
        if (pages != null && pages.isNotEmpty) {
          final page = pages.values.first;
          final infoList = page['imageinfo'] as List?;
          if (infoList != null && infoList.isNotEmpty) {
            final url = (infoList.first['thumburl'] ?? infoList.first['url']) as String?;
            _cache[query] = url;
            return url;
          }
        }
      }
    } catch (_) {
      // نتجاهل الخطأ ونرجع null، الواجهة رح تستخدم صورة بديلة تلقائيًا
    }
    _cache[query] = null;
    return null;
  }
}
