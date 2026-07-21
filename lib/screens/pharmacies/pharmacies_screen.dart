import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../../widgets/responsive.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../services/favorites_service.dart';
import '../../services/api_service.dart';
import '../map/map_screen.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_toggle_bar.dart';
import '../../widgets/keyboard_scrollable.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/sort_toggle.dart';
import 'package:share_plus/share_plus.dart';

// ==================== بيانات الصيدلية ====================
class PharmacyData {
  final String nameAr;
  final String nameEn;
  final String locationAr;
  final String locationEn;
  final double rating;
  final int reviews;
  final String hoursAr; // نص ساعات العمل
  final String hoursEn;
  final bool is24Hours; // تعمل 24 ساعة (للفلترة السريعة)
  final bool hasDelivery; // هل يوجد توصيل
  final String aboutAr;
  final String aboutEn;
  final String phone;
  final String image;
  final List<String> tags; // nearHospital
  final IconData placeholderIcon;
  final Color placeholderColor;
  final String? customImageBase64;
  final bool isFeatured;
  final double? lat;
  final double? lng;
  final String? serverImageUrl;

  PharmacyData({
    required this.nameAr,
    required this.nameEn,
    required this.locationAr,
    required this.locationEn,
    required this.rating,
    required this.reviews,
    required this.hoursAr,
    required this.hoursEn,
    this.is24Hours = false,
    this.hasDelivery = false,
    required this.aboutAr,
    required this.aboutEn,
    this.phone = '',
    this.image = '',
    this.tags = const [],
    required this.placeholderIcon,
    required this.placeholderColor,
    this.customImageBase64,
    this.isFeatured = false,
    this.lat,
    this.lng,
    this.serverImageUrl,
  });
}

