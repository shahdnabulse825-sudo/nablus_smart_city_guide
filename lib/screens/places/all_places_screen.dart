import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../common/detail_screen.dart';
import '../category/category_data.dart';
import '../restaurants/restaurants_screen.dart'
    show restaurantsSeedData, restaurantPhotoQuery, RestaurantData;

/// عنصر موحّد يمثل أي مكان (مطعم، فندق، معلم، محل تسوق...) لعرضه بشاشة واحدة.
class UniversalPlace {
  final String nameAr;
  final String nameEn;
  final String typeAr;
  final String typeEn;
  final String locationAr;
  final String locationEn;
  final String categoryKey;
  final double rating;
  final int reviews;
  final String aboutAr;
  final String aboutEn;
  final String photoQuery;
  final IconData icon;
  final Color color;

  UniversalPlace({
    required this.nameAr,
    required this.nameEn,
    required this.typeAr,
    required this.typeEn,
    required this.locationAr,
    required this.locationEn,
    required this.categoryKey,
    required this.rating,
    required this.reviews,
    required this.aboutAr,
    required this.aboutEn,
    required this.photoQuery,
    required this.icon,
    required this.color,
  });
}

UniversalPlace _fromListing(ListingItem it, String categoryKey) => UniversalPlace(
      nameAr: it.nameAr,
      nameEn: it.nameEn,
      typeAr: it.typeAr,
      typeEn: it.typeEn,
      locationAr: it.locationAr,
      locationEn: it.locationEn,
      categoryKey: categoryKey,
      rating: it.rating,
      reviews: it.reviews,
      aboutAr: it.aboutAr,
      aboutEn: it.aboutEn,
      photoQuery: it.photoQuery,
      icon: it.placeholderIcon,
      color: it.placeholderColor,
    );

UniversalPlace _fromRestaurant(RestaurantData r) => UniversalPlace(
      nameAr: r.nameAr,
      nameEn: r.nameEn,
      typeAr: r.categoryAr,
      typeEn: r.categoryEn,
      locationAr: r.locationAr,
      locationEn: r.locationEn,
      categoryKey: 'restaurant',
      rating: r.rating,
      reviews: r.reviews,
      aboutAr: r.aboutAr,
      aboutEn: r.aboutEn,
      photoQuery: restaurantPhotoQuery(r),
      icon: r.placeholderIcon,
      color: r.placeholderColor,
    );

final List<UniversalPlace> allPlaces = [
  ...attractionsData.map((it) => _fromListing(it, 'attraction')),
  ...hotelsData.map((it) => _fromListing(it, 'hotel')),
  ...shoppingData.map((it) => _fromListing(it, 'shopping')),
  ...transportData.map((it) => _fromListing(it, 'transport')),
  ...healthData.map((it) => _fromListing(it, 'health')),
  ...pharmaciesData.map((it) => _fromListing(it, 'pharmacy')),
  ...educationData.map((it) => _fromListing(it, 'education')),
  ...banksData.map((it) => _fromListing(it, 'bank')),
  ...entertainmentData.map((it) => _fromListing(it, 'entertainment')),
  ...governmentData.map((it) => _fromListing(it, 'government')),
  ...restaurantsSeedData.map(_fromRestaurant),
];

final Map<String, IconData> _categoryChipIcons = {
  'all': Icons.apps,
  'attraction': Icons.mosque,
  'hotel': Icons.bed,
  'restaurant': Icons.restaurant,
  'shopping': Icons.shopping_bag,
  'transport': Icons.directions_bus,
  'health': Icons.favorite,
  'pharmacy': Icons.local_pharmacy,
  'education': Icons.school,
  'bank': Icons.account_balance,
  'entertainment': Icons.attractions,
  'government': Icons.apartment,
};

final Map<String, String> _categoryLabelsAr = {
  'all': 'الكل',
  'attraction': 'سياحة ومعالم',
  'hotel': 'فنادق',
  'restaurant': 'مطاعم',
  'shopping': 'تسوق',
  'transport': 'مواصلات',
  'health': 'صحة',
  'pharmacy': 'صيدليات',
  'education': 'تعليم',
  'bank': 'بنوك',
  'entertainment': 'ترفيه',
  'government': 'حكومي',
};

