import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'services/local_db_service.dart';
import 'services/auth_service.dart';
import 'services/data_converters.dart';
import 'screens/category/category_data.dart';
import 'screens/restaurants/restaurants_screen.dart' show restaurantsSeedData;
import 'screens/news/news_screen.dart' show newsSeedData;
import 'theme/app_theme.dart';
// import 'screens/splash/splash_screen.dart'; // فعّلها إذا بدك تبدأ بشاشة Splash

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDbService.instance.init(); // تهيئة قاعدة البيانات المحلية (Hive)
  await _seedAllBoxes(); // نعبّي كل الصناديق مبكرًا حتى الشاشات المجمّعة (استكشف/المساعد الذكي) تشوف بيانات الأدمن فورًا
  AuthService.instance.restoreSession(); // نسترجع جلسة الدخول المحفوظة حتى ما نرجع لتسجيل الدخول بعد تحديث الصفحة
  runApp(const NablusGuideApp());
}

Widget _resolveStartScreen() {
  final auth = AuthService.instance;
  if (auth.isAdmin) return AdminHomeScreen();
  if (auth.hasRestoredSession) return HomeScreen();
  return LoginScreen();
}

/// تعبئة كل صناديق البيانات ببياناتها الابتدائية أول مرة فقط (لو كانت فاضية)،
/// حتى تعمل الشاشات اللي بتجمع بيانات من كل الأقسام معًا (استكشف، المساعد الذكي،
/// الأماكن المفضلة/الأكثر زيارة/أحدث الأماكن) بدون انتظار زيارة كل قسم بشكل منفصل.
Future<void> _seedAllBoxes() async {
  final db = LocalDbService.instance;
  await db.seedIfEmpty('hotels', hotelsData.map(listingToMap).toList());
  await db.seedIfEmpty('attractions', attractionsData.map(listingToMap).toList());
  await db.seedIfEmpty('shopping', shoppingData.map(listingToMap).toList());
  await db.seedIfEmpty('transport', transportData.map(listingToMap).toList());
  await db.seedIfEmpty('health', healthData.map(listingToMap).toList());
  await db.seedIfEmpty('pharmacies', pharmaciesData.map(listingToMap).toList());
  await db.seedIfEmpty('education', educationData.map(listingToMap).toList());
  await db.seedIfEmpty('banks', banksData.map(listingToMap).toList());
  await db.seedIfEmpty('entertainment', entertainmentData.map(listingToMap).toList());
  await db.seedIfEmpty('government', governmentData.map(listingToMap).toList());
  await db.seedIfEmpty('restaurants', restaurantsSeedData.map(restaurantToMap).toList());
  await db.seedIfEmpty('news', newsSeedData.map(newsToMap).toList());
}

class NablusGuideApp extends StatelessWidget {
  const NablusGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دليل نابلس الذكي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      // نقطة البداية: تعتمد على وجود جلسة دخول محفوظة من قبل (استرجعناها بأول main())
      home: _resolveStartScreen(),
    );
  }
}
