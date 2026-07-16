import 'dart:async';
import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../admin/admin_screen.dart';
import '../auth/login_screen.dart';
import '../../services/auth_service.dart';
import '../../theme/app_typography.dart';

/// شاشة البداية (Splash) — أول شي يشوفه أي زائر لحظة فتح التطبيق، قبل ما نحدد
/// وين بالضبط رح نوديه (تسجيل دخول / الرئيسية / لوحة الأدمن حسب جلسته المحفوظة).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _bgController;
  late final Animation<Offset> _bgMovementOne;
  late final Animation<Offset> _bgMovementTwo;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
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

    _navTimer = Timer(const Duration(milliseconds: 2400), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final auth = AuthService.instance;
    final Widget next = auth.isAdmin
        ? const AdminHomeScreen()
        : (auth.hasRestoredSession ? HomeScreen() : const LoginScreen());
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => next));
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _fadeController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return Directionality(
          textDirection: app.dir,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: Stack(
              children: [
                // كتل ضوء متحركة بألوان هوية التطبيق (كهرماني ← برتقالي ← مرجاني)
                AnimatedBuilder(
                  animation: _bgController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Transform.translate(
                          offset: _bgMovementOne.value * 140,
                          child: Container(
                            width: 340,
                            height: 340,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.16),
                                  AppColors.primary.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Transform.translate(
                            offset: _bgMovementTwo.value * 140,
                            child: Container(
                              width: 380,
                              height: 380,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.coral.withValues(alpha: 0.14),
                                    AppColors.coral.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SafeArea(
                  child: Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.primaryGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xl,
                                ),
                                boxShadow: AppColors.glowShadow,
                              ),
                              child: const Icon(
                                Icons.location_city_rounded,
                                color: Colors.white,
                                size: 54,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              app.t('دليل نابلس الذكي', 'Nablus Smart Guide'),
                              textDirection: app.dir,
                              textAlign: TextAlign.center,
                              style: AppTypography.display(
                                AppColors.textWhite,
                              ).copyWith(fontSize: 26),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              app.t(
                                'دليلك السياحي الذكي لمدينة نابلس',
                                'Your smart travel guide to Nablus',
                              ),
                              textDirection: app.dir,
                              textAlign: TextAlign.center,
                              style: AppTypography.body(
                                AppColors.textGrey,
                              ).copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 48),
                            SizedBox(
                              width: 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 4,
                                  child: LinearProgressIndicator(
                                    backgroundColor: AppColors.cardDark2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
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
          ),
        );
      },
    );
  }
}
