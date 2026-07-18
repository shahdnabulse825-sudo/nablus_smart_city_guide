import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../../widgets/responsive.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../services/favorites_service.dart';
import '../../services/api_service.dart';
import '../map/map_screen.dart';
import '../../theme/app_typography.dart';
import '../restaurants/restaurants_screen.dart';
import '../attractions/attractions_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_toggle_bar.dart';
import '../../widgets/keyboard_scrollable.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/sort_toggle.dart';
import 'package:share_plus/share_plus.dart';

// ==================== بيانات مركز تجاري (مكان حقيقي) ====================
class ShoppingVenueData {
  final String nameAr;
  final String nameEn;
  final String typeAr;
  final String typeEn;
  final String locationAr;
  final String locationEn;
  final double rating;
  final int reviews;
  final String hoursAr;
  final String hoursEn;
  final String aboutAr;
  final String aboutEn;
  final String phone;
  final String image;
  final IconData placeholderIcon;
  final Color placeholderColor;
  final String? customImageBase64;
  final bool isFeatured;
  final double? lat;
  final double? lng;

  ShoppingVenueData({
    required this.nameAr,
    required this.nameEn,
    required this.typeAr,
    required this.typeEn,
    required this.locationAr,
    required this.locationEn,
    required this.rating,
    required this.reviews,
    this.hoursAr = '',
    this.hoursEn = '',
    required this.aboutAr,
    required this.aboutEn,
    this.phone = '',
    this.image = '',
    required this.placeholderIcon,
    required this.placeholderColor,
    this.customImageBase64,
    this.isFeatured = false,
    this.lat,
    this.lng,
  });
}

