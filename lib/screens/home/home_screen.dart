import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import '../../services/api_service.dart';
import '../category/category_list_screen.dart';
import '../category/category_data.dart';
import '../category/more_categories_screen.dart';
import '../explore/explore_screen.dart';
import '../notifications/notifications_screen.dart';
import '../places/all_places_screen.dart';
import '../places/visit_history_screen.dart';
import '../events/events_screen.dart';
import '../nearby/nearby_places_screen.dart';
import '../transport/transport_screen.dart';
import 'recommendations_section.dart';
import 'sponsored_section.dart';
import 'quick_info_section.dart';
import 'mobile_home.dart';
import 'settings_panel.dart';
import 'news_ticker.dart';
import 'quick_actions_row.dart';
import 'top_highlights_row.dart';
import '../../services/favorites_service.dart';
import '../info/about_us_screen.dart';
import '../../widgets/responsive.dart';
import '../../widgets/fade_slide_in.dart';
import '../info/privacy_policy_screen.dart';
import '../info/terms_screen.dart';
import '../info/faq_screen.dart';
import '../info/contact_us_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_card.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/heritage_pattern.dart';
import '../../widgets/keyboard_scrollable.dart';
export '../../theme/app_colors.dart' show AppColors;
export '../../theme/app_spacing.dart' show AppSpacing, AppRadius;
export '../../widgets/app_card.dart' show AppCard;
import '../../widgets/themed_image.dart';
import '../../services/weather_service.dart';
import '../weather/weather_screen.dart';
import '../../services/local_db_service.dart';

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

  // ---------- شريط الأخبار المتحرك بالصفحة الرئيسية ----------
  bool hideNewsTicker = LocalDbService.instance.getBoolSetting('hideNewsTicker');
  Future<void> toggleNewsTicker() async {
    hideNewsTicker = !hideNewsTicker;
    await LocalDbService.instance.setBoolSetting('hideNewsTicker', hideNewsTicker);
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

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
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
                if (!AppState.instance.hideNewsTicker) const NewsTicker(),
                FadeSlideIn(child: BannerSlider()),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: SearchBar_(),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: const QuickActionsRow(),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: StatsRow(),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: CategoriesSection(),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 180),
                  child: const TopHighlightsRow(),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 220),
                  child: FavoritePlacesSection(),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 260),
                  child: SponsoredSection(),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: RecommendationsSection(),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 340),
                  child: EventsAndMapSection(),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 380),
                  child: LatestNewsSection(),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 420),
                  child: FooterSection(
                    onScrollToTop: () => _scrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    ),
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
            bottomNavigationBar: mobile ? const MobileBottomNav() : null,
            body: HeritagePatternBackground(
              child: mobile
                  ? content
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SideBar(),
                        Expanded(child: content),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== الشريط الجانبي ====================
/// شريط جانبي قابل للطي (ديسكتوب فقط) — بضغطة زر يتقلص لعمود أيقونات ضيّق
/// (Tooltip بدل النص) بدل ما ياخذ 210px دايمًا، ويرجع يتوسّع بنفس الزر.
class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    // المحتوى (موسّع/مطوي) بيتبدّل فورًا لما تنضغط الزر، بعكس عرض
    // AnimatedContainer اللي بياخد 220ms لياخد قيمته النهائية. لو حطينا
    // المحتوى مباشرة جوّا AnimatedContainer، هيك بيصير قيود تخطيط ضيقة
    // بمنتصف الأنيميشن (مثلاً عرض 130 لمحتوى مصمم لـ 210) وبيطلع overflow.
    // الحل: نخلي المحتوى ياخد عرضه المستهدف الثابت دايمًا عبر OverflowBox،
    // والـ AnimatedContainer الخارجي بس بيقص (clip) الجزء الزائد بصريًا.
    final targetWidth = _collapsed ? 72.0 : 210.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: targetWidth,
      color: AppColors.sidebarDark,
      clipBehavior: Clip.hardEdge,
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: 0,
        maxWidth: targetWidth,
        child: SizedBox(
          width: targetWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _collapsed ? 12 : 16,
              vertical: 20,
            ),
            child: _collapsed
                ? _CollapsedRail(
                    onExpand: () => setState(() => _collapsed = false),
                  )
                : _ExpandedSideBarContent(
                    onCollapse: () => setState(() => _collapsed = true),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedRail extends StatelessWidget {
  final VoidCallback onExpand;
  const _CollapsedRail({required this.onExpand});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return SingleChildScrollView(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/branding/logo_icon.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 14),
          _RailButton(
            icon: Icons.chevron_right_rounded,
            tooltip: app.t('توسيع الشريط', 'Expand sidebar'),
            onTap: onExpand,
          ),
          SizedBox(height: 18),
          Divider(color: AppColors.borderColor, height: 1),
          SizedBox(height: 18),
          _RailButton(
            icon: Icons.emergency_rounded,
            iconColor: AppColors.red,
            tooltip: app.t('الطوارئ', 'Emergency'),
            onTap: () => showEmergencySheet(context),
          ),
          SizedBox(height: 14),
          _RailButton(
            icon: Icons.mosque_rounded,
            iconColor: AppColors.teal,
            tooltip: app.t('أوقات الصلاة', 'Prayer Times'),
            onTap: () => showPrayerTimesSheet(context),
          ),
          SizedBox(height: 14),
          _RailButton(
            icon: Icons.headset_mic_rounded,
            iconColor: AppColors.teal,
            tooltip: app.t('تواصل معنا', 'Contact Us'),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => ContactUsScreen())),
          ),
          SizedBox(height: 14),
          _RailButton(
            icon: Icons.download_rounded,
            iconColor: AppColors.primary,
            tooltip: app.t('حمل التطبيق', 'Download App'),
            onTap: onExpand,
          ),
        ],
      ),
    );
  }
}

