import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../common/detail_screen.dart';
import '../restaurants/restaurants_screen.dart';
import '../category/category_list_screen.dart';
import '../category/category_data.dart';
import '../category/more_categories_screen.dart';
import '../places/all_places_screen.dart';

/// شاشة استكشاف عامة: بحث سريع + كل التصنيفات + أفضل الأماكن تقييمًا بالمدينة.
class ExploreScreen extends StatefulWidget {
  ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String searchQuery = '';

  late final List<Map<String, dynamic>> _categories = [
    {
      'labelAr': 'مطاعم',
      'labelEn': 'Restaurants',
      'icon': Icons.restaurant,
      'color': AppColors.red,
      'onTap': (BuildContext context) => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => RestaurantsScreen())),
    },
    {
      'labelAr': 'فنادق',
      'labelEn': 'Hotels',
      'icon': Icons.bed,
      'color': AppColors.purple,
      'onTap': (BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CategoryListScreen(
              titleAr: 'فنادق',
              titleEn: 'Hotels',
              bannerSubtitleAr: 'أفضل أماكن الإقامة في نابلس',
              bannerSubtitleEn: 'The best places to stay in Nablus',
              icon: Icons.bed,
              boxName: 'hotels',
              seedData: hotelsData,
            ),
          )),
    },
    {
      'labelAr': 'سياحة ومعالم',
      'labelEn': 'Attractions',
      'icon': Icons.mosque,
      'color': AppColors.gold,
      'onTap': (BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CategoryListScreen(
              titleAr: 'سياحة ومعالم',
              titleEn: 'Attractions',
              bannerSubtitleAr: 'اكتشف أجمل معالم نابلس التاريخية والطبيعية',
              bannerSubtitleEn: 'Discover the finest historic and natural landmarks of Nablus',
              icon: Icons.mosque,
              boxName: 'attractions',
              seedData: attractionsData,
            ),
          )),
    },
    {
      'labelAr': 'تسوق',
      'labelEn': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': AppColors.blue,
      'onTap': (BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CategoryListScreen(
              titleAr: 'تسوق',
              titleEn: 'Shopping',
              bannerSubtitleAr: 'أفضل أماكن التسوق في المدينة',
              bannerSubtitleEn: 'The best shopping spots in the city',
              icon: Icons.shopping_bag,
              boxName: 'shopping',
              seedData: shoppingData,
            ),
          )),
    },
    {
      'labelAr': 'مواصلات',
      'labelEn': 'Transport',
      'icon': Icons.directions_bus,
      'color': AppColors.teal,
      'onTap': (BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CategoryListScreen(
              titleAr: 'مواصلات',
              titleEn: 'Transport',
              bannerSubtitleAr: 'كل خيارات التنقل داخل نابلس',
              bannerSubtitleEn: 'All transportation options within Nablus',
              icon: Icons.directions_bus,
              boxName: 'transport',
              seedData: transportData,
            ),
          )),
    },
    {
      'labelAr': 'صحة',
      'labelEn': 'Health',
      'icon': Icons.favorite,
      'color': AppColors.teal,
      'onTap': (BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CategoryListScreen(
              titleAr: 'صحة',
              titleEn: 'Health',
              bannerSubtitleAr: 'المستشفيات والعيادات في نابلس',
              bannerSubtitleEn: 'Hospitals and clinics in Nablus',
              icon: Icons.favorite,
              boxName: 'health',
              seedData: healthData,
            ),
          )),
    },
    {
      'labelAr': 'صيدليات',
      'labelEn': 'Pharmacies',
      'icon': Icons.local_pharmacy,
      'color': AppColors.blue,
      'onTap': (BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CategoryListScreen(
              titleAr: 'صيدليات',
              titleEn: 'Pharmacies',
              bannerSubtitleAr: 'أقرب الصيدليات وأوقات عملها',
              bannerSubtitleEn: 'Nearest pharmacies and their working hours',
              icon: Icons.local_pharmacy,
              boxName: 'pharmacies',
              seedData: pharmaciesData,
            ),
          )),
    },
    {
      'labelAr': 'المزيد',
      'labelEn': 'More',
      'icon': Icons.grid_view,
      'color': AppColors.textGrey,
      'onTap': (BuildContext context) => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => MoreCategoriesScreen())),
    },
  ];

  List<UniversalPlace> get _searchResults {
    if (searchQuery.isEmpty) return [];
    return allPlaces
        .where((p) =>
            p.nameAr.contains(searchQuery) ||
            p.nameEn.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  List<UniversalPlace> get _topRated {
    final list = List.of(allPlaces)..sort((a, b) => b.rating.compareTo(a.rating));
    return list.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final results = _searchResults;
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
                        Icon(Icons.explore, color: AppColors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(app.t('استكشف', 'Explore'),
                            textDirection: app.dir,
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 46,
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(23),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: AppColors.textGrey),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    onChanged: (v) => setState(() => searchQuery = v),
                                    style: TextStyle(color: AppColors.textWhite),
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      border: InputBorder.none,
                                      hintText: app.t(
                                          'ابحث عن مكان، مطعم، فندق، معلم...',
                                          'Search for a place, restaurant, hotel...'),
                                      hintStyle:
                                          TextStyle(color: AppColors.textGrey, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (searchQuery.isNotEmpty) ...[
                            SizedBox(height: 20),
                            Text(app.t('نتائج البحث', 'Search Results'),
                                textDirection: app.dir,
                                style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                            if (results.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: Center(
                                  child: Text(
                                      app.t('لا توجد نتائج مطابقة', 'No matching results'),
                                      style: TextStyle(color: AppColors.textGrey)),
                                ),
                              )
                            else
                              ...results.map((p) => _placeRow(context, app, p)),
                          ] else ...[
                            SizedBox(height: 24),
                            Text(app.t('التصنيفات', 'Categories'),
                                textDirection: app.dir,
                                style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 14),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _categories.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.85,
                              ),
                              itemBuilder: (context, i) {
                                final c = _categories[i];
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => (c['onTap'] as Function)(context),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: (c['color'] as Color).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(c['icon'], color: c['color'], size: 26),
                                      ),
                                      SizedBox(height: 6),
                                      Text(app.t(c['labelAr'], c['labelEn']),
                                          textDirection: app.dir,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: AppColors.textWhite, fontSize: 11)),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 28),
                            Text(app.t('الأعلى تقييمًا', 'Top Rated'),
                                textDirection: app.dir,
                                style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 14),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _topRated.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.75,
                              ),
                              itemBuilder: (context, i) {
                                final p = _topRated[i];
                                return _placeCard(context, app, p);
                              },
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

  void _openDetail(BuildContext context, UniversalPlace p) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DetailScreen(
        titleAr: p.nameAr,
        titleEn: p.nameEn,
        subtitleAr: p.typeAr,
        subtitleEn: p.typeEn,
        descriptionAr: p.aboutAr,
        descriptionEn: p.aboutEn,
        rating: p.rating,
        locationAr: p.locationAr,
        locationEn: p.locationEn,
      ),
    ));
  }

  Widget _placeRow(BuildContext context, AppState app, UniversalPlace p) {
    final name = app.isArabic ? p.nameAr : p.nameEn;
    final type = app.isArabic ? p.typeAr : p.typeEn;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(context, p),
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ThemedImage(
                query: p.photoQuery,
                fallbackSeed: p.nameEn,
                height: 48,
                fallbackIcon: p.icon,
                fallbackColor: p.color,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name,
                      textDirection: app.dir,
                      style: TextStyle(
                          color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(type,
                      textDirection: app.dir,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.star, size: 13, color: AppColors.gold),
            SizedBox(width: 3),
            Text('${p.rating}', style: TextStyle(color: AppColors.textWhite, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _placeCard(BuildContext context, AppState app, UniversalPlace p) {
    final name = app.isArabic ? p.nameAr : p.nameEn;
    final type = app.isArabic ? p.typeAr : p.typeEn;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(context, p),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ThemedImage(
                  query: p.photoQuery,
                  fallbackSeed: p.nameEn,
                  height: 90,
                  fallbackIcon: p.icon,
                  fallbackColor: p.color,
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration:
                        BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 10, color: Colors.white),
                        SizedBox(width: 2),
                        Text('${p.rating}',
                            style: TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name,
                      textDirection: app.dir,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text(type,
                      textDirection: app.dir,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