final List<ShoppingVenueData> shoppingVenuesSeedData = [
  ShoppingVenueData(
    nameAr: 'نابلس مول',
    nameEn: 'Nablus Mall',
    typeAr: 'مركز تسوق',
    typeEn: 'Shopping Mall',
    locationAr: 'شارع رفيديا - نابلس',
    locationEn: 'Rafidia St. - Nablus',
    rating: 4.4,
    reviews: 340,
    hoursAr: 'يفتح 10ص - 10م',
    hoursEn: 'Open 10AM - 10PM',
    aboutAr:
        'أكبر مركز تسوق بالمدينة يضم محلات أزياء عالمية ومحلية، مطاعم، وصالة ألعاب للأطفال.',
    aboutEn:
        'The largest shopping mall in the city, featuring international and local fashion stores, restaurants, and a kids\' game arcade.',
    placeholderIcon: Icons.shopping_bag,
    placeholderColor: Color(0xFF3B82F6),
    isFeatured: true,
  ),
  ShoppingVenueData(
    nameAr: 'مجمع رفيديا التجاري',
    nameEn: 'Rafidia Commercial Complex',
    typeAr: 'مجمع تجاري',
    typeEn: 'Commercial Complex',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.3,
    reviews: 190,
    hoursAr: 'يفتح 9ص - 9م',
    hoursEn: 'Open 9AM - 9PM',
    aboutAr: 'مجمع تجاري حديث يضم محلات إلكترونيات، ملابس، وأجهزة منزلية.',
    aboutEn:
        'A modern commercial complex featuring electronics, clothing, and home appliance stores.',
    placeholderIcon: Icons.store,
    placeholderColor: Color(0xFFD4A017),
  ),
  ShoppingVenueData(
    nameAr: 'سوق البلدة القديمة',
    nameEn: 'Old City Souq',
    typeAr: 'سوق شعبي',
    typeEn: 'Traditional Market',
    locationAr: 'البلدة القديمة - نابلس',
    locationEn: 'Old City - Nablus',
    rating: 4.7,
    reviews: 512,
    hoursAr: 'يفتح 8ص - 8م',
    hoursEn: 'Open 8AM - 8PM',
    aboutAr:
        'سوق تاريخي عريق داخل البلدة القديمة يبيع التوابل والحلويات النابلسية والصابون البلدي والمنتجات التقليدية.',
    aboutEn:
        'A historic market inside the Old City selling spices, Nabulsi sweets, traditional soap, and local handmade products.',
    placeholderIcon: Icons.storefront,
    placeholderColor: Color(0xFFB5651D),
    isFeatured: true,
  ),
  ShoppingVenueData(
    nameAr: 'سيتي مول نابلس',
    nameEn: 'City Mall Nablus',
    typeAr: 'مركز تسوق',
    typeEn: 'Shopping Mall',
    locationAr: 'شارع سفيان - نابلس',
    locationEn: 'Sufyan St. - Nablus',
    rating: 4.5,
    reviews: 287,
    hoursAr: 'يفتح 10ص - 11م',
    hoursEn: 'Open 10AM - 11PM',
    aboutAr: 'مركز تسوق حديث بعلامات تجارية عالمية، مطاعم، وسينما.',
    aboutEn:
        'A modern shopping mall with international brands, restaurants, and a cinema.',
    placeholderIcon: Icons.shopping_bag,
    placeholderColor: Color(0xFF6C5CE7),
    isFeatured: true,
  ),
  ShoppingVenueData(
    nameAr: 'مجمع رفيديا جاليريا',
    nameEn: 'Rafidia Galleria',
    typeAr: 'مجمع تجاري',
    typeEn: 'Commercial Complex',
    locationAr: 'شارع رفيديا - نابلس',
    locationEn: 'Rafidia St. - Nablus',
    rating: 4.2,
    reviews: 133,
    hoursAr: 'يفتح 9ص - 10م',
    hoursEn: 'Open 9AM - 10PM',
    aboutAr: 'محلات ملابس وأحذية وإكسسوارات لمختلف الأعمار.',
    aboutEn: 'Clothing, footwear, and accessory stores for all ages.',
    placeholderIcon: Icons.checkroom,
    placeholderColor: Color(0xFFEF6F53),
  ),
  ShoppingVenueData(
    nameAr: 'سوق الذهب النابلسي',
    nameEn: 'Nablus Gold Souq',
    typeAr: 'سوق مجوهرات',
    typeEn: 'Jewelry Market',
    locationAr: 'وسط البلد - نابلس',
    locationEn: 'City Center - Nablus',
    rating: 4.6,
    reviews: 204,
    hoursAr: 'يفتح 9ص - 8م',
    hoursEn: 'Open 9AM - 8PM',
    aboutAr: 'محلات مجوهرات وذهب تقليدية وحديثة بأسعار تنافسية.',
    aboutEn: 'Traditional and modern gold and jewelry stores at competitive prices.',
    placeholderIcon: Icons.diamond_outlined,
    placeholderColor: Color(0xFFFBBF24),
  ),
  ShoppingVenueData(
    nameAr: 'مركز الميدان للتسوق',
    nameEn: 'Al-Maidan Shopping Center',
    typeAr: 'مركز تسوق',
    typeEn: 'Shopping Center',
    locationAr: 'ميدان الشهداء - نابلس',
    locationEn: 'Martyrs Square - Nablus',
    rating: 4.1,
    reviews: 98,
    hoursAr: 'يفتح 10ص - 9م',
    hoursEn: 'Open 10AM - 9PM',
    aboutAr: 'محلات متنوعة للإلكترونيات والهدايا وسط المدينة.',
    aboutEn: 'A variety of electronics and gift shops in the city center.',
    placeholderIcon: Icons.devices_other,
    placeholderColor: Color(0xFF14B8A6),
  ),
  ShoppingVenueData(
    nameAr: 'سوق الخضار المركزي',
    nameEn: 'Central Vegetable Market',
    typeAr: 'سوق شعبي',
    typeEn: 'Traditional Market',
    locationAr: 'البلدة القديمة - نابلس',
    locationEn: 'Old City - Nablus',
    rating: 4.4,
    reviews: 167,
    hoursAr: 'يفتح 6ص - 6م',
    hoursEn: 'Open 6AM - 6PM',
    aboutAr: 'سوق شعبي للخضار والفواكه الطازجة والمنتجات المحلية.',
    aboutEn: 'A traditional market for fresh produce and local goods.',
    placeholderIcon: Icons.local_grocery_store,
    placeholderColor: Color(0xFF22C55E),
  ),
  ShoppingVenueData(
    nameAr: 'مجمع الجامعة التجاري',
    nameEn: 'University Commercial Complex',
    typeAr: 'مجمع تجاري',
    typeEn: 'Commercial Complex',
    locationAr: 'قرب الجامعة - نابلس',
    locationEn: 'Near the University - Nablus',
    rating: 4.0,
    reviews: 76,
    hoursAr: 'يفتح 9ص - 11م',
    hoursEn: 'Open 9AM - 11PM',
    aboutAr: 'مكتبات، قرطاسية، وكافيهات قريبة من الحرم الجامعي.',
    aboutEn: 'Bookstores, stationery shops, and cafes near the university campus.',
    placeholderIcon: Icons.school,
    placeholderColor: Color(0xFF3B82F6),
  ),
  ShoppingVenueData(
    nameAr: 'سوق الأقمشة القديم',
    nameEn: 'Old Textile Market',
    typeAr: 'سوق شعبي',
    typeEn: 'Traditional Market',
    locationAr: 'البلدة القديمة - نابلس',
    locationEn: 'Old City - Nablus',
    rating: 4.3,
    reviews: 89,
    hoursAr: 'يفتح 9ص - 7م',
    hoursEn: 'Open 9AM - 7PM',
    aboutAr: 'أقمشة تقليدية وحديثة ومستلزمات الخياطة.',
    aboutEn: 'Traditional and modern fabrics and sewing supplies.',
    placeholderIcon: Icons.content_cut,
    placeholderColor: Color(0xFFD4A017),
  ),
];

