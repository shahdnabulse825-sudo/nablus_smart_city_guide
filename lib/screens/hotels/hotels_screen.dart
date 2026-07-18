import 'package:flutter/material.dart';
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

// ==================== بيانات الفندق ====================
class HotelData {
  final String nameAr;
  final String nameEn;
  final String typeAr; // "فندق 4 نجوم" / "شقق فندقية" ...
  final String typeEn;
  final String locationAr;
  final String locationEn;
  final double rating;
  final int reviews;
  final String priceInfoAr; // "180-250 ₪ / ليلة"
  final String priceInfoEn;
  final String priceTier; // cheap / medium / high (للفلترة: اقتصادية/فاخرة)
  final String hoursAr; // أوقات الاستقبال/التواصل
  final String hoursEn;
  final String aboutAr;
  final String aboutEn;
  final String phone;
  final String image; // مسار صورة محلية رئيسية (اختياري)
  final List<String> gallery; // صور إضافية لمعرض الصور
  final List<String> amenities; // wifi / parking / restaurant / roomService
  final List<String>
  tags; // nearOldCity / nearUniversity / nearAttractions / familyFriendly
  final IconData placeholderIcon;
  final Color placeholderColor;
  final String? customImageBase64;
  final bool isFeatured;
  final double? lat;
  final double? lng;

  HotelData({
    required this.nameAr,
    required this.nameEn,
    required this.typeAr,
    required this.typeEn,
    required this.locationAr,
    required this.locationEn,
    required this.rating,
    required this.reviews,
    required this.priceInfoAr,
    required this.priceInfoEn,
    required this.priceTier,
    required this.hoursAr,
    required this.hoursEn,
    required this.aboutAr,
    required this.aboutEn,
    this.phone = '',
    this.image = '',
    this.gallery = const [],
    this.amenities = const [],
    this.tags = const [],
    required this.placeholderIcon,
    required this.placeholderColor,
    this.customImageBase64,
    this.isFeatured = false,
    this.lat,
    this.lng,
  });
}

