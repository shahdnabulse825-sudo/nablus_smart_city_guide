import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'responsive.dart';

/// شريط ترقيم صفحات مشترك (نفس تصميم _Pagination الأصلي بشاشة المطاعم)،
/// يُستخدم بكل شاشات الأقسام حتى ما يتكرر نفس التصميم بكل شاشة على حدة.
class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final void Function(int) onPageChange;
  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) return const SizedBox.shrink();
    final pageRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: currentPage > 0 ? () => onPageChange(currentPage - 1) : null,
          child: Icon(
            Icons.chevron_right,
            color: currentPage > 0 ? AppColors.textWhite : AppColors.borderColor,
          ),
        ),
        SizedBox(width: 8),
        for (int p = 0; p < pageCount; p++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onPageChange(p),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p == currentPage ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${p + 1}',
                style: TextStyle(
                  color: p == currentPage ? Colors.white : AppColors.textWhite,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        SizedBox(width: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: currentPage < pageCount - 1 ? () => onPageChange(currentPage + 1) : null,
          child: Icon(
            Icons.chevron_left,
            color: currentPage < pageCount - 1 ? AppColors.textWhite : AppColors.borderColor,
          ),
        ),
      ],
    );
    if (!isMobile(context)) {
      return Center(child: pageRow);
    }
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: pageRow);
  }
}
