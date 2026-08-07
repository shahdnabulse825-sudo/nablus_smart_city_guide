import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../screens/home/home_screen.dart'; // AppState, AppColors, AppRadius
import '../screens/auth/login_screen.dart';
import '../services/review_service.dart';
import '../services/auth_service.dart';
import '../theme/app_typography.dart';

/// قسم تقييمات ومراجعات حقيقية من مستخدمين حقيقيين (بدل رقم تقييم ثابت
/// بالكود بس) — بيجيب المراجعات من السيرفر، وبيسمح لأي مستخدم مسجّل دخول
/// يكتب/يعدّل تقييمه. لو السيرفر مو شغال، القسم بيختفي بهدوء بدون رسالة خطأ
/// (الشاشة الأصلية تكمل تعرض رقم التقييم الثابت العادي كالمعتاد).
class ReviewsSection extends StatefulWidget {
  final String placeType;
  final String placeNameEn;
  const ReviewsSection({
    super.key,
    required this.placeType,
    required this.placeNameEn,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  ReviewsResult? _result;
  bool _loading = true;
  int _myRating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await ReviewService.instance.fetchReviews(
      widget.placeType,
      widget.placeNameEn,
    );
    if (!mounted) return;
    final email = AuthService.instance.currentUserEmail;
    final mine = email == null
        ? null
        : result?.reviews.where((r) => r.userEmail == email).firstOrNull;
    setState(() {
      _result = result;
      _loading = false;
      if (mine != null) {
        _myRating = mine.rating;
        _commentController.text = mine.comment;
      }
    });
  }

  Future<void> _submit() async {
    if (_myRating == 0) return;
    setState(() => _submitting = true);
    final error = await ReviewService.instance.submitReview(
      placeType: widget.placeType,
      placeNameEn: widget.placeNameEn,
      rating: _myRating,
      comment: _commentController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppState.instance.t('تم إرسال تقييمك، شكرًا! 🌿', 'Your review was submitted, thanks! 🌿'),
        ),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    if (_loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }
    if (_result == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Text(
              app.t('التقييمات والمراجعات', 'Ratings & Reviews'),
              textDirection: app.dir,
              style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 15),
            ),
            Spacer(),
            if (_result!.average != null) ...[
              Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
              SizedBox(width: 4),
              Text(
                '${_result!.average!.toStringAsFixed(1)} (${_result!.count})',
                style: AppTypography.label(AppColors.textWhite),
              ),
            ],
          ],
        ),
        SizedBox(height: 12),
        _writeReviewCard(app),
        SizedBox(height: 12),
        if (_result!.reviews.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              app.t('ما في مراجعات بعد — كوني أول من يقيّم!', 'No reviews yet — be the first to rate!'),
              textDirection: app.dir,
              style: AppTypography.body(AppColors.textGrey).copyWith(fontSize: 12),
            ),
          )
        else
          for (final r in _result!.reviews) ...[
            _reviewTile(app, r),
            SizedBox(height: 8),
          ],
      ],
    );
  }

  Widget _writeReviewCard(AppState app) {
    final loggedIn = AuthService.instance.isLoggedIn;
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: loggedIn ? _writeReviewForm(app) : _loginPrompt(app),
    );
  }

  Widget _writeReviewForm(AppState app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          app.t('قيّمي هذا المكان', 'Rate this place'),
          textDirection: app.dir,
          style: AppTypography.caption(AppColors.textGrey),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final starIndex = i + 1;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _myRating = starIndex),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Icon(
                  starIndex <= _myRating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.gold,
                  size: 26,
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgDark,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: TextField(
            controller: _commentController,
            maxLines: 2,
            textDirection: app.dir,
            style: AppTypography.body(AppColors.textWhite).copyWith(fontSize: 12),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(10),
              hintText: app.t('رأيك بهذا المكان (اختياري)...', 'Your thoughts (optional)...'),
              hintStyle: AppTypography.body(AppColors.textGrey).copyWith(fontSize: 12),
            ),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: (_myRating == 0 || _submitting) ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.cardDark2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            child: _submitting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    app.t('إرسال التقييم', 'Submit review'),
                    style: AppTypography.label(Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _loginPrompt(AppState app) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.textGrey),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            app.t('سجّل دخول حتى تقدر تقيّم هذا المكان', 'Log in to rate this place'),
            textDirection: app.dir,
            style: AppTypography.body(AppColors.textGrey).copyWith(fontSize: 12),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
          child: Text(app.t('دخول', 'Log in'), style: AppTypography.label(AppColors.primary)),
        ),
      ],
    );
  }

  Widget _reviewTile(AppState app, ReviewItem r) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  r.userName,
                  textDirection: app.dir,
                  style: AppTypography.label(AppColors.textWhite).copyWith(fontSize: 13),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < r.rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 13,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          if (r.comment.isNotEmpty) ...[
            SizedBox(height: 6),
            Text(
              r.comment,
              textDirection: app.dir,
              textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
              style: AppTypography.body(AppColors.textGrey).copyWith(fontSize: 12),
            ),
          ],
          SizedBox(height: 6),
          Text(
            DateFormat('yyyy/MM/dd').format(r.createdAt),
            style: AppTypography.caption(AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
