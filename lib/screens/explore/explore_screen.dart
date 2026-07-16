import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../common/detail_screen.dart';
import '../restaurants/restaurants_screen.dart';
import '../hotels/hotels_screen.dart';
import '../pharmacies/pharmacies_screen.dart';
import '../attractions/attractions_screen.dart';
import '../shopping/shopping_screen.dart';
import '../category/category_list_screen.dart';
import '../category/category_data.dart';
import '../category/more_categories_screen.dart';
import '../places/all_places_screen.dart';
import '../../theme/app_typography.dart';
import '../../widgets/responsive.dart';
import '../../widgets/keyboard_scrollable.dart';

/// شاشة استكشاف عامة: بحث سريع + كل التصنيفات + أفضل الأماكن تقييمًا بالمدينة.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  late final List<Map<String, dynamic>> _categories = [
    {
      'labelAr': 'مطاعم',
      'labelEn': 'Restaurants',
      'icon': Icons.restaurant,
      'color': AppColors.red,
      'onTap': (BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => RestaurantCategoriesScreen()),
      ),
    },
    {
      'labelAr': 'فنادق',
      'labelEn': 'Hotels',
      'icon': Icons.bed,
      'color': AppColors.purple,
      'onTap': (BuildContext context) => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => HotelsScreen())),
    },
    {
      'labelAr': 'سياحة ومعالم',
      'labelEn': 'Attractions',
      'icon': Icons.mosque,
      'color': AppColors.gold,
      'onTap': (BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => AttractionCategoriesScreen()),
      ),
    },
    {
      'labelAr': 'تسوق',
      'labelEn': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': AppColors.primary,
      'onTap': (BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ShoppingCategoriesScreen()),
      ),
    },
    {
      'labelAr': 'مواصلات',
      'labelEn': 'Transport',
      'icon': Icons.directions_bus,
      'color': AppColors.teal,
      'onTap': (BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CategoryListScreen(
            titleAr: 'مواصلات',
            titleEn: 'Transport',
            bannerSubtitleAr: 'كل خيارات التنقل داخل نابلس',
            bannerSubtitleEn: 'All transportation options within Nablus',
            icon: Icons.directions_bus,
            boxName: 'transport',
            seedData: transportData,
          ),
        ),
      ),
    },
    {
      'labelAr': 'صحة',
      'labelEn': 'Health',
      'icon': Icons.favorite,
      'color': AppColors.teal,
      'onTap': (BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CategoryListScreen(
            titleAr: 'صحة',
            titleEn: 'Health',
            bannerSubtitleAr: 'المستشفيات والعيادات في نابلس',
            bannerSubtitleEn: 'Hospitals and clinics in Nablus',
            icon: Icons.favorite,
            boxName: 'health',
            seedData: healthData,
          ),
        ),
      ),
    },
    {
      'labelAr': 'صيدليات',
      'labelEn': 'Pharmacies',
      'icon': Icons.local_pharmacy,
      'color': AppColors.primary,
      'onTap': (BuildContext context) => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => PharmaciesScreen())),
    },
    {
      'labelAr': 'المزيد',
      'labelEn': 'More',
      'icon': Icons.grid_view,
      'color': AppColors.textGrey,
      'onTap': (BuildContext context) => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => MoreCategoriesScreen())),
    },
  ];

  List<UniversalPlace> get _searchResults {
    if (searchQuery.isEmpty) return [];
    return allPlaces
        .where(
          (p) =>
              p.nameAr.contains(searchQuery) ||
              p.nameEn.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<UniversalPlace> get _topRated {
    final list = List.of(allPlaces)
      ..sort((a, b) => b.rating.compareTo(a.rating));
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
                            gradient: LinearGradient(
                              colors: AppColors.primaryGradient,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.explore_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          app.t('استكشف', 'Explore'),
                          textDirection: app.dir,
                          style: AppTypography.title(
                            AppColors.textWhite,
                          ).copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: KeyboardScrollable(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 50,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                ),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.14,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.search_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (v) =>
                                          setState(() => searchQuery = v),
                                      style: AppTypography.body(
                                        AppColors.textWhite,
                                      ),
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        border: InputBorder.none,
                                        hintText: app.t(
                                          'ابحث عن مكان، مطعم، فندق، معلم...',
                                          'Search for a place, restaurant, hotel...',
                                        ),
                                        hintStyle: AppTypography.body(
                                          AppColors.textGrey,
                                        ).copyWith(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (searchQuery.isNotEmpty) ...[
                              SizedBox(height: 20),
                              Text(
                                app.t('نتائج البحث', 'Search Results'),
                                textDirection: app.dir,
                                style: AppTypography.headline(
                                  AppColors.textWhite,
                                ).copyWith(fontSize: 16),
                              ),
                              SizedBox(height: 12),
                              if (results.isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 30),
                                  child: Center(
                                    child: Text(
                                      app.t(
                                        'لا توجد نتائج مطابقة',
                                        'No matching results',
                                      ),
                                      style: AppTypography.body(
                                        AppColors.textGrey,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...results.map(
                                  (p) => _placeRow(context, app, p),
                                ),
                            ] else ...[
                              SizedBox(height: 24),
                              Text(
                                app.t('التصنيفات', 'Categories'),
                                textDirection: app.dir,
                                style: AppTypography.headline(
                                  AppColors.textWhite,
                                ).copyWith(fontSize: 16),
                              ),
                              SizedBox(height: 14),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _categories.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: responsiveGridColumns(
                                        context,
                                        wide: 4,
                                        narrow: 3,
                                      ),
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      childAspectRatio: 0.85,
                                    ),
                                itemBuilder: (context, i) {
                                  final c = _categories[i];
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () =>
                                        (c['onTap'] as Function)(context),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                c['color'] as Color,
                                                (c['color'] as Color)
                                                    .withValues(alpha: 0.7),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.lg,
                                            ),
                                            boxShadow: AppColors.cardShadow,
                                          ),
                                          child: Icon(
                                            c['icon'],
                                            color: Colors.white,
                                            size: 26,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          app.t(c['labelAr'], c['labelEn']),
                                          textDirection: app.dir,
                                          textAlign: TextAlign.center,
                                          style:
                                              AppTypography.label(
                                                AppColors.textWhite,
                                              ).copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 28),
                              Text(
                                app.t('الأعلى تقييمًا', 'Top Rated'),
                                textDirection: app.dir,
                                style: AppTypography.headline(
                                  AppColors.textWhite,
                                ).copyWith(fontSize: 16),
                              ),
                              SizedBox(height: 14),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _topRated.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: responsiveGridColumns(
                                        context,
                                        wide: 4,
                                        narrow: 2,
                                      ),
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
    Navigator.of(context).push(
      MaterialPageRoute(
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
          customImageBase64: p.customImageBase64,
          localAsset: p.image,
        ),
      ),
    );
  }

  Widget _placeRow(BuildContext context, AppState app, UniversalPlace p) {
    final name = app.isArabic ? p.nameAr : p.nameEn;
    final type = app.isArabic ? p.typeAr : p.typeEn;
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: EdgeInsets.all(10),
        onTap: () => _openDetail(context, p),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: ThemedImage(
                query: p.photoQuery,
                fallbackSeed: p.nameEn,
                height: 48,
                fallbackIcon: p.icon,
                fallbackColor: p.color,
                customImageBase64: p.customImageBase64,
                localAsset: p.image,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    name,
                    textDirection: app.dir,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(AppColors.textWhite),
                  ),
                  Text(
                    type,
                    textDirection: app.dir,
                    style: AppTypography.caption(AppColors.textGrey),
                  ),
                ],
              ),
            ),
            Icon(Icons.star_rounded, size: 13, color: AppColors.gold),
            SizedBox(width: 3),
            Text(
              '${p.rating}',
              style: AppTypography.label(AppColors.textWhite),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeCard(BuildContext context, AppState app, UniversalPlace p) {
    final name = app.isArabic ? p.nameAr : p.nameEn;
    final type = app.isArabic ? p.typeAr : p.typeEn;
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => _openDetail(context, p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ThemedImage(
                  query: p.photoQuery,
                  fallbackSeed: p.nameEn,
                  height: double.infinity,
                  fallbackIcon: p.icon,
                  fallbackColor: p.color,
                  customImageBase64: p.customImageBase64,
                  localAsset: p.image,
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded, size: 10, color: Colors.white),
                        SizedBox(width: 2),
                        Text(
                          '${p.rating}',
                          style: AppTypography.caption(Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(AppColors.textWhite),
                ),
                SizedBox(height: 2),
                Text(
                  type,
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(AppColors.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
