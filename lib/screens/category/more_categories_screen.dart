import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import 'category_list_screen.dart';
import 'category_data.dart';
import '../../theme/app_typography.dart';
import '../../widgets/responsive.dart';

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
      'photoQuery': 'university campus Nablus',
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
      'photoQuery': 'bank building Nablus',
      'localAsset': 'assets/images/category_icons/banks.jpg',
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
      'photoQuery': 'entertainment amusement park Nablus',
      'localAsset': 'assets/images/category_icons/entertainment.webp',
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
      'photoQuery': 'government building Nablus',
      'localAsset': 'assets/images/category_icons/government.png',
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
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppColors.cardDark, shape: BoxShape.circle),
                            child: Icon(Icons.arrow_back_rounded, color: AppColors.textWhite, size: 18),
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
                          child: Icon(Icons.grid_view_rounded, color: Colors.white, size: 16),
                        ),
                        SizedBox(width: 10),
                        Text(
                          app.t('المزيد', 'More'),
                          textDirection: app.dir,
                          style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(20),
                      itemCount: _items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: responsiveGridColumns(context, wide: 3, narrow: 2),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.95,
                      ),
                      itemBuilder: (context, i) {
                        final item = _items[i];
                        return AppCard(
                          padding: EdgeInsets.zero,
                          radius: AppRadius.lg,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CategoryListScreen(
                                  titleAr: item['labelAr'],
                                  titleEn: item['labelEn'],
                                  bannerSubtitleAr: item['subtitleAr'],
                                  bannerSubtitleEn: item['subtitleEn'],
                                  icon: item['icon'],
                                  boxName: item['boxName'],
                                  seedData: item['seedData'],
                                ),
                              ),
                            );
                          },
                          child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ThemedImage(
                                  query: item['photoQuery'] as String,
                                  localAsset: item['localAsset'] as String?,
                                  fallbackSeed: item['boxName'] as String,
                                  height: double.infinity,
                                  fallbackIcon: item['icon'],
                                  fallbackColor: item['color'],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.25),
                                        Colors.black.withValues(alpha: 0.75),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(14),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              item['color'] as Color,
                                              (item['color'] as Color).withValues(alpha: 0.7),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(AppRadius.md),
                                          boxShadow: AppColors.cardShadow,
                                        ),
                                        child: Icon(
                                          item['icon'],
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        app.t(item['labelAr'], item['labelEn']),
                                        textDirection: app.dir,
                                        textAlign: TextAlign.center,
                                        style: AppTypography.label(Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
