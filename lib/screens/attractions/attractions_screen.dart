import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../services/location_service.dart' show findNearest;
import '../../widgets/themed_image.dart';
import '../../widgets/responsive.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../services/favorites_service.dart';
import '../../services/api_service.dart';
import '../map/map_screen.dart';
import '../../theme/app_typography.dart';
import '../restaurants/restaurants_screen.dart';
import '../hotels/hotels_screen.dart';
import '../../widgets/app_toggle_bar.dart';
import '../../widgets/keyboard_scrollable.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/sort_toggle.dart';
import 'package:share_plus/share_plus.dart';

// ==================== بيانات المعلم السياحي ====================
class AttractionData {
  final String nameAr;
  final String nameEn;
  final List<String>
  categories; // historical / religious / nature / oldCity / culture
  final String locationAr;
  final String locationEn;
  final double rating;
  final int reviews;
  final String aboutAr; // نبذة تاريخية
  final String aboutEn;
  final String visitHoursAr; // فاضي = بدون معلومة مؤكدة (تُخفى بالواجهة)
  final String visitHoursEn;
  final String entryFeeAr; // 'مجاني' أو فاضي لو غير مؤكد
  final String entryFeeEn;
  final String image;
  final IconData placeholderIcon;
  final Color placeholderColor;
  final String? customImageBase64;
  final bool isFeatured;
  final double? lat;
  final double? lng;
  final String? serverImageUrl;

  AttractionData({
    required this.nameAr,
    required this.nameEn,
    required this.categories,
    required this.locationAr,
    required this.locationEn,
    required this.rating,
    required this.reviews,
    required this.aboutAr,
    required this.aboutEn,
    this.visitHoursAr = '',
    this.visitHoursEn = '',
    this.entryFeeAr = '',
    this.entryFeeEn = '',
    this.image = '',
    required this.placeholderIcon,
    required this.placeholderColor,
    this.customImageBase64,
    this.isFeatured = false,
    this.lat,
    this.lng,
    this.serverImageUrl,
  });
}

