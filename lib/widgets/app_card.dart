import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// بطاقة موحّدة لكل المشروع: حواف دائرية، ظل ناعم، وتأثير ضغط/تحويم (Hover)
/// خفيف عند التفاعل — بدل الـ Container العادي المكرّر بكل شاشة.
class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? color;
  final Border? border;
  final Clip clipBehavior;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.radius = AppRadius.lg,
    this.color,
    this.border,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.97 : (_hovering ? 1.015 : 1.0);
    final card = AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: widget.padding,
        clipBehavior: widget.clipBehavior,
        decoration: BoxDecoration(
          color: widget.color ?? AppColors.cardDark,
          borderRadius: BorderRadius.circular(widget.radius),
          border: widget.border ?? Border.all(color: AppColors.borderColor),
          boxShadow: _hovering ? AppColors.glowShadow : AppColors.cardShadow,
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return card;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: card,
      ),
    );
  }
}
