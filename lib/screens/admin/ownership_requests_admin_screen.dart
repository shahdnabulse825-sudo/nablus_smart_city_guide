import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../theme/app_typography.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

const Map<String, (String, String)> _placeTypeLabel = {
  'restaurant': ('مطعم', 'Restaurant'),
  'hotel': ('فندق', 'Hotel'),
  'pharmacy': ('صيدلية', 'Pharmacy'),
  'shopping': ('محل تجاري', 'Shop'),
};

/// شاشة أدمن لمراجعة طلبات ملكية المحلات (مطاعم/فنادق/صيدليات/تسوق) اللي
/// بعتها أصحابها من داخل التطبيق — موافقة الأدمن هون هي اللي فعليًا بتربط
/// المحل بحساب صاحب الطلب (انظر PUT /api/ownership-requests/:id/approve).
class OwnershipRequestsAdminScreen extends StatefulWidget {
  const OwnershipRequestsAdminScreen({super.key});

  @override
  State<OwnershipRequestsAdminScreen> createState() =>
      _OwnershipRequestsAdminScreenState();
}

class _OwnershipRequestsAdminScreenState
    extends State<OwnershipRequestsAdminScreen> {
  String _filter = 'pending';
  bool _loading = true;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final token = AuthService.instance.adminToken;
    if (token == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final items = await ApiService.fetchAllOwnershipRequests(
      token,
      status: _filter,
    );
    if (!mounted) return;
    setState(() {
      _requests = items ?? [];
      _loading = false;
    });
  }

  Future<void> _approve(String id) async {
    final token = AuthService.instance.adminToken;
    if (token == null) return;
    final ok = await ApiService.approveOwnershipRequest(token, id);
    if (!mounted) return;
    _showResult(ok);
    if (ok) _refresh();
  }

  Future<void> _reject(String id) async {
    final token = AuthService.instance.adminToken;
    if (token == null) return;
    final ok = await ApiService.rejectOwnershipRequest(token, id);
    if (!mounted) return;
    _showResult(ok);
    if (ok) _refresh();
  }

  void _showResult(bool ok) {
    final app = AppState.instance;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? app.t('تم تحديث الطلب', 'Request updated')
              : app.t(
                  'فشلت العملية — تأكدي إنه السيرفر شغال',
                  'Operation failed — make sure the server is running',
                ),
        ),
        backgroundColor: ok ? AppColors.teal : AppColors.red,
      ),
    );
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
                            app.t('طلبات ملكية المحلات', 'Business Ownership Requests'),
                            textDirection: app.dir,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title(
                              AppColors.textWhite,
                            ).copyWith(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: app.t('قيد المراجعة', 'Pending'),
                          selected: _filter == 'pending',
                          onTap: () => setState(() {
                            _filter = 'pending';
                            _refresh();
                          }),
                        ),
                        SizedBox(width: 8),
                        _FilterChip(
                          label: app.t('مقبولة', 'Approved'),
                          selected: _filter == 'approved',
                          onTap: () => setState(() {
                            _filter = 'approved';
                            _refresh();
                          }),
                        ),
                        SizedBox(width: 8),
                        _FilterChip(
                          label: app.t('مرفوضة', 'Rejected'),
                          selected: _filter == 'rejected',
                          onTap: () => setState(() {
                            _filter = 'rejected';
                            _refresh();
                          }),
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
                        : _requests.isEmpty
                        ? Center(
                            child: Text(
                              app.t('لا يوجد طلبات هون', 'No requests here'),
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _requests.length,
                            itemBuilder: (context, i) => _RequestCard(
                              request: _requests[i],
                              onApprove: () => _approve(_requests[i]['id']),
                              onReject: () => _reject(_requests[i]['id']),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textGrey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _RequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final placeType = request['placeType'] as String;
    final label = _placeTypeLabel[placeType];
    final placeName = app.isArabic
        ? (request['placeNameAr'] as String? ?? '')
        : (request['placeNameEn'] as String? ?? '');
    final status = request['status'] as String;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  placeName,
                  textDirection: app.dir,
                  style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 14),
                ),
              ),
              if (label != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark2,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    app.t(label.$1, label.$2),
                    style: TextStyle(color: AppColors.textGrey, fontSize: 10),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            '${request['requesterName'] ?? ''} — ${request['requesterEmail'] ?? ''}',
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          if ((request['message'] as String?)?.isNotEmpty == true) ...[
            SizedBox(height: 6),
            Text(
              request['message'],
              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          ],
          if (status == 'pending') ...[
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.red),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: Text(
                      app.t('رفض', 'Reject'),
                      style: TextStyle(color: AppColors.red, fontSize: 12),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: Text(
                      app.t('قبول', 'Approve'),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