class _RailButton extends StatefulWidget {
  final IconData icon;
  final Color? iconColor;
  final String tooltip;
  final VoidCallback onTap;
  const _RailButton({
    required this.icon,
    this.iconColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_RailButton> createState() => _RailButtonState();
}

class _RailButtonState extends State<_RailButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _hovering
                  ? AppColors.cardDark2
                  : AppColors.cardDark2.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.iconColor ?? AppColors.textWhite,
            ),
          ),
        ),
      ),
    );
  }
}

// ملف APK حقيقي قابل للتحميل المباشر (بدون نشر على Google Play) — مستضاف عبر
// نفس سيرفر الباك اند المحلي (backend/downloads/). لازم يكون الهاتف على نفس
// شبكة الواي فاي متل جهاز السيرفر. لو تغيّر عنوان IP جهازك (Get-NetIPAddress
// بالـ PowerShell)، لازم تحدّثي هاد الرابط.
const String apkDownloadUrl = 'http://192.168.1.4:4000/downloads/nabligo.apk';

class _ExpandedSideBarContent extends StatelessWidget {
  final VoidCallback onCollapse;
  const _ExpandedSideBarContent({required this.onCollapse});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الشعار
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/branding/logo_icon.png',
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NabliGo',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Explore Nablus',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: AppState.instance.t('طي الشريط', 'Collapse sidebar'),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onCollapse,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.cardDark2,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 16,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // معلومات سريعة (طوارئ، أوقات صلاة، هل تعلم، فعالية اليوم)
          QuickInfoSection(),
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
                ContactRow(icon: Icons.phone, text: '+972 59 437 1950'),
                SizedBox(height: 10),
                ContactRow(icon: Icons.email, text: 'nabligo860@gmail.com'),
                SizedBox(height: 10),
                ContactRow(icon: Icons.location_on, text: 'Nablus, Palestine'),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SocialIcon(
                      icon: Icons.facebook,
                      url:
                          'https://www.facebook.com/share/1PEdrJJzja/?mibextid=wwXIfr',
                    ),
                    SocialIcon(
                      icon: Icons.camera_alt,
                      url:
                          'https://www.instagram.com/m.aseedeh?igsh=MTFpdXI2eHU4ajk5cw%3D%3D&utm_source=qr',
                    ),
                  ],
                ),
                SizedBox(height: 12),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ContactUsScreen()),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: AppColors.glowShadow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          AppState.instance.t('أرسل رسالة', 'Send a Message'),
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
                  onTap: () => launchUrl(
                    Uri.parse(apkDownloadUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                SizedBox(height: 8),
                StoreButton(
                  icon: Icons.apple,
                  line1: 'Download on the',
                  line2: 'App Store',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppState.instance.t(
                          'نسخة الآيفون قريبًا — بتحتاج حساب مطوّر آبل مدفوع',
                          'iPhone version coming soon — requires a paid Apple developer account',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14),
                GestureDetector(
                  onTap: () => launchUrl(
                    Uri.parse(apkDownloadUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Container(
                    height: 90,
                    width: 90,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: QrImageView(
                      data: apkDownloadUrl,
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppState.instance.t(
                    'صوّري الرمز أو اضغطي الزر لتحميل ملف APK حقيقي مباشرة — لازم هاتفك يكون على نفس شبكة الواي فاي متل هاد الجهاز',
                    'Scan the code or tap the button to download a real APK directly — your phone must be on the same Wi-Fi network as this device',
                  ),
                  textDirection: AppState.instance.dir,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 10, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SideCard extends StatelessWidget {
  final Widget child;
  const SideCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.all(12),
      radius: 12,
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

class ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const ContactRow({super.key, required this.icon, required this.text});

  Future<void> _onTap(BuildContext context) async {
    if (icon == Icons.phone) {
      final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
      await _launchExternalUrl('https://wa.me/$digits');
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

/// يفتح رابط خارجي (واتساب/سوشال ميديا) بأمان على الويب — وضع
/// LaunchMode.externalApplication على الويب بيستخدم window.open() تحت
/// الغطا، ومتصفح Chrome (خصوصًا بنافذة --app بدون شريط عنوان) بيحجبه بصمت
/// كـ popup بدون أي إشعار للمستخدم. الوضع الافتراضي بيحاكي ضغطة رابط حقيقية
/// (target=_blank) فما بينحجب، وبيضل يفتح تطبيق خارجي حقيقي على أندرويد/iOS.
Future<void> _launchExternalUrl(String url) {
  return launchUrl(
    Uri.parse(url),
    mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
  );
}

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;
  const SocialIcon({super.key, required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _launchExternalUrl(url),
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
  final VoidCallback? onTap;
  const StoreButton({
    super.key,
    required this.icon,
    required this.line1,
    required this.line2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
        icon: Icons.home_rounded,
        active: true,
      ),
      NavItem(
        iconAr: 'استكشف',
        iconEn: 'Explore',
        icon: Icons.explore_rounded,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => ExploreScreen())),
      ),
      NavItem(
        iconAr: 'الخريطة',
        iconEn: 'Map',
        icon: Icons.map_rounded,
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
        icon: Icons.article_rounded,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => NewsScreen())),
      ),
      NavItem(
        iconAr: 'المساعد الذكي',
        iconEn: 'AI Assistant',
        icon: Icons.auto_awesome_rounded,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => AiAssistantScreen())),
      ),
    ];
    // بكل المنصات (هاتف وويب وويندوز): جرس الإشعارات + زر إعدادات واحد يفتح
    // لوحة "زي الأندرويد" (الوضع الليلي/اللغة/الحساب/تسجيل الخروج مجمّعين هناك)
    // بدل أيقونات متفرقة بالشريط العلوي.
    final trailingControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NotificationBell(),
        SizedBox(width: mobile ? 14 : 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => showSettingsSheet(context),
          child: Icon(
            Icons.settings_rounded,
            size: 22,
            color: AppColors.textWhite,
          ),
        ),
      ],
    );

    if (mobile) {
      // على الهاتف: Drawer يسار + لوجو + إشعارات وزر إعدادات يمين.
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: AppColors.sidebarDark,
        child: Row(
          children: [
            if (onMenuTap != null)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onMenuTap,
                child: Icon(
                  Icons.menu_rounded,
                  size: 22,
                  color: AppColors.textWhite,
                ),
              ),
            SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/branding/logo_icon.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'NabliGo',
              style: AppTypography.title(
                AppColors.textWhite,
              ).copyWith(fontSize: 16),
            ),
            Spacer(),
            trailingControls,
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      color: AppColors.sidebarDark,
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: AppColors.textGrey),
          SizedBox(width: 6),
          Text(
            app.currentTime,
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: navItems,
            ),
          ),
          SizedBox(width: 16),
          trailingControls,
        ],
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

class NavItem extends StatefulWidget {
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
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final color = widget.active ? AppColors.primary : AppColors.textGrey;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _hovering
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 18, color: color),
                SizedBox(height: 2),
                Text(
                  app.t(widget.iconAr, widget.iconEn),
                  textDirection: app.dir,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.only(top: 3),
                  height: 2,
                  width: widget.active ? 20 : 0,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
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
      'title': '🏛 اكتشف نابلس',
      'subtitle': 'مدينة التاريخ... والطعام... والثقافة',
      'titleEn': '🏛 Discover Nablus',
      'subtitleEn': 'A City of History... Food... and Culture',
      'photoQuery': 'nablus palestine cityscape',
      'localAsset': 'assets/images/banner/nablus_cityscape.jpg',
    },
    {
      'title': '🕌 اكتشف البلدة القديمة',
      'subtitle': 'أزقة تحمل قصص آلاف السنين',
      'titleEn': '🕌 Discover the Old City',
      'subtitleEn': 'Alleys That Hold Thousand-Year Stories',
      'photoQuery': 'old town stone alley',
      'localAsset': 'assets/images/banner/old_city_alley.jpg',
    },
    {
      'title': '🍽 نكهات نابلس الأصيلة',
      'subtitle': 'الكنافة النابلسية وأشهى المأكولات',
      'titleEn': '🍽 Authentic Nablus Flavors',
      'subtitleEn': 'Nabulsi Kunafa and the Finest Dishes',
      'photoQuery': 'kunafa dessert',
      'localAsset': 'assets/images/banner/kunafa.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final bannerHeight = mobile ? 200.0 : 240.0;
    return Padding(
      padding: EdgeInsets.all(mobile ? 14 : 20),
      child: SizedBox(
        height: bannerHeight,
        child: Stack(
          children: [
            CarouselSlider.builder(
              carouselController: _controller,
              itemCount: _slides.length,
              options: CarouselOptions(
                height: bannerHeight,
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
                        localAsset: slide['localAsset'],
                        fallbackSeed: 'banner-${slide['titleEn']}',
                        height: bannerHeight,
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
                              style: AppTypography.display(Colors.white)
                                  .copyWith(
                                    fontSize: mobile ? 28 : 26,
                                    height: 1.15,
                                  ),
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
                                  app.t('ابدأ الاستكشاف', 'Start Exploring'),
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
              top: bannerHeight / 2 - 17,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _controller.previousPage(),
                child: _arrowButton(Icons.chevron_left),
              ),
            ),
            Positioned(
              right: 12,
              top: bannerHeight / 2 - 17,
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
              SizedBox(width: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ExploreScreen()),
                ),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.cardDark2,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: AppColors.textGrey,
                    size: 17,
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

  static const _weekdaysAr = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  static const _weekdaysEn = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _monthsAr = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  static const _monthsEn = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String _formattedDate(bool arabic) {
    final now = DateTime.now();
    final weekday = arabic
        ? _weekdaysAr[now.weekday - 1]
        : _weekdaysEn[now.weekday - 1];
    final month = arabic ? _monthsAr[now.month - 1] : _monthsEn[now.month - 1];
    return arabic
        ? '$weekday، ${now.day} $month ${now.year}'
        : '$weekday, $month ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    const weatherCard = _WeatherStatCard();
    const visitorsCard = _VisitorsStatCard();
    final timeCard = _TimeStatCard(
      dateText: _formattedDate(AppState.instance.isArabic),
    );

    if (mobile) {
      // بعرض الهاتف: تمرير أفقي بعرض ثابت لكل بطاقة حتى ما ينقص النص أبدًا
      return SizedBox(
        height: 124,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
          scrollDirection: Axis.horizontal,
          children: [
            SizedBox(width: 240, child: weatherCard),
            SizedBox(width: 14),
            SizedBox(width: 190, child: visitorsCard),
            SizedBox(width: 14),
            SizedBox(width: 200, child: timeCard),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      // IntrinsicHeight بدل Row.crossAxisAlignment.stretch — الأخيرة بتحتاج
      // ارتفاع محدود من الأب عشان "تمدّد" له، لكن هون الـ Row جوّا عمود
      // بيتمرّر (SingleChildScrollView) يعطيه ارتفاع غير محدود (infinity)،
      // وتمديد لارتفاع لانهائي بيرمي RenderFlex exception بصمت وبيوقف رسم
      // كل اللي بعده بالصفحة. IntrinsicHeight بتقيس أطول بطاقة فعليًا
      // وبتدي الكل نفس الارتفاع المحدود هذا، فبتحقق نفس التناسق بأمان.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: weatherCard),
            SizedBox(width: 14),
            Expanded(child: visitorsCard),
            SizedBox(width: 14),
            Expanded(child: timeCard),
          ],
        ),
      ),
    );
  }
}

class _WeatherStatCard extends StatelessWidget {
  const _WeatherStatCard();

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final weather = app.weather;
    final tempText = app.weatherLoading
        ? '--'
        : weather == null
        ? app.t('غير متاح', 'N/A')
        : '${weather.temperature.round()}°';
    final condition = app.weatherLoading
        ? app.t('جارِ التحميل...', 'Loading...')
        : weather == null
        ? ''
        : (app.isArabic
              ? weatherConditionFor(weather.weatherCode).descriptionAr
              : weatherConditionFor(weather.weatherCode).descriptionEn);

    return GlassContainer(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => WeatherScreen())),
      padding: EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.wb_sunny_rounded,
              color: AppColors.gold,
              size: 22,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  app.t('الطقس الآن', 'Weather Now'),
                  textDirection: app.dir,
                  style: AppTypography.caption(AppColors.textGrey),
                ),
                Text(
                  tempText,
                  style: AppTypography.title(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 21, fontWeight: FontWeight.w800),
                ),
                if (condition.isNotEmpty)
                  Text(
                    condition,
                    textDirection: app.dir,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption(AppColors.textGrey),
                  ),
              ],
            ),
          ),
          if (weather != null) ...[
            SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _WeatherMiniStat(
                  value: '${weather.humidity}%',
                  label: app.t('الرطوبة', 'Humidity'),
                ),
                SizedBox(height: 5),
                _WeatherMiniStat(
                  value: '${weather.windSpeed.round()}',
                  label: app.t('كم/س الرياح', 'km/h Wind'),
                ),
                SizedBox(height: 5),
                _WeatherMiniStat(
                  value: '${weather.uvIndex.round()}',
                  label: app.t('مؤشر UV', 'UV Index'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WeatherMiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _WeatherMiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          textDirection: app.dir,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.textGrey, fontSize: 8.5),
        ),
      ],
    );
  }
}

