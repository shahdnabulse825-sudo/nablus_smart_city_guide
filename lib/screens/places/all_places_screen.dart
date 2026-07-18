import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../common/detail_screen.dart';
import '../category/category_data.dart';
import '../restaurants/restaurants_screen.dart'
    show restaurantPhotoQuery, RestaurantData;
import '../hotels/hotels_screen.dart' show HotelData, hotelPhotoQuery;
import '../pharmacies/pharmacies_screen.dart' show PharmacyData;
import '../attractions/attractions_screen.dart'
    show AttractionData, attractionPhotoQuery, attractionCategoryLabels;
import '../shopping/shopping_screen.dart'
    show ShoppingVenueData, shoppingVenuePhotoQuery;
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/responsive.dart';
import '../../theme/app_typography.dart';
import '../../widgets/keyboard_scrollable.dart';

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
  final String? customImageBase64;
  final bool isFeatured;
  final String image;
  final double? lat;
  final double? lng;
  final String? priceTier; // 'cheap' | 'medium' | 'high' | null (not all categories have a price tier)
  final bool is24Hours;

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
    this.customImageBase64,
    this.isFeatured = false,
    this.image = '',
    this.lat,
    this.lng,
    this.priceTier,
    this.is24Hours = false,
  });
}

UniversalPlace _fromListing(ListingItem it, String categoryKey) =>
    UniversalPlace(
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
      customImageBase64: it.customImageBase64,
      isFeatured: it.isFeatured,
    );

UniversalPlace _fromHotel(HotelData h) => UniversalPlace(
  nameAr: h.nameAr,
  nameEn: h.nameEn,
  typeAr: h.typeAr,
  typeEn: h.typeEn,
  locationAr: h.locationAr,
  locationEn: h.locationEn,
  categoryKey: 'hotel',
  rating: h.rating,
  reviews: h.reviews,
  aboutAr: h.aboutAr,
  aboutEn: h.aboutEn,
  photoQuery: hotelPhotoQuery(h),
  icon: h.placeholderIcon,
  color: h.placeholderColor,
  customImageBase64: h.customImageBase64,
  isFeatured: h.isFeatured,
  image: h.image,
  lat: h.lat,
  lng: h.lng,
  priceTier: h.priceTier,
);

UniversalPlace _fromAttraction(AttractionData a) => UniversalPlace(
  nameAr: a.nameAr,
  nameEn: a.nameEn,
  typeAr:
      attractionCategoryLabels[a.categories.isNotEmpty
              ? a.categories.first
              : '']
          ?.$1 ??
      '',
  typeEn:
      attractionCategoryLabels[a.categories.isNotEmpty
              ? a.categories.first
              : '']
          ?.$2 ??
      '',
  locationAr: a.locationAr,
  locationEn: a.locationEn,
  categoryKey: 'attraction',
  rating: a.rating,
  reviews: a.reviews,
  aboutAr: a.aboutAr,
  aboutEn: a.aboutEn,
  photoQuery: attractionPhotoQuery(a),
  icon: a.placeholderIcon,
  color: a.placeholderColor,
  customImageBase64: a.customImageBase64,
  isFeatured: a.isFeatured,
  image: a.image,
  lat: a.lat,
  lng: a.lng,
);

UniversalPlace _fromShoppingVenue(ShoppingVenueData v) => UniversalPlace(
  nameAr: v.nameAr,
  nameEn: v.nameEn,
  typeAr: v.typeAr,
  typeEn: v.typeEn,
  locationAr: v.locationAr,
  locationEn: v.locationEn,
  categoryKey: 'shopping',
  rating: v.rating,
  reviews: v.reviews,
  aboutAr: v.aboutAr,
  aboutEn: v.aboutEn,
  photoQuery: shoppingVenuePhotoQuery(v),
  icon: v.placeholderIcon,
  color: v.placeholderColor,
  customImageBase64: v.customImageBase64,
  isFeatured: v.isFeatured,
  image: v.image,
  lat: v.lat,
  lng: v.lng,
);