final List<PharmacyData> pharmaciesSeedData = [
  PharmacyData(
    nameAr: 'صيدلية ابن سينا',
    nameEn: 'Ibn Sina Pharmacy',
    locationAr: 'شارع عمر المختار - نابلس',
    locationEn: 'Omar Al-Mukhtar St. - Nablus',
    rating: 4.4,
    reviews: 60,
    hoursAr: '',
    hoursEn: '',
    aboutAr: 'توفر خدمات صيدلانية وأدوية مختلفة.',
    aboutEn: 'Provides pharmaceutical services and a variety of medications.',
    phone: '+970 9 237 6548',
    image: 'assets/images/pharmaces/sinna.jpeg',
    tags: [],
    placeholderIcon: Icons.local_pharmacy,
    placeholderColor: Color(0xFF3B82F6),
    isFeatured: true,
  ),
  PharmacyData(
    nameAr: 'صيدلية ليان',
    nameEn: 'Leen Pharmacy',
    locationAr: 'شارع رفيديا الرئيسي - مقابل مسجد رفيديا القديم - نابلس',
    locationEn: 'Main Rafidia St. - opposite the old Rafidia Mosque - Nablus',
    rating: 4.3,
    reviews: 45,
    hoursAr: '',
    hoursEn: '',
    aboutAr: 'مناسبة لسكان منطقة رفيديا وقريبة من الخدمات والمطاعم.',
    aboutEn:
        'Convenient for Rafidia residents and close to services and restaurants.',
    phone: '09-2344572',
    image: 'assets/images/pharmaces/layan.jpeg',
    tags: ['nearHospital'],
    placeholderIcon: Icons.local_pharmacy,
    placeholderColor: Color(0xFF22C55E),
  ),
  PharmacyData(
    nameAr: 'صيدلية الضميدي',
    nameEn: 'Demaidi Pharmacy',
    locationAr: 'شارع نابلس الجديد - نابلس',
    locationEn: 'New Nablus St. - Nablus',
    rating: 4.2,
    reviews: 50,
    hoursAr: 'تعمل لساعات طويلة',
    hoursEn: 'Open long hours',
    aboutAr:
        'تعمل لساعات طويلة وتوفر خدمات صيدلانية متنوعة، قريبة من المستشفى العربي التخصصي.',
    aboutEn:
        'Open long hours, offering a variety of pharmaceutical services, close to Al-Arabi Specialized Hospital.',
    phone: '0599-294996',
    image: 'assets/images/pharmaces/demadi.jpeg',
    tags: ['nearHospital'],
    placeholderIcon: Icons.local_pharmacy,
    placeholderColor: Color(0xFFC9A227),
  ),
  PharmacyData(
    nameAr: 'صيدلية الفيحاء',
    nameEn: 'Al-Fayha Pharmacy',
    locationAr: 'شارع الجامعة - نابلس',
    locationEn: 'University St. - Nablus',
    rating: 4.5,
    reviews: 55,
    hoursAr: '',
    hoursEn: '',
    aboutAr: 'قريبة من منطقة جامعة النجاح والخدمات المحيطة.',
    aboutEn: 'Close to the An-Najah University area and surrounding services.',
    phone: '09-2341391',
    image: 'assets/images/pharmaces/faiha.jpeg',
    tags: ['nearHospital'],
    placeholderIcon: Icons.local_pharmacy,
    placeholderColor: Color(0xFF14B8A6),
  ),
  PharmacyData(
    nameAr: 'صيدلية خريم',
    nameEn: 'Khraim Pharmacy',
    locationAr: 'شارع الاتحاد - مقابل مستشفى الاتحاد - نابلس',
    locationEn: 'Al-Ittihad St. - opposite Al-Ittihad Hospital - Nablus',
    rating: 4.4,
    reviews: 65,
    hoursAr: 'مفتوحة لساعات طويلة',
    hoursEn: 'Open long hours',
    aboutAr: 'مفتوحة لساعات طويلة وقريبة من مستشفى الاتحاد.',
    aboutEn: 'Open long hours, close to Al-Ittihad Hospital.',
    phone: '+970 9 237 0647',
    image: 'assets/images/pharmaces/khraim.jpeg',
    tags: ['nearHospital'],
    placeholderIcon: Icons.local_pharmacy,
    placeholderColor: Color(0xFFE85D5D),
  ),
  PharmacyData(
    nameAr: 'صيدلية رفيديا',
    nameEn: 'Rafidia Pharmacy',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.1,
    reviews: 35,
    hoursAr: '',
    hoursEn: '',
    aboutAr:
        'صيدلية بموقع مناسب بمنطقة رفيديا، قريبة من مستشفى رفيديا ومستشفى النجاح الوطني الجامعي.',
    aboutEn:
        'A conveniently located pharmacy in the Rafidia area, close to Rafidia Hospital and An-Najah National University Hospital.',
    phone: '09-2341864',
    image: 'assets/images/pharmaces/rafidea.jpeg',
    tags: ['nearHospital'],
    placeholderIcon: Icons.local_pharmacy,
    placeholderColor: Color(0xFF9C6B30),
  ),
  PharmacyData(
    nameAr: 'صيدلية مستشفى النجاح الوطني الجامعي',
    nameEn: 'An-Najah National University Hospital Pharmacy',
    locationAr: 'مستشفى النجاح الوطني الجامعي - شارع عصيرة - نابلس',
    locationEn: 'An-Najah National University Hospital - Asira St. - Nablus',
    rating: 4.3,
    reviews: 40,
    hoursAr: 'تعمل 24 ساعة لخدمة مرضى المستشفى والأقسام المختلفة',
    hoursEn: '24 hours, serving hospital patients and departments',
    is24Hours: true,
    aboutAr:
        'صيدلية داخل مستشفى النجاح الوطني الجامعي، تعمل على مدار الساعة لخدمة المرضى والأقسام المختلفة.',
    aboutEn:
        'A pharmacy inside An-Najah National University Hospital, operating around the clock to serve patients and departments.',
    lat: 32.239066,
    lng: 35.247876,
    image: 'assets/images/pharmaces/najah.jpeg',
    tags: ['nearHospital'],
    placeholderIcon: Icons.local_pharmacy,
    placeholderColor: Color(0xFF2563EB),
  ),
  PharmacyData(
    nameAr: 'صيدلية المستقبل',
    nameEn: 'Al-Mustaqbal Pharmacy',
    locationAr: 'عسكر - الشارع الرئيسي - نابلس',
    locationEn: 'Askar - Main St. - Nablus',
    rating: 4.2,
    reviews: 30,
    hoursAr: 'مفتوحة 24 ساعة طوال أيام الأسبوع',
    hoursEn: 'Open 24 hours, every day of the week',
    is24Hours: true,
    aboutAr: 'صيدلية مفتوحة على مدار الساعة طوال أيام الأسبوع بمنطقة عسكر.',
    aboutEn:
        'A pharmacy open around the clock every day of the week in the Askar area.',
    phone: '09-2328412',
    image: 'assets/images/pharmaces/askar.jpeg',
    tags: [],
    placeholderIcon: Icons.local_pharmacy,
    placeholderColor: Color(0xFF16A34A),
  ),
  PharmacyData(
    nameAr: 'صيدلية غازي',
    nameEn: 'Ghazi Pharmacy',
    locationAr: 'شارع حيفا - نابلس',
    locationEn: 'Haifa St. - Nablus',
    rating: 4.2,
    reviews: 30,
    hoursAr: '',
    hoursEn: '',
    aboutAr: 'صيدلية بشارع حيفا، قريبة من المستشفى العربي التخصصي.',
    aboutEn: 'A pharmacy on Haifa St., close to Al-Arabi Specialized Hospital.',
    phone: '09-2373372',
    image: 'assets/images/pharmaces/gazi.jpeg',
    tags: ['nearHospital'],
    placeholderIcon: Icons.local_pharmacy,
    placeholderColor: Color(0xFF0EA5E9),
  ),
  PharmacyData(
    nameAr: 'صيدلية نور اليوسف',
    nameEn: 'Nour Al-Yousef Pharmacy',
    locationAr: 'شارع جامعة النجاح (الحرم القديم) - نابلس',
    locationEn: 'An-Najah University St. (Old Campus) - Nablus',
    rating: 4.1,
    reviews: 25,
    hoursAr: '',
    hoursEn: '',
    aboutAr: 'صيدلية قريبة من وسط المدينة والمراكز الطبية.',
    aboutEn: 'A pharmacy close to the city center and medical centers.',
    phone: '09-2373570',
    image: 'assets/images/pharmaces/nour.jpeg',
    tags: ['nearHospital'],
    placeholderIcon: Icons.local_pharmacy,
    placeholderColor: Color(0xFFA855F7),
  ),
];