class _VisitorsStatCard extends StatelessWidget {
  const _VisitorsStatCard();

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final count = app.visitorCount;
    return GlassContainer(
      padding: EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.people_rounded,
              color: AppColors.purple,
              size: 22,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  app.t('إجمالي الزوار الآن', 'Total Visitors Now'),
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(AppColors.textGrey),
                ),
                Text(
                  count == null
                      ? app.t('غير متاح', 'N/A')
                      : NumberFormat.decimalPattern().format(count),
                  style: AppTypography.title(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 21, fontWeight: FontWeight.w800),
                ),
                Text(
                  app.t('مستخدم نشط', 'active users'),
                  textDirection: app.dir,
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

class _TimeStatCard extends StatelessWidget {
  final String dateText;
  const _TimeStatCard({required this.dateText});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return GlassContainer(
      padding: EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.access_time_filled_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  app.t('الوقت الآن', 'Current Time'),
                  textDirection: app.dir,
                  style: AppTypography.caption(AppColors.textGrey),
                ),
                Text(
                  app.currentTime,
                  style: AppTypography.title(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  dateText,
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
    return GlassContainer(
      onTap: onTap,
      padding: EdgeInsets.all(16),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          SizedBox(width: 12),
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
                  ).copyWith(fontSize: 22, fontWeight: FontWeight.w800),
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
    },
    {'labelAr': 'فنادق', 'labelEn': 'Hotels', 'icon': Icons.bed_rounded},
    {
      'labelAr': 'معالم',
      'labelEn': 'Attractions',
      'icon': Icons.mosque_rounded,
    },
    {
      'labelAr': 'تسوق',
      'labelEn': 'Shopping',
      'icon': Icons.shopping_bag_rounded,
    },
    {
      'labelAr': 'مواصلات',
      'labelEn': 'Transport',
      'icon': Icons.directions_bus_rounded,
    },
    {'labelAr': 'صحة', 'labelEn': 'Health', 'icon': Icons.favorite_rounded},
    {
      'labelAr': 'صيدليات',
      'labelEn': 'Pharmacies',
      'icon': Icons.local_pharmacy_rounded,
    },
    {
      'labelAr': 'خدمات حكومية',
      'labelEn': 'Gov Services',
      'icon': Icons.account_balance_rounded,
    },
    {'labelAr': 'المزيد', 'labelEn': 'More', 'icon': Icons.grid_view_rounded},
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
                          (item) => _HomeCategoryIcon(
                            labelAr: item['labelAr'],
                            labelEn: item['labelEn'],
                            icon: item['icon'],
                            onTap: () => _onCategoryTap(
                              context,
                              item['labelAr'] as String,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: items
                      .map(
                        (item) => _HomeCategoryIcon(
                          labelAr: item['labelAr'],
                          labelEn: item['labelEn'],
                          icon: item['icon'],
                          onTap: () => _onCategoryTap(
                            context,
                            item['labelAr'] as String,
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
    } else if (label == 'معالم') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => AttractionCategoriesScreen()),
      );
    } else if (label == 'تسوق') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ShoppingCategoriesScreen()),
      );
    } else if (label == 'مواصلات') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => TransportScreen()));
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

