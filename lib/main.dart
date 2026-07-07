import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/local_db_service.dart';
// import 'screens/splash/splash_screen.dart'; // فعّلها إذا بدك تبدأ بشاشة Splash

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDbService.instance.init(); // تهيئة قاعدة البيانات المحلية (Hive)
  runApp(const NablusGuideApp());
}

class NablusGuideApp extends StatelessWidget {
  const NablusGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دليل نابلس الذكي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        fontFamily: 'Tajawal',
      ),
      // نقطة البداية الآن: شاشة تسجيل الدخول
      home: LoginScreen(),
    );
  }
}