UniversalPlace _fromPharmacy(PharmacyData p) => UniversalPlace(
  nameAr: p.nameAr,
  nameEn: p.nameEn,
  typeAr: 'صيدلية',
  typeEn: 'Pharmacy',
  locationAr: p.locationAr,
  locationEn: p.locationEn,
  categoryKey: 'pharmacy',
  rating: p.rating,
  reviews: p.reviews,
  aboutAr: p.aboutAr,
  aboutEn: p.aboutEn,
  photoQuery: 'pharmacy interior',
  icon: p.placeholderIcon,
  color: p.placeholderColor,
  customImageBase64: p.customImageBase64,
  isFeatured: p.isFeatured,
  image: p.image,
  lat: p.lat,
  lng: p.lng,
  is24Hours: p.is24Hours,
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
  customImageBase64: r.customImageBase64,
  isFeatured: r.isFeatured,
  image: r.image,
  lat: r.lat,
  lng: r.lng,
  priceTier: r.priceTier,
);

List<ListingItem> _liveListings(String boxName) => LocalDbService.instance
    .getAll(boxName)
    .map((e) => mapToListing(e.value))
    .toList();

List<RestaurantData> _liveRestaurants() => LocalDbService.instance
    .getAll('restaurants')
    .map((e) => mapToRestaurant(e.value))
    .toList();

List<HotelData> _liveHotels() => LocalDbService.instance
    .getAll('hotels')
    .map((e) => mapToHotel(e.value))
    .toList();

// نسخ عامة (public) من القوائم الحية أعلاه، حتى تقدر خدمة البحث الذكي تفحص
// حقول فرعية (cuisineKey, categories, tags) مش موجودة بـ UniversalPlace نفسه.
List<RestaurantData> liveRestaurantsForSearch() => _liveRestaurants();
List<HotelData> liveHotelsForSearch() => _liveHotels();

List<PharmacyData> _livePharmacies() => LocalDbService.instance
    .getAll('pharmacies')
    .map((e) => mapToPharmacy(e.value))
    .toList();

List<AttractionData> _liveAttractions() => LocalDbService.instance
    .getAll('attractions')
    .map((e) => mapToAttraction(e.value))
    .toList();

List<ShoppingVenueData> _liveShoppingVenues() => LocalDbService.instance
    .getAll('shopping')
    .map((e) => mapToShoppingVenue(e.value))
    .toList();

List<AttractionData> liveAttractionsForSearch() => _liveAttractions();