final List<HotelData> hotelsSeedData = [
  HotelData(
    nameAr: 'فندق القصر',
    nameEn: 'Al Qaser Hotel',
    typeAr: 'فندق 3 نجوم',
    typeEn: '3-Star Hotel',
    locationAr: 'شارع جامعة النجاح - نابلس',
    locationEn: 'An-Najah University St. - Nablus',
    rating: 3.7,
    reviews: 180,
    priceInfoAr: '180-250 ₪ / ليلة',
    priceInfoEn: '180-250 ₪ / night',
    priceTier: 'high',
    hoursAr: 'استقبال على مدار الساعة',
    hoursEn: '24-hour front desk',
    aboutAr:
        'فندق 3 نجوم بطابع راقٍ ومناسب للزوار ورجال الأعمال، قريب من جامعة النجاح ومناطق التسوق والمطاعم.',
    aboutEn:
        'A 3-star hotel with an upscale feel, suitable for visitors and business travelers, near An-Najah University and shopping and dining areas.',
    phone: '+970 9 234 1444',
    image: 'assets/images/hotels/alqaser_hotel.jpeg',
    amenities: ['wifi', 'parking', 'restaurant', 'roomService'],
    tags: ['familyFriendly', 'luxury'],
    placeholderIcon: Icons.hotel,
    placeholderColor: Color(0xFF6C5CE7),
    isFeatured: true,
  ),
  HotelData(
    nameAr: 'فندق خان الوكالة',
    nameEn: 'Khan Al-Wakala Hotel',
    typeAr: 'فندق تراثي بوتيك',
    typeEn: 'Boutique Heritage Hotel',
    locationAr: 'البلدة القديمة - سوق الحدادين - نابلس',
    locationEn: 'Old City - Souq Al-Hadadeen - Nablus',
    rating: 4.2,
    reviews: 100,
    priceInfoAr: '70-130 ₪ / ليلة',
    priceInfoEn: '70-130 ₪ / night',
    priceTier: 'cheap',
    hoursAr: 'استقبال على مدار الساعة',
    hoursEn: '24-hour front desk',
    aboutAr:
        'فندق تراثي داخل مبنى تاريخي، مناسب للسياح لأنه قريب من الأسواق القديمة والمعالم التراثية.',
    aboutEn:
        'A heritage hotel inside a historic building, ideal for tourists thanks to its proximity to the old markets and heritage sites.',
    phone: '+970 9 237 7779',
    image: 'assets/images/hotels/khan_hotel.jpeg',
    amenities: ['wifi', 'restaurant'],
    tags: ['nearOldCity', 'nearMarkets', 'nearAttractions'],
    placeholderIcon: Icons.mosque,
    placeholderColor: Color(0xFFB5651D),
    isFeatured: true,
  ),
  HotelData(
    nameAr: 'فندق الأجنحة الملكية',
    nameEn: 'Royal Suites Hotel',
    typeAr: 'فندق 5 نجوم',
    typeEn: '5-Star Hotel',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.3,
    reviews: 85,
    priceInfoAr: '140-200 ₪ / ليلة',
    priceInfoEn: '140-200 ₪ / night',
    priceTier: 'high',
    hoursAr: 'استقبال على مدار الساعة',
    hoursEn: '24-hour front desk',
    aboutAr:
        'فندق فاخر بتصميم حديث، مناسب لرجال الأعمال والسياح. يحتوي على غرف وأجنحة، مطعم، خدمة غرف، وإنترنت مجاني.',
    aboutEn:
        'A luxury hotel with a modern design, suitable for business travelers and tourists. Features rooms and suites, a restaurant, room service, and free WiFi.',
    phone: '+970 56 890 0370',
    image: 'assets/images/hotels/royal_hotel.jpeg',
    amenities: ['wifi', 'parking', 'restaurant', 'roomService'],
    tags: ['luxury'],
    placeholderIcon: Icons.hotel,
    placeholderColor: Color(0xFF4C6EF5),
  ),
  HotelData(
    nameAr: 'فندق يلدز بالاس',
    nameEn: 'Yaldiz Palace Hotel',
    typeAr: 'فندق 4 نجوم',
    typeEn: '4-Star Hotel',
    locationAr: 'بيت وزان - نابلس',
    locationEn: 'Beit Wazan - Nablus',
    rating: 4.4,
    reviews: 70,
    priceInfoAr: '250-350 ₪ / ليلة',
    priceInfoEn: '250-350 ₪ / night',
    priceTier: 'high',
    hoursAr: 'استقبال على مدار الساعة',
    hoursEn: '24-hour front desk',
    aboutAr:
        'فندق بطابع فاخر وإطلالة مميزة، مناسب للعائلات والزوار الباحثين عن الهدوء عند سفح جبل جرزيم.',
    aboutEn:
        'A hotel with a luxurious feel and a distinctive view, suitable for families and visitors seeking quiet at the foot of Mount Gerizim.',
    phone: '+970 594 355 366',
    image: 'assets/images/hotels/yaldeez_hotel.jpeg',
    amenities: ['wifi', 'parking', 'restaurant'],
    tags: ['nearGerizim', 'luxury', 'familyFriendly'],
    placeholderIcon: Icons.terrain,
    placeholderColor: Color(0xFF4C8C4A),
  ),
  HotelData(
    nameAr: 'بيت ضيافة تركواز',
    nameEn: 'Turquoise Guest House',
    typeAr: 'بيت ضيافة',
    typeEn: 'Guest House',
    locationAr: 'شارع ناصر - داخل أجواء البلدة القديمة - نابلس',
    locationEn: 'Al-Nasser St. - within the Old City ambiance - Nablus',
    rating: 4.6,
    reviews: 60,
    priceInfoAr: '80-140 ₪ / ليلة',
    priceInfoEn: '80-140 ₪ / night',
    priceTier: 'cheap',
    hoursAr: 'استقبال حسب الطلب',
    hoursEn: 'Reception on request',
    aboutAr:
        'بيت ضيافة بطابع تراثي، قريب من الأسواق القديمة والأماكن السياحية.',
    aboutEn:
        'A heritage-style guest house, close to the old markets and tourist sites.',
    phone: '+970 59 867 6719',
    image: 'assets/images/hotels/turquoise_hotels.jpeg',
    amenities: ['wifi'],
    tags: ['nearOldCity', 'nearMarkets'],
    placeholderIcon: Icons.villa,
    placeholderColor: Color(0xFF14B8A6),
  ),
  HotelData(
    nameAr: 'فندق الياسمين',
    nameEn: 'Al Yasmeen Hotel',
    typeAr: 'فندق',
    typeEn: 'Hotel',
    locationAr: 'وسط نابلس - قريب من البلدة القديمة والأسواق',
    locationEn: 'Central Nablus - near the Old City and markets',
    rating: 3.9,
    reviews: 55,
    priceInfoAr: '90-150 ₪ / ليلة',
    priceInfoEn: '90-150 ₪ / night',
    priceTier: 'cheap',
    hoursAr: 'استقبال على مدار الساعة',
    hoursEn: '24-hour front desk',
    aboutAr:
        'مناسب للزوار الذين يريدون الإقامة بالقرب من مركز المدينة والمعالم القديمة.',
    aboutEn:
        'Suitable for visitors who want to stay close to the city center and the old landmarks.',
    phone: '+970 9 233 3555',
    image: 'assets/images/hotels/alyasmeen_hotels.jpeg',
    amenities: ['wifi'],
    tags: ['nearOldCity', 'nearMarkets'],
    placeholderIcon: Icons.hotel,
    placeholderColor: Color(0xFFD4A017),
  ),
  HotelData(
    nameAr: 'بيت ضيافة سوفان',
    nameEn: 'Soufan Guest House',
    typeAr: 'بيت ضيافة',
    typeEn: 'Guest House',
    locationAr: 'حارة القريون - البلدة القديمة - نابلس',
    locationEn: 'Harat Al-Quryoun - Old City - Nablus',
    rating: 4.7,
    reviews: 45,
    priceInfoAr: '80-140 ₪ / ليلة',
    priceInfoEn: '80-140 ₪ / night',
    priceTier: 'cheap',
    hoursAr: 'استقبال حسب الطلب',
    hoursEn: 'Reception on request',
    aboutAr:
        'بيت ضيافة داخل منطقة تاريخية، قريب من الأسواق والمعالم مثل برج الساعة ومصانع الصابون القديمة.',
    aboutEn:
        'A guest house within a historic area, close to the markets and landmarks like the Clock Tower and old soap factories.',
    phone: '+970 59 778 1420',
    image: 'assets/images/hotels/soufan_hotels.jpeg',
    amenities: ['wifi'],
    tags: ['nearOldCity', 'nearMarkets', 'nearAttractions'],
    placeholderIcon: Icons.villa,
    placeholderColor: Color(0xFF9C6B30),
  ),
  HotelData(
    nameAr: 'فندق سليم أفندي',
    nameEn: 'Saleem Afandi Hotel',
    typeAr: 'فندق',
    typeEn: 'Hotel',
    locationAr: 'وسط البلد - مجمع الحسين التجاري - نابلس',
    locationEn: 'Downtown - Al-Hussein Commercial Complex - Nablus',
    rating: 4.1,
    reviews: 50,
    priceInfoAr: '200-280 ₪ / ليلة',
    priceInfoEn: '200-280 ₪ / night',
    priceTier: 'high',
    hoursAr: 'استقبال على مدار الساعة',
    hoursEn: '24-hour front desk',
    aboutAr:
        'فندق فاخر في قلب المدينة، قريب من الأسواق والمطاعم والأماكن السياحية، مناسب للزوار الذين يريدون الإقامة بالقرب من مركز المدينة.',
    aboutEn:
        'A luxury hotel in the heart of the city, close to the markets, restaurants, and tourist sites, ideal for visitors who want to stay near the city center.',
    phone: '+970 9 237 3338',
    image: 'assets/images/hotels/saleem_afandi.jpeg',
    amenities: ['wifi', 'restaurant'],
    tags: ['luxury', 'nearOldCity'],
    placeholderIcon: Icons.hotel,
    placeholderColor: Color(0xFF9C27B0),
  ),
  HotelData(
    nameAr: 'سكن ديمة',
    nameEn: 'Dima Residence',
    typeAr: 'استوديوهات طلابية',
    typeEn: 'Student Studios',
    locationAr:
        'رفيديا - شارع رفيديا الرئيسي - مقابل بوابة كلية الرياضة لجامعة النجاح - نابلس',
    locationEn:
        "Rafidia - Main Rafidia St. - opposite An-Najah's Sports College gate - Nablus",
    rating: 4.4,
    reviews: 40,
    priceInfoAr: '60-100 ₪ / ليلة',
    priceInfoEn: '60-100 ₪ / night',
    priceTier: 'cheap',
    hoursAr: 'استقبال على مدار الساعة',
    hoursEn: '24-hour front desk',
    aboutAr:
        'استوديوهات مفروشة بتصميم عصري ومناسبة للطالبات، قريبة جدًا من الجامعة.',
    aboutEn:
        'Modern furnished studios suitable for female students, very close to the university.',
    phone: '+970 59 822 1212',
    image: 'assets/images/hotels/dima.jpeg',
    amenities: ['wifi'],
    tags: ['nearUniversity'],
    placeholderIcon: Icons.apartment,
    placeholderColor: Color(0xFF22C55E),
  ),
  HotelData(
    nameAr: 'سكن لين للطالبات',
    nameEn: 'Leen Residence for Female Students',
    typeAr: 'سكن طلابي',
    typeEn: 'Student Housing',
    locationAr: 'مقابل الباب الغربي لجامعة النجاح - الحرم القديم - نابلس',
    locationEn:
        "Opposite An-Najah University's West Gate - Old Campus - Nablus",
    rating: 4.3,
    reviews: 35,
    priceInfoAr: '60-100 ₪ / ليلة',
    priceInfoEn: '60-100 ₪ / night',
    priceTier: 'cheap',
    hoursAr: 'استقبال على مدار الساعة',
    hoursEn: '24-hour front desk',
    aboutAr:
        'يحتوي على أجنحة واستوديوهات مفروشة ومكيفة مع خدمات مناسبة للطالبات.',
    aboutEn:
        'Features furnished, air-conditioned suites and studios with services suited for female students.',
    phone: '+970 59 534 9870',
    image: 'assets/images/hotels/leen.jpeg',
    amenities: ['wifi'],
    tags: ['nearUniversity'],
    placeholderIcon: Icons.apartment,
    placeholderColor: Color(0xFF14B8A6),
  ),
  HotelData(
    nameAr: 'إسكان النور',
    nameEn: 'Al-Nour Housing',
    typeAr: 'شقق مفروشة',
    typeEn: 'Furnished Apartments',
    locationAr: 'رفيديا - الشارع الرئيسي - نابلس',
    locationEn: 'Rafidia - Main St. - Nablus',
    rating: 4.2,
    reviews: 30,
    priceInfoAr: '60-100 ₪ / ليلة',
    priceInfoEn: '60-100 ₪ / night',
    priceTier: 'cheap',
    hoursAr: 'استقبال على مدار الساعة',
    hoursEn: '24-hour front desk',
    aboutAr: 'شقق مفروشة قريبة من منطقة جامعة النجاح والمطاعم والخدمات.',
    aboutEn:
        'Furnished apartments close to the An-Najah University area, restaurants, and services.',
    image: 'assets/images/hotels/al_nour.jpeg',
    amenities: ['wifi'],
    tags: ['nearUniversity'],
    placeholderIcon: Icons.apartment,
    placeholderColor: Color(0xFFC9A227),
  ),
];