final List<AttractionData> attractionsSeedData = [
  // ---------- تاريخية + البلدة القديمة ----------
  AttractionData(
    nameAr: 'البلدة القديمة',
    nameEn: 'Old City',
    categories: ['historical', 'oldCity'],
    locationAr: 'وسط نابلس - البلدة القديمة',
    locationEn: 'Central Nablus - Old City',
    rating: 4.8,
    reviews: 520,
    aboutAr:
        'قلب نابلس التاريخي، أزقة ضيقة وأسواق تراثية وعمارة عثمانية ومملوكية عريقة تعكس عمق تاريخ المدينة.',
    aboutEn:
        'The historic heart of Nablus, with narrow alleys, heritage markets, and ancient Ottoman and Mamluk architecture reflecting the city\'s deep history.',
    visitHoursAr: 'على مدار اليوم (ساعات النهار)',
    visitHoursEn: 'All day (daylight hours)',
    entryFeeAr: 'مجاني',
    entryFeeEn: 'Free',
    image: 'assets/images/landmark/old_city_alley.jpg',
    placeholderIcon: Icons.account_balance,
    placeholderColor: Color(0xFFC9A227),
    isFeatured: true,
    lat: 32.2202,
    lng: 35.2588,
  ),
  AttractionData(
    nameAr: 'خان الوكالة',
    nameEn: 'Khan Al-Wakala',
    categories: ['historical', 'oldCity'],
    locationAr: 'البلدة القديمة - سوق الحدادين - نابلس',
    locationEn: 'Old City - Souq Al-Hadadeen - Nablus',
    rating: 4.6,
    reviews: 210,
    aboutAr:
        'خان تاريخي من العهد العثماني كان محطة رئيسية للقوافل التجارية، يعكس عراقة نابلس التجارية القديمة.',
    aboutEn:
        'A historic Ottoman-era caravanserai that was a major stop for trade caravans, reflecting the ancient commercial legacy of Nablus.',
    visitHoursAr: 'على مدار اليوم (ساعات النهار)',
    visitHoursEn: 'All day (daylight hours)',
    entryFeeAr: 'مجاني',
    entryFeeEn: 'Free',
    image: 'assets/images/hotels/khan_hotel.jpeg',
    placeholderIcon: Icons.location_city,
    placeholderColor: Color(0xFF9C6B30),
    isFeatured: true,
  ),
  AttractionData(
    nameAr: 'برج الساعة',
    nameEn: 'Clock Tower',
    categories: ['historical', 'oldCity'],
    locationAr: 'وسط البلد - نابلس',
    locationEn: 'Downtown - Nablus',
    rating: 4.5,
    reviews: 190,
    aboutAr:
        'برج الساعة التاريخي، بُني عام 1906 في عهد السلطان العثماني عبد الحميد الثاني، ويُعد من أبرز معالم وسط نابلس.',
    aboutEn:
        'The historic Clock Tower, built in 1906 under Ottoman Sultan Abdul Hamid II, and one of the most prominent landmarks in downtown Nablus.',
    visitHoursAr: 'على مدار اليوم',
    visitHoursEn: 'All day',
    entryFeeAr: 'مجاني',
    entryFeeEn: 'Free',
    image: 'assets/images/landmark/برج الساعة.jpeg',
    placeholderIcon: Icons.access_time_filled,
    placeholderColor: Color(0xFFB5651D),
    lat: 32.218889,
    lng: 35.261389,
  ),
  AttractionData(
    nameAr: 'مصنع النابلسي للصابون',
    nameEn: 'Al-Nabulsi Soap Factory',
    categories: ['historical', 'oldCity'],
    locationAr: 'البلدة القديمة - نابلس',
    locationEn: 'Old City - Nablus',
    rating: 4.3,
    reviews: 80,
    aboutAr:
        'مصنع تقليدي عريق لصناعة الصابون النابلسي الشهير، يحمل اسم عائلة نابلسية عريقة بهذه الحرفة.',
    aboutEn:
        'A long-established traditional factory for the famous Nabulsi soap, bearing the name of a Nablus family renowned for this craft.',
    image: 'assets/images/landmark/مصنع النابلسي.jpeg',
    placeholderIcon: Icons.spa,
    placeholderColor: Color(0xFF6F8F4E),
  ),
  AttractionData(
    nameAr: 'سوق القيسارية',
    nameEn: 'Al-Qaisariya Souq',
    categories: ['historical', 'oldCity'],
    locationAr: 'البلدة القديمة - نابلس',
    locationEn: 'Old City - Nablus',
    rating: 4.5,
    reviews: 140,
    aboutAr:
        'سوق مسقوف تاريخي داخل البلدة القديمة، من أقدم أسواق نابلس التجارية.',
    aboutEn:
        'A historic covered market inside the Old City, one of the oldest commercial souqs in Nablus.',
    visitHoursAr: 'يفتح صباحًا حتى المساء',
    visitHoursEn: 'Open morning to evening',
    entryFeeAr: 'مجاني',
    entryFeeEn: 'Free',
    image: 'assets/images/landmark/souq_qaysariya.jpg',
    placeholderIcon: Icons.storefront,
    placeholderColor: Color(0xFFD4A017),
  ),
  AttractionData(
    nameAr: 'سوق الخان',
    nameEn: 'Al-Khan Souq',
    categories: ['historical', 'oldCity'],
    locationAr: 'البلدة القديمة - نابلس',
    locationEn: 'Old City - Nablus',
    rating: 4.3,
    reviews: 90,
    aboutAr:
        'سوق تراثي داخل نسيج البلدة القديمة المتشابك من الأزقة والأسواق التاريخية.',
    aboutEn:
        'A heritage market woven into the interlocking alleys and historic souqs of the Old City.',
    visitHoursAr: 'يفتح صباحًا حتى المساء',
    visitHoursEn: 'Open morning to evening',
    entryFeeAr: 'مجاني',
    entryFeeEn: 'Free',
    image: 'assets/images/landmark/سوق الخان.jpeg',
    placeholderIcon: Icons.storefront,
    placeholderColor: Color(0xFF9C6B30),
  ),
  AttractionData(
    nameAr: 'باب الساحة',
    nameEn: 'Bab Al-Saha',
    categories: ['historical', 'oldCity'],
    locationAr: 'البلدة القديمة - نابلس',
    locationEn: 'Old City - Nablus',
    rating: 4.3,
    reviews: 75,
    aboutAr:
        'أحد أبواب وحارات البلدة القديمة التاريخية، ويشكل مدخلًا لأحد أعرق أحيائها.',
    aboutEn:
        'One of the historic gates and quarters of the Old City, forming an entrance to one of its oldest neighborhoods.',
    visitHoursAr: 'على مدار اليوم',
    visitHoursEn: 'All day',
    entryFeeAr: 'مجاني',
    entryFeeEn: 'Free',
    image: 'assets/images/landmark/باب الساحة.jpeg',
    placeholderIcon: Icons.door_front_door,
    placeholderColor: Color(0xFF7C6A46),
  ),

  // ---------- دينية ----------
  AttractionData(
    nameAr: 'جامع النصر',
    nameEn: 'An-Nasr Mosque',
    categories: ['religious'],
    locationAr: 'البلدة القديمة - نابلس',
    locationEn: 'Old City - Nablus',
    rating: 4.6,
    reviews: 130,
    aboutAr:
        'من المساجد التاريخية المعروفة بنابلس، يعكس طابع العمارة الإسلامية التقليدية بالمدينة.',
    aboutEn:
        'One of the well-known historic mosques in Nablus, reflecting the city\'s traditional Islamic architecture.',
    visitHoursAr: 'أوقات الصلاة والنهار',
    visitHoursEn: 'Prayer times and daytime',
    entryFeeAr: 'مجاني',
    entryFeeEn: 'Free',
    image: 'assets/images/landmark/جامع النصر.jpeg',
    placeholderIcon: Icons.mosque,
    placeholderColor: Color(0xFFB5651D),
    lat: 32.218889,
    lng: 35.261389,
  ),
  AttractionData(
    nameAr: 'جامع الخضر',
    nameEn: 'Al-Khader Mosque',
    categories: ['religious'],
    locationAr: 'نابلس',
    locationEn: 'Nablus',
    rating: 4.5,
    reviews: 100,
    aboutAr:
        'مسجد تاريخي معروف بنابلس يحمل اسم الخضر، ويعد من المعالم الدينية المهمة بالمدينة.',
    aboutEn:
        'A historic mosque in Nablus named after Al-Khader, and one of the city\'s important religious landmarks.',
    visitHoursAr: 'أوقات الصلاة والنهار',
    visitHoursEn: 'Prayer times and daytime',
    entryFeeAr: 'مجاني',
    entryFeeEn: 'Free',
    image: 'assets/images/landmark/جامع الخضر.jpg',
    placeholderIcon: Icons.mosque,
    placeholderColor: Color(0xFFB5651D),
    lat: 32.2123,
    lng: 35.2709,
  ),
  AttractionData(
    nameAr: 'جبل جرزيم',
    nameEn: 'Mount Gerizim',
    categories: ['nature'],
    locationAr: 'جنوب نابلس',
    locationEn: 'South Nablus',
    rating: 4.7,
    reviews: 310,
    aboutAr:
        'جبل مقدس عند الطائفة السامرية ومقر تجمعها الرئيسي، ويوفر إطلالة بانورامية رائعة على مدينة نابلس بالكامل.',
    aboutEn:
        'A mountain sacred to the Samaritan community and their main gathering place, offering a stunning panoramic view over the entire city of Nablus.',
    visitHoursAr: 'على مدار اليوم (ساعات النهار)',
    visitHoursEn: 'All day (daylight hours)',
    entryFeeAr: 'مجاني',
    entryFeeEn: 'Free',
    image: 'assets/images/landmark/جبل_جرزيم.jpg',
    placeholderIcon: Icons.terrain,
    placeholderColor: Color(0xFF4C8C4A),
    isFeatured: true,
    lat: 32.2009,
    lng: 35.2731,
  ),
  AttractionData(
    nameAr: 'مقام النبي يوسف',
    nameEn: "Joseph's Tomb",
    categories: ['religious'],
    locationAr: 'بلاطة - نابلس',
    locationEn: 'Balata - Nablus',
    rating: 4.2,
    reviews: 60,
    aboutAr:
        'موقع ديني تقليدي يُنسب للنبي يوسف عليه السلام، والزيارة إليه منسّقة عادة عبر الجهات المختصة.',
    aboutEn:
        "A traditional religious site attributed to the Prophet Joseph, with visits typically coordinated through the relevant authorities.",
    image: 'assets/images/landmark/مقام النبي يوسف.jpg',
    placeholderIcon: Icons.location_on,
    placeholderColor: Color(0xFF6C5CE7),
    lat: 32.211389,
    lng: 35.282222,
  ),

  // ---------- طبيعة وحدائق ----------
  AttractionData(
    nameAr: 'وادي الباذان',
    nameEn: 'Wadi Al-Badhan',
    categories: ['nature'],
    locationAr: 'وادي الباذان - شمال شرق نابلس',
    locationEn: 'Wadi Al-Badhan - Northeast of Nablus',
    rating: 4.6,
    reviews: 220,
    aboutAr:
        'منطقة طبيعية خلابة على بعد نحو 5 كم شمال شرق نابلس، تشتهر بينابيعها المتعددة وأشجار الحور والصفصاف، ومقصد شهير للتنزه.',
    aboutEn:
        'A scenic natural area about 5km northeast of Nablus, known for its many springs and poplar and willow trees, a popular destination for outings.',
    visitHoursAr: 'على مدار اليوم (ساعات النهار)',
    visitHoursEn: 'All day (daylight hours)',
    entryFeeAr: 'مجاني',
    entryFeeEn: 'Free',
    image: 'assets/images/landmark/وادي البادان.jpeg',
    placeholderIcon: Icons.landscape,
    placeholderColor: Color(0xFF4C8C4A),
    isFeatured: true,
  ),
  AttractionData(
    nameAr: 'متنزه جمال عبد الناصر',
    nameEn: 'Gamal Abdel Nasser Park',
    categories: ['nature'],
    locationAr: 'نابلس',
    locationEn: 'Nablus',
    rating: 4.3,
    reviews: 170,
    aboutAr:
        'متنزه عام مناسب للعائلات، فيه مساحات خضراء ومقاعد ومسارات مشي للاسترخاء.',
    aboutEn:
        'A public park suitable for families, with green spaces, seating, and walking paths for relaxation.',
    visitHoursAr: 'على مدار اليوم (ساعات النهار)',
    visitHoursEn: 'All day (daylight hours)',
    entryFeeAr: 'مجاني',
    entryFeeEn: 'Free',
    image: 'assets/images/landmark/منتزه جمال عبدالناصر.jpeg',
    placeholderIcon: Icons.park,
    placeholderColor: Color(0xFF22C55E),
  ),

  // ---------- متاحف وثقافة ----------
  AttractionData(
    nameAr: 'مركز الطفل الثقافي',
    nameEn: 'Children\'s Cultural Center',
    categories: ['culture'],
    locationAr: 'البلدة القديمة - نابلس',
    locationEn: 'Old City - Nablus',
    rating: 4.3,
    reviews: 50,
    aboutAr:
        'مركز ثقافي بقلب البلدة القديمة تأسس عام 1998 بالتعاون مع اليونيسكو، يقدّم أنشطة وورشات ثقافية واجتماعية.',
    aboutEn:
        'A cultural center in the heart of the Old City, established in 1998 in cooperation with UNICEF, offering cultural and social activities and workshops.',
    image: 'assets/images/landmark/مركز الطفل الثقافي.jpeg',
    placeholderIcon: Icons.theater_comedy,
    placeholderColor: Color(0xFFD4A017),
  ),
  AttractionData(
    nameAr: 'المركز الثقافي البلدي',
    nameEn: 'Nablus Municipal Cultural Center',
    categories: ['culture'],
    locationAr: 'نابلس',
    locationEn: 'Nablus',
    rating: 4.2,
    reviews: 45,
    aboutAr:
        'مركز ثقافي تابع لبلدية نابلس تأسس عام 1996، يستضيف فعاليات ومعارض فنية محلية أبرزها معرض "الأصالة والإبداع" السنوي.',
    aboutEn:
        'A cultural center run by the Nablus Municipality, established in 1996, hosting local events and art exhibitions, most notably the annual "Authenticity and Creativity" exhibition.',
    image: 'assets/images/landmark/مركز الثقافي البلدي.jpeg',
    placeholderIcon: Icons.palette,
    placeholderColor: Color(0xFFB33A2E),
  ),
  AttractionData(
    nameAr: 'مكتبة بلدية نابلس',
    nameEn: 'Nablus Municipal Library',
    categories: ['culture'],
    locationAr: 'نابلس',
    locationEn: 'Nablus',
    rating: 4.1,
    reviews: 40,
    aboutAr:
        'المكتبة العامة التابعة لبلدية نابلس، تخدم الطلاب والباحثين والمهتمين بالقراءة.',
    aboutEn:
        'The public library run by the Nablus Municipality, serving students, researchers, and reading enthusiasts.',
    image: 'assets/images/landmark/مكتبة بلدية نابلس.jpeg',
    placeholderIcon: Icons.local_library,
    placeholderColor: Color(0xFF14B8A6),
  ),
];