/// كل الأماكن بكل الأقسام، مقروءة حيًا من قاعدة البيانات المحلية (تعكس أي تعديل
/// أو صورة يضيفها الأدمن فورًا) بدلًا من قائمة ثابتة.
List<UniversalPlace> get allPlaces => [
  ..._liveAttractions().map(_fromAttraction),
  ..._liveHotels().map(_fromHotel),
  ..._liveShoppingVenues().map(_fromShoppingVenue),
  ..._liveListings('transport').map((it) => _fromListing(it, 'transport')),
  ..._liveListings('health').map((it) => _fromListing(it, 'health')),
  ..._livePharmacies().map(_fromPharmacy),
  ..._liveListings('education').map((it) => _fromListing(it, 'education')),
  ..._liveListings('banks').map((it) => _fromListing(it, 'bank')),
  ..._liveListings(
    'entertainment',
  ).map((it) => _fromListing(it, 'entertainment')),
  ..._liveListings('government').map((it) => _fromListing(it, 'government')),
  ..._liveRestaurants().map(_fromRestaurant),
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

enum PlacesSortMode { featured, topRated, newest, trending, recommended, interests }

/// شاشة موحّدة تعرض كل الأماكن (مطاعم، فنادق، معالم، تسوق...) قابلة للبحث
/// والتصفية، تُستخدم كوجهة "عرض الكل" لأقسام الأماكن المفضلة/الأكثر زيارة/أحدث الأماكن.
class AllPlacesScreen extends StatefulWidget {
  final String titleAr;
  final String titleEn;
  final PlacesSortMode sortMode;

  const AllPlacesScreen({
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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<UniversalPlace> get _baseList {
    switch (widget.sortMode) {
      case PlacesSortMode.topRated:
        return List.of(allPlaces)..sort((a, b) => b.rating.compareTo(a.rating));
      case PlacesSortMode.newest:
        return allPlaces.reversed.toList();
      case PlacesSortMode.featured:
        return List.of(allPlaces)..sort((a, b) {
          if (a.isFeatured != b.isFeatured) {
            return a.isFeatured ? -1 : 1;
          }
          return b.rating.compareTo(a.rating);
        });
      case PlacesSortMode.trending:
        return RecommendationService.trendingToday(limit: 100);
      case PlacesSortMode.recommended:
        return RecommendationService.recommendedForYou(limit: 100);
      case PlacesSortMode.interests:
        return RecommendationService.basedOnYourInterests(limit: 100);
    }
  }

  List<UniversalPlace> get _filtered {
    return _baseList.where((p) {
      final matchesCategory =
          categoryFilter == 'all' || p.categoryKey == categoryFilter;
      final matchesSearch =
          searchQuery.isEmpty ||
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
                            Icons.place_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            app.t(widget.titleAr, widget.titleEn),
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Container(
                      height: 46,
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.borderColor),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => searchQuery = v),
                              style: AppTypography.body(
                                AppColors.textWhite,
                              ).copyWith(fontSize: 13),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: app.t(
                                  'ابحث عن مكان...',
                                  'Search a place...',
                                ),
                                hintStyle: AppTypography.caption(
                                  AppColors.textGrey,
                                ),
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
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: selected
                                      ? LinearGradient(
                                          colors: AppColors.primaryGradient,
                                        )
                                      : null,
                                  color: selected ? null : AppColors.cardDark2,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.transparent
                                        : AppColors.borderColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _categoryChipIcons[key],
                                      size: 13,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textGrey,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      app.isArabic
                                          ? _categoryLabelsAr[key]!
                                          : _categoryLabelsEn[key]!,
                                      style: AppTypography.caption(
                                        selected
                                            ? Colors.white
                                            : AppColors.textWhite,
                                      ),
                                    ),
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
                            child: Text(
                              app.t(
                                'لا توجد نتائج مطابقة',
                                'No matching results',
                              ),
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          )
                        : KeyboardScrollable(
                            controller: _scrollController,
                            child: GridView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(16),
                              itemCount: filtered.length,
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
                                final p = filtered[i];
                                final name = app.isArabic ? p.nameAr : p.nameEn;
                                final type = app.isArabic ? p.typeAr : p.typeEn;
                                final location = app.isArabic
                                    ? p.locationAr
                                    : p.locationEn;
                                return AppCard(
                                  padding: EdgeInsets.zero,
                                  onTap: () {
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
                                          customImageBase64:
                                              p.customImageBase64,
                                          localAsset: p.image,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ThemedImage(
                                              query: p.photoQuery,
                                              fallbackSeed: p.nameEn,
                                              height: double.infinity,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                  ),
                                              fallbackIcon: p.icon,
                                              fallbackColor: p.color,
                                              customImageBase64:
                                                  p.customImageBase64,
                                              localAsset: p.image,
                                            ),
                                            if (p.isFeatured)
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: AppColors
                                                          .primaryGradient,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.bolt,
                                                        size: 10,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 2),
                                                      Text(
                                                        app.t(
                                                          'مميز',
                                                          'Featured',
                                                        ),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            Positioned(
                                              bottom: 8,
                                              left: 8,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      size: 11,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 3),
                                                    Text(
                                                      '${p.rating}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              name,
                                              textDirection: app.dir,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.label(
                                                AppColors.textWhite,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              type,
                                              textDirection: app.dir,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.caption(
                                                AppColors.textGrey,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              textDirection: TextDirection.rtl,
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 11,
                                                  color: AppColors.textGrey,
                                                ),
                                                SizedBox(width: 3),
                                                Expanded(
                                                  child: Text(
                                                    location,
                                                    textDirection: app.dir,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: AppColors.textGrey,
                                                      fontSize: 9,
                                                    ),
                                                  ),
                                                ),
                                              ],
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
