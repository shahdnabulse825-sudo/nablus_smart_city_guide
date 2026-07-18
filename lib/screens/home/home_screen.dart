import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import '../restaurants/restaurants_screen.dart';
import '../hotels/hotels_screen.dart';
import '../pharmacies/pharmacies_screen.dart';
import '../attractions/attractions_screen.dart';
import '../shopping/shopping_screen.dart';
import '../common/detail_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import '../map/map_screen.dart';
import '../news/news_screen.dart';
import '../ai_assistant/ai_assistant_screen.dart';
import '../auth/login_screen.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../category/category_list_screen.dart';
import '../category/category_data.dart';
import '../category/more_categories_screen.dart';
import '../explore/explore_screen.dart';
import '../notifications/notifications_screen.dart';
import '../places/all_places_screen.dart';
import '../events/events_screen.dart';
import '../nearby/nearby_places_screen.dart';
import 'recommendations_section.dart';
import '../../services/favorites_service.dart';
import '../info/about_us_screen.dart';
import '../../widgets/responsive.dart';
import '../info/privacy_policy_screen.dart';
import '../info/terms_screen.dart';
import '../info/faq_screen.dart';
import '../info/contact_us_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_toggle_bar.dart';
import '../../widgets/keyboard_scrollable.dart';
export '../../theme/app_colors.dart' show AppColors;
export '../../theme/app_spacing.dart' show AppSpacing, AppRadius;
export '../../widgets/app_card.dart' show AppCard;
import '../../widgets/themed_image.dart';
import '../../services/weather_service.dart';
import '../weather/weather_screen.dart';

// ==================== إدارة الحالة العامة (الثيم / اللغة / العملات / الوقت) ====================
class AppState extends ChangeNotifier {
  AppState._internal() {
    _startClock();
    fetchRates();
    fetchWeather();
  }
  static final AppState instance = AppState._internal();

  // ---------- الثيم ----------
  bool isDark = true;
  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }

  // ---------- اللغة ----------
  bool isArabic = true;
  void toggleLanguage() {
    isArabic = !isArabic;
    notifyListeners();
  }

  TextDirection get dir => isArabic ? TextDirection.rtl : TextDirection.ltr;

  /// يرجع النص العربي أو الإنجليزي حسب اللغة الحالية
  String t(String ar, String en) => isArabic ? ar : en;

  // ---------- الساعة الحية ----------
  String currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
  Timer? _clockTimer;
  void _startClock() {
    _clockTimer = Timer.periodic(Duration(seconds: 1), (_) {
      currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
      notifyListeners();
    });
  }

  // ---------- أسعار العملات الحقيقية ----------
  bool ratesLoading = true;
  String? ratesError;
  double usdToIls = 3.73;
  double jodToIls = 5.26;
  double eurToIls = 4.02;

  Future<void> fetchRates() async {
    ratesLoading = true;
    ratesError = null;
    notifyListeners();
    try {
      final res = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final rates = data['rates'] as Map<String, dynamic>;
        final usdIls = (rates['ILS'] as num).toDouble();
        final usdJod = (rates['JOD'] as num).toDouble();
        final usdEur = (rates['EUR'] as num).toDouble();
        usdToIls = usdIls;
        jodToIls = usdIls / usdJod;
        eurToIls = usdIls / usdEur;
      } else {
        ratesError = 'فشل تحميل الأسعار';
      }
    } catch (e) {
      ratesError = 'تعذر الاتصال بالإنترنت';
    }
    ratesLoading = false;
    notifyListeners();
  }

  // ---------- الطقس الحقيقي بنابلس ----------
  bool weatherLoading = true;
  WeatherData? weather;

  Future<void> fetchWeather() async {
    weatherLoading = true;
    notifyListeners();
    weather = await WeatherService.instance.fetchNablusWeather();
    weatherLoading = false;
    notifyListeners();
  }

  // ---------- عدّاد الزوار الحقيقي (مشترك بين كل المستخدمين عبر السيرفر) ----------
  int? visitorCount;

  Future<void> fetchVisitorCount() async {
    visitorCount = await ApiService.getVisitCount();
    notifyListeners();
  }

  /// تُستدعى مرة وحدة عند بدء التطبيق (main.dart) — بتسجّل هاي الزيارة بالسيرفر
  /// وبتحدّث الرقم المعروض فورًا بالنتيجة الحقيقية الجديدة بدون طلب إضافي.
  Future<void> incrementVisitorCount() async {
    final newCount = await ApiService.incrementVisitCount();
    if (newCount != null) {
      visitorCount = newCount;
      notifyListeners();
    }
  }
}