final Map<String, String> _categoryLabelsEn = {
  'all': 'All',
  'attraction': 'Attractions',
  'hotel': 'Hotels',
  'restaurant': 'Restaurants',
  'shopping': 'Shopping',
  'transport': 'Transport',
  'health': 'Health',
  'pharmacy': 'Pharmacies',
  'education': 'Education',
  'bank': 'Banks',
  'entertainment': 'Entertainment',
  'government': 'Government',
};

enum PlacesSortMode { featured, topRated, newest }

/// شاشة موحّدة تعرض كل الأماكن (مطاعم، فنادق، معالم، تسوق...) قابلة للبحث
/// والتصفية، تُستخدم كوجهة "عرض الكل" لأقسام الأماكن المفضلة/الأكثر زيارة/أحدث الأماكن.
class AllPlacesScreen extends StatefulWidget {
  final String titleAr;
  final String titleEn;
  final PlacesSortMode sortMode;

  AllPlacesScreen({
    super.key,
    required this.titleAr,
    required this.titleEn,
    this.sortMode = PlacesSortMode.featured,
  });

  @override
  State<AllPlacesScreen> createState() => _AllPlacesScreenState();
}

class _AllPlacesScreenState extends State<AllPlacesScreen> {
  String categoryFilter = 'all';
  String searchQuery = '';

  List<UniversalPlace> get _baseList {
    switch (widget.sortMode) {
      case PlacesSortMode.topRated:
        return List.of(allPlaces)..sort((a, b) => b.rating.compareTo(a.rating));
      case PlacesSortMode.newest:
        return allPlaces.reversed.toList();
      case PlacesSortMode.featured:
        return allPlaces;
    }
  }

  List<UniversalPlace> get _filtered {
    return _baseList.where((p) {
      final matchesCategory = categoryFilter == 'all' || p.categoryKey == categoryFilter;
      final matchesSearch = searchQuery.isEmpty ||
          p.nameAr.contains(searchQuery) ||
          p.nameEn.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final filtered = _filtered;
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
                        Icon(Icons.place, color: AppColors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(app.t(widget.titleAr, widget.titleEn),
                            textDirection: app.dir,
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Container(
                      height: 42,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 18, color: AppColors.textGrey),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => searchQuery = v),
                              style: TextStyle(color: AppColors.textWhite, fontSize: 13),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: app.t('ابحث عن مكان...', 'Search a place...'),
                                hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: SizedBox(
                      height: 34,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _categoryChipIcons.keys.map((key) {
                          final selected = categoryFilter == key;
                          return Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => categoryFilter = key),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.blue : AppColors.cardDark2,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: selected ? AppColors.blue : AppColors.borderColor),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_categoryChipIcons[key],
                                        size: 13, color: selected ? Colors.white : AppColors.textGrey),
                                    SizedBox(width: 5),
                                    Text(
                                        app.isArabic
                                            ? _categoryLabelsAr[key]!
                                            : _categoryLabelsEn[key]!,
                                        style: TextStyle(
                                            color: selected ? Colors.white : AppColors.textWhite,
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(app.t('لا توجد نتائج مطابقة', 'No matching results'),
                                style: TextStyle(color: AppColors.textGrey)),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: filtered.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.75,
                            ),
                            itemBuilder: (context, i) {
                              final p = filtered[i];
                              final name = app.isArabic ? p.nameAr : p.nameEn;
                              final type = app.isArabic ? p.typeAr : p.typeEn;
                              final location = app.isArabic ? p.locationAr : p.locationEn;
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
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
                                },
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
                                            height: 100,
                                            fallbackIcon: p.icon,
                                            fallbackColor: p.color,
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            left: 8,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: AppColors.blue,
                                                  borderRadius: BorderRadius.circular(6)),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.star, size: 11, color: Colors.white),
                                                  SizedBox(width: 3),
                                                  Text('${p.rating}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold)),
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
                                                    color: AppColors.textWhite,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold)),
                                            SizedBox(height: 2),
                                            Text(type,
                                                textDirection: app.dir,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: AppColors.textGrey, fontSize: 10)),
                                            SizedBox(height: 4),
                                            Row(
                                              textDirection: TextDirection.rtl,
                                              children: [
                                                Icon(Icons.location_on,
                                                    size: 11, color: AppColors.textGrey),
                                                SizedBox(width: 3),
                                                Expanded(
                                                  child: Text(location,
                                                      textDirection: app.dir,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: AppColors.textGrey, fontSize: 9)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
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
