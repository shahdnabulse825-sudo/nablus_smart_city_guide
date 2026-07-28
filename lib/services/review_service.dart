import 'api_service.dart';
import 'auth_service.dart';

class ReviewItem {
  final String id;
  final String userName;
  final String userEmail;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewItem({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewItem.fromMap(Map<String, dynamic> m) => ReviewItem(
    id: m['id'] as String? ?? '',
    userName: m['userName'] as String? ?? '',
    userEmail: m['userEmail'] as String? ?? '',
    rating: (m['rating'] as num?)?.toInt() ?? 0,
    comment: m['comment'] as String? ?? '',
    createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class ReviewsResult {
  final double? average;
  final int count;
  final List<ReviewItem> reviews;
  ReviewsResult({required this.average, required this.count, required this.reviews});
}

/// تقييمات ومراجعات حقيقية من مستخدمين حقيقيين، مخزّنة على السيرفر (مش أرقام
/// ثابتة بالكود). محتاجة السيرفر شغال — لو مو شغال، الشاشات بترجع تلقائيًا
/// لعرض التقييم الثابت الأصلي بدل قسم المراجعات (بدون كراش أو رسالة خطأ).
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  Future<ReviewsResult?> fetchReviews(String placeType, String placeNameEn) async {
    final data = await ApiService.fetchReviews(placeType, placeNameEn);
    if (data == null) return null;
    final rows = (data['reviews'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(ReviewItem.fromMap)
        .toList();
    return ReviewsResult(
      average: (data['average'] as num?)?.toDouble(),
      count: (data['count'] as num?)?.toInt() ?? rows.length,
      reviews: rows,
    );
  }

  /// بترجع null لو نجح، أو رسالة خطأ عربية لو فشل (تشمل حالة "لازم تسجّلي دخول")
  Future<String?> submitReview({
    required String placeType,
    required String placeNameEn,
    required int rating,
    String comment = '',
  }) async {
    final token = AuthService.instance.userToken;
    if (token == null) {
      return 'لازم تسجّلي دخول بحساب حقيقي حتى تقدري تكتبي تقييم';
    }
    final result = await ApiService.submitReview(
      token: token,
      placeType: placeType,
      placeNameEn: placeNameEn,
      rating: rating,
      comment: comment,
    );
    if (result['ok'] == true) return null;
    if (result['unreachable'] == true) return 'تعذّر الوصول للسيرفر — تأكدي إنك متصلة بالإنترنت';
    return result['error'] as String? ?? 'فشل إرسال التقييم';
  }

  Future<void> deleteReview(String reviewId) async {
    final token = AuthService.instance.userToken;
    if (token == null) return;
    await ApiService.deleteReview(token, reviewId);
  }
}