// ==================== الألوان الأساسية (تتغيّر تلقائيًا حسب الثيم) ====================
// ==================== تخمين كلمة بحث مناسبة لصورة حقيقية حسب الوصف العربي ====================
String guessPhotoQuery(String subtitleAr, String titleAr) {
  final text = '$subtitleAr $titleAr';
  if (text.contains('معلم تاريخي') ||
      text.contains('البلدة القديمة') ||
      text.contains('خان')) {
    return 'old town stone alley';
  }
  if (text.contains('جبل') || text.contains('طبيعي')) {
    return 'mountain landscape';
  }
  if (text.contains('حديقة') ||
      text.contains('حدائق') ||
      text.contains('پارك')) {
    return 'public park garden';
  }
  if (text.contains('جامع') || text.contains('مسجد') || text.contains('ديني')) {
    return 'mosque islamic architecture';
  }
  if (text.contains('ميدان') || text.contains('مربع')) {
    return 'city square';
  }
  if (text.contains('مطعم') ||
      text.contains('مطاعم') ||
      text.contains('مأكولات') ||
      text.contains('شاورما')) {
    return 'middle eastern restaurant food';
  }
  if (text.contains('حلويات') || text.contains('كنافة')) {
    return 'kunafa dessert';
  }
  if (text.contains('مقهى') ||
      text.contains('كافيه') ||
      text.contains('كافي')) {
    return 'coffee shop interior';
  }
  if (text.contains('فندق') || text.contains('قصر')) {
    return 'hotel exterior building';
  }
  if (text.contains('تسوق') || text.contains('مول') || text.contains('مركز')) {
    return 'shopping mall interior';
  }
  if (text.contains('مؤتمر')) {
    return 'conference hall event';
  }
  if (text.contains('معرض') || text.contains('الكتاب')) {
    return 'book fair exhibition';
  }
  if (text.contains('مهرجان')) {
    return 'street festival crowd';
  }
  if (text.contains('فعاليات') ||
      text.contains('ثقافي') ||
      text.contains('ثقافية')) {
    return 'cultural event celebration';
  }
  if (text.contains('سياحة') ||
      text.contains('سياحي') ||
      text.contains('زوار') ||
      text.contains('زيارة')) {
    return 'tourists sightseeing';
  }
  if (text.contains('تطوير') ||
      text.contains('مشروع') ||
      text.contains('بناء')) {
    return 'urban development construction';
  }
  if (text.contains('جامعة') || text.contains('النجاح')) {
    return 'university campus';
  }
  if (text.contains('مستشفى') ||
      text.contains('عيادة') ||
      text.contains('صحة')) {
    return 'hospital medical';
  }
  if (text.contains('صيدلية') || text.contains('صيدليات')) {
    return 'pharmacy medicine shelves';
  }
  if (text.contains('مواصلات') ||
      text.contains('باص') ||
      text.contains('محطة') ||
      text.contains('سرفيس')) {
    return 'bus station street';
  }
  return 'nablus palestine city';
}

// ملاحظة: تعريف AppColors انتقل إلى lib/theme/app_colors.dart (مُصدَّر أعلاه
// عبر `export`) حتى تصير الألوان بملف Theme منفصل بدون كسر أي استيراد قديم.