// كلمة بحث إنجليزية مناسبة لصورة المركز التجاري، لما ما توجد صورة محلية.
String shoppingVenuePhotoQuery(ShoppingVenueData v) {
  final text = '${v.nameAr} ${v.nameEn} ${v.typeAr} ${v.typeEn}'.toLowerCase();
  if (text.contains('سوق') ||
      text.contains('بازار') ||
      text.contains('bazaar') ||
      text.contains('market')) {
    return 'traditional market bazaar';
  }
  if (text.contains('مجمع') || text.contains('complex')) {
    return 'shopping complex storefront';
  }
  return 'shopping mall interior';
}

// ==================== بطاقة دليل صنف (معلومات، مش مكان مخزّن) ====================
class ShoppingProductGuide {
  final String emoji;
  final String categoryKey; // heritage | localProducts
  final String titleAr;
  final String titleEn;
  final String descAr;
  final String descEn;
  final VoidCallback Function(BuildContext)? buildAction; // null = بدون زر
  ShoppingProductGuide({
    required this.emoji,
    required this.categoryKey,
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
    this.buildAction,
  });
}

final List<ShoppingProductGuide> shoppingProductGuides = [
  // ---------- تراث وهدايا ----------
  ShoppingProductGuide(
    emoji: '🧼',
    categoryKey: 'heritage',
    titleAr: 'الصابون النابلسي',
    titleEn: 'Nabulsi Soap',
    descAr: 'صناعة نابلسية عريقة بزيت الزيتون، من أشهر منتجات المدينة عالميًا.',
    descEn:
        'A time-honored Nablus craft made from olive oil, one of the city\'s most famous products worldwide.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AttractionsScreen(initialCategory: 'oldCity'),
          ),
        ),
  ),
  ShoppingProductGuide(
    emoji: '🧀',
    categoryKey: 'heritage',
    titleAr: 'الجبنة النابلسية',
    titleEn: 'Nabulsi Cheese',
    descAr:
        'جبنة بيضاء تقليدية تحمل اسم المدينة، تستخدم بالكنافة وأطباق فلسطينية كثيرة.',
    descEn:
        'A traditional white cheese bearing the city\'s name, used in kunafa and many Palestinian dishes.',
  ),
  ShoppingProductGuide(
    emoji: '🪡',
    categoryKey: 'heritage',
    titleAr: 'التطريز الفلسطيني',
    titleEn: 'Palestinian Embroidery',
    descAr:
        'فن التطريز اليدوي (التطريز الفلسطيني) بزخارفه وألوانه التراثية المميزة.',
    descEn:
        'The traditional Palestinian hand-embroidery craft, known for its distinctive patterns and colors.',
  ),
  ShoppingProductGuide(
    emoji: '💍',
    categoryKey: 'heritage',
    titleAr: 'الحلي والمشغولات الفضية',
    titleEn: 'Silver Jewelry & Crafts',
    descAr:
        'مشغولات فضية وحلي تقليدية بلمسة يدوية، هدية مميزة تفتكر بيها زيارتك.',
    descEn:
        'Handcrafted silver jewelry and traditional pieces, a distinctive gift to remember your visit.',
  ),
  ShoppingProductGuide(
    emoji: '🎁',
    categoryKey: 'heritage',
    titleAr: 'التحف والهدايا التذكارية',
    titleEn: 'Antiques & Souvenirs',
    descAr: 'قطع تذكارية وتحف صغيرة تحمل طابع نابلس وتاريخها.',
    descEn:
        'Small souvenir pieces and antiques carrying the character and history of Nablus.',
  ),

  // ---------- منتجات نابلس المحلية ----------
  ShoppingProductGuide(
    emoji: '🍰',
    categoryKey: 'localProducts',
    titleAr: 'الكنافة النابلسية',
    titleEn: 'Nabulsi Kunafa',
    descAr: 'الحلوى الأشهر باسم المدينة، جبنة ساخنة مغطاة بقطر وقشطة القطايف.',
    descEn:
        'The most famous sweet bearing the city\'s name — hot cheese topped with syrup and shredded pastry.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RestaurantsScreen(initialCuisine: 'sweets'),
          ),
        ),
  ),
  ShoppingProductGuide(
    emoji: '🍬',
    categoryKey: 'localProducts',
    titleAr: 'الحلويات',
    titleEn: 'Sweets',
    descAr: 'محلات الحلويات النابلسية بتشكيلة واسعة إلى جانب الكنافة.',
    descEn: 'Nablus sweet shops offering a wide variety alongside kunafa.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RestaurantsScreen(initialCuisine: 'sweets'),
          ),
        ),
  ),
  ShoppingProductGuide(
    emoji: '🫒',
    categoryKey: 'localProducts',
    titleAr: 'زيت الزيتون',
    titleEn: 'Olive Oil',
    descAr: 'زيت زيتون فلسطيني بجودة عالية، من أهم منتجات المنطقة الزراعية.',
    descEn:
        'High-quality Palestinian olive oil, one of the region\'s most important agricultural products.',
  ),
  ShoppingProductGuide(
    emoji: '☕',
    categoryKey: 'localProducts',
    titleAr: 'القهوة والمكسرات',
    titleEn: 'Coffee & Nuts',
    descAr: 'محامص القهوة العربية والمكسرات المحمصة الطازجة، نكهة محلية أصيلة.',
    descEn:
        'Arabic coffee roasteries and freshly roasted nuts, an authentic local flavor.',
  ),
  ShoppingProductGuide(
    emoji: '🌿',
    categoryKey: 'localProducts',
    titleAr: 'الزعتر والسماق والتوابل',
    titleEn: 'Za\'atar, Sumac & Spices',
    descAr: 'أعشاب وتوابل بلدية أصيلة، أشهرها الزعتر والسماق الفلسطيني.',
    descEn:
        'Authentic local herbs and spices, most famously Palestinian za\'atar and sumac.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AttractionsScreen(initialCategory: 'oldCity'),
          ),
        ),
  ),
];

