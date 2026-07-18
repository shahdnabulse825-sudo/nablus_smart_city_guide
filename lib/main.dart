import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/local_db_service.dart';
import 'services/auth_service.dart';
import 'services/data_converters.dart';
import 'services/api_service.dart';
import 'screens/category/category_data.dart';
import 'screens/restaurants/restaurants_screen.dart' show restaurantsSeedData;
import 'screens/hotels/hotels_screen.dart' show hotelsSeedData;
import 'screens/pharmacies/pharmacies_screen.dart' show pharmaciesSeedData;
import 'screens/attractions/attractions_screen.dart' show attractionsSeedData;
import 'screens/shopping/shopping_screen.dart' show shoppingVenuesSeedData;
import 'screens/news/news_screen.dart' show newsSeedData;
import 'screens/events/events_data.dart' show eventsData;
import 'screens/home/home_screen.dart' show AppState;
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDbService.instance.init(); // تهيئة قاعدة البيانات المحلية (Hive)
  await _seedAllBoxes(); // نعبّي كل الصناديق مبكرًا حتى الشاشات المجمّعة (استكشف/المساعد الذكي) تشوف بيانات الأدمن فورًا
  AuthService.instance
      .restoreSession(); // نسترجع جلسة الدخول المحفوظة حتى ما نرجع لتسجيل الدخول بعد تحديث الصفحة
  runApp(const NablusGuideApp());
}

/// تعبئة كل صناديق البيانات ببياناتها الابتدائية أول مرة فقط (لو كانت فاضية)،
/// حتى تعمل الشاشات اللي بتجمع بيانات من كل الأقسام معًا (استكشف، المساعد الذكي،
/// الأماكن المفضلة/الأكثر زيارة/أحدث الأماكن) بدون انتظار زيارة كل قسم بشكل منفصل.
Future<void> _seedAllBoxes() async {
  final db = LocalDbService.instance;
  await db.syncSeed('hotels', hotelsSeedData.map(hotelToMap).toList());
  await db.syncSeed(
    'attractions',
    attractionsSeedData.map(attractionToMap).toList(),
  );
  await db.syncSeed(
    'shopping',
    shoppingVenuesSeedData.map(shoppingVenueToMap).toList(),
  );
  await db.seedIfEmpty('transport', transportData.map(listingToMap).toList());
  await db.seedIfEmpty('health', healthData.map(listingToMap).toList());
  await db.syncSeed(
    'pharmacies',
    pharmaciesSeedData.map(pharmacyToMap).toList(),
  );
  await db.seedIfEmpty('education', educationData.map(listingToMap).toList());
  await db.seedIfEmpty('banks', banksData.map(listingToMap).toList());
  await db.seedIfEmpty(
    'entertainment',
    entertainmentData.map(listingToMap).toList(),
  );
  await db.seedIfEmpty('government', governmentData.map(listingToMap).toList());
  await db.syncSeed(
    'restaurants',
    restaurantsSeedData.map(restaurantToMap).toList(),
  );
  await db.seedIfEmpty('news', newsSeedData.map(newsToMap).toList());
  await db.seedIfEmpty('events', eventsData.map(eventToMap).toList());

  // نحاول نجيب أحدث بيانات من سيرفر الباك اند الحقيقي (backend/) لو كان شغال —
  // ولو مو شغال/بدون إنترنت، بتنلقط بصمت ونكمل بالبيانات المحلية فوق بدون أي مشكلة.
  await ApiService.syncHotels();
  await ApiService.syncRestaurants();
  await ApiService.syncPharmacies();
  await ApiService.syncAttractions();
  await ApiService.syncShopping();
  await ApiService.syncNews();
  await ApiService.syncEvents();
  await AppState.instance.incrementVisitorCount();
}

class NablusGuideApp extends StatelessWidget {
  const NablusGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دليل نابلس الذكي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      // نخلي أسهم لوح المفاتيح (فوق/تحت) تمرّر الصفحة فعليًا (متل أي موقع ويب عادي)
      // بدل السلوك الافتراضي بفلاتر اللي بينقّل التركيز بين الأزرار بس.
      shortcuts: <ShortcutActivator, Intent>{
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.arrowDown): const ScrollIntent(
          direction: AxisDirection.down,
        ),
        const SingleActivator(LogicalKeyboardKey.arrowUp): const ScrollIntent(
          direction: AxisDirection.up,
        ),
        const SingleActivator(LogicalKeyboardKey.pageDown): const ScrollIntent(
          direction: AxisDirection.down,
          type: ScrollIncrementType.page,
        ),
        const SingleActivator(LogicalKeyboardKey.pageUp): const ScrollIntent(
          direction: AxisDirection.up,
          type: ScrollIncrementType.page,
        ),
      },
      // نضمن إنه في دايمًا عنصر عليه تركيز من أول ما تفتح الصفحة، حتى الأسهم
      // تشتغل فورًا بدون ما تحتاج تكبسي بالصفحة قبل.
      builder: (context, child) => Focus(autofocus: true, child: child!),
      // نقطة البداية: شاشة Splash دايمًا أول شي، وهي بدورها بتقرر (بعد فترة قصيرة)
      // تسجيل دخول/الرئيسية/لوحة الأدمن حسب جلسة الدخول المحفوظة (استرجعناها بأول main())
      home: const SplashScreen(),
    );
  }
}