// كلمة بحث إنجليزية مناسبة لصورة المعلم حسب تصنيفه، لما ما توجد صورة محلية.
String attractionPhotoQuery(AttractionData a) {
  if (a.categories.contains('nature')) return 'nature landscape valley';
  if (a.categories.contains('religious')) return 'historic mosque church';
  if (a.categories.contains('culture')) return 'museum cultural exhibit';
  if (a.categories.contains('oldCity')) return 'old town stone alley market';
  return 'historic landmark';
}

const List<String> attractionCategoryOrder = [
  'historical',
  'religious',
  'nature',
  'oldCity',
  'culture',
];

const Map<String, (String, String)> attractionCategoryLabels = {
  'historical': ('🏛️ المعالم التاريخية', '🏛️ Historical Landmarks'),
  'religious': ('🕌 الأماكن الدينية', '🕌 Religious Sites'),
  'nature': ('⛰️ الطبيعة والحدائق', '⛰️ Nature & Parks'),
  'oldCity': ('🏘️ البلدة القديمة', '🏘️ Old City'),
  'culture': ('🏺 المتاحف والثقافة', '🏺 Museums & Culture'),
};

const Map<String, IconData> _attractionCategoryIcons = {
  'historical': Icons.account_balance,
  'religious': Icons.mosque,
  'nature': Icons.terrain,
  'oldCity': Icons.storefront,
  'culture': Icons.museum,
};