const List<(String, String, String)> shoppingCategoryOrder = [
  ('heritage', '🎁 تراث وهدايا', '🎁 Heritage & Gifts'),
  ('localProducts', '🧺 منتجات نابلس المحلية', '🧺 Local Nablus Products'),
  ('commercial', '🏬 المراكز التجارية', '🏬 Commercial Centers'),
];

// ==================== شاشة التصنيفات (نقطة الدخول) ====================
class ShoppingCategoriesScreen extends StatefulWidget {
  const ShoppingCategoriesScreen({super.key});

  @override
  State<ShoppingCategoriesScreen> createState() =>
      _ShoppingCategoriesScreenState();
}

class _ShoppingCategoriesScreenState extends State<ShoppingCategoriesScreen> {
  bool _loaded = false;
  List<ShoppingVenueData> _liveVenues = [];
  final ScrollController _scrollController = ScrollController();

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
      'shopping',
      shoppingVenuesSeedData.map(shoppingVenueToMap).toList(),
    );
    await ApiService.syncShopping();
    final entries = db.getAll('shopping');
    setState(() {
      _liveVenues = entries.map((e) => mapToShoppingVenue(e.value)).toList();
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
            body: KeyboardScrollable(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ShoppingTopBar(titleAr: 'تسوق', titleEn: 'Shopping'),
                    _ShoppingBanner(),
                    Padding(
                      padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: shoppingCategoryOrder.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                          final def = shoppingCategoryOrder[i];
                          final key = def.$1;
                          final count = key == 'commercial'
                              ? _liveVenues.length
                              : shoppingProductGuides
                                    .where((p) => p.categoryKey == key)
                                    .length;
                          return _ShoppingCategoryCard(
                            titleAr: def.$2,
                            titleEn: def.$3,
                            count: count,
                            onTap: () {
                              if (key == 'commercial') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ShoppingVenuesScreen(),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ShoppingProductGuideScreen(
                                          categoryKey: key,
                                        ),
                                  ),
                                );
                              }
                            },
                          );
                        },
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

