import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// شكل نابض (pulse) بديل عن CircularProgressIndicator أثناء تحميل قوائم
/// الأماكن — يعطي إحساس أسرع بالتحميل من مؤشر دوّار وحيد بمنتصف الشاشة.
class SkeletonPulse extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  const SkeletonPulse({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(AppColors.cardDark2, AppColors.borderColor, t),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

/// بطاقة هيكلية بديلة لبطاقة مكان أثناء التحميل، بنفس أبعاد بطاقة الشبكة
/// تقريبًا (صورة + سطرين نص + تقييم) حتى ما تقفز الواجهة لما توصل البيانات.
class SkeletonCard extends StatelessWidget {
  final bool isGridView;
  const SkeletonCard({super.key, this.isGridView = true});

  @override
  Widget build(BuildContext context) {
    if (!isGridView) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SkeletonPulse(width: 64, height: 64, borderRadius: BorderRadius.circular(8)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonPulse(height: 12),
                  SizedBox(height: 8),
                  SkeletonPulse(width: 100, height: 10),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonPulse(height: 100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
        const SizedBox(height: 8),
        const SkeletonPulse(height: 12),
        const SizedBox(height: 6),
        const SkeletonPulse(width: 80, height: 10),
      ],
    );
  }
}

/// شبكة/قائمة بطاقات هيكلية (عدد قابل للتخصيص) — تُستخدم بمكان
/// CircularProgressIndicator أثناء أول تحميل لأي شاشة تصنيف.
class SkeletonGrid extends StatelessWidget {
  final bool isGridView;
  final int count;
  const SkeletonGrid({super.key, this.isGridView = true, this.count = 6});

  @override
  Widget build(BuildContext context) {
    if (!isGridView) {
      return Column(
        children: List.generate(count, (i) => SkeletonCard(isGridView: false)),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, i) => const SkeletonCard(),
    );
  }
}