const Map<String, Color> _attractionCategoryColors = {
  'historical': Color(0xFFC9A227),
  'religious': Color(0xFFB5651D),
  'nature': Color(0xFF4C8C4A),
  'oldCity': Color(0xFF9C6B30),
  'culture': Color(0xFF6C5CE7),
};

// صور حقيقية لكروت التصنيفات (اختيارية) - إذا ما في صورة لقسم معيّن بيرجع
// لتصميم الأيقونة الافتراضي.
const Map<String, String> _attractionCategoryImages = {
  'historical': 'assets/images/landmark/andmark.jpeg',
  'religious': 'assets/images/landmark/religious sites.jpeg',
  'nature': 'assets/images/landmark/nature.jpeg',
  'oldCity': 'assets/images/landmark/old town.jpeg',
  'culture': 'assets/images/landmark/culture.jpeg',
};

List<HotelData> _liveHotelsSync() => LocalDbService.instance
    .getAll('hotels')
    .map((e) => mapToHotel(e.value))
    .toList();

List<RestaurantData> _liveRestaurantsSync() => LocalDbService.instance
    .getAll('restaurants')
    .map((e) => mapToRestaurant(e.value))
    .toList();

// ==================== شاشة التصنيفات (نقطة الدخول) ====================
class AttractionCategoriesScreen extends StatefulWidget {
  const AttractionCategoriesScreen({super.key});

  @override
  State<AttractionCategoriesScreen> createState() =>
      _AttractionCategoriesScreenState();
}

class _AttractionCategoriesScreenState
    extends State<AttractionCategoriesScreen> {
  bool _loaded = false;
  List<AttractionData> _liveAttractionsList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = LocalDbService.instance;
    await db.syncSeed(
      'attractions',
      attractionsSeedData.map(attractionToMap).toList(),
    );
    await ApiService.syncAttractions();
    final entries = db.getAll('attractions');
    setState(() {
      _liveAttractionsList = entries
          .map((e) => mapToAttraction(e.value))
          .toList();
      _loaded = true;
    });
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
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AttractionsTopBar(
                    titleAr: 'سياحة ومعالم',
                    titleEn: 'Attractions',
                  ),
                  _AttractionsBanner(),
                  Padding(
                    padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TourPlannerScreen(),
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.primaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              boxShadow: AppColors.glowShadow,
                            ),
                            child: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Icon(
                                  Icons.explore,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        app.t(
                                          '🧭 خطط جولتي',
                                          '🧭 Plan My Tour',
                                        ),
                                        textDirection: app.dir,
                                        style: AppTypography.title(
                                          Colors.white,
                                        ).copyWith(fontSize: 15),
                                      ),
                                      Text(
                                        app.t(
                                          'مسار سياحي جاهز حسب الوقت اللي عندك',
                                          'A ready-made tour route based on your time',
                                        ),
                                        textDirection: app.dir,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: attractionCategoryOrder.length + 1,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: responsiveGridColumns(
                                  context,
                                  wide: 3,
                                  narrow: 2,
                                ),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.05,
                              ),
                          itemBuilder: (context, i) {
                            if (i == attractionCategoryOrder.length) {
                              return _ExperienceCategoryCard(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LocalExperiencesScreen(),
                                  ),
                                ),
                              );
                            }
                            final key = attractionCategoryOrder[i];
                            final count = _liveAttractionsList
                                .where((a) => a.categories.contains(key))
                                .length;
                            return _AttractionCategoryCard(
                              categoryKey: key,
                              count: count,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AttractionsScreen(initialCategory: key),
                                ),
                              ),
                            );
                          },
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

