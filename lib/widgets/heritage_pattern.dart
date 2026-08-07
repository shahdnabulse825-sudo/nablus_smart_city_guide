import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// خلفية Gradient داكنة ناعمة خلف محتوى الصفحة — بديل عن الخلفية المزخرفة
/// السابقة، أهدأ للعين وأقرب لهوية تطبيقات السفر الحديثة.
class HeritagePatternBackground extends StatelessWidget {
  final Widget child;
  const HeritagePatternBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.4,
                colors: [
                  AppColors.cardDark2.withValues(alpha: 0.55),
                  AppColors.bgDark,
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
