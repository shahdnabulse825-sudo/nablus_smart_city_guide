import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart'; // لإعادة استخدام AppState و AppColors

/// بانر تحذيري يظهر بأي شاشة تفاصيل مكان لو كان معلّقًا مؤقتًا للصيانة —
/// نفس الشكل والنص بكل مكان يُستخدم فيه، عشان الأدمن يعلّم مكان من لوحة
/// الإدارة (انظر [LocalDbService.suspensionStatus]) وينعكس فورًا لكل المستخدمين.
class SuspensionBanner extends StatelessWidget {
  final ({DateTime? until, String reason}) suspension;
  const SuspensionBanner({super.key, required this.suspension});

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.35)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.build_circle_rounded, color: AppColors.red, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.t(
                    'هذا المكان مغلّق مؤقتًا للصيانة',
                    'This place is temporarily closed for maintenance',
                  ),
                  textDirection: app.dir,
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (suspension.reason.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    suspension.reason,
                    textDirection: app.dir,
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                ],
                if (suspension.until != null) ...[
                  SizedBox(height: 4),
                  Text(
                    app.t(
                      'من المتوقع العودة بتاريخ ${_formatDate(suspension.until!)}',
                      'Expected to reopen on ${_formatDate(suspension.until!)}',
                    ),
                    textDirection: app.dir,
                    style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
