import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart'; // تأكدي من صحة المسار لملف السبلاش عندكِ

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دليل نابلس السياحي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Tajawal',
        scaffoldBackgroundColor: const Color(0xFFF8FAF9),
      ),
      // تشغيل صفحة السبلاش كأول شاشة في التطبيق
      home: const SplashScreen(), 
    );
  }
}