import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'local_db_service.dart';

/// طبقة مزامنة بين تطبيق Flutter وسيرفر الباك اند الحقيقي (backend/، Node + Prisma).
/// كل دالة هون بتحاول تجيب أحدث بيانات من السيرفر وتدمجها بصندوق Hive المحلي عبر
/// [LocalDbService.syncSeed] الموجودة أصلاً — فبتوصل البيانات لكل الشاشات تلقائيًا
/// بدون أي تغيير على منطق عرضها. لو السيرفر مو شغال أو بدون إنترنت، أي خطأ بينلقط
/// بصمت والتطبيق يكمل ببياناته المحلية الموجودة أصلاً (بدون أي كراش أو رسالة خطأ).
class ApiService {
  ApiService._();

  /// عنوان السيرفر — شغال افتراضيًا لما التطبيق والسيرفر عالجهاز نفسه (متصفح Chrome
  /// وقت التطوير). لو حبيتي تجربي التطبيق من جهاز/موبايل تاني، لازم تغيّري هاد
  /// العنوان لعنوان IP جهاز السيرفر بالشبكة (مثلاً http://192.168.1.5:4000/api).
  static const String baseUrl = 'http://localhost:4000/api';

  static const Duration _timeout = Duration(seconds: 3);

  static List<String> _splitCsv(dynamic v) {
    if (v is! String || v.trim().isEmpty) return [];
    return v
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static Future<List<Map<String, dynamic>>?> _fetchList(String path) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/$path')).timeout(_timeout);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is! List) return null;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null; // سيرفر مقفول / بدون إنترنت / استجابة غير متوقعة — نتجاهل بصمت
    }
  }

  /// يجيب قائمة من السيرفر ويدمجها بصندوق Hive المحلي [boxName]، محافظًا على
  /// image/customImageBase64 المحليين (السيرفر لسا ما عنده صور مرفوعة)، وفاكًّا
  /// حقول القوائم بـ[listFields] من نص مفصول بفواصل (SQLite ما بيدعم مصفوفات).
  static Future<void> _syncBoxFromApi(
    String boxName,
    String apiPath, {
    List<String> listFields = const [],
  }) async {
    final items = await _fetchList(apiPath);
    if (items == null) return;

    final db = LocalDbService.instance;
    final existingByName = {
      for (final e in db.getAll(boxName))
        if ((e.value['nameEn'] as String?)?.isNotEmpty == true)
          e.value['nameEn']: e.value,
    };

    final merged = items.map((item) {
      final map = Map<String, dynamic>.from(item);
      final prev = existingByName[map['nameEn']];
      for (final f in listFields) {
        map[f] = _splitCsv(map[f]);
      }
      map['image'] = prev?['image'] ?? '';
      map['customImageBase64'] = prev?['customImageBase64'];
      // بعض الأقسام (مطاعم/الأقسام العامة/أخبار) ما عندها عمود isFeatured بقاعدة
      // البيانات لسا، فردّها ما بيتضمّنها — نحافظ على القيمة المحلية الموجودة
      // بدل ما تنمسح لـ false تلقائيًا. الأقسام اللي عندها العمود (فنادق/صيدليات/
      // معالم/تسوق) بتاخد قيمة السيرفر الأحدث عادي لأنها موجودة فعليًا بالرد.
      if (!map.containsKey('isFeatured')) {
        map['isFeatured'] = prev?['isFeatured'] ?? false;
      }
      // نحتفظ بمعرّف السيرفر (apiId) ورابط الصورة المرفوعة (serverImageUrl) بأسماء
      // مختلفة عشان لوحة الأدمن تقدر تعدّل/تحذف/تعرض معاينة العنصر الصحيح بالسيرفر —
      // بدون ما يتعارضوا مع مفتاح Hive المحلي أو حقل image/customImageBase64 المحلي.
      map['apiId'] = item['id'];
      map['serverImageUrl'] = item['imageUrl'];
      map.remove('id');
      map.remove('imageUrl');
      map.remove('createdAt');
      map.remove('updatedAt');
      return map;
    }).toList();

    await db.syncSeed(boxName, merged);
  }

  static Future<void> syncHotels() => _syncBoxFromApi(
    'hotels',
    'hotels',
    listFields: ['gallery', 'amenities', 'tags'],
  );

  static Future<void> syncRestaurants() =>
      _syncBoxFromApi('restaurants', 'restaurants');

  static Future<void> syncPharmacies() =>
      _syncBoxFromApi('pharmacies', 'pharmacies', listFields: ['tags']);

  static Future<void> syncAttractions() =>
      _syncBoxFromApi('attractions', 'attractions', listFields: ['categories']);

  static Future<void> syncShopping() => _syncBoxFromApi('shopping', 'shopping');

  static Future<void> syncNews() => _syncBoxFromApi('news', 'news');

  static Future<void> syncEvents() => _syncBoxFromApi('events', 'events');

  /// يجيب صور التصنيفات يلي رفعها الأدمن (خريطة categoryKey → رابط) ويخزّنها
  /// محليًا مباشرة بمفتاح categoryKey نفسه (مش زي باقي الأقسام يلي بتتوزّع
  /// بمفاتيح Hive تلقائية) — حتى نقدر نقرأها فورًا بـ [categoryImageUrl] بدون
  /// حاجة لأي مطابقة بالاسم.
  static Future<void> syncCategoryImages() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/category-images'))
          .timeout(_timeout);
      if (res.statusCode != 200) return;
      final decoded = jsonDecode(res.body);
      if (decoded is! Map) return;
      final db = LocalDbService.instance;
      // السيرفر هو المرجع الوحيد هون (مافي تعديلات محلية لازم نحافظ عليها) —
      // نمسح الصندوق كامل ونعبّيه من جديد، حتى صورة انحذفت بالسيرفر تختفي محليًا
      // كمان بدل ما تضل عالقة إلى الأبد.
      await db.clearBox('category_images');
      for (final entry in decoded.entries) {
        await db.update('category_images', entry.key, {
          'imageUrl': entry.value,
        });
      }
    } catch (_) {}
  }

  /// الرابط الحالي لصورة تصنيف مخصّصة (لو رفعها الأدمن)، أو null لو ما في —
  /// وقتها الشاشة يلي بتستدعيها بترجع للصورة الافتراضية الجاهزة بالتطبيق.
  static String? categoryImageUrl(String categoryKey) {
    final v = LocalDbService.instance.get('category_images', categoryKey);
    final url = v?['imageUrl'] as String?;
    return (url != null && url.isNotEmpty) ? url : null;
  }

  /// يزيد عدّاد الزوار الحقيقي بالسيرفر مرة وحدة لكل فتحة تطبيق، ويرجّع الرقم
  /// الجديد لو نجح (حتى نعرضه فورًا بدون الحاجة لطلب تاني). بيتجاهل الفشل بصمت
  /// (بدون إنترنت/سيرفر مقفول) — نفس أسلوب باقي دوال المزامنة بهاد الملف.
  static Future<int?> incrementVisitCount() async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl/visits/increment'))
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body);
      return decoded is Map ? (decoded['count'] as num?)?.toInt() : null;
    } catch (_) {
      return null;
    }
  }

  static Future<int?> getVisitCount() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/visits')).timeout(_timeout);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body);
      return decoded is Map ? (decoded['count'] as num?)?.toInt() : null;
    } catch (_) {
      return null;
    }
  }

  /// يزامن أي صندوق بالاسم (تُستخدم من لوحة الأدمن بعد أي عملية كتابة ناجحة، بدون
  /// ما تحتاج تعرف مسبقًا إذا كان قسم غني أو قسم عام).
  static Future<void> syncBox(String boxName) {
    switch (boxName) {
      case 'hotels':
        return syncHotels();
      case 'restaurants':
        return syncRestaurants();
      case 'pharmacies':
        return syncPharmacies();
      case 'attractions':
        return syncAttractions();
      case 'shopping':
        return syncShopping();
      case 'news':
        return syncNews();
      case 'events':
        return syncEvents();
      default:
        return _syncBoxFromApi(boxName, 'listings?category=$boxName');
    }
  }

  // ==================== تسجيل دخول الأدمن الحقيقي ====================
  /// يرجّع توكن JWT حقيقي لو نجح الدخول، أو null لو فشل (سيرفر مقفول أو بيانات غلط).
  static Future<String?> adminLogin(String username, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/admin-login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is Map && decoded['token'] is String) {
        return decoded['token'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ==================== حسابات المستخدمين الحقيقية (سيرفر) ====================
  /// نتيجة موحّدة: {ok:true, token, name, email} لو نجح، أو {ok:false, unreachable:true}
  /// لو تعذّر الوصول للسيرفر أصلاً، أو {ok:false, error:'...'} لو السيرفر ردّ برفض حقيقي
  /// (بريد مكرر، كلمة سر غلط...) — الفرق بين الحالتين الأخيرتين هو اللي بيحدد بـ
  /// [AuthService] هل نرجع لحساب محلي احتياطي أو نعرض رسالة الخطأ الحقيقية.
  static Future<Map<String, dynamic>> _authRequest(
    String path,
    Map<String, String> body,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      final decoded = jsonDecode(res.body);
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          decoded is Map &&
          decoded['token'] is String &&
          decoded['user'] is Map) {
        final user = decoded['user'] as Map;
        return {
          'ok': true,
          'token': decoded['token'],
          'name': user['name'],
          'email': user['email'],
        };
      }
      return {
        'ok': false,
        'error': (decoded is Map ? decoded['error'] as String? : null) ??
            'فشلت العملية',
      };
    } catch (_) {
      return {'ok': false, 'unreachable': true};
    }
  }

  static Future<Map<String, dynamic>> userRegister(
    String name,
    String email,
    String password,
  ) =>
      _authRequest('register', {'name': name, 'email': email, 'password': password});

  static Future<Map<String, dynamic>> userLogin(String email, String password) =>
      _authRequest('login', {'email': email, 'password': password});

  static Future<bool?> checkEmailExists(String email) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/auth/check-email/$email'))
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body);
      return decoded is Map ? decoded['exists'] as bool? : null;
    } catch (_) {
      return null; // null = تعذّر الوصول للسيرفر، مختلف عن false = الحساب مش موجود
    }
  }

  static Future<Map<String, dynamic>> resetPasswordServer(
    String email,
    String newPassword,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'newPassword': newPassword}),
          )
          .timeout(_timeout);
      final decoded = jsonDecode(res.body);
      if (res.statusCode == 200 && decoded is Map && decoded['success'] == true) {
        return {'ok': true};
      }
      return {
        'ok': false,
        'error': (decoded is Map ? decoded['error'] as String? : null) ??
            'فشلت العملية',
      };
    } catch (_) {
      return {'ok': false, 'unreachable': true};
    }
  }

  // ==================== المفضلة وسجل الزيارات (حساب حقيقي مُتزامن) ====================
  static Future<void> pushFavoriteAdd(String token, String nameEn) async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl/favorites'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'nameEn': nameEn}),
          )
          .timeout(_timeout);
    } catch (_) {}
  }

  static Future<void> pushFavoriteRemove(String token, String nameEn) async {
    try {
      await http
          .delete(
            Uri.parse('$baseUrl/favorites/${Uri.encodeComponent(nameEn)}'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);
    } catch (_) {}
  }

  /// بترجع لائحة {nameEn, createdAt} أو null لو تعذّر الوصول للسيرفر
  static Future<List<Map<String, dynamic>>?> fetchFavorites(String token) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/favorites'), headers: {'Authorization': 'Bearer $token'})
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is! List) return null;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  static Future<void> pushPlaceView(String token, String nameEn) async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl/place-views'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'nameEn': nameEn}),
          )
          .timeout(_timeout);
    } catch (_) {}
  }

  /// بترجع لائحة {nameEn, viewedAt} أو null لو تعذّر الوصول للسيرفر
  static Future<List<Map<String, dynamic>>?> fetchPlaceViews(
    String token, {
    int limit = 100,
  }) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/place-views?limit=$limit'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is! List) return null;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  // ==================== تقييمات ومراجعات حقيقية ====================
  /// بترجع {average, count, reviews: [...]}  أو null لو تعذّر الوصول للسيرفر
  static Future<Map<String, dynamic>?> fetchReviews(
    String placeType,
    String placeNameEn,
  ) async {
    try {
      final res = await http
          .get(
            Uri.parse(
              '$baseUrl/reviews?placeType=${Uri.encodeComponent(placeType)}'
              '&placeNameEn=${Uri.encodeComponent(placeNameEn)}',
            ),
          )
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is! Map) return null;
      return decoded.cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }

  /// بترجع {ok:true} أو {ok:false, error} — بتحتاج تسجيل دخول حقيقي (token)
  static Future<Map<String, dynamic>> submitReview({
    required String token,
    required String placeType,
    required String placeNameEn,
    required int rating,
    String comment = '',
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/reviews'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'placeType': placeType,
              'placeNameEn': placeNameEn,
              'rating': rating,
              'comment': comment,
            }),
          )
          .timeout(_timeout);
      if (res.statusCode == 200 || res.statusCode == 201) return {'ok': true};
      final decoded = jsonDecode(res.body);
      return {
        'ok': false,
        'error': (decoded is Map ? decoded['error'] as String? : null) ?? 'فشل إرسال التقييم',
      };
    } catch (_) {
      return {'ok': false, 'unreachable': true};
    }
  }

  static Future<void> deleteReview(String token, String reviewId) async {
    try {
      await http
          .delete(
            Uri.parse('$baseUrl/reviews/${Uri.encodeComponent(reviewId)}'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);
    } catch (_) {}
  }

  // ==================== رسائل التواصل/البلاغات (متزامنة مع السيرفر) ====================
  /// بترجع صف الرسالة كما اتخزّن بالسيرفر (فيه الـ id الحقيقي) أو null لو تعذّر الوصول
  static Future<Map<String, dynamic>?> pushFeedback({
    required String name,
    required String email,
    required String type,
    required String message,
    String? relatedPlace,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/feedback'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'type': type,
              'message': message,
              'relatedPlace': relatedPlace,
            }),
          )
          .timeout(_timeout);
      if (res.statusCode != 201) return null;
      final decoded = jsonDecode(res.body);
      return decoded is Map ? decoded.cast<String, dynamic>() : null;
    } catch (_) {
      return null;
    }
  }

  /// رسائل زائر معيّن حسب بريده — أو null لو تعذّر الوصول للسيرفر
  static Future<List<Map<String, dynamic>>?> fetchFeedbackForEmail(String email) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/feedback/mine?email=${Uri.encodeComponent(email)}'))
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is! List) return null;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  /// كل رسائل الزوار — للوحة الأدمن فقط (بتحتاج adminToken)
  static Future<List<Map<String, dynamic>>?> fetchAllFeedback(String adminToken) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/feedback'), headers: {'Authorization': 'Bearer $adminToken'})
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is! List) return null;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> markFeedbackRead(String adminToken, String id) async {
    try {
      final res = await http
          .patch(
            Uri.parse('$baseUrl/feedback/${Uri.encodeComponent(id)}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $adminToken',
            },
            body: jsonEncode({'read': true}),
          )
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> replyFeedback(String adminToken, String id, String reply) async {
    try {
      final res = await http
          .patch(
            Uri.parse('$baseUrl/feedback/${Uri.encodeComponent(id)}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $adminToken',
            },
            body: jsonEncode({'reply': reply}),
          )
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteFeedback(String adminToken, String id) async {
    try {
      final res = await http
          .delete(
            Uri.parse('$baseUrl/feedback/${Uri.encodeComponent(id)}'),
            headers: {'Authorization': 'Bearer $adminToken'},
          )
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==================== أخبار حقيقية مباشرة عن الضفة الغربية (Al Jazeera) ====================
  static Future<List<Map<String, dynamic>>?> fetchLiveWestBankNews() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/news/live'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is! List) return null;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  // ==================== المساعد الذكي (نموذج لغوي حقيقي عبر السيرفر) ====================
  /// بترجع {ok:true, textAr, textEn, placeNameEn, eventTitleEn} لو نجح، أو
  /// {ok:false} لو تعذّر الوصول أو المساعد مش مُفعّل بعد — الشاشة بترجع بهاي
  /// الحالة تلقائيًا للردود المحلية القديمة (_generateReply) بدل ما توقف.
  static Future<Map<String, dynamic>> askAiAssistant(
    String message, {
    List<Map<String, String>> history = const [],
    String lang = 'ar',
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/ai-chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': message,
              'history': history,
              'lang': lang,
            }),
          )
          .timeout(const Duration(seconds: 25));
      if (res.statusCode != 200) return {'ok': false};
      final decoded = jsonDecode(res.body);
      if (decoded is! Map) return {'ok': false};
      return {
        'ok': true,
        'textAr': decoded['textAr'],
        'textEn': decoded['textEn'],
        'placeNameEn': decoded['placeNameEn'],
        'eventTitleEn': decoded['eventTitleEn'],
      };
    } catch (_) {
      return {'ok': false};
    }
  }

  /// فحص سريع إذا كان السيرفر شغال (تُستخدم لعرض تنبيه بلوحة الأدمن)
  static Future<bool> isServerReachable() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==================== كتابة (إضافة/تعديل/حذف) — لوحة الأدمن ====================
  static const Set<String> _richSections = {
    'hotels',
    'restaurants',
    'pharmacies',
    'attractions',
    'shopping',
    'news',
    'events',
  };

  /// الأقسام الغنية (فنادق/مطاعم/صيدليات/معالم/تسوق/أخبار) إلها مسار API خاص فيها،
  /// وباقي الأقسام (مواصلات/صحة/تعليم/بنوك/ترفيه/حكومي) كلها عبر /api/listings
  /// مع حقل category = اسم الصندوق.
  static String _apiPathFor(String boxName) =>
      _richSections.contains(boxName) ? boxName : 'listings';

  /// بيحدّد نوع MIME للصورة من امتداد اسم الملف — لازم نبعته صراحة لأن
  /// [http.MultipartFile.fromBytes] بدون contentType بيبعت application/octet-stream
  /// افتراضيًا، وسيرفر الباك اند بيرفض أي ملف مش image/* (upload.js).
  static MediaType _imageContentType(String filename) {
    final ext = filename.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  /// بيرجّع كود حالة HTTP الحقيقي لو وصل رد من السيرفر (حتى لو فشل، مثل 401/500)،
  /// أو -1 لو فشل الاتصال نفسه (سيرفر مقفول/لا يوجد إنترنت) — حتى نقدر نميّز بلوحة
  /// الأدمن بين "الجلسة منتهية" و"السيرفر مش شغال" بدل رسالة عامة واحدة مضلّلة.
  static Future<int> _sendMultipart(
    String method,
    String url,
    String token,
    Map<String, dynamic> fields, {
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    try {
      final request = http.MultipartRequest(method, Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      fields.forEach((key, value) {
        // نبعت null كنص فاضي (مش نتجاهله) — حتى نقدر نمسح قيمة موجودة أصلاً
        // بقاعدة البيانات (مثل موقع محدد على الخريطة) بدل ما تضل عالقة كما هي.
        request.fields[key] = value == null
            ? ''
            : (value is List ? value.join(',') : value.toString());
      });
      if (imageBytes != null) {
        final name = imageFilename ?? 'upload.jpg';
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: name,
            contentType: _imageContentType(name),
          ),
        );
      }
      final streamed = await request.send().timeout(
        const Duration(seconds: 20),
      );
      return streamed.statusCode;
    } catch (_) {
      return -1;
    }
  }

  /// يضيف عنصر جديد لقسم [boxName]. [fields] خريطة الحقول النصية/الرقمية (قوائم
  /// زي tags بتنبعت تلقائيًا كنص مفصول بفواصل). يرجّع كود حالة HTTP (201 لو نجح)،
  /// أو -1 لو فشل الاتصال بالسيرفر نفسه.
  static Future<int> createItem(
    String token,
    String boxName,
    Map<String, dynamic> fields, {
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    final path = _apiPathFor(boxName);
    final f = Map<String, dynamic>.from(fields);
    if (path == 'listings') f['category'] = boxName;
    return _sendMultipart(
      'POST',
      '$baseUrl/$path',
      token,
      f,
      imageBytes: imageBytes,
      imageFilename: imageFilename,
    );
  }

  static Future<int> updateItem(
    String token,
    String boxName,
    String apiId,
    Map<String, dynamic> fields, {
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    final path = _apiPathFor(boxName);
    final f = Map<String, dynamic>.from(fields);
    if (path == 'listings') f['category'] = boxName;
    return _sendMultipart(
      'PUT',
      '$baseUrl/$path/$apiId',
      token,
      f,
      imageBytes: imageBytes,
      imageFilename: imageFilename,
    );
  }

  static Future<bool> deleteItem(
    String token,
    String boxName,
    String apiId,
  ) async {
    try {
      final res = await http
          .delete(
            Uri.parse('$baseUrl/${_apiPathFor(boxName)}/$apiId'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// يرفع/يستبدل صورة تصنيف كامل (مطاعم/صحة/...) — يرجّع كود حالة HTTP.
  static Future<int> uploadCategoryImage(
    String token,
    String categoryKey,
    List<int> imageBytes,
    String imageFilename,
  ) {
    return _sendMultipart(
      'PUT',
      '$baseUrl/category-images/$categoryKey',
      token,
      const {},
      imageBytes: imageBytes,
      imageFilename: imageFilename,
    );
  }

  /// يحذف صورة تصنيف مخصّصة ويرجّعها للصورة الافتراضية الجاهزة بالتطبيق.
  static Future<bool> deleteCategoryImage(String token, String categoryKey) async {
    try {
      final res = await http
          .delete(
            Uri.parse('$baseUrl/category-images/$categoryKey'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