// كلمة بحث إنجليزية مناسبة لصورة الفندق حسب نوعه، لما ما توجد صورة محلية.
String hotelPhotoQuery(HotelData h) {
  final text = '${h.nameAr} ${h.nameEn} ${h.typeEn}'.toLowerCase();
  if (text.contains('شقق') || text.contains('apartment')) {
    return 'furnished apartment interior';
  }
  if (text.contains('نزل') ||
      text.contains('guesthouse') ||
      text.contains('heritage')) {
    return 'traditional guesthouse interior';
  }
  return 'hotel exterior building';
}

const Map<String, IconData> amenityIcons = {
  'wifi': Icons.wifi,
  'parking': Icons.local_parking,
  'restaurant': Icons.restaurant,
  'roomService': Icons.room_service,
};

const Map<String, (String, String)> amenityLabels = {
  'wifi': ('واي فاي', 'WiFi'),
  'parking': ('مواقف سيارات', 'Parking'),
  'restaurant': ('مطعم', 'Restaurant'),
  'roomService': ('خدمة الغرف', 'Room Service'),
};

const List<(String, String, String)> _quickFilters = [
  ('nearOldCity', '🏛️ قريب من البلدة القديمة', '🏛️ Near Old City'),
  ('nearUniversity', '🎓 سكن الطلاب', '🎓 Student Housing'),
  ('luxury', '👑 فاخرة', '👑 Luxury'),
];

