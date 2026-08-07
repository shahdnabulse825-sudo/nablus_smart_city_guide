import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../news/news_screen.dart';

/// شريط أخبار متحرك أعلى الصفحة — أخبار حقيقية عن الضفة الغربية (نفس مصدر
/// شاشة الأخبار [NewsScreen])، يتحرك أفقيًا تلقائيًا بدل قسم ثابت.
class NewsTicker extends StatefulWidget {
  const NewsTicker({super.key});

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> {
  final ScrollController _controller = ScrollController();
  Timer? _timer;
  List<Map<String, dynamic>>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final live = await ApiService.fetchLiveWestBankNews();
    if (!mounted) return;
    if (live != null && live.isNotEmpty) {
      setState(() => _items = live);
      _startAutoScroll();
      return;
    }
    // تعذّر الوصول للأخبار المباشرة (مثلاً قيود شبكة) — نستخدم نفس الأخبار
    // المحلية المعروضة بشاشة "آخر الأخبار" بدل ما يختفي الشريط بصمت.
    final app = AppState.instance;
    final local = LocalDbService.instance
        .getAll('news')
        .map(
          (e) => {
            'title': app.isArabic
                ? e.value['titleAr'] as String? ?? ''
                : e.value['titleEn'] as String? ?? '',
          },
        )
        .where((m) => (m['title'] as String).isNotEmpty)
        .toList();
    if (!mounted || local.isEmpty) return;
    setState(() => _items = local);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!_controller.hasClients) return;
      final max = _controller.position.maxScrollExtent;
      if (max <= 0) return;
      final next = _controller.offset + 0.6;
      if (next >= max) {
        _controller.jumpTo(0);
      } else {
        _controller.jumpTo(next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items == null || items.isEmpty) return const SizedBox.shrink();
    final app = AppState.instance;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => NewsScreen())),
      child: Container(
        height: 36,
        color: AppColors.sidebarDark,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              height: double.infinity,
              alignment: Alignment.center,
              color: AppColors.primary.withValues(alpha: 0.14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.campaign_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 5),
                  Text(
                    app.t('أخبار', 'News'),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final item in items)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: Text(
                          (item['title'] as String?) ?? '',
                          textDirection: app.dir,
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