const List<(String, String, String)> _quickFilters = [
  ('is24Hours', '🕗 صيدليات 24 ساعة', '🕗 24-Hour Pharmacies'),
  ('nearestToMe', '📍 الأقرب لموقعي', '📍 Nearest to Me'),
  ('nearHospital', '🏥 قرب المستشفيات', '🏥 Near Hospitals'),
];

// ==================== الشاشة الرئيسية لصفحة الصيدليات ====================
class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({super.key});

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  bool _loaded = false;
  List<PharmacyData> _livePharmacies = [];
  bool isGridView = true;

  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';
  String quickFilter = ''; // فاضي = بدون فلتر (الكل)
  double minRating = 0;
  int sortMode = 0;
  int currentPage = 0;
  static const int perPage = 9;

  Position? _userPosition;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = LocalDbService.instance;
    await db.syncSeed(
      'pharmacies',
      pharmaciesSeedData.map(pharmacyToMap).toList(),
    );
    await ApiService.syncPharmacies();
    final entries = db.getAll('pharmacies');
    setState(() {
      _livePharmacies = entries.map((e) => mapToPharmacy(e.value)).toList();
      _loaded = true;
    });
  }

  Future<void> _activateNearestToMe() async {
    setState(() => _locating = true);
    final app = AppState.instance;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw app.t(
          'خدمة الموقع غير مفعّلة على جهازك',
          'Location services are disabled on your device',
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw app.t(
          'تم رفض إذن الوصول للموقع',
          'Location permission was denied',
        );
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _userPosition = position;
        quickFilter = 'nearestToMe';
        _locating = false;
      });
    } catch (e) {
      setState(() => _locating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e is String ? e : e.toString())));
    }
  }

  double? _distanceKmTo(PharmacyData p) {
    if (_userPosition == null) return null;
    final point = resolveMapPoint(
      nameAr: p.nameAr,
      nameEn: p.nameEn,
      locationAr: p.locationAr,
      locationEn: p.locationEn,
      lat: p.lat,
      lng: p.lng,
    );
    final meters = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      point.latitude,
      point.longitude,
    );
    return meters / 1000;
  }

  List<PharmacyData> get _filtered {
    var list = _livePharmacies.where((p) {
      final matchesSearch =
          searchQuery.isEmpty ||
          p.nameAr.contains(searchQuery) ||
          p.nameEn.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.locationAr.contains(searchQuery) ||
          p.locationEn.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter = switch (quickFilter) {
        'is24Hours' => p.is24Hours,
        'nearestToMe' => true,
        '' => true,
        _ => p.tags.contains(quickFilter),
      };
      final matchesRating = p.rating >= minRating;
      return matchesSearch && matchesFilter && matchesRating;
    }).toList();

    if (quickFilter == 'nearestToMe' && _userPosition != null) {
      list.sort((a, b) => _distanceKmTo(a)!.compareTo(_distanceKmTo(b)!));
    } else if (sortMode == 1) {
      list.sort((a, b) => b.reviews.compareTo(a.reviews));
    } else if (sortMode == 2) {
      list.sort((a, b) => a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()));
    } else {
      list.sort((a, b) {
        if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
        return b.rating.compareTo(a.rating);
      });
    }
    return list;
  }

  List<PharmacyData> get _paged {
    final list = _filtered;
    final start = (currentPage * perPage).clamp(0, list.length);
    final end = (start + perPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get _pageCount {
    final len = _filtered.length;
    return len == 0 ? 1 : ((len - 1) ~/ perPage) + 1;
  }

  void _openPharmacyDetail(BuildContext context, PharmacyData p) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PharmacyDetailScreen(pharmacy: p),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    if (!_loaded) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColors.bgDark,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final filtered = _filtered;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: KeyboardScrollable(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PharmaciesTopBar(),
                    _PharmaciesBanner(),
                    Padding(
                      padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SearchBar(
                            controller: searchController,
                            onChanged: (v) => setState(() {
                              searchQuery = v;
                              currentPage = 0;
                            }),
                          ),
                          SizedBox(height: 14),
                          _QuickFiltersRow(
                            selected: quickFilter,
                            locating: _locating,
                            onTap: (key) {
                              if (key == 'nearestToMe') {
                                if (quickFilter == 'nearestToMe') {
                                  setState(() => quickFilter = '');
                                } else {
                                  _activateNearestToMe();
                                }
                                return;
                              }
                              setState(() {
                                quickFilter = quickFilter == key ? '' : key;
                                currentPage = 0;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          _RatingFiltersRow(
                            minRating: minRating,
                            onRatingTap: (v) => setState(() {
                              minRating = minRating == v ? 0 : v;
                              currentPage = 0;
                            }),
                          ),
                          SizedBox(height: 22),
                          Row(
                            children: [
                              Text(
                                app.t(
                                  '${filtered.length} صيدلية',
                                  '${filtered.length} pharmacies',
                                ),
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 12),
                              if (quickFilter != 'nearestToMe')
                                SortToggle(
                                  activeIndex: sortMode,
                                  labelsAr: const ['الأعلى تقييماً', 'الأكثر مراجعة', 'أبجدياً'],
                                  labelsEn: const ['Top Rated', 'Most Reviewed', 'A–Z'],
                                  isArabic: app.isArabic,
                                  onChanged: (m) => setState(() => sortMode = m),
                                ),
                              Spacer(),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => setState(() => isGridView = false),
                                child: Icon(
                                  Icons.view_list,
                                  size: 20,
                                  color: isGridView
                                      ? AppColors.textGrey
                                      : AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 8),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => setState(() => isGridView = true),
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isGridView
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.grid_view,
                                    size: 16,
                                    color: isGridView
                                        ? Colors.white
                                        : AppColors.textGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          if (filtered.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: Center(
                                child: Text(
                                  app.t(
                                    'لا توجد صيدليات مطابقة',
                                    'No matching pharmacies',
                                  ),
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                              ),
                            )
                          else if (isGridView)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _paged.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: responsiveGridColumns(
                                      context,
                                      wide: 4,
                                      narrow: 2,
                                    ),
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.72,
                                  ),
                              itemBuilder: (context, i) {
                                final p = _paged[i];
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _openPharmacyDetail(context, p),
                                  child: _PharmacyCard(
                                    pharmacy: p,
                                    distanceKm: _distanceKmTo(p),
                                    isFavorite: FavoritesService.instance
                                        .isFavorite(p.nameEn),
                                    onFavorite: () async {
                                      await FavoritesService.instance
                                          .toggleFavorite(p.nameEn);
                                      setState(() {});
                                    },
                                  ),
                                );
                              },
                            )
                          else
                            Column(
                              children: _paged
                                  .map(
                                    (p) => Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () =>
                                            _openPharmacyDetail(context, p),
                                        child: _PharmacyListTile(
                                          pharmacy: p,
                                          distanceKm: _distanceKmTo(p),
                                          isFavorite: FavoritesService.instance
                                              .isFavorite(p.nameEn),
                                          onFavorite: () async {
                                            await FavoritesService.instance
                                                .toggleFavorite(p.nameEn);
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          if (filtered.isNotEmpty) ...[
                            SizedBox(height: 18),
                            PaginationBar(
                              currentPage: currentPage,
                              pageCount: _pageCount,
                              onPageChange: (p) => setState(() => currentPage = p),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== الشريط العلوي ====================
class _PharmaciesTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
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
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.local_pharmacy, color: Colors.white, size: 16),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              app.t('الصيدليات', 'Pharmacies'),
              textDirection: app.dir,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(
                AppColors.textWhite,
              ).copyWith(fontSize: 16),
            ),
          ),
          AppToggleBar(),
        ],
      ),
    );
  }
}

// ==================== بانر ترحيبي ====================
class _PharmaciesBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
      height: 200,
      margin: EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => showImageZoom(
              context,
              query: 'pharmacy shelves medicine colorful',
              fallbackSeed: 'nablus-pharmacies-banner',
              localAsset: 'assets/images/pharmaces/pharmacy.jpeg',
              fallbackIcon: Icons.local_pharmacy,
            ),
            child: ThemedImage(
              query: 'pharmacy shelves medicine colorful',
              fallbackSeed: 'nablus-pharmacies-banner',
              height: 200,
              localAsset: 'assets/images/pharmaces/pharmacy.jpeg',
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.6),
                  AppColors.primaryDark.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          Center(
            child: Text(
              app.t('الصيدليات في نابلس', 'Pharmacies in Nablus'),
              textDirection: app.dir,
              textAlign: TextAlign.center,
              style: AppTypography.display(Colors.white).copyWith(fontSize: 26),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== شريط البحث ====================
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark2,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: AppColors.textGrey),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.body(
                AppColors.textWhite,
              ).copyWith(fontSize: 13),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: app.t(
                  'ابحث بالاسم أو المنطقة...',
                  'Search by name or area...',
                ),
                hintStyle: AppTypography.caption(AppColors.textGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== فلتر التقييم ====================
class _RatingFiltersRow extends StatelessWidget {
  final double minRating;
  final void Function(double) onRatingTap;
  const _RatingFiltersRow({required this.minRating, required this.onRatingTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final r in [4.5, 4.0, 3.5])
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onRatingTap(r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: minRating == r ? AppColors.primary : AppColors.cardDark2,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: minRating == r ? Colors.transparent : AppColors.borderColor,
                    ),
                  ),
                  child: Text(
                    '⭐ $r+',
                    style: TextStyle(
                      color: minRating == r ? Colors.white : AppColors.textWhite,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== تصنيفات سريعة ====================
class _QuickFiltersRow extends StatelessWidget {
  final String selected;
  final bool locating;
  final void Function(String) onTap;
  const _QuickFiltersRow({
    required this.selected,
    required this.locating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _quickFilters.map((f) {
          final key = f.$1;
          final isSelected = selected == key;
          final isLocatingChip = key == 'nearestToMe' && locating;
          return Padding(
            padding: EdgeInsets.only(left: 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isLocatingChip ? null : () => onTap(key),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: AppColors.primaryGradient)
                      : null,
                  color: isSelected ? null : AppColors.cardDark2,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLocatingChip) ...[
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textWhite,
                        ),
                      ),
                      SizedBox(width: 6),
                    ],
                    Text(
                      app.t(f.$2, f.$3),
                      textDirection: app.dir,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ==================== ودجت صف ساعات العمل + توصيل ====================
class _HoursAndDeliveryRow extends StatelessWidget {
  final PharmacyData pharmacy;
  const _HoursAndDeliveryRow({required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final p = pharmacy;
    final hours = app.isArabic ? p.hoursAr : p.hoursEn;
    final showHours = p.is24Hours || hours.isNotEmpty;
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        if (showHours) ...[
          Icon(Icons.access_time, size: 11, color: AppColors.textGrey),
          SizedBox(width: 3),
          Expanded(
            child: Text(
              p.is24Hours ? app.t('24 ساعة', '24 hours') : hours,
              textDirection: app.dir,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textGrey, fontSize: 9),
            ),
          ),
        ],
        if (p.hasDelivery) ...[
          SizedBox(width: 4),
          Icon(Icons.delivery_dining, size: 13, color: AppColors.teal),
        ],
      ],
    );
  }
}

// ==================== كرت الصيدلية (Grid) ====================
class _PharmacyCard extends StatelessWidget {
  final PharmacyData pharmacy;
  final double? distanceKm;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const _PharmacyCard({
    required this.pharmacy,
    required this.distanceKm,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final p = pharmacy;
    final name = app.isArabic ? p.nameAr : p.nameEn;
    final location = app.isArabic ? p.locationAr : p.locationEn;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ThemedImage(
                  query: 'pharmacy interior',
                  fallbackSeed: p.nameEn,
                  height: double.infinity,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  fallbackIcon: p.placeholderIcon,
                  fallbackColor: p.placeholderColor,
                  customImageBase64: p.customImageBase64,
                  serverImageUrl: p.serverImageUrl,
                  localAsset: p.image,
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: distanceKm != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.near_me,
                                size: 11,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3),
                              Text(
                                '${distanceKm!.toStringAsFixed(1)} ${app.t('كم', 'km')}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                '${p.rating}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (p.isFeatured)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 10, color: Colors.white),
                          SizedBox(width: 2),
                          Text(
                            app.t('مميز', 'Featured'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onFavorite,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: isFavorite ? AppColors.red : AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.textGrey,
                    ),
                    SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        location,
                        textDirection: app.dir,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                _HoursAndDeliveryRow(pharmacy: p),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== بطاقة قائمة الصيدلية (List) ====================
class _PharmacyListTile extends StatelessWidget {
  final PharmacyData pharmacy;
  final double? distanceKm;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const _PharmacyListTile({
    required this.pharmacy,
    required this.distanceKm,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final p = pharmacy;
    final name = app.isArabic ? p.nameAr : p.nameEn;
    final location = app.isArabic ? p.locationAr : p.locationEn;

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: ThemedImage(
              query: 'pharmacy interior',
              fallbackSeed: p.nameEn,
              height: 70,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              fallbackIcon: p.placeholderIcon,
              fallbackColor: p.placeholderColor,
              customImageBase64: p.customImageBase64,
              serverImageUrl: p.serverImageUrl,
              localAsset: p.image,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.textGrey,
                    ),
                    SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        location,
                        textDirection: app.dir,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                _HoursAndDeliveryRow(pharmacy: p),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (distanceKm != null)
                Text(
                  '${distanceKm!.toStringAsFixed(1)} ${app.t('كم', 'km')}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Row(
                  children: [
                    Icon(Icons.star, size: 12, color: AppColors.gold),
                    SizedBox(width: 3),
                    Text(
                      '${p.rating}',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 4),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onFavorite,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isFavorite ? AppColors.red : AppColors.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== شاشة تفاصيل الصيدلية ====================
class PharmacyDetailScreen extends StatelessWidget {
  final PharmacyData pharmacy;
  const PharmacyDetailScreen({super.key, required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final p = pharmacy;
    final name = app.isArabic ? p.nameAr : p.nameEn;
    final location = app.isArabic ? p.locationAr : p.locationEn;
    final hours = p.is24Hours
        ? app.t('24 ساعة', '24 hours')
        : (app.isArabic ? p.hoursAr : p.hoursEn);
    final about = app.isArabic ? p.aboutAr : p.aboutEn;

    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => showImageZoom(
                          context,
                          query: 'pharmacy interior',
                          fallbackSeed: p.nameEn,
                          fallbackIcon: p.placeholderIcon,
                          fallbackColor: p.placeholderColor,
                          customImageBase64: p.customImageBase64,
                          serverImageUrl: p.serverImageUrl,
                          localAsset: p.image,
                        ),
                        child: ThemedImage(
                          query: 'pharmacy interior',
                          fallbackSeed: p.nameEn,
                          height: 260,
                          fallbackIcon: p.placeholderIcon,
                          fallbackColor: p.placeholderColor,
                          customImageBase64: p.customImageBase64,
                          serverImageUrl: p.serverImageUrl,
                          localAsset: p.image,
                        ),
                      ),
                      Container(
                        height: 260,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 44,
                        left: 16,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        left: 16,
                        child: Text(
                          name,
                          textDirection: app.dir,
                          style: AppTypography.display(
                            Colors.white,
                          ).copyWith(fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    '${p.rating}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '(${p.reviews} ${app.t('تقييم', 'reviews')})',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 11,
                              ),
                            ),
                            Spacer(),
                            if (p.hasDelivery)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.teal.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.delivery_dining,
                                      size: 14,
                                      color: AppColors.teal,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      app.t('يوجد توصيل', 'Delivery available'),
                                      style: TextStyle(
                                        color: AppColors.teal,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 13,
                              color: AppColors.textGrey,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                textDirection: app.dir,
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (p.is24Hours || hours.isNotEmpty) ...[
                          SizedBox(height: 6),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 13,
                                color: AppColors.textGrey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                hours,
                                textDirection: app.dir,
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (!p.hasDelivery) ...[
                          SizedBox(height: 6),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Icon(
                                Icons.delivery_dining,
                                size: 13,
                                color: AppColors.textGrey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                app.t('لا يوجد توصيل', 'No delivery'),
                                textDirection: app.dir,
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 18),
                        Text(
                          app.t('نبذة', 'Overview'),
                          textDirection: app.dir,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          about,
                          textDirection: app.dir,
                          textAlign: app.isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 22),
                        if (p.phone.isNotEmpty) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  launchUrl(Uri.parse('tel:${p.phone}')),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.borderColor),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                              ),
                              icon: Icon(
                                Icons.call,
                                size: 16,
                                color: AppColors.textWhite,
                              ),
                              label: Text(
                                app.t('اتصال: ${p.phone}', 'Call: ${p.phone}'),
                                style: AppTypography.label(AppColors.textWhite),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.primaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: AppColors.glowShadow,
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final point = resolveMapPoint(
                                  nameAr: p.nameAr,
                                  nameEn: p.nameEn,
                                  locationAr: p.locationAr,
                                  locationEn: p.locationEn,
                                  lat: p.lat,
                                  lng: p.lng,
                                );
                                openDirectionsInExternalMaps(point);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                              ),
                              icon: Icon(
                                Icons.directions_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                app.t('الاتجاهات (GPS)', 'Directions (GPS)'),
                                style: AppTypography.title(
                                  Colors.white,
                                ).copyWith(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final point = resolveMapPoint(
                                nameAr: p.nameAr,
                                nameEn: p.nameEn,
                                locationAr: p.locationAr,
                                locationEn: p.locationEn,
                                lat: p.lat,
                                lng: p.lng,
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MapScreen(
                                    focusPoint: point,
                                    focusNameAr: p.nameAr,
                                    focusNameEn: p.nameEn,
                                    focusCategoryAr: app.t(
                                      'صيدلية',
                                      'Pharmacy',
                                    ),
                                    focusCategoryEn: 'Pharmacy',
                                    focusRating: p.rating,
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.borderColor),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.map_rounded,
                              size: 16,
                              color: AppColors.textWhite,
                            ),
                            label: Text(
                              app.t('عرض على الخريطة', 'Show on Map'),
                              style: AppTypography.label(AppColors.textWhite),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Share.share('$name (${p.rating}⭐) — $location'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.borderColor),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.share,
                              size: 16,
                              color: AppColors.textWhite,
                            ),
                            label: Text(
                              app.t('مشاركة', 'Share'),
                              style: AppTypography.label(AppColors.textWhite),
                            ),
                          ),
                        ),
                      ],
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
