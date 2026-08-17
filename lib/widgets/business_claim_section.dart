import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../theme/app_typography.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/local_db_service.dart';
import '../screens/admin/admin_screen.dart' show openOwnerEditForm, AdminSchema;

const Map<String, String> _boxNameFor = {
  'restaurant': 'restaurants',
  'hotel': 'hotels',
  'pharmacy': 'pharmacies',
  'shopping': 'shopping',
};

const Map<String, AdminSchema> _schemaFor = {
  'restaurant': AdminSchema.restaurant,
  'hotel': AdminSchema.hotel,
  'pharmacy': AdminSchema.pharmacy,
  'shopping': AdminSchema.shoppingVenue,
};

/// قسم "ملكية المحل" بشاشة تفاصيل مطعم/فندق/صيدلية/محل تسوق — بيظهر بس
/// للمستخدمين المسجّلين (غير الأدمن) على أماكن جايّة فعليًا من السيرفر (لها apiId).
/// ثلاث حالات: صاحب المحل الحالي (زر تعديل) / طلب معلّق (شارة انتظار) / بدون
/// طلب (زر "هاد المحل إلي"). التعديل بيفتح نفس فورم لوحة الأدمن — بيلاقي
/// العنصر بصندوق Hive المحلي حسب [placeType]+[apiId] مباشرة (بدون ما تحتاج كل
/// شاشة تفاصيل تبني initialValues يدويًا)، فيكفي تمرير [apiId] فقط من أي مكان
/// بالتطبيق حتى الزر يشتغل صح.
class BusinessClaimSection extends StatefulWidget {
  final String placeType; // restaurant | hotel | pharmacy | shopping
  final String? apiId;
  final String ownerEmail;

  const BusinessClaimSection({
    super.key,
    required this.placeType,
    required this.apiId,
    required this.ownerEmail,
  });

  @override
  State<BusinessClaimSection> createState() => _BusinessClaimSectionState();
}

class _BusinessClaimSectionState extends State<BusinessClaimSection> {
  bool _loadingStatus = true;
  bool _hasPendingRequest = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadPendingStatus();
  }

  bool get _isMine =>
      widget.ownerEmail.isNotEmpty &&
      widget.ownerEmail == AuthService.instance.currentUserEmail;

  Future<void> _openEdit() async {
    final boxName = _boxNameFor[widget.placeType];
    final schema = _schemaFor[widget.placeType];
    final apiId = widget.apiId;
    if (boxName == null || schema == null || apiId == null) return;

    Map<String, dynamic>? initialValues;
    for (final e in LocalDbService.instance.getAll(boxName)) {
      if (e.value['apiId'] == apiId) {
        initialValues = Map<String, dynamic>.from(e.value);
        break;
      }
    }
    if (initialValues == null || !mounted) return;

    await openOwnerEditForm(
      context,
      boxName: boxName,
      schema: schema,
      apiId: apiId,
      initialValues: initialValues,
    );
  }

  Future<void> _loadPendingStatus() async {
    final token = AuthService.instance.userToken;
    if (token == null || widget.apiId == null || _isMine) {
      setState(() => _loadingStatus = false);
      return;
    }
    final mine = await ApiService.fetchMyOwnershipRequests(token);
    if (!mounted) return;
    setState(() {
      _hasPendingRequest =
          mine?.any(
            (r) =>
                r['placeType'] == widget.placeType &&
                r['placeId'] == widget.apiId &&
                r['status'] == 'pending',
          ) ??
          false;
      _loadingStatus = false;
    });
  }

  Future<void> _submitClaim() async {
    final token = AuthService.instance.userToken;
    if (token == null || widget.apiId == null) return;
    final app = AppState.instance;
    setState(() => _submitting = true);
    final status = await ApiService.submitOwnershipClaim(
      token,
      widget.placeType,
      widget.apiId!,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (status == 201) {
      setState(() => _hasPendingRequest = true);
      _showMessage(
        app.t(
          'تم إرسال طلبك — رح نراجعه ونوافق عليه قريبًا',
          'Your request was sent — we will review it soon',
        ),
        isError: false,
      );
    } else if (status == 409) {
      setState(() => _hasPendingRequest = true);
      _showMessage(
        app.t(
          'عندك طلب مرسل على هاد المكان فعلًا',
          'You already have a request sent for this place',
        ),
      );
    } else if (status == 401 || status == 403) {
      _showMessage(
        app.t(
          'سجّلي دخول من جديد حتى تقدري تبعتي الطلب',
          'Please log in again to send the request',
        ),
      );
    } else if (status == -1) {
      _showMessage(
        app.t(
          'تعذّر الوصول للسيرفر — تأكدي إنه شغال',
          'Could not reach the server — make sure it is running',
        ),
      );
    } else {
      _showMessage(app.t('فشل إرسال الطلب', 'Failed to send the request'));
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.red : AppColors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    // ما منعرض شي لغير المسجّلين (زوار)، للأدمن (عنده صلاحية كاملة أصلًا)، أو
    // للأماكن اللي مش أصلًا من السيرفر (بدون apiId).
    if (widget.apiId == null ||
        AuthService.instance.userToken == null ||
        AuthService.instance.isAdmin) {
      return const SizedBox.shrink();
    }

    if (_isMine) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openEdit,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.teal),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            icon: Icon(Icons.edit_rounded, size: 16, color: AppColors.teal),
            label: Text(
              app.t('تعديل بيانات المحل', 'Edit business info'),
              style: AppTypography.label(AppColors.teal),
            ),
          ),
        ),
      );
    }

    if (_loadingStatus) return const SizedBox.shrink();

    if (_hasPendingRequest) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                size: 16,
                color: AppColors.textGrey,
              ),
              const SizedBox(width: 8),
              Text(
                app.t(
                  'طلب ملكية هذا المكان قيد المراجعة',
                  'Your ownership request is under review',
                ),
                style: AppTypography.label(AppColors.textGrey),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _submitting ? null : _submitClaim,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.borderColor),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          icon: _submitting
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textWhite,
                  ),
                )
              : Icon(
                  Icons.storefront_rounded,
                  size: 16,
                  color: AppColors.textWhite,
                ),
          label: Text(
            app.t('هاد المحل إلي', 'This is my business'),
            style: AppTypography.label(AppColors.textWhite),
          ),
        ),
      ),
    );
  }
}
