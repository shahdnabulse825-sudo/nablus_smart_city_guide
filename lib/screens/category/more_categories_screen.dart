import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import 'category_list_screen.dart';
import 'category_data.dart';

/// شاشة "المزيد" تعرض بقية التصنيفات غير الظاهرة بالصف الرئيسي بالشاشة الرئيسية.
class MoreCategoriesScreen extends StatelessWidget {
  MoreCategoriesScreen({super.key});

  final List<Map<String, dynamic>> _items = [
    {
      'labelAr': 'تعليم',
      'labelEn': 'Education',
      'icon': Icons.school,
      'color': AppColors.purple,
      'boxName': 'education',
      'seedData': educationData,
      'subtitleAr': 'الجامعات والمدارس في نابلس',
      'subtitleEn': 'Universities and schools in Nablus',
    },
    {
      'labelAr': 'بنوك وصرافة',
      'labelEn': 'Banks & Exchange',
      'icon': Icons.account_balance,
      'color': AppColors.teal,
      'boxName': 'banks',
      'seedData': banksData,
      'subtitleAr': 'البنوك ومحلات الصرافة',
      'subtitleEn': 'Banks and currency exchange shops',
    },
    {
      'labelAr': 'ترفيه',
      'labelEn': 'Entertainment',
      'icon': Icons.attractions,
      'color': AppColors.red,
      'boxName': 'entertainment',
      'seedData': entertainmentData,
      'subtitleAr': 'أماكن الترفيه والتسلية في المدينة',
      'subtitleEn': 'Entertainment and fun spots in the city',
    },
    {
      'labelAr': 'خدمات حكومية',
      'labelEn': 'Government Services',
      'icon': Icons.apartment,
      'color': AppColors.gold,
      'boxName': 'government',
      'seedData': governmentData,
      'subtitleAr': 'الدوائر الرسمية والخدمات الحكومية',
      'subtitleEn': 'Official departments and government services',
    },
  ];

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
                    color: AppColors.sidebarDark,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Icon(Icons.arrow_back, color: AppColors.textWhite),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.grid_view, color: AppColors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(app.t('المزيد', 'More'),
                            textDirection: app.dir,
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(20),
                      itemCount: _items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.95,
                      ),
                      itemBuilder: (context, i) {
                        final item = _items[i];
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CategoryListScreen(
                                titleAr: item['labelAr'],
                                titleEn: item['labelEn'],
                                bannerSubtitleAr: item['subtitleAr'],
                                bannerSubtitleEn: item['subtitleEn'],
                                icon: item['icon'],
                                boxName: item['boxName'],
                                seedData: item['seedData'],
                              ),
                            ));
                          },
                          child: Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: (item['color'] as Color).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(item['icon'], color: item['color'], size: 24),
                                ),
                                SizedBox(height: 10),
                                Text(app.t(item['labelAr'], item['labelEn']),
                                    textDirection: app.dir,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        );
                      },
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
