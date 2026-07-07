import 'dart:convert';
import 'package:http/http.dart' as http;

/// خدمة جلب صور حقيقية مرتبطة بالموضوع من Unsplash.
///
/// ⚠️ لازم تحطي مفتاحك المجاني هون:
/// 1. سجلي بموقع https://unsplash.com/developers (مجاني، بدون بطاقة ائتمان)
/// 2. أنشئي "New Application"
/// 3. انسخي "Access Key" وحطيه بدل النص أدناه
const String unsplashAccessKey = 'ضعي_مفتاحك_هنا';

class UnsplashService {
  UnsplashService._internal();
  static final UnsplashService instance = UnsplashService._internal();

  // تخزين مؤقت بالذاكرة حتى ما نكرر نفس الطلب لنفس الكلمة أكثر من مرة
  final Map<String, String?> _cache = {};

  bool get isConfigured =>
      unsplashAccessKey.isNotEmpty && unsplashAccessKey != 'ضعي_مفتاحك_هنا';

  /// يرجع رابط صورة حقيقية مرتبطة بالكلمة المفتاحية، أو null لو فشل/المفتاح غير مُفعّل
  Future<String?> getPhotoUrl(String query) async {
    if (!isConfigured) return null;
    if (_cache.containsKey(query)) return _cache[query];

    try {
      final uri = Uri.parse(
          'https://api.unsplash.com/photos/random?query=${Uri.encodeComponent(query)}&client_id=$unsplashAccessKey&orientation=landscape');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final url = data['urls']?['regular'] as String?;
        _cache[query] = url;
        return url;
      }
    } catch (_) {
      // نتجاهل الخطأ ونرجع null، الواجهة رح تستخدم صورة بديلة تلقائيًا
    }
    _cache[query] = null;
    return null;
  }
}