/// أيقونة تصنيف دائرية بسيطة (بدون صورة) — لصف "التصنيفات" بالصفحة الرئيسية
/// فقط، بلون كهرماني موحّد لكل الأيقونات بدل تلوين مختلف لكل تصنيف، مطابقةً
/// لهوية الثيم الكحلي/الكهرماني المطلوبة. شاشة "استكشف" لسا بتستخدم
/// [CategoryTile] القديمة (بطاقة صورة) لأنها سياق تصفّح مختلف.
class _HomeCategoryIcon extends StatefulWidget {
  final String labelAr;
  final String labelEn;
  final IconData icon;
  final VoidCallback? onTap;
  const _HomeCategoryIcon({
    required this.labelAr,
    required this.labelEn,
    required this.icon,
    this.onTap,
  });

  @override
  State<_HomeCategoryIcon> createState() => _HomeCategoryIconState();
}

class _HomeCategoryIconState extends State<_HomeCategoryIcon> {
  bool _pressed = false;
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.92 : (_hovering ? 1.05 : 1.0),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: SizedBox(
            width: 76,
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cardDark2,
                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: _hovering ? 0.55 : 0.25,
                      ),
                    ),
                  ),
                  child: Icon(widget.icon, color: AppColors.primary, size: 24),
                ),
                SizedBox(height: 8),
                Text(
                  app.t(widget.labelAr, widget.labelEn),
                  textDirection: app.dir,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(
                    AppColors.textWhite,
                  ).copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryTile extends StatefulWidget {
  final String labelAr;
  final String labelEn;
  final IconData icon;
  final Color color;
  final String? photoQuery;
  final String?
  localAsset; // صورة ثابتة رفعها الأدمن يدويًا — لو موجودة ما تتغيّر ديناميكيًا
  final String?
  serverImageUrl; // صورة تصنيف رفعها الأدمن من لوحة التحكم — لها الأولوية على الافتراضية
  final int? count; // عدد الأماكن الحقيقي بهذا التصنيف (لو معروف)
  final VoidCallback? onTap;
  const CategoryTile({
    super.key,
    required this.labelAr,
    required this.labelEn,
    required this.icon,
    required this.color,
    this.photoQuery,
    this.localAsset,
    this.serverImageUrl,
    this.count,
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
                    if (widget.serverImageUrl != null ||
                        widget.localAsset != null ||
                        widget.photoQuery != null)
                      ThemedImage(
                        query: widget.photoQuery ?? 'nablus palestine city',
                        localAsset: widget.serverImageUrl == null
                            ? widget.localAsset
                            : null,
                        serverImageUrl: widget.serverImageUrl,
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
              if (widget.count != null) ...[
                SizedBox(height: 2),
                Text(
                  app.t('${widget.count} مكان', '${widget.count} places'),
                  textDirection: app.dir,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption(
                    AppColors.textGrey,
                  ).copyWith(fontSize: 9.5),
                ),
              ],
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
        SizedBox(width: 8),
        Expanded(
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 18)),
                SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  title,
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headline(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
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
                  sortMode: PlacesSortMode.favorites,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VisitHistoryScreen(),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: app.dir,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 13,
                      color: AppColors.textGrey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      app.t('سجل الزيارات', 'Visit History'),
                      textDirection: app.dir,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                    ),
                  ],
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
                      'اضغط على أيقونة القلب بأي مكان لإضافته هنا',
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
      radius: AppRadius.xl,
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
                height: 140,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
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
                      Flexible(
                        child: Text(
                          app.t('مشاركة برمز QR', 'Share via QR'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption(AppColors.primary),
                        ),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/branding/logo_icon.png',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NabliGo',
                  textDirection: app.dir,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  app.t('استكشف نابلس', 'Explore Nablus'),
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
        ContactRow(icon: Icons.phone, text: '+972 59 437 1950'),
        SizedBox(height: 8),
        ContactRow(icon: Icons.email, text: 'nabligo860@gmail.com'),
        SizedBox(height: 8),
        ContactRow(icon: Icons.location_on, text: 'Nablus, Palestine'),
        SizedBox(height: 10),
        Row(
          children: [
            SocialIcon(
              icon: Icons.facebook,
              url: 'https://www.facebook.com/share/1PEdrJJzja/?mibextid=wwXIfr',
            ),
            SocialIcon(
              icon: Icons.camera_alt,
              url:
                  'https://www.instagram.com/m.aseedeh?igsh=MTFpdXI2eHU4ajk5cw%3D%3D&utm_source=qr',
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
