import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  late AnimationController _bgController;
  late Animation<Offset> _bgMovementOne;
  late Animation<Offset> _bgMovementTwo;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _bgMovementOne = Tween<Offset>(
      begin: const Offset(-0.15, -0.08),
      end: const Offset(0.15, 0.08),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _bgMovementTwo = Tween<Offset>(
      begin: const Offset(0.08, 0.15),
      end: const Offset(-0.08, -0.15),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _fadeController.forward();

    Timer(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6C5CE7); 
    final accentColor = const Color(0xFFFF7675);  
    final textColor = const Color(0xFF2D3436); 

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC), 
      body: Stack(
        children: [
          // 1️⃣ تدرج ألوان الخلفية الأساسي المعمق
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withValues(alpha: 0.08),
                    const Color(0xFFF4F6FC),
                    accentColor.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
          ),

          // 2️⃣ شبكة الخطوط الهندسية لملء الفراغ (Smart Grid)
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: GridPaper(
                color: primaryColor,
                divisions: 2,
                subdivisions: 2,
                interval: 100,
              ),
            ),
          ),

          // 3️⃣ الدوائر الشفقية الضخمة المتحركة لتعطي حيوية للمتصفح
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Stack(
                children: [
                  Transform.translate(
                    offset: _bgMovementOne.value * 120,
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Transform.translate(
                      offset: _bgMovementTwo.value * 120,
                      child: Container(
                        width: 380,
                        height: 380,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // 4️⃣ فلتر تنعيم الخلفية الشفقي
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), 
              child: const SizedBox.shrink(),
            ),
          ),

          // 5️⃣ محتوى الشاشة الأمامي داخل بطاقة زجاجية فخمة
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
  margin: const EdgeInsets.symmetric(horizontal: 24),
  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
  constraints: const BoxConstraints(maxWidth: 450), // 👈 التعديل الصحيح هنا
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: 0.65),
    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.05),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // أيقونة البوصلة ومحيطها مؤشر تحميل دائري ناعم
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor.withValues(alpha: 0.3)),
                              strokeWidth: 2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white, 
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  blurRadius: 25,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [primaryColor, accentColor],
                              ).createShader(bounds),
                              child: const Icon(
                                Icons.explore_rounded, 
                                size: 65, 
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // اسم المشروع المتدرج الفخم "دَلِيلْ"
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primaryColor, accentColor],
                        ).createShader(bounds),
                        child: const Text(
                          'دَلِيلْ',
                          style: TextStyle(
                            fontSize: 56, 
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: 'Tajawal',
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // شعار التطبيق النصي الجديد
                      Text(
                        'حيث تلتقي عراقة التاريخ بذكاء المستقبل',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600, 
                          color: textColor.withValues(alpha: 0.8), 
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // شريط التحميل الأفقي الأنيق بأسفل البطاقة
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 4,
                            child: LinearProgressIndicator(
                              backgroundColor: primaryColor.withValues(alpha: 0.08),
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor.withValues(alpha: 0.7)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Text(
                        'جاري تهيئة دليلك الذكي...',
                        style: TextStyle(
                          fontSize: 11, 
                          fontWeight: FontWeight.bold,
                          color: textColor.withValues(alpha: 0.4), 
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
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