class _AttractionCategoryCard extends StatelessWidget {
  final String categoryKey;
  final int count;
  final VoidCallback onTap;
  const _AttractionCategoryCard({
    required this.categoryKey,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final label = attractionCategoryLabels[categoryKey];
    final title = label == null ? '' : app.t(label.$1, label.$2);
    final image = _attractionCategoryImages[categoryKey];

    if (image != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppColors.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(image, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.start,
                      textDirection: app.dir,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      app.t('$count معلم', '$count places'),
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final icon = _attractionCategoryIcons[categoryKey] ?? Icons.place;
    final color = _attractionCategoryColors[categoryKey] ?? AppColors.primary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.sidebarDark,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderColor),
        ),
        padding: EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              textDirection: app.dir,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              app.t('$count معلم', '$count places'),
              style: TextStyle(color: AppColors.textGrey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceCategoryCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ExperienceCategoryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/landmark/تجارب محلية.jpeg',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                app.t('🍽️ تجارب محلية', '🍽️ Local Experiences'),
                textAlign: TextAlign.start,
                textDirection: app.dir,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== الشريط العلوي (مشترك) ====================
class _AttractionsTopBar extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  const _AttractionsTopBar({required this.titleAr, required this.titleEn});

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
            child: Icon(Icons.mosque, color: Colors.white, size: 16),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              app.t(titleAr, titleEn),
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
class _AttractionsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
      height: 190,
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
              query: 'old town stone alley',
              fallbackSeed: 'nablus-attractions-banner',
              fallbackIcon: Icons.mosque,
            ),
            child: ThemedImage(
              query: 'old town stone alley',
              fallbackSeed: 'nablus-attractions-banner',
              height: 190,
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
              app.t('اكتشف معالم نابلس', 'Discover the Landmarks of Nablus'),
              textDirection: app.dir,
              textAlign: TextAlign.center,
              style: AppTypography.display(Colors.white).copyWith(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== شريط البحث (مشترك) ====================
class _AttractionsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;
  const _AttractionsSearchBar({
    required this.controller,
    required this.onChanged,
  });

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
                hintText: app.t('ابحث عن معلم...', 'Search for a landmark...'),
                hintStyle: AppTypography.caption(AppColors.textGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== شاشة قائمة المعالم ====================
class AttractionsScreen extends StatefulWidget {
  final String? initialCategory;
  const AttractionsScreen({super.key, this.initialCategory});

  @override
  State<AttractionsScreen> createState() => _AttractionsScreenState();
}

class _AttractionsScreenState extends State<AttractionsScreen> {
  bool _loaded = false;
  List<AttractionData> _liveAttractionsList = [];
  bool isGridView = true;

  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';
  late String categoryFilter;
  double minRating = 0;
  int sortMode = 0;
  int currentPage = 0;
  static const int perPage = 9;

  @override
  void initState() {
    super.initState();
    categoryFilter = widget.initialCategory ?? '';
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
      'attractions',
      attractionsSeedData.map(attractionToMap).toList(),
    );
    await ApiService.syncAttractions();
    final entries = db.getAll('attractions');
    setState(() {
      _liveAttractionsList = entries
          .map((e) => mapToAttraction(e.value))
          .toList();
      _loaded = true;
    });
  }

  List<AttractionData> get _filtered {
    var list = _liveAttractionsList.where((a) {
      final matchesSearch =
          searchQuery.isEmpty ||
          a.nameAr.contains(searchQuery) ||
          a.nameEn.toLowerCase().contains(searchQuery.toLowerCase()) ||
          a.locationAr.contains(searchQuery) ||
          a.locationEn.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter =
          categoryFilter.isEmpty || a.categories.contains(categoryFilter);
      final matchesRating = a.rating >= minRating;
      return matchesSearch && matchesFilter && matchesRating;
    }).toList();
    if (sortMode == 1) {
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

  List<AttractionData> get _paged {
    final list = _filtered;
    final start = (currentPage * perPage).clamp(0, list.length);
    final end = (start + perPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get _pageCount {
    final len = _filtered.length;
    return len == 0 ? 1 : ((len - 1) ~/ perPage) + 1;
  }

  void _openDetail(BuildContext context, AttractionData a) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AttractionDetailScreen(attraction: a),
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
        final label = attractionCategoryLabels[categoryFilter];
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
                    _AttractionsTopBar(
                      titleAr: label?.$1 ?? 'سياحة ومعالم',
                      titleEn: label?.$2 ?? 'Attractions',
                    ),
                    Padding(
                      padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AttractionsSearchBar(
                            controller: searchController,
                            onChanged: (v) => setState(() {
                              searchQuery = v;
                              currentPage = 0;
                            }),
                          ),
                          SizedBox(height: 14),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _CategoryChip(
                                  label: app.t('الكل', 'All'),
                                  selected: categoryFilter.isEmpty,
                                  onTap: () => setState(() {
                                    categoryFilter = '';
                                    currentPage = 0;
                                  }),
                                ),
                                ...attractionCategoryOrder.map((key) {
                                  final l = attractionCategoryLabels[key]!;
                                  return Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: _CategoryChip(
                                      label: app.t(l.$1, l.$2),
                                      selected: categoryFilter == key,
                                      onTap: () => setState(() {
                                        categoryFilter = key;
                                        currentPage = 0;
                                      }),
                                    ),
                                  );
                                }),
                              ],
                            ),
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
                                  '${filtered.length} معلم',
                                  '${filtered.length} places',
                                ),
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 12),
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
                                    'لا توجد معالم مطابقة',
                                    'No matching places',
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
                                    childAspectRatio: 0.75,
                                  ),
                              itemBuilder: (context, i) {
                                final a = _paged[i];
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _openDetail(context, a),
                                  child: _AttractionCard(
                                    attraction: a,
                                    isFavorite: FavoritesService.instance
                                        .isFavorite(a.nameEn),
                                    onFavorite: () async {
                                      await FavoritesService.instance
                                          .toggleFavorite(a.nameEn);
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
                                    (a) => Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _openDetail(context, a),
                                        child: _AttractionListTile(
                                          attraction: a,
                                          isFavorite: FavoritesService.instance
                                              .isFavorite(a.nameEn),
                                          onFavorite: () async {
                                            await FavoritesService.instance
                                                .toggleFavorite(a.nameEn);
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: AppColors.primaryGradient)
              : null,
          color: selected ? null : AppColors.cardDark2,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          textDirection: app.dir,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ==================== كرت المعلم (Grid) ====================
class _AttractionCard extends StatelessWidget {
  final AttractionData attraction;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const _AttractionCard({
    required this.attraction,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final a = attraction;
    final name = app.isArabic ? a.nameAr : a.nameEn;
    final location = app.isArabic ? a.locationAr : a.locationEn;

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
                  query: attractionPhotoQuery(a),
                  fallbackSeed: a.nameEn,
                  height: double.infinity,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  fallbackIcon: a.placeholderIcon,
                  fallbackColor: a.placeholderColor,
                  customImageBase64: a.customImageBase64,
                  serverImageUrl: a.serverImageUrl,
                  localAsset: a.image,
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
                          '${a.rating}',
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
                if (a.isFeatured)
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== بطاقة قائمة المعلم (List) ====================
class _AttractionListTile extends StatelessWidget {
  final AttractionData attraction;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const _AttractionListTile({
    required this.attraction,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final a = attraction;
    final name = app.isArabic ? a.nameAr : a.nameEn;
    final location = app.isArabic ? a.locationAr : a.locationEn;

    return AppCard(
      padding: EdgeInsets.all(10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: ThemedImage(
              query: attractionPhotoQuery(a),
              fallbackSeed: a.nameEn,
              height: 70,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              fallbackIcon: a.placeholderIcon,
              fallbackColor: a.placeholderColor,
              customImageBase64: a.customImageBase64,
              serverImageUrl: a.serverImageUrl,
              localAsset: a.image,
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
                    '${a.rating}',
                    style: TextStyle(color: AppColors.textWhite, fontSize: 11),
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

// ==================== ودجت "الأقرب لك" ====================
class _NearbyMiniCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double distanceKm;
  final VoidCallback onTap;
  const _NearbyMiniCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.distanceKm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 160,
        margin: EdgeInsets.only(left: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardDark2,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                Spacer(),
                Text(
                  '${distanceKm.toStringAsFixed(1)} ${app.t('كم', 'km')}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              textDirection: app.dir,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              textDirection: app.dir,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textGrey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== شاشة تفاصيل المعلم ====================
class AttractionDetailScreen extends StatelessWidget {
  final AttractionData attraction;
  const AttractionDetailScreen({super.key, required this.attraction});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final a = attraction;
    final name = app.isArabic ? a.nameAr : a.nameEn;
    final location = app.isArabic ? a.locationAr : a.locationEn;
    final about = app.isArabic ? a.aboutAr : a.aboutEn;
    final hours = app.isArabic ? a.visitHoursAr : a.visitHoursEn;
    final fee = app.isArabic ? a.entryFeeAr : a.entryFeeEn;
    final point = resolveMapPoint(
      nameAr: a.nameAr,
      nameEn: a.nameEn,
      locationAr: a.locationAr,
      locationEn: a.locationEn,
      lat: a.lat,
      lng: a.lng,
    );
    final nearestHotel = findNearest(
      _liveHotelsSync(),
      point,
      (h) => resolveMapPoint(
        nameAr: h.nameAr,
        nameEn: h.nameEn,
        locationAr: h.locationAr,
        locationEn: h.locationEn,
        lat: h.lat,
        lng: h.lng,
      ),
    );
    final restaurants = _liveRestaurantsSync();
    final nearestRestaurant = findNearest(
      restaurants.where((r) => r.cuisineKey != 'cafe').toList(),
      point,
      (r) => resolveMapPoint(
        nameAr: r.nameAr,
        nameEn: r.nameEn,
        locationAr: r.locationAr,
        locationEn: r.locationEn,
        lat: r.lat,
        lng: r.lng,
      ),
    );
    final nearestCafe = findNearest(
      restaurants.where((r) => r.cuisineKey == 'cafe').toList(),
      point,
      (r) => resolveMapPoint(
        nameAr: r.nameAr,
        nameEn: r.nameEn,
        locationAr: r.locationAr,
        locationEn: r.locationEn,
        lat: r.lat,
        lng: r.lng,
      ),
    );

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
                          query: attractionPhotoQuery(a),
                          fallbackSeed: a.nameEn,
                          fallbackIcon: a.placeholderIcon,
                          fallbackColor: a.placeholderColor,
                          customImageBase64: a.customImageBase64,
                          serverImageUrl: a.serverImageUrl,
                          localAsset: a.image,
                        ),
                        child: ThemedImage(
                          query: attractionPhotoQuery(a),
                          fallbackSeed: a.nameEn,
                          height: 260,
                          fallbackIcon: a.placeholderIcon,
                          fallbackColor: a.placeholderColor,
                          customImageBase64: a.customImageBase64,
                          serverImageUrl: a.serverImageUrl,
                          localAsset: a.image,
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
                                    '${a.rating}',
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
                              '(${a.reviews} ${app.t('تقييم', 'reviews')})',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 11,
                              ),
                            ),
                            Spacer(),
                            if (fee.isNotEmpty)
                              Text(
                                fee,
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
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 6,
                          runSpacing: 6,
                          children: a.categories.map((key) {
                            final l = attractionCategoryLabels[key];
                            if (l == null) return SizedBox.shrink();
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
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
                              child: Text(
                                app.t(l.$1, l.$2),
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
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
                        if (hours.isNotEmpty) ...[
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
                        SizedBox(height: 18),
                        Text(
                          app.t('نبذة تاريخية', 'Historical Overview'),
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
                        if (nearestHotel != null ||
                            nearestRestaurant != null ||
                            nearestCafe != null) ...[
                          SizedBox(height: 22),
                          Text(
                            app.t('الأقرب لك', 'Nearest to You'),
                            textDirection: app.dir,
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 92,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              children: [
                                if (nearestHotel != null)
                                  _NearbyMiniCard(
                                    icon: Icons.hotel,
                                    title: app.isArabic
                                        ? nearestHotel.item.nameAr
                                        : nearestHotel.item.nameEn,
                                    subtitle: app.t(
                                      'أقرب فندق',
                                      'Nearest hotel',
                                    ),
                                    distanceKm: nearestHotel.distanceKm,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => HotelDetailScreen(
                                          hotel: nearestHotel.item,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (nearestRestaurant != null)
                                  _NearbyMiniCard(
                                    icon: Icons.restaurant,
                                    title: app.isArabic
                                        ? nearestRestaurant.item.nameAr
                                        : nearestRestaurant.item.nameEn,
                                    subtitle: app.t(
                                      'أقرب مطعم',
                                      'Nearest restaurant',
                                    ),
                                    distanceKm: nearestRestaurant.distanceKm,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => RestaurantsScreen(
                                          initialCuisine:
                                              nearestRestaurant.item.cuisineKey,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (nearestCafe != null)
                                  _NearbyMiniCard(
                                    icon: Icons.coffee,
                                    title: app.isArabic
                                        ? nearestCafe.item.nameAr
                                        : nearestCafe.item.nameEn,
                                    subtitle: app.t(
                                      'أقرب كافيه',
                                      'Nearest cafe',
                                    ),
                                    distanceKm: nearestCafe.distanceKm,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => RestaurantsScreen(
                                          initialCuisine: 'cafe',
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 22),
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
                              onPressed: () =>
                                  openDirectionsInExternalMaps(point),
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
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  focusPoint: point,
                                  focusNameAr: a.nameAr,
                                  focusNameEn: a.nameEn,
                                  focusRating: a.rating,
                                ),
                              ),
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
                            onPressed: () => Share.share('$name (${a.rating}⭐) — $location'),
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

// ==================== شاشة "التجارب المحلية" ====================
class _LocalExperience {
  final String emoji;
  final String titleAr, titleEn;
  final String descAr, descEn;
  final VoidCallback Function(BuildContext) buildAction;
  _LocalExperience({
    required this.emoji,
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
    required this.buildAction,
  });
}

final List<_LocalExperience> _localExperiences = [
  _LocalExperience(
    emoji: '🍰',
    titleAr: 'تذوق الكنافة النابلسية',
    titleEn: 'Taste Nabulsi Kunafa',
    descAr: 'جربي الكنافة النابلسية الأصلية بمحلات الحلويات المشهورة بالمدينة.',
    descEn:
        'Try the original Nabulsi kunafa at the city\'s famous sweet shops.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RestaurantsScreen(initialCuisine: 'sweets'),
          ),
        ),
  ),
  _LocalExperience(
    emoji: '🧼',
    titleAr: 'زيارة مصانع الصابون النابلسي',
    titleEn: 'Visit the Nabulsi Soap Factories',
    descAr: 'شوفي طريقة صناعة الصابون النابلسي التقليدي بزيت الزيتون عن قرب.',
    descEn:
        'See the traditional olive-oil-based Nabulsi soap-making process up close.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AttractionsScreen(initialCategory: 'oldCity'),
          ),
        ),
  ),
  _LocalExperience(
    emoji: '🛍️',
    titleAr: 'التسوق في الأسواق القديمة',
    titleEn: 'Shop in the Old Markets',
    descAr:
        'تجولي بأسواق البلدة القديمة التاريخية زي القيسارية والعطارين والخان.',
    descEn:
        'Wander through the historic Old City markets like Al-Qaisariya, Al-Attarin, and Al-Khan.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AttractionsScreen(initialCategory: 'oldCity'),
          ),
        ),
  ),
  _LocalExperience(
    emoji: '☕',
    titleAr: 'الجلوس في كافيهات البلدة القديمة',
    titleEn: 'Sit at an Old City Cafe',
    descAr: 'استريحي بكافيهات نابلس بأجواء مميزة داخل وحوالين البلدة القديمة.',
    descEn:
        'Relax at one of Nablus\'s cafes with a distinctive atmosphere in and around the Old City.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RestaurantsScreen(initialCuisine: 'cafe'),
          ),
        ),
  ),
  _LocalExperience(
    emoji: '🥘',
    titleAr: 'تجربة المسخن والمقلوبة في المطاعم الشعبية',
    titleEn: 'Try Musakhan & Maqluba at Local Restaurants',
    descAr: 'جربي أشهر الأطباق الفلسطينية الشعبية بمطاعم نابلس التقليدية.',
    descEn:
        'Try the most famous traditional Palestinian dishes at Nablus\'s local restaurants.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                RestaurantsScreen(initialCuisine: 'traditional'),
          ),
        ),
  ),
  _LocalExperience(
    emoji: '🛒',
    titleAr: 'شراء الحلويات والهدايا التراثية',
    titleEn: 'Buy Sweets & Heritage Gifts',
    descAr: 'اشتري حلويات وهدايا تراثية تفتكري فيها زيارتك لنابلس.',
    descEn: 'Buy sweets and heritage gifts to remember your visit to Nablus.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RestaurantsScreen(initialCuisine: 'sweets'),
          ),
        ),
  ),
];

class LocalExperiencesScreen extends StatelessWidget {
  const LocalExperiencesScreen({super.key});

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
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AttractionsTopBar(
                    titleAr: 'تجارب محلية',
                    titleEn: 'Local Experiences',
                  ),
                  Padding(
                    padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _localExperiences
                          .map(
                            (e) => Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: e.buildAction(context),
                                child: Container(
                                  padding: EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.sidebarDark,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                    ),
                                  ),
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Text(
                                        e.emoji,
                                        style: TextStyle(fontSize: 28),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              app.t(e.titleAr, e.titleEn),
                                              textDirection: app.dir,
                                              style: TextStyle(
                                                color: AppColors.textWhite,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              app.t(e.descAr, e.descEn),
                                              textDirection: app.dir,
                                              textAlign: app.isArabic
                                                  ? TextAlign.right
                                                  : TextAlign.left,
                                              style: TextStyle(
                                                color: AppColors.textGrey,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppColors.textGrey,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
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

// ==================== شاشة "خطط جولتي" ====================
class TourPlannerScreen extends StatefulWidget {
  const TourPlannerScreen({super.key});

  @override
  State<TourPlannerScreen> createState() => _TourPlannerScreenState();
}

class _TourPlannerScreenState extends State<TourPlannerScreen> {
  bool _loaded = false;
  List<AttractionData> _all = [];
  String? _duration; // 'half' | 'full'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = LocalDbService.instance;
    await db.syncSeed(
      'attractions',
      attractionsSeedData.map(attractionToMap).toList(),
    );
    await ApiService.syncAttractions();
    final entries = db.getAll('attractions');
    setState(() {
      _all = entries.map((e) => mapToAttraction(e.value)).toList();
      _loaded = true;
    });
  }

  List<AttractionData> _buildRoute(int stopsCount) {
    if (_all.isEmpty) return [];
    final remaining = List<AttractionData>.from(_all);
    // نبلش من "البلدة القديمة" كنقطة مرجعية مركزية لو موجودة، وإلا أول معلم بالقائمة
    AttractionData start = remaining.firstWhere(
      (a) => a.nameEn == 'Old City',
      orElse: () => remaining.first,
    );
    final route = <AttractionData>[start];
    remaining.remove(start);
    var currentPoint = resolveMapPoint(
      nameAr: start.nameAr,
      nameEn: start.nameEn,
      locationAr: start.locationAr,
      locationEn: start.locationEn,
      lat: start.lat,
      lng: start.lng,
    );
    while (route.length < stopsCount && remaining.isNotEmpty) {
      final nearest = findNearest(
        remaining,
        currentPoint,
        (a) => resolveMapPoint(
          nameAr: a.nameAr,
          nameEn: a.nameEn,
          locationAr: a.locationAr,
          locationEn: a.locationEn,
          lat: a.lat,
          lng: a.lng,
        ),
      );
      if (nearest == null) break;
      route.add(nearest.item);
      remaining.remove(nearest.item);
      currentPoint = resolveMapPoint(
        nameAr: nearest.item.nameAr,
        nameEn: nearest.item.nameEn,
        locationAr: nearest.item.locationAr,
        locationEn: nearest.item.locationEn,
        lat: nearest.item.lat,
        lng: nearest.item.lng,
      );
    }
    return route;
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
    final route = _duration == null
        ? <AttractionData>[]
        : _buildRoute(_duration == 'half' ? 3 : 6);
    final restaurants = _liveRestaurantsSync();

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
                  _AttractionsTopBar(
                    titleAr: 'خطط جولتي',
                    titleEn: 'Plan My Tour',
                  ),
                  Padding(
                    padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          app.t(
                            'اختاري مدة جولتك',
                            'Choose Your Tour Duration',
                          ),
                          textDirection: app.dir,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DurationCard(
                                emoji: '🌤️',
                                labelAr: 'نصف يوم',
                                labelEn: 'Half Day',
                                subAr: '3 محطات',
                                subEn: '3 stops',
                                selected: _duration == 'half',
                                onTap: () => setState(() => _duration = 'half'),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _DurationCard(
                                emoji: '☀️',
                                labelAr: 'يوم كامل',
                                labelEn: 'Full Day',
                                subAr: '6 محطات',
                                subEn: '6 stops',
                                selected: _duration == 'full',
                                onTap: () => setState(() => _duration = 'full'),
                              ),
                            ),
                          ],
                        ),
                        if (route.isNotEmpty) ...[
                          SizedBox(height: 24),
                          Text(
                            app.t('مسار جولتك', 'Your Tour Route'),
                            textDirection: app.dir,
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          ...List.generate(route.length, (i) {
                            final a = route[i];
                            final point = resolveMapPoint(
                              nameAr: a.nameAr,
                              nameEn: a.nameEn,
                              locationAr: a.locationAr,
                              locationEn: a.locationEn,
                              lat: a.lat,
                              lng: a.lng,
                            );
                            final nearestRestaurant = findNearest(
                              restaurants
                                  .where((r) => r.cuisineKey != 'cafe')
                                  .toList(),
                              point,
                              (r) => resolveMapPoint(
                                nameAr: r.nameAr,
                                nameEn: r.nameEn,
                                locationAr: r.locationAr,
                                locationEn: r.locationEn,
                                lat: r.lat,
                                lng: r.lng,
                              ),
                            );
                            final nearestCafe = findNearest(
                              restaurants
                                  .where((r) => r.cuisineKey == 'cafe')
                                  .toList(),
                              point,
                              (r) => resolveMapPoint(
                                nameAr: r.nameAr,
                                nameEn: r.nameEn,
                                locationAr: r.locationAr,
                                locationEn: r.locationEn,
                                lat: r.lat,
                                lng: r.lng,
                              ),
                            );
                            return _TourStopCard(
                              index: i + 1,
                              attraction: a,
                              nearestRestaurantName: nearestRestaurant == null
                                  ? null
                                  : (app.isArabic
                                        ? nearestRestaurant.item.nameAr
                                        : nearestRestaurant.item.nameEn),
                              nearestCafeName: nearestCafe == null
                                  ? null
                                  : (app.isArabic
                                        ? nearestCafe.item.nameAr
                                        : nearestCafe.item.nameEn),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AttractionDetailScreen(attraction: a),
                                ),
                              ),
                            );
                          }),
                          SizedBox(height: 10),
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
                                  final firstPoint = resolveMapPoint(
                                    nameAr: route.first.nameAr,
                                    nameEn: route.first.nameEn,
                                    locationAr: route.first.locationAr,
                                    locationEn: route.first.locationEn,
                                    lat: route.first.lat,
                                    lng: route.first.lng,
                                  );
                                  openDirectionsInExternalMaps(firstPoint);
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
                                  Icons.directions_walk,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  app.t('ابدأ الجولة', 'Start the Tour'),
                                  style: AppTypography.title(
                                    Colors.white,
                                  ).copyWith(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
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

class _DurationCard extends StatelessWidget {
  final String emoji, labelAr, labelEn, subAr, subEn;
  final bool selected;
  final VoidCallback onTap;
  const _DurationCard({
    required this.emoji,
    required this.labelAr,
    required this.labelEn,
    required this.subAr,
    required this.subEn,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: AppColors.primaryGradient)
              : null,
          color: selected ? null : AppColors.sidebarDark,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.borderColor,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 30)),
            SizedBox(height: 8),
            Text(
              app.t(labelAr, labelEn),
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              app.t(subAr, subEn),
              style: TextStyle(
                color: selected ? Colors.white70 : AppColors.textGrey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourStopCard extends StatelessWidget {
  final int index;
  final AttractionData attraction;
  final String? nearestRestaurantName;
  final String? nearestCafeName;
  final VoidCallback onTap;
  const _TourStopCard({
    required this.index,
    required this.attraction,
    required this.nearestRestaurantName,
    required this.nearestCafeName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final a = attraction;
    final name = app.isArabic ? a.nameAr : a.nameEn;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.sidebarDark,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: 56,
              height: 56,
              child: ThemedImage(
                query: attractionPhotoQuery(a),
                fallbackSeed: a.nameEn,
                height: 56,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                fallbackIcon: a.placeholderIcon,
                fallbackColor: a.placeholderColor,
                customImageBase64: a.customImageBase64,
                serverImageUrl: a.serverImageUrl,
                localAsset: a.image,
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
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (nearestRestaurantName != null) ...[
                    SizedBox(height: 4),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 11,
                          color: AppColors.textGrey,
                        ),
                        SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            nearestRestaurantName!,
                            textDirection: app.dir,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (nearestCafeName != null) ...[
                    SizedBox(height: 2),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(Icons.coffee, size: 11, color: AppColors.textGrey),
                        SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            nearestCafeName!,
                            textDirection: app.dir,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
