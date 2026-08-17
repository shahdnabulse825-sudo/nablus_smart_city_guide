import 'package:flutter/material.dart';
import 'home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../theme/app_typography.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../admin/admin_screen.dart' show openOwnerEditForm, AdminSchema;

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

const Map<String, (String, String)> _placeTypeLabel = {
  'restaurant': ('مطعم', 'Restaurant'),
  'hotel': ('فندق', 'Hotel'),
  'pharmacy': ('صيدلية', 'Pharmacy'),
  'shopping': ('محل تجاري', 'Shop'),
};

/// يحوّل عنصر خام جاي من `/ownership-requests/my-listings` (نفس شكل رد
/// السيرفر مباشرة) لخريطة متوافقة مع [AdminFormScreen] (نفس تحويل serverImageUrl
/// اللي بتعمله [ApiService._syncBoxFromApi] لكل عناصر لوحة الأدمن).
Map<String, dynamic> _toFormInitialValues(Map<String, dynamic> raw) {
  final m = Map<String, dynamic>.from(raw);
  m['serverImageUrl'] = m['imageUrl'];
  m['customImageBase64'] = null;
  m['image'] = '';
  return m;
}

/// شاشة "أعمالي" — بتعرض لصاحب حساب عادي كل المحلات (مطعم/فندق/صيدلية/تسوق)
/// اللي وافق الأدمن على ربطها فيه، وحالة أي طلبات ملكية سابقة (معلّقة/مرفوضة).
class MyBusinessesScreen extends StatefulWidget {
  const MyBusinessesScreen({super.key});

  @override
  State<MyBusinessesScreen> createState() => _MyBusinessesScreenState();
}

class _MyBusinessesScreenState extends State<MyBusinessesScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _listings = [];
  List<Map<String, dynamic>> _pendingOrRejected = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final token = AuthService.instance.userToken;
    if (token == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final listings = await ApiService.fetchMyOwnedListings(token);
    final requests = await ApiService.fetchMyOwnershipRequests(token);
    if (!mounted) return;
    setState(() {
      _listings = listings ?? [];
      _pendingOrRejected =
          (requests ?? []).where((r) => r['status'] != 'approved').toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.sidebarDark, AppColors.cardDark2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.textWhite,
                              size: 18,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.primaryGradient),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            app.t('أعمالي', 'My Businesses'),
                            textDirection: app.dir,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title(
                              AppColors.textWhite,
                            ).copyWith(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            color: AppColors.primary,
                            child: _listings.isEmpty &&
                                    _pendingOrRejected.isEmpty
                                ? _EmptyState(app: app)
                                : ListView(
                                    padding: EdgeInsets.all(16),
                                    children: [
                                      ..._listings.map(
                                        (item) => _OwnedListingCard(
                                          item: item,
                                          onEdited: _refresh,
                                        ),
                                      ),
                                      if (_pendingOrRejected.isNotEmpty) ...[
                                        SizedBox(height: 8),
                                        Text(
                                          app.t(
                                            'طلبات سابقة',
                                            'Past requests',
                                          ),
                                          textDirection: app.dir,
                                          style: AppTypography.label(
                                            AppColors.textGrey,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        ..._pendingOrRejected.map(
                                          (r) => _RequestStatusCard(request: r),
                                        ),
                                      ],
                                    ],
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppState app;
  const _EmptyState({required this.app});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        SizedBox(height: 60),
        Icon(
          Icons.storefront_outlined,
          size: 56,
          color: AppColors.textGrey,
        ),
        SizedBox(height: 16),
        Text(
          app.t(
            'ما عندك محلات مرتبطة بحسابك لسا. لو إنت صاحب مطعم أو فندق أو صيدلية أو محل، افتح صفحته بالتطبيق واضغط "هاد المحل إلي".',
            'You don\'t have any businesses linked to your account yet. If you own a restaurant, hotel, pharmacy, or shop, open its page in the app and tap "This is my business".',
          ),
          textAlign: TextAlign.center,
          textDirection: app.dir,
          style: TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }
}

class _OwnedListingCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdited;
  const _OwnedListingCard({required this.item, required this.onEdited});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final placeType = item['placeType'] as String;
    final label = _placeTypeLabel[placeType];
    final nameAr = item['nameAr'] as String? ?? '';
    final nameEn = item['nameEn'] as String? ?? '';
    final apiId = item['id'] as String;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.isArabic ? nameAr : nameEn,
                  textDirection: app.dir,
                  style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 14),
                ),
                if (label != null) ...[
                  SizedBox(height: 4),
                  Text(
                    app.t(label.$1, label.$2),
                    textDirection: app.dir,
                    style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              await openOwnerEditForm(
                context,
                boxName: _boxNameFor[placeType]!,
                schema: _schemaFor[placeType]!,
                apiId: apiId,
                initialValues: _toFormInitialValues(item),
              );
              onEdited();
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestStatusCard extends StatelessWidget {
  final Map<String, dynamic> request;
  const _RequestStatusCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final status = request['status'] as String;
    final isRejected = status == 'rejected';
    final name = app.isArabic
        ? (request['placeNameAr'] as String? ?? '')
        : (request['placeNameEn'] as String? ?? '');

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(
            isRejected ? Icons.close_rounded : Icons.hourglass_top_rounded,
            size: 16,
            color: isRejected ? AppColors.red : AppColors.textGrey,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              textDirection: app.dir,
              style: TextStyle(color: AppColors.textWhite, fontSize: 12),
            ),
          ),
          Text(
            isRejected
                ? app.t('مرفوض', 'Rejected')
                : app.t('قيد المراجعة', 'Pending'),
            style: TextStyle(
              color: isRejected ? AppColors.red : AppColors.textGrey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