class _ShoppingCategoryCard extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  final int count;
  final VoidCallback onTap;
  const _ShoppingCategoryCard({
    required this.titleAr,
    required this.titleEn,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
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
            Text(
              app.t(titleAr, titleEn),
              textAlign: TextAlign.center,
              textDirection: app.dir,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              app.t('$count', '$count'),
              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== الشريط العلوي (مشترك) ====================
class _ShoppingTopBar extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  const _ShoppingTopBar({required this.titleAr, required this.titleEn});

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
            child: Icon(Icons.shopping_bag, color: Colors.white, size: 16),
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
class _ShoppingBanner extends StatelessWidget {
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
              query: 'traditional market bazaar gifts',
              fallbackSeed: 'nablus-shopping-banner',
              fallbackIcon: Icons.shopping_bag,
            ),
            child: ThemedImage(
              query: 'traditional market bazaar gifts',
              fallbackSeed: 'nablus-shopping-banner',
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
              app.t('تسوّقي من نابلس', 'Shop from Nablus'),
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

// ==================== شاشة دليل الأصناف ====================
class ShoppingProductGuideScreen extends StatelessWidget {
  final String categoryKey;
  const ShoppingProductGuideScreen({super.key, required this.categoryKey});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final items = shoppingProductGuides
        .where((p) => p.categoryKey == categoryKey)
        .toList();
    final label = shoppingCategoryOrder.firstWhere((c) => c.$1 == categoryKey);

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
                  _ShoppingTopBar(titleAr: label.$2, titleEn: label.$3),
                  Padding(
                    padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: items
                          .map(
                            (p) => Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: p.buildAction?.call(context),
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
                                        p.emoji,
                                        style: TextStyle(fontSize: 28),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              app.t(p.titleAr, p.titleEn),
                                              textDirection: app.dir,
                                              style: TextStyle(
                                                color: AppColors.textWhite,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              app.t(p.descAr, p.descEn),
                                              textDirection: app.dir,
                                              textAlign: app.isArabic
                                                  ? TextAlign.right
                                                  : TextAlign.left,
                                              style: TextStyle(
                                                color: AppColors.textGrey,
                                                fontSize: 11,
                                              ),
                                            ),
                                            if (p.buildAction != null) ...[
                                              SizedBox(height: 8),
                                              Text(
                                                app.t(
                                                  'أين أجدها؟ ←',
                                                  'Where to find it ←',
                                                ),
                                                textDirection: app.dir,
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
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

// ==================== شاشة المراكز التجارية ====================
class ShoppingVenuesScreen extends StatefulWidget {
  const ShoppingVenuesScreen({super.key});

  @override
  State<ShoppingVenuesScreen> createState() => _ShoppingVenuesScreenState();
}

class _ShoppingVenuesScreenState extends State<ShoppingVenuesScreen> {
  bool _loaded = false;
  List<ShoppingVenueData> _liveVenues = [];
  bool isGridView = true;
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';
  double minRating = 0;
  int sortMode = 0;
  int currentPage = 0;
  static const int perPage = 9;

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
      'shopping',
      shoppingVenuesSeedData.map(shoppingVenueToMap).toList(),
    );
    await ApiService.syncShopping();
    final entries = db.getAll('shopping');
    setState(() {
      _liveVenues = entries.map((e) => mapToShoppingVenue(e.value)).toList();
      _loaded = true;
    });
  }

  List<ShoppingVenueData> get _filtered {
    var list = _liveVenues.where((v) {
      final matchesSearch = searchQuery.isEmpty ||
          v.nameAr.contains(searchQuery) ||
          v.nameEn.toLowerCase().contains(searchQuery.toLowerCase()) ||
          v.locationAr.contains(searchQuery) ||
          v.locationEn.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesSearch && v.rating >= minRating;
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

  List<ShoppingVenueData> get _paged {
    final list = _filtered;
    final start = (currentPage * perPage).clamp(0, list.length);
    final end = (start + perPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get _pageCount {
    final len = _filtered.length;
    return len == 0 ? 1 : ((len - 1) ~/ perPage) + 1;
  }

  void _openDetail(BuildContext context, ShoppingVenueData v) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShoppingVenueDetailScreen(venue: v),
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
                    _ShoppingTopBar(
                      titleAr: 'المراكز التجارية',
                      titleEn: 'Commercial Centers',
                    ),
                    Padding(
                      padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 44,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark2,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  size: 18,
                                  color: AppColors.textGrey,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    onChanged: (v) => setState(() {
                                      searchQuery = v;
                                      currentPage = 0;
                                    }),
                                    style: AppTypography.body(
                                      AppColors.textWhite,
                                    ).copyWith(fontSize: 13),
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      border: InputBorder.none,
                                      hintText: app.t(
                                        'ابحث عن مركز تجاري...',
                                        'Search for a commercial center...',
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
                          SizedBox(height: 10),
                          _RatingFiltersRow(
                            minRating: minRating,
                            onRatingTap: (v) => setState(() {
                              minRating = minRating == v ? 0 : v;
                              currentPage = 0;
                            }),
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: [
                              Text(
                                app.t(
                                  '${filtered.length} مركز',
                                  '${filtered.length} centers',
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
                                    'لا توجد مراكز مطابقة',
                                    'No matching centers',
                                  ),
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                              ),
                            )
                          else if (isGridView)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
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
                                final v = _paged[i];
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _openDetail(context, v),
                                  child: _ShoppingVenueCard(
                                    venue: v,
                                    isFavorite: FavoritesService.instance
                                        .isFavorite(v.nameEn),
                                    onFavorite: () async {
                                      await FavoritesService.instance
                                          .toggleFavorite(v.nameEn);
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
                                    (v) => Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _openDetail(context, v),
                                        child: _ShoppingVenueListTile(
                                          venue: v,
                                          isFavorite: FavoritesService.instance
                                              .isFavorite(v.nameEn),
                                          onFavorite: () async {
                                            await FavoritesService.instance
                                                .toggleFavorite(v.nameEn);
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

// ==================== كرت المركز التجاري (Grid) ====================
class _ShoppingVenueCard extends StatelessWidget {
  final ShoppingVenueData venue;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const _ShoppingVenueCard({
    required this.venue,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final v = venue;
    final name = app.isArabic ? v.nameAr : v.nameEn;
    final location = app.isArabic ? v.locationAr : v.locationEn;

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
                  query: shoppingVenuePhotoQuery(v),
                  fallbackSeed: v.nameEn,
                  height: double.infinity,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  fallbackIcon: v.placeholderIcon,
                  fallbackColor: v.placeholderColor,
                  customImageBase64: v.customImageBase64,
                  localAsset: v.image,
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
                          '${v.rating}',
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
                if (v.isFeatured)
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

// ==================== بطاقة قائمة المركز التجاري (List) ====================
class _ShoppingVenueListTile extends StatelessWidget {
  final ShoppingVenueData venue;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const _ShoppingVenueListTile({
    required this.venue,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final v = venue;
    final name = app.isArabic ? v.nameAr : v.nameEn;
    final location = app.isArabic ? v.locationAr : v.locationEn;

    return AppCard(
      padding: EdgeInsets.all(10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: ThemedImage(
              query: shoppingVenuePhotoQuery(v),
              fallbackSeed: v.nameEn,
              height: 70,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              fallbackIcon: v.placeholderIcon,
              fallbackColor: v.placeholderColor,
              customImageBase64: v.customImageBase64,
              localAsset: v.image,
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
                    '${v.rating}',
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

// ==================== شاشة تفاصيل المركز التجاري ====================
class ShoppingVenueDetailScreen extends StatelessWidget {
  final ShoppingVenueData venue;
  const ShoppingVenueDetailScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final v = venue;
    final name = app.isArabic ? v.nameAr : v.nameEn;
    final type = app.isArabic ? v.typeAr : v.typeEn;
    final location = app.isArabic ? v.locationAr : v.locationEn;
    final hours = app.isArabic ? v.hoursAr : v.hoursEn;
    final about = app.isArabic ? v.aboutAr : v.aboutEn;
    final point = resolveMapPoint(
      nameAr: v.nameAr,
      nameEn: v.nameEn,
      locationAr: v.locationAr,
      locationEn: v.locationEn,
      lat: v.lat,
      lng: v.lng,
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
                          query: shoppingVenuePhotoQuery(v),
                          fallbackSeed: v.nameEn,
                          fallbackIcon: v.placeholderIcon,
                          fallbackColor: v.placeholderColor,
                          customImageBase64: v.customImageBase64,
                          localAsset: v.image,
                        ),
                        child: ThemedImage(
                          query: shoppingVenuePhotoQuery(v),
                          fallbackSeed: v.nameEn,
                          height: 260,
                          fallbackIcon: v.placeholderIcon,
                          fallbackColor: v.placeholderColor,
                          customImageBase64: v.customImageBase64,
                          localAsset: v.image,
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
                                    '${v.rating}',
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
                              '(${v.reviews} ${app.t('تقييم', 'reviews')})',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 11,
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
                        if (v.phone.isNotEmpty) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  launchUrl(Uri.parse('tel:${v.phone}')),
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
                                app.t('اتصال: ${v.phone}', 'Call: ${v.phone}'),
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
                                  focusNameAr: v.nameAr,
                                  focusNameEn: v.nameEn,
                                  focusCategoryAr: v.typeAr,
                                  focusCategoryEn: v.typeEn,
                                  focusRating: v.rating,
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
                            onPressed: () => Share.share('$name (${v.rating}⭐) — $location'),
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