// ==================== الشاشة الرئيسية ====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final mobile = isMobile(context);
        final content = KeyboardScrollable(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TopBar(
                  onMenuTap: mobile
                      ? () => _scaffoldKey.currentState?.openDrawer()
                      : null,
                ),
                BannerSlider(),
                SearchBar_(),
                StatsRow(),
                CategoriesSection(),
                FavoritePlacesSection(),
                RecommendationsSection(),
                EventsAndMapSection(),
                LatestNewsSection(),
                FooterSection(
                  onScrollToTop: () => _scrollController.animateTo(
                    0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  ),
                ),
              ],
            ),
          ),
        );
        return Directionality(
          textDirection:
              TextDirection.ltr, // تخطيط الصفحة العام (مواقع الأقسام) يبقى ثابت
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.bgDark,
            drawer: mobile ? Drawer(child: SideBar()) : null,
            body: mobile
                ? content
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SideBar(),
                      Expanded(child: content),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

// ==================== الشريط الجانبي ====================
class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      color: AppColors.sidebarDark,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الشعار
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_city,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'دليل نابلس الذكي',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Nablus Smart Guide',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // أسعار العملات
            SideCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SideSectionTitle(
                    icon: Icons.attach_money,
                    iconBg: AppColors.gold,
                    titleAr: 'أسعار العملات',
                    titleEn: 'Exchange Rates',
                  ),
                  SizedBox(height: 10),
                  if (AppState.instance.ratesLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (AppState.instance.ratesError != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppState.instance.ratesError!,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: AppColors.red, fontSize: 10),
                        ),
                        SizedBox(height: 6),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => AppState.instance.fetchRates(),
                          child: Text(
                            'إعادة المحاولة',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    CurrencyRow(
                      flagColor: Colors.blue,
                      code: 'USD',
                      rate:
                          '${AppState.instance.usdToIls.toStringAsFixed(2)} ILS',
                    ),
                    Divider(color: AppColors.borderColor, height: 16),
                    CurrencyRow(
                      flagColor: Colors.green,
                      code: 'JOD',
                      rate:
                          '${AppState.instance.jodToIls.toStringAsFixed(2)} ILS',
                    ),
                    Divider(color: AppColors.borderColor, height: 16),
                    CurrencyRow(
                      flagColor: Colors.indigo,
                      code: 'EUR',
                      rate:
                          '${AppState.instance.eurToIls.toStringAsFixed(2)} ILS',
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 16),

            // تواصل معنا
            SideCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SideSectionTitle(
                    icon: Icons.headset_mic,
                    iconBg: AppColors.teal,
                    titleAr: 'تواصل معنا',
                    titleEn: 'Contact Us',
                  ),
                  SizedBox(height: 12),
                  ContactRow(icon: Icons.phone, text: '+970 59 123 4567'),
                  SizedBox(height: 10),
                  ContactRow(icon: Icons.email, text: 'info@nablus-guide.com'),
                  SizedBox(height: 10),
                  ContactRow(
                    icon: Icons.location_on,
                    text: 'Nablus, Palestine',
                  ),
                  SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SocialIcon(
                        icon: Icons.facebook,
                        url: 'https://facebook.com',
                      ),
                      SocialIcon(
                        icon: Icons.camera_alt,
                        url: 'https://instagram.com',
                      ),
                      SocialIcon(
                        icon: Icons.alternate_email,
                        url: 'https://twitter.com',
                      ),
                      SocialIcon(
                        icon: Icons.play_circle_fill,
                        url: 'https://youtube.com',
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ContactUsScreen(),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            AppState.instance.t(
                              'أرسلي رسالة',
                              'Send a Message',
                            ),
                            textDirection: AppState.instance.dir,
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // تحميل التطبيق
            SideCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SideSectionTitle(
                    icon: Icons.download,
                    iconBg: AppColors.primary,
                    titleAr: 'حمل التطبيق',
                    titleEn: 'Download App',
                  ),
                  SizedBox(height: 12),
                  StoreButton(
                    icon: Icons.play_arrow,
                    line1: 'GET IT ON',
                    line2: 'Google Play',
                  ),
                  SizedBox(height: 8),
                  StoreButton(
                    icon: Icons.apple,
                    line1: 'Download on the',
                    line2: 'App Store',
                  ),
                  SizedBox(height: 14),
                  Container(
                    height: 90,
                    width: 90,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: QrImageView(
                      data: 'https://nablus-guide.com/download',
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SideCard extends StatelessWidget {
  final Widget child;
  const SideCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: child,
    );
  }
}

class SideSectionTitle extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String titleAr;
  final String titleEn;
  const SideSectionTitle({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.titleAr,
    required this.titleEn,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconBg.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconBg),
        ),
        SizedBox(width: 8),
        Text(
          app.t(titleAr, titleEn),
          textDirection: app.dir,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class CurrencyRow extends StatelessWidget {
  final Color flagColor;
  final String code;
  final String rate;
  const CurrencyRow({
    super.key,
    required this.flagColor,
    required this.code,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 10, backgroundColor: flagColor),
        SizedBox(width: 8),
        Text(
          code,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacer(),
        Text(
          rate,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const ContactRow({super.key, required this.icon, required this.text});

  Future<void> _onTap(BuildContext context) async {
    if (icon == Icons.phone) {
      await launchUrl(Uri.parse('tel:$text'));
    } else if (icon == Icons.email) {
      await launchUrl(Uri.parse('mailto:$text'));
    } else if (icon == Icons.location_on) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => MapScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(context),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.purpleLight),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;
  const SocialIcon({super.key, required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        margin: EdgeInsets.only(right: 8),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.cardDark2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: AppColors.textWhite),
      ),
    );
  }
}

class StoreButton extends StatelessWidget {
  final IconData icon;
  final String line1;
  final String line2;
  const StoreButton({
    super.key,
    required this.icon,
    required this.line1,
    required this.line2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(line1, style: TextStyle(color: Colors.white70, fontSize: 8)),
              Text(
                line2,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== الشريط العلوي ====================
class TopBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  const TopBar({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final mobile = isMobile(context);
    final navItems = [
      NavItem(
        iconAr: 'الرئيسية',
        iconEn: 'Home',
        icon: Icons.home,
        active: true,
      ),
      NavItem(
        iconAr: 'استكشف',
        iconEn: 'Explore',
        icon: Icons.explore,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => ExploreScreen())),
      ),
      NavItem(
        iconAr: 'الخريطة',
        iconEn: 'Map',
        icon: Icons.map,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => MapScreen())),
      ),
      NavItem(
        iconAr: 'قريب مني',
        iconEn: 'Nearby',
        icon: Icons.near_me_rounded,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => NearbyPlacesScreen())),
      ),
      NavItem(
        iconAr: 'الأخبار',
        iconEn: 'News',
        icon: Icons.article,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => NewsScreen())),
      ),
      NavItem(
        iconAr: 'المساعد الذكي',
        iconEn: 'AI Assistant',
        icon: Icons.smart_toy,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => AiAssistantScreen())),
      ),
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 12 : 24, vertical: 14),
      color: AppColors.sidebarDark,
      child: Row(
        children: [
          if (onMenuTap != null) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onMenuTap,
              child: Icon(Icons.menu, size: 22, color: AppColors.textWhite),
            ),
            SizedBox(width: 12),
          ],
          if (!mobile) ...[
            Icon(Icons.access_time, size: 16, color: AppColors.textGrey),
            SizedBox(width: 6),
            Text(
              app.currentTime,
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
            Spacer(),
          ],
          if (mobile)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: navItems),
              ),
            )
          else ...[
            ...navItems,
            Spacer(),
          ],
          SizedBox(width: mobile ? 10 : 16),
          _NotificationBell(),
          SizedBox(width: mobile ? 10 : 16),
          AppToggleBar(),
          SizedBox(width: mobile ? 10 : 16),
          // زر تسجيل الخروج
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _confirmLogout(context),
            child: Icon(Icons.logout, color: AppColors.red, size: 20),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final app = AppState.instance;
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: app.dir,
        child: AlertDialog(
          backgroundColor: AppColors.cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            app.t('تسجيل الخروج', 'Log Out'),
            textDirection: app.dir,
            style: TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            app.t(
              'هل أنت متأكد من رغبتك بتسجيل الخروج؟',
              'Are you sure you want to log out?',
            ),
            textDirection: app.dir,
            style: TextStyle(color: AppColors.textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                app.t('إلغاء', 'Cancel'),
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await AuthService.instance.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(
                app.t('تسجيل الخروج', 'Log Out'),
                style: TextStyle(
                  color: AppColors.red,
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

class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  @override
  Widget build(BuildContext context) {
    final unread = visitorUnreadCount;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => NotificationsScreen()));
        if (mounted) setState(() {});
      },
      child: Stack(
        children: [
          Icon(Icons.notifications_none, color: AppColors.textWhite, size: 22),
          if (unread > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unread',
                  style: TextStyle(color: Colors.white, fontSize: 8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final String iconAr;
  final String iconEn;
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;
  const NavItem({
    super.key,
    required this.iconAr,
    required this.iconEn,
    required this.icon,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final color = active ? AppColors.primary : AppColors.textGrey;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(height: 2),
            Text(
              app.t(iconAr, iconEn),
              textDirection: app.dir,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (active)
              Container(
                margin: EdgeInsets.only(top: 3),
                height: 2,
                width: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

// ==================== شريط الصور المتحركة (Banner) ====================
class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  final List<Map<String, String>> _slides = [
    {
      'title': '🏛 مرحباً بك في نابلس',
      'subtitle': 'تاريخ عريق... مستقبل مشرق',
      'titleEn': '🏛 Welcome to Nablus',
      'subtitleEn': 'Rich History... Bright Future',
      'photoQuery': 'nablus palestine cityscape',
    },
    {
      'title': '🕌 اكتشف البلدة القديمة',
      'subtitle': 'أزقة تحمل قصص آلاف السنين',
      'titleEn': '🕌 Discover the Old City',
      'subtitleEn': 'Alleys That Hold Thousand-Year Stories',
      'photoQuery': 'old town stone alley',
    },
    {
      'title': '🍽 نكهات نابلس الأصيلة',
      'subtitle': 'الكنافة النابلسية وأشهى المأكولات',
      'titleEn': '🍽 Authentic Nablus Flavors',
      'subtitleEn': 'Nabulsi Kunafa and the Finest Dishes',
      'photoQuery': 'kunafa dessert',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: SizedBox(
        height: 210,
        child: Stack(
          children: [
            CarouselSlider.builder(
              carouselController: _controller,
              itemCount: _slides.length,
              options: CarouselOptions(
                height: 210,
                viewportFraction: 1,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 4),
                onPageChanged: (index, reason) {
                  setState(() => _current = index);
                },
              ),
              itemBuilder: (context, index, realIndex) {
                final slide = _slides[index];
                final app = AppState.instance;
                final shownTitle = app.isArabic
                    ? slide['title']!
                    : (slide['titleEn'] ?? slide['title']!);
                final shownSubtitle = app.isArabic
                    ? slide['subtitle']!
                    : (slide['subtitleEn'] ?? slide['subtitle']!);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // صورة الخلفية: صورة حقيقية مرتبطة بمضمون كل شريحة
                      ThemedImage(
                        query: slide['photoQuery'] ?? 'nablus palestine city',
                        fallbackSeed: 'banner-${slide['titleEn']}',
                        height: 210,
                      ),
                      // تدرّج أنيق فوق الصورة لإظهار النص بوضوح مع لمسة من هوية التطبيق
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.55),
                              AppColors.primaryDark.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 12,
                                    color: AppColors.gold,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    app.t('نابلس، فلسطين', 'Nablus, Palestine'),
                                    style: AppTypography.caption(Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              shownTitle,
                              textDirection: app.dir,
                              textAlign: TextAlign.center,
                              style: AppTypography.display(
                                Colors.white,
                              ).copyWith(fontSize: 26, height: 1.2),
                            ),
                            SizedBox(height: 6),
                            Text(
                              shownSubtitle,
                              textDirection: app.dir,
                              textAlign: TextAlign.center,
                              style: AppTypography.body(Colors.white70),
                            ),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ExploreScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: AppColors.primaryGradient,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                  boxShadow: AppColors.glowShadow,
                                ),
                                child: Text(
                                  app.t('استكشف الآن', 'Explore Now'),
                                  textDirection: app.dir,
                                  style: AppTypography.title(Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // أسهم التنقل باستخدام carousel controller
            Positioned(
              left: 12,
              top: 90,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _controller.previousPage(),
                child: _arrowButton(Icons.chevron_left),
              ),
            ),
            Positioned(
              right: 12,
              top: 90,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _controller.nextPage(),
                child: _arrowButton(Icons.chevron_right),
              ),
            ),
            // نقاط المؤشر الحقيقية المرتبطة بحالة الكاروسيل
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _current;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _arrowButton(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

// ==================== شريط البحث ====================
class SearchBar_ extends StatelessWidget {
  const SearchBar_({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExploreScreen(autofocusSearch: true),
          ),
        ),
        child: Container(
          height: 54,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: IgnorePointer(
                  child: TextField(
                    enabled: false,
                    textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                    style: AppTypography.body(AppColors.textWhite),
                    decoration: InputDecoration(
                      hintText: app.t(
                        'ابحث عن مكان، مطعم، فندق، معلم...',
                        'Search for a place, restaurant, hotel...',
                      ),
                      hintStyle: AppTypography.body(
                        AppColors.textGrey,
                      ).copyWith(fontSize: 13),
                      border: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== صف الإحصائيات (طقس / زوار / وقت) ====================
class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                final app = AppState.instance;
                final weather = app.weather;
                final value = app.weatherLoading
                    ? app.t('جارِ التحميل...', 'Loading...')
                    : weather == null
                    ? app.t('غير متاح', 'Unavailable')
                    : app.isArabic
                    ? weatherConditionFor(weather.weatherCode).descriptionAr
                    : weatherConditionFor(weather.weatherCode).descriptionEn;
                return StatCard(
                  icon: Icons.wb_sunny,
                  iconColor: AppColors.gold,
                  titleAr: 'الطقس',
                  titleEn: 'Weather',
                  value: value,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => WeatherScreen()),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Builder(
              builder: (context) {
                final app = AppState.instance;
                final count = app.visitorCount;
                return StatCard(
                  icon: Icons.people,
                  iconColor: AppColors.purple,
                  titleAr: 'إجمالي الزوار',
                  titleEn: 'Total Visitors',
                  value: count == null
                      ? app.t('غير متاح', 'Unavailable')
                      : NumberFormat.decimalPattern().format(count),
                );
              },
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: StatCard(
              icon: Icons.access_time_filled,
              iconColor: AppColors.primary,
              titleAr: 'الوقت الآن',
              titleEn: 'Current Time',
              value: AppState.instance.currentTime,
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String titleAr;
  final String? titleEn;
  final String value;
  final VoidCallback? onTap;
  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.titleAr,
    this.titleEn,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(16),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  app.t(titleAr, titleEn ?? titleAr),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: app.dir,
                  style: AppTypography.label(
                    AppColors.textGrey,
                  ).copyWith(fontWeight: FontWeight.w400),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== التصنيفات ====================
class CategoriesSection extends StatelessWidget {
  CategoriesSection({super.key});

  final List<Map<String, dynamic>> items = [
    {
      'labelAr': 'مطاعم',
      'labelEn': 'Restaurants',
      'icon': Icons.restaurant_rounded,
      'color': AppColors.red,
      'photoQuery': 'restaurant food table Nablus',
    },
    {
      'labelAr': 'فنادق',
      'labelEn': 'Hotels',
      'icon': Icons.bed_rounded,
      'color': AppColors.purple,
      'photoQuery': 'hotel room bed Nablus',
    },
    {
      'labelAr': 'سياحة ومعالم',
      'labelEn': 'Attractions',
      'icon': Icons.mosque_rounded,
      'color': AppColors.gold,
      'photoQuery': 'landmark old city alley Nablus',
    },
    {
      'labelAr': 'تسوق',
      'labelEn': 'Shopping',
      'icon': Icons.shopping_bag_rounded,
      'color': AppColors.primary,
      'photoQuery': 'market shopping bags Nablus',
    },
    {
      'labelAr': 'مواصلات',
      'labelEn': 'Transport',
      'icon': Icons.directions_bus_rounded,
      'color': AppColors.teal,
      'photoQuery': 'bus station transport Nablus',
    },
    {
      'labelAr': 'صحة',
      'labelEn': 'Health',
      'icon': Icons.favorite_rounded,
      'color': AppColors.teal,
      'photoQuery': 'hospital medical cross Nablus',
    },
    {
      'labelAr': 'صيدليات',
      'labelEn': 'Pharmacies',
      'icon': Icons.local_pharmacy_rounded,
      'color': AppColors.primary,
      'photoQuery': 'pharmacy medicine shelves Nablus',
    },
    {
      'labelAr': 'المزيد',
      'labelEn': 'More',
      'icon': Icons.grid_view_rounded,
      'color': AppColors.textGrey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SectionHeader(
            titleAr: 'التصنيفات',
            titleEn: 'Categories',
            onViewAll: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => ExploreScreen())),
          ),
          SizedBox(height: 12),
          isMobile(context)
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: items
                        .map(
                          (item) => SizedBox(
                            width: 76,
                            child: CategoryTile(
                              labelAr: item['labelAr'],
                              labelEn: item['labelEn'],
                              icon: item['icon'],
                              color: item['color'],
                              photoQuery: item['photoQuery'],
                              onTap: () => _onCategoryTap(
                                context,
                                item['labelAr'] as String,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              : Row(
                  children: items
                      .map(
                        (item) => Expanded(
                          child: CategoryTile(
                            labelAr: item['labelAr'],
                            labelEn: item['labelEn'],
                            icon: item['icon'],
                            color: item['color'],
                            photoQuery: item['photoQuery'],
                            onTap: () => _onCategoryTap(
                              context,
                              item['labelAr'] as String,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }

  void _onCategoryTap(BuildContext context, String label) {
    if (label == 'مطاعم') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => RestaurantCategoriesScreen()),
      );
    } else if (label == 'فنادق') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => HotelsScreen()));
    } else if (label == 'سياحة ومعالم') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => AttractionCategoriesScreen()),
      );
    } else if (label == 'تسوق') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ShoppingCategoriesScreen()),
      );
    } else if (label == 'مواصلات') {
      Navigator.of(context).push(
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
      );
    } else if (label == 'صحة') {
      Navigator.of(context).push(
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
      );
    } else if (label == 'صيدليات') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => PharmaciesScreen()));
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => MoreCategoriesScreen()));
    }
  }
}

class CategoryTile extends StatefulWidget {
  final String labelAr;
  final String labelEn;
  final IconData icon;
  final Color color;
  final String? photoQuery;
  final VoidCallback? onTap;
  const CategoryTile({
    super.key,
    required this.labelAr,
    required this.labelEn,
    required this.icon,
    required this.color,
    this.photoQuery,
    this.onTap,
  });

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.35),
                  ),
                  boxShadow: AppColors.cardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.photoQuery != null)
                      ThemedImage(
                        query: widget.photoQuery!,
                        fallbackSeed: widget.labelEn,
                        height: 66,
                        fallbackIcon: widget.icon,
                        fallbackColor: widget.color,
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color,
                              widget.color.withValues(alpha: 0.65),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    if (widget.photoQuery != null)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      right: 5,
                      bottom: 5,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color,
                              widget.color.withValues(alpha: 0.75),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 13),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 7),
              Text(
                app.t(widget.labelAr, widget.labelEn),
                textDirection: app.dir,
                textAlign: TextAlign.center,
                style: AppTypography.label(
                  AppColors.textWhite,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== عنوان القسم مع "عرض الكل" ====================
class SectionHeader extends StatelessWidget {
  final String titleAr;
  final String? titleEn;
  final String? emoji;
  final VoidCallback onViewAll;
  const SectionHeader({
    super.key,
    required this.titleAr,
    this.titleEn,
    this.emoji,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final title = app.isArabic ? titleAr : (titleEn ?? titleAr);
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onViewAll,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  app.t('عرض الكل', 'View All'),
                  textDirection: app.dir,
                  style: AppTypography.label(AppColors.primary),
                ),
                SizedBox(width: 3),
                Icon(
                  app.isArabic
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 18)),
              SizedBox(width: 6),
            ],
            Text(
              title,
              textDirection: app.dir,
              style: AppTypography.headline(
                AppColors.textWhite,
              ).copyWith(fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== الأماكن المفضلة ====================
class FavoritePlacesSection extends StatelessWidget {
  FavoritePlacesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final favNames = FavoritesService.instance.getFavoriteNames();
    final favPlaces = favNames
        .map((n) => allPlaces.where((p) => p.nameEn == n).firstOrNull)
        .whereType<UniversalPlace>()
        .take(5)
        .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SectionHeader(
            titleAr: 'الأماكن المفضلة',
            titleEn: 'Favorite Places',
            emoji: '❤️',
            onViewAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AllPlacesScreen(
                  titleAr: 'الأماكن المفضلة',
                  titleEn: 'Favorite Places',
                  sortMode: PlacesSortMode.featured,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          if (favPlaces.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite_border,
                    color: AppColors.textGrey,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    app.t(
                      'لسا ما أضفتِ أي مكان للمفضلة',
                      "You haven't added any favorites yet",
                    ),
                    textDirection: app.dir,
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                  SizedBox(height: 2),
                  Text(
                    app.t(
                      'اضغطي على أيقونة القلب بأي مكان لإضافته هنا',
                      'Tap the heart icon on any place to add it here',
                    ),
                    textDirection: app.dir,
                    style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                  ),
                ],
              ),
            )
          else if (isMobile(context))
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: favPlaces
                    .map(
                      (p) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          width: 150,
                          child: PlaceCard(
                            title: p.nameAr,
                            subtitle: p.typeAr,
                            titleEn: p.nameEn,
                            subtitleEn: p.typeEn,
                            rating: p.rating,
                            favorited: true,
                            image: p.image,
                            customImageBase64: p.customImageBase64,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
          else
            Row(
              children: favPlaces
                  .map(
                    (p) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: PlaceCard(
                          title: p.nameAr,
                          subtitle: p.typeAr,
                          titleEn: p.nameEn,
                          subtitleEn: p.typeEn,
                          rating: p.rating,
                          favorited: true,
                          image: p.image,
                          customImageBase64: p.customImageBase64,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class PlaceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? titleEn;
  final String? subtitleEn;
  final bool favorited;
  final double? rating;
  final String? image;
  final String? customImageBase64;
  const PlaceCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleEn,
    this.subtitleEn,
    this.favorited = false,
    this.rating,
    this.image,
    this.customImageBase64,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final shownTitle = app.isArabic ? title : (titleEn ?? title);
    final shownSubtitle = app.isArabic ? subtitle : (subtitleEn ?? subtitle);
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              titleAr: title,
              titleEn: titleEn ?? title,
              subtitleAr: subtitle,
              subtitleEn: subtitleEn ?? subtitle,
              rating: rating,
              localAsset: image,
              customImageBase64: customImageBase64,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ThemedImage(
                query: guessPhotoQuery(subtitle, title),
                fallbackSeed: title,
                height: 100,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                localAsset: image,
                customImageBase64: customImageBase64,
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    favorited ? Icons.favorite : Icons.favorite_border,
                    size: 14,
                    color: favorited ? AppColors.red : Colors.white,
                  ),
                ),
              ),
              if (rating != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: AppColors.gold,
                        ),
                        SizedBox(width: 3),
                        Text(
                          '$rating',
                          style: AppTypography.caption(Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  shownTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: app.dir,
                  style: AppTypography.label(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  shownSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: app.dir,
                  style: AppTypography.caption(AppColors.textGrey),
                ),
                SizedBox(height: 6),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showPlaceQrDialog(context, app, shownTitle),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        app.t('مشاركة برمز QR', 'Share via QR'),
                        style: AppTypography.caption(AppColors.primary),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.qr_code_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaceQrDialog(BuildContext context, AppState app, String name) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: app.dir,
        child: AlertDialog(
          backgroundColor: AppColors.cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            name,
            textAlign: TextAlign.center,
            style: AppTypography.title(AppColors.textWhite),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 180,
                height: 180,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: QrImageView(
                  data: 'https://nablus-guide.com/place/$name',
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(height: 12),
              Text(
                app.t('امسحيه لمشاركة هذا المكان', 'Scan to share this place'),
                style: AppTypography.caption(AppColors.textGrey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                app.t('إغلاق', 'Close'),
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== الأكثر زيارة + أحدث الأماكن ====================
// صف بطاقات أماكن: يتمدد على الديسكتوب، ويصير قابل للتمرير الأفقي على الموبايل
class PlaceCardRow extends StatelessWidget {
  final List<PlaceCard> cards;
  const PlaceCardRow({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    if (isMobile(context)) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: cards
              .map(
                (c) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(width: 150, child: c),
                ),
              )
              .toList(),
        ),
      );
    }
    return Row(
      children: cards
          .map(
            (c) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: c,
              ),
            ),
          )
          .toList(),
    );
  }
}

// ==================== الفعاليات القادمة + الخريطة ====================
class EventsAndMapSection extends StatelessWidget {
  const EventsAndMapSection({super.key});

  @override
  Widget build(BuildContext context) {
    final eventsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SectionHeader(
          titleAr: 'الفعاليات القادمة',
          titleEn: 'Upcoming Events',
          emoji: '📅',
          onViewAll: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => EventsScreen())),
        ),
        SizedBox(height: 12),
        EventRow(
          title: 'مهرجان التسوق السنوي',
          subtitle: 'مركز المدينة',
          titleEn: 'Annual Shopping Festival',
          subtitleEn: 'City Center',
          day: '15',
          month: 'يونيو',
          monthEn: 'Jun',
        ),
        SizedBox(height: 10),
        EventRow(
          title: 'معرض نابلس للكتاب',
          subtitle: 'مركز المعارض',
          titleEn: 'Nablus Book Fair',
          subtitleEn: 'Exhibition Center',
          day: '22',
          month: 'يونيو',
          monthEn: 'Jun',
        ),
        SizedBox(height: 10),
        EventRow(
          title: 'مهرجان الموسيقى التراثية',
          subtitle: 'المسرح الوطني',
          titleEn: 'Heritage Music Festival',
          subtitleEn: 'National Theater',
          day: '30',
          month: 'يونيو',
          monthEn: 'Jun',
        ),
      ],
    );

    final mapColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SectionHeader(
          titleAr: 'الخريطة',
          titleEn: 'Map',
          emoji: '🗺️',
          onViewAll: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => MapScreen())),
        ),
        SizedBox(height: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => MapScreen()));
          },
          child: Container(
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                IgnorePointer(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: nablusCenter,
                      initialZoom: 13.5,
                      interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.nablus.smart_city_guide',
                      ),
                      MarkerLayer(
                        markers: mapPlaces
                            .map(
                              (p) => Marker(
                                point: p.point,
                                width: 26,
                                height: 26,
                                child: Icon(
                                  Icons.location_on,
                                  color: p.color,
                                  size: 26,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Container(color: Colors.black.withValues(alpha: 0.06)),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppState.instance.t(
                        'فتح الخريطة الكاملة',
                        'Open Full Map',
                      ),
                      textDirection: AppState.instance.dir,
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: isMobile(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [eventsColumn, SizedBox(height: 20), mapColumn],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: eventsColumn),
                SizedBox(width: 16),
                Expanded(child: mapColumn),
              ],
            ),
    );
  }
}

class EventRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String day;
  final String month;
  final String? titleEn;
  final String? subtitleEn;
  final String? monthEn;
  const EventRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.day,
    required this.month,
    this.titleEn,
    this.subtitleEn,
    this.monthEn,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final shownTitle = app.isArabic ? title : (titleEn ?? title);
    final shownSubtitle = app.isArabic ? subtitle : (subtitleEn ?? subtitle);
    final shownMonth = app.isArabic ? month : (monthEn ?? month);
    return AppCard(
      padding: EdgeInsets.all(10),
      radius: AppRadius.md,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              titleAr: title,
              titleEn: titleEn ?? title,
              subtitleAr: subtitle,
              subtitleEn: subtitleEn ?? subtitle,
              extraInfo: '$day $shownMonth',
            ),
          ),
        );
      },
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.purple, AppColors.purpleLight],
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: AppTypography.title(
                    Colors.white,
                  ).copyWith(fontSize: 14),
                ),
                Text(shownMonth, style: AppTypography.caption(Colors.white)),
              ],
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  shownTitle,
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 12.5),
                ),
                Text(
                  shownSubtitle,
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

// ==================== آخر الأخبار ====================
class LatestNewsSection extends StatelessWidget {
  LatestNewsSection({super.key});

  final List<Map<String, String>> news = [
    {
      'title': 'افتتاح مشروع تطوير البلدة القديمة',
      'titleEn': 'Old City Development Project Launched',
      'date': '10 مايو 2025',
      'dateEn': 'May 10, 2025',
    },
    {
      'title': 'نابلس تستضيف المؤتمر السياحي الدولي',
      'titleEn': 'Nablus Hosts International Tourism Conference',
      'date': '8 مايو 2025',
      'dateEn': 'May 8, 2025',
    },
    {
      'title': 'تحسن حركة السياحة في نابلس',
      'titleEn': 'Tourism Activity Improves in Nablus',
      'date': '5 مايو 2025',
      'dateEn': 'May 5, 2025',
    },
    {
      'title': 'فعاليات ثقافية جديدة في المدينة',
      'titleEn': 'New Cultural Events in the City',
      'date': '2 مايو 2025',
      'dateEn': 'May 2, 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SectionHeader(
            titleAr: 'آخر الأخبار',
            titleEn: 'Latest News',
            emoji: '📰',
            onViewAll: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => NewsScreen())),
          ),
          SizedBox(height: 12),
          isMobile(context)
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: news
                        .map(
                          (n) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: SizedBox(
                              width: 200,
                              child: NewsCard(
                                title: n['title']!,
                                date: n['date']!,
                                titleEn: n['titleEn'],
                                dateEn: n['dateEn'],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              : Row(
                  children: news
                      .map(
                        (n) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: NewsCard(
                              title: n['title']!,
                              date: n['date']!,
                              titleEn: n['titleEn'],
                              dateEn: n['dateEn'],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String title;
  final String date;
  final String? titleEn;
  final String? dateEn;
  const NewsCard({
    super.key,
    required this.title,
    required this.date,
    this.titleEn,
    this.dateEn,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final shownTitle = app.isArabic ? title : (titleEn ?? title);
    final shownDate = app.isArabic ? date : (dateEn ?? date);
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              titleAr: title,
              titleEn: titleEn ?? title,
              extraInfo: shownDate,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ThemedImage(
            query: guessPhotoQuery(title, ''),
            fallbackSeed: title,
            height: 90,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  shownTitle,
                  textDirection: app.dir,
                  textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  shownDate,
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

// ==================== الفوتر ====================
class FooterSection extends StatelessWidget {
  final VoidCallback onScrollToTop;
  const FooterSection({super.key, required this.onScrollToTop});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final logoBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.location_city, color: Colors.white, size: 16),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.t('دليل نابلس الذكي', 'Nablus Smart Guide'),
                  textDirection: app.dir,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  app.t('دليلك السياحي الذكي', 'Your Smart City Guide'),
                  style: TextStyle(color: AppColors.textGrey, fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final quickLinksColumn = FooterColumn(
      titleAr: 'روابط سريعة',
      titleEn: 'Quick Links',
      itemsAr: ['الرئيسية', 'استكشف', 'الخريطة', 'الأخبار', 'المساعد الذكي'],
      itemsEn: ['Home', 'Explore', 'Map', 'News', 'AI Assistant'],
      onScrollToTop: onScrollToTop,
    );
    final infoColumn = FooterColumn(
      titleAr: 'معلومات',
      titleEn: 'Information',
      itemsAr: [
        'من نحن',
        'سياسة الخصوصية',
        'الشروط والأحكام',
        'الأسئلة الشائعة',
      ],
      itemsEn: ['About Us', 'Privacy Policy', 'Terms & Conditions', 'FAQ'],
    );
    final contactColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => ContactUsScreen())),
          child: Text(
            app.t('تواصل معنا', 'Contact Us'),
            textDirection: app.dir,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        ContactRow(icon: Icons.phone, text: '+970 59 123 4567'),
        SizedBox(height: 8),
        ContactRow(icon: Icons.email, text: 'info@nablus-guide.com'),
        SizedBox(height: 8),
        ContactRow(icon: Icons.location_on, text: 'Nablus, Palestine'),
        SizedBox(height: 10),
        Row(
          children: [
            SocialIcon(icon: Icons.facebook, url: 'https://facebook.com'),
            SocialIcon(icon: Icons.camera_alt, url: 'https://instagram.com'),
            SocialIcon(icon: Icons.alternate_email, url: 'https://twitter.com'),
            SocialIcon(
              icon: Icons.play_circle_fill,
              url: 'https://youtube.com',
            ),
          ],
        ),
      ],
    );
    final mobile = isMobile(context);

    return Container(
      margin: EdgeInsets.only(top: 30),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 24, vertical: 24),
      color: AppColors.sidebarDark,
      child: Column(
        children: [
          mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    logoBlock,
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: quickLinksColumn,
                    ),
                    SizedBox(height: 20),
                    Align(alignment: Alignment.centerRight, child: infoColumn),
                    SizedBox(height: 20),
                    contactColumn,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: logoBlock),
                    Expanded(child: quickLinksColumn),
                    Expanded(child: infoColumn),
                    Expanded(child: contactColumn),
                  ],
                ),
          Divider(color: AppColors.borderColor, height: 32),
          Text(
            app.t(
              '© 2026 دليل نابلس الذكي - جميع الحقوق محفوظة',
              '© 2026 Nablus Smart Guide - All Rights Reserved',
            ),
            textDirection: app.dir,
            style: TextStyle(color: AppColors.textGrey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class FooterColumn extends StatelessWidget {
  final String titleAr;
  final String? titleEn;
  final List<String> itemsAr;
  final List<String>? itemsEn;
  final VoidCallback? onScrollToTop;
  const FooterColumn({
    super.key,
    required this.titleAr,
    this.titleEn,
    required this.itemsAr,
    this.itemsEn,
    this.onScrollToTop,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final title = app.isArabic ? titleAr : (titleEn ?? titleAr);
    final items = app.isArabic ? itemsAr : (itemsEn ?? itemsAr);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          textDirection: app.dir,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ...items.map(
          (i) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (i == 'الرئيسية' || i == 'Home') {
                  onScrollToTop?.call();
                } else if (i == 'استكشف' || i == 'Explore') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ExploreScreen()),
                  );
                } else if (i == 'الأخبار' || i == 'News') {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => NewsScreen()));
                } else if (i == 'الخريطة' || i == 'Map') {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => MapScreen()));
                } else if (i == 'المساعد الذكي' || i == 'AI Assistant') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AiAssistantScreen(),
                    ),
                  );
                } else if (i == 'من نحن' || i == 'About Us') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AboutUsScreen()),
                  );
                } else if (i == 'سياسة الخصوصية' || i == 'Privacy Policy') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PrivacyPolicyScreen(),
                    ),
                  );
                } else if (i == 'الشروط والأحكام' ||
                    i == 'Terms & Conditions') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => TermsScreen()),
                  );
                } else if (i == 'الأسئلة الشائعة' || i == 'FAQ') {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => FaqScreen()));
                }
              },
              child: Text(
                i,
                textDirection: app.dir,
                style: TextStyle(color: AppColors.textGrey, fontSize: 11),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