// ==================== الشاشة الرئيسية لصفحة الفنادق ====================
class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  bool _loaded = false;
  List<HotelData> _liveHotels = [];
  bool isGridView = true;

  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';
  String quickFilter = ''; // فاضي = بدون فلتر (الكل)
  double minRating = 0;
  String priceTier = 'all';
  int sortMode = 0; // 0 = الأعلى تقييماً، 1 = الأرخص أولاً، 2 = أبجدياً
  int currentPage = 0;
  static const int perPage = 9;
  static const _priceOrder = {'cheap': 0, 'medium': 1, 'high': 2};

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
    await db.syncSeed('hotels', hotelsSeedData.map(hotelToMap).toList());
    await ApiService.syncHotels();
    final entries = db.getAll('hotels');
    setState(() {
      _liveHotels = entries.map((e) => mapToHotel(e.value)).toList();
      _loaded = true;
    });
  }

  List<HotelData> get _filtered {
    var list = _liveHotels.where((h) {
      final matchesSearch =
          searchQuery.isEmpty ||
          h.nameAr.contains(searchQuery) ||
          h.nameEn.toLowerCase().contains(searchQuery.toLowerCase()) ||
          h.locationAr.contains(searchQuery) ||
          h.locationEn.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter = quickFilter.isEmpty || h.tags.contains(quickFilter);
      final matchesRating = h.rating >= minRating;
      final matchesPrice = priceTier == 'all' || h.priceTier == priceTier;
      return matchesSearch && matchesFilter && matchesRating && matchesPrice;
    }).toList();
    if (sortMode == 1) {
      list.sort(
        (a, b) => (_priceOrder[a.priceTier] ?? 1).compareTo(_priceOrder[b.priceTier] ?? 1),
      );
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

  List<HotelData> get _paged {
    final list = _filtered;
    final start = (currentPage * perPage).clamp(0, list.length);
    final end = (start + perPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get _pageCount {
    final len = _filtered.length;
    return len == 0 ? 1 : ((len - 1) ~/ perPage) + 1;
  }

  void _openHotelDetail(BuildContext context, HotelData h) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => HotelDetailScreen(hotel: h)),
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
                    _HotelsTopBar(),
                    _HotelsBanner(),
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
                            onTap: (key) => setState(() {
                              quickFilter = quickFilter == key ? '' : key;
                              currentPage = 0;
                            }),
                          ),
                          SizedBox(height: 10),
                          _RatingPriceFiltersRow(
                            minRating: minRating,
                            priceTier: priceTier,
                            onRatingTap: (v) => setState(() {
                              minRating = minRating == v ? 0 : v;
                              currentPage = 0;
                            }),
                            onPriceTap: (v) => setState(() {
                              priceTier = v;
                              currentPage = 0;
                            }),
                          ),
                          SizedBox(height: 22),
                          Row(
                            children: [
                              Text(
                                app.t(
                                  '${filtered.length} فندق',
                                  '${filtered.length} hotels',
                                ),
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 12),
                              SortToggle(
                                activeIndex: sortMode,
                                labelsAr: const ['الأعلى تقييماً', 'الأقل سعراً', 'أبجدياً'],
                                labelsEn: const ['Top Rated', 'Lowest Price', 'A–Z'],
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
                                    'لا توجد فنادق مطابقة',
                                    'No matching hotels',
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
                                final h = _paged[i];
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _openHotelDetail(context, h),
                                  child: _HotelCard(
                                    hotel: h,
                                    isFavorite: FavoritesService.instance
                                        .isFavorite(h.nameEn),
                                    onFavorite: () async {
                                      await FavoritesService.instance
                                          .toggleFavorite(h.nameEn);
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
                                    (h) => Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () =>
                                            _openHotelDetail(context, h),
                                        child: _HotelListTile(
                                          hotel: h,
                                          isFavorite: FavoritesService.instance
                                              .isFavorite(h.nameEn),
                                          onFavorite: () async {
                                            await FavoritesService.instance
                                                .toggleFavorite(h.nameEn);
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
class _HotelsTopBar extends StatelessWidget {
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
            child: Icon(Icons.hotel, color: Colors.white, size: 16),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              app.t('الفنادق', 'Hotels'),
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
class _HotelsBanner extends StatelessWidget {
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
              query: 'hotel room bed Nablus',
              fallbackSeed: 'nablus-hotels-banner',
              fallbackIcon: Icons.hotel,
            ),
            child: ThemedImage(
              query: 'hotel room bed Nablus',
              fallbackSeed: 'nablus-hotels-banner',
              height: 200,
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
              app.t('أفضل أماكن الإقامة في نابلس', 'The Best Stays in Nablus'),
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

// ==================== فلتر التقييم والسعر ====================
class _RatingPriceFiltersRow extends StatelessWidget {
  final double minRating;
  final String priceTier;
  final void Function(double) onRatingTap;
  final void Function(String) onPriceTap;
  const _RatingPriceFiltersRow({
    required this.minRating,
    required this.priceTier,
    required this.onRatingTap,
    required this.onPriceTap,
  });

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardDark2,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textWhite,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final r in [4.5, 4.0, 3.5])
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: _chip(
                '⭐ $r+',
                minRating == r,
                () => onRatingTap(r),
              ),
            ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: 1,
            height: 20,
            color: AppColors.borderColor,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: _chip(app.t('كل الأسعار', 'All Prices'), priceTier == 'all', () => onPriceTap('all')),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: _chip(app.t('رخيص', 'Cheap'), priceTier == 'cheap', () => onPriceTap('cheap')),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: _chip(app.t('متوسط', 'Medium'), priceTier == 'medium', () => onPriceTap('medium')),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: _chip(app.t('مرتفع', 'High'), priceTier == 'high', () => onPriceTap('high')),
          ),
        ],
      ),
    );
  }
}

// ==================== تصنيفات سريعة ====================
class _QuickFiltersRow extends StatelessWidget {
  final String selected;
  final void Function(String) onTap;
  const _QuickFiltersRow({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _quickFilters.map((f) {
          final key = f.$1;
          final isSelected = selected == key;
          return Padding(
            padding: EdgeInsets.only(left: 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(key),
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
                child: Text(
                  app.t(f.$2, f.$3),
                  textDirection: app.dir,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ==================== ودجت صف أيقونات الخدمات الصغير ====================
class _AmenitiesRow extends StatelessWidget {
  final List<String> amenities;
  const _AmenitiesRow({required this.amenities});

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) return SizedBox.shrink();
    return Row(
      children: amenities
          .take(4)
          .map(
            (key) => Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(
                amenityIcons[key] ?? Icons.check_circle_outline,
                size: 13,
                color: AppColors.textGrey,
              ),
            ),
          )
          .toList(),
    );
  }
}

// ==================== كرت الفندق (Grid) ====================
class _HotelCard extends StatelessWidget {
  final HotelData hotel;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const _HotelCard({
    required this.hotel,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final h = hotel;
    final name = app.isArabic ? h.nameAr : h.nameEn;
    final type = app.isArabic ? h.typeAr : h.typeEn;
    final location = app.isArabic ? h.locationAr : h.locationEn;
    final priceInfo = app.isArabic ? h.priceInfoAr : h.priceInfoEn;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ThemedImage(
                  query: hotelPhotoQuery(h),
                  fallbackSeed: h.nameEn,
                  height: double.infinity,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  fallbackIcon: h.placeholderIcon,
                  fallbackColor: h.placeholderColor,
                  customImageBase64: h.customImageBase64,
                  localAsset: h.image,
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
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.white),
                        SizedBox(width: 3),
                        Text(
                          '${h.rating}',
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
                if (h.isFeatured)
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
                SizedBox(height: 2),
                Text(
                  type,
                  textDirection: app.dir,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 10),
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
                Text(
                  priceInfo,
                  textDirection: app.dir,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (h.amenities.isNotEmpty) ...[
                  SizedBox(height: 6),
                  _AmenitiesRow(amenities: h.amenities),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== بطاقة قائمة الفندق (List) ====================
class _HotelListTile extends StatelessWidget {
  final HotelData hotel;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const _HotelListTile({
    required this.hotel,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final h = hotel;
    final name = app.isArabic ? h.nameAr : h.nameEn;
    final type = app.isArabic ? h.typeAr : h.typeEn;
    final location = app.isArabic ? h.locationAr : h.locationEn;
    final priceInfo = app.isArabic ? h.priceInfoAr : h.priceInfoEn;

    return AppCard(
      padding: EdgeInsets.all(10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: ThemedImage(
              query: hotelPhotoQuery(h),
              fallbackSeed: h.nameEn,
              height: 70,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              fallbackIcon: h.placeholderIcon,
              fallbackColor: h.placeholderColor,
              customImageBase64: h.customImageBase64,
              localAsset: h.image,
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
                Text(
                  type,
                  textDirection: app.dir,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 10),
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
                _AmenitiesRow(amenities: h.amenities),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.star, size: 12, color: AppColors.gold),
                  SizedBox(width: 3),
                  Text(
                    '${h.rating}',
                    style: TextStyle(color: AppColors.textWhite, fontSize: 11),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                priceInfo,
                textDirection: app.dir,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
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

// ==================== شاشة تفاصيل الفندق ====================
class HotelDetailScreen extends StatefulWidget {
  final HotelData hotel;
  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final h = widget.hotel;
    final name = app.isArabic ? h.nameAr : h.nameEn;
    final type = app.isArabic ? h.typeAr : h.typeEn;
    final location = app.isArabic ? h.locationAr : h.locationEn;
    final priceInfo = app.isArabic ? h.priceInfoAr : h.priceInfoEn;
    final hours = app.isArabic ? h.hoursAr : h.hoursEn;
    final about = app.isArabic ? h.aboutAr : h.aboutEn;
    final images = [h.image, ...h.gallery].where((s) => s.isNotEmpty).toList();

    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
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
                    Stack(
                      children: [
                        SizedBox(
                          height: 260,
                          child: images.length > 1
                              ? PageView.builder(
                                  controller: _pageController,
                                  itemCount: images.length,
                                  onPageChanged: (i) =>
                                      setState(() => _page = i),
                                  itemBuilder: (context, i) => GestureDetector(
                                    onTap: () => showImageZoom(
                                      context,
                                      query: hotelPhotoQuery(h),
                                      fallbackSeed: '${h.nameEn}-$i',
                                      fallbackIcon: h.placeholderIcon,
                                      fallbackColor: h.placeholderColor,
                                      customImageBase64: i == 0
                                          ? h.customImageBase64
                                          : null,
                                      localAsset: images[i],
                                    ),
                                    child: ThemedImage(
                                      query: hotelPhotoQuery(h),
                                      fallbackSeed: '${h.nameEn}-$i',
                                      height: 260,
                                      fallbackIcon: h.placeholderIcon,
                                      fallbackColor: h.placeholderColor,
                                      customImageBase64: i == 0
                                          ? h.customImageBase64
                                          : null,
                                      localAsset: images[i],
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () => showImageZoom(
                                    context,
                                    query: hotelPhotoQuery(h),
                                    fallbackSeed: h.nameEn,
                                    fallbackIcon: h.placeholderIcon,
                                    fallbackColor: h.placeholderColor,
                                    customImageBase64: h.customImageBase64,
                                    localAsset: h.image,
                                  ),
                                  child: ThemedImage(
                                    query: hotelPhotoQuery(h),
                                    fallbackSeed: h.nameEn,
                                    height: 260,
                                    fallbackIcon: h.placeholderIcon,
                                    fallbackColor: h.placeholderColor,
                                    customImageBase64: h.customImageBase64,
                                    localAsset: h.image,
                                  ),
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
                        if (images.length > 1)
                          Positioned(
                            bottom: 60,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                images.length,
                                (i) => Container(
                                  width: 6,
                                  height: 6,
                                  margin: EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i == _page
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          left: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                name,
                                textDirection: app.dir,
                                style: AppTypography.display(
                                  Colors.white,
                                ).copyWith(fontSize: 22),
                              ),
                              Text(
                                type,
                                textDirection: app.dir,
                                style: AppTypography.body(Colors.white70),
                              ),
                            ],
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
                                      '${h.rating}',
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
                                '(${h.reviews} ${app.t('تقييم', 'reviews')})',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 11,
                                ),
                              ),
                              Spacer(),
                              Text(
                                priceInfo,
                                textDirection: app.dir,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
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
                          if (h.amenities.isNotEmpty) ...[
                            SizedBox(height: 18),
                            Text(
                              app.t('الخدمات المتاحة', 'Available Services'),
                              textDirection: app.dir,
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: h.amenities.map((key) {
                                final label = amenityLabels[key];
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardDark2,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.pill,
                                    ),
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        amenityIcons[key] ??
                                            Icons.check_circle_outline,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        label == null
                                            ? key
                                            : app.t(label.$1, label.$2),
                                        style: TextStyle(
                                          color: AppColors.textWhite,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
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
                          if (h.phone.isNotEmpty) ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    launchUrl(Uri.parse('tel:${h.phone}')),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColors.borderColor,
                                  ),
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
                                  app.t(
                                    'اتصال: ${h.phone}',
                                    'Call: ${h.phone}',
                                  ),
                                  style: AppTypography.label(
                                    AppColors.textWhite,
                                  ),
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
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                boxShadow: AppColors.glowShadow,
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final point = resolveMapPoint(
                                    nameAr: h.nameAr,
                                    nameEn: h.nameEn,
                                    locationAr: h.locationAr,
                                    locationEn: h.locationEn,
                                    lat: h.lat,
                                    lng: h.lng,
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
                                  nameAr: h.nameAr,
                                  nameEn: h.nameEn,
                                  locationAr: h.locationAr,
                                  locationEn: h.locationEn,
                                  lat: h.lat,
                                  lng: h.lng,
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MapScreen(
                                      focusPoint: point,
                                      focusNameAr: h.nameAr,
                                      focusNameEn: h.nameEn,
                                      focusCategoryAr: h.typeAr,
                                      focusCategoryEn: h.typeEn,
                                      focusRating: h.rating,
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
                              onPressed: () => Share.share(
                                '${app.isArabic ? h.nameAr : h.nameEn} '
                                '(${h.rating}⭐) — ${app.isArabic ? h.locationAr : h.locationEn}',
                              ),
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
          ),
        );
      },
    );
  }
}
