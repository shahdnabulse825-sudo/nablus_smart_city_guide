import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// يفتح الصورة بحجم كامل مع إمكانية التكبير/التصغير باللمس، ويُغلق بالضغط
/// على الخلفية أو زر الإغلاق. استخدميها بأي مكان عندك فيه ThemedImage رئيسية
/// (بانر، صورة تفاصيل) لإتاحة "اضغط لتكبير الصورة".
void showImageZoom(
  BuildContext context, {
  required String query,
  required String fallbackSeed,
  String? customImageBase64,
  String? localAsset,
  String? serverImageUrl,
  IconData fallbackIcon = Icons.image,
  Color fallbackColor = const Color(0xFF6C5CE7),
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (context, animation, _) => FadeTransition(
        opacity: animation,
        child: _ImageZoomScreen(
          query: query,
          fallbackSeed: fallbackSeed,
          customImageBase64: customImageBase64,
          localAsset: localAsset,
          serverImageUrl: serverImageUrl,
          fallbackIcon: fallbackIcon,
          fallbackColor: fallbackColor,
        ),
      ),
    ),
  );
}

class _ImageZoomScreen extends StatelessWidget {
  final String query;
  final String fallbackSeed;
  final String? customImageBase64;
  final String? localAsset;
  final String? serverImageUrl;
  final IconData fallbackIcon;
  final Color fallbackColor;
  const _ImageZoomScreen({
    required this.query,
    required this.fallbackSeed,
    this.customImageBase64,
    this.localAsset,
    this.serverImageUrl,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).maybePop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: GestureDetector(
                  onTap: () {}, // تمتص الضغطة حتى ما تغلق الصورة نفسها عند اللمس
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: ThemedImage(
                      query: query,
                      fallbackSeed: fallbackSeed,
                      height: MediaQuery.sizeOf(context).height,
                      customImageBase64: customImageBase64,
                      localAsset: localAsset,
                      serverImageUrl: serverImageUrl,
                      fallbackIcon: fallbackIcon,
                      fallbackColor: fallbackColor,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 44,
              right: 16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ودجت يعرض صورة حقيقية مرتبطة بموضوع معيّن (query)، مثلاً "mosque" أو "burger".
/// لو الأدمن رفع صورة مخصّصة لهذا العنصر (customImageBase64) فهذي تُعرض دائمًا أولاً.
/// وإلا يجرّب صورة حقيقية من الإنترنت، وإذا فشلت كلها، بيعرض أيقونة ولون مميز.
class ThemedImage extends StatefulWidget {
  final String
  query; // الكلمة المفتاحية بالإنجليزي، مثلاً "mosque", "burger", "hotel exterior"
  final String fallbackSeed; // اسم فريد يُستخدم كـ seed للصورة البديلة
  final double height;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final String? customImageBase64; // صورة رفعها الأدمن يدويًا لهذا العنصر تحديدًا
  final String? localAsset; // مسار صورة محلية جاهزة بالمشروع (assets/...)
  final String? serverImageUrl; // مسار صورة رفعها الأدمن ومخزّنة على السيرفر (/uploads/...)

  const ThemedImage({
    super.key,
    required this.query,
    required this.fallbackSeed,
    required this.height,
    this.borderRadius,
    this.fallbackIcon = Icons.image,
    this.fallbackColor = const Color(0xFF6C5CE7),
    this.customImageBase64,
    this.localAsset,
    this.serverImageUrl,
  });

  @override
  State<ThemedImage> createState() => _ThemedImageState();
}

class _ThemedImageState extends State<ThemedImage> {
  @override
  Widget build(BuildContext context) {
    Widget content;

    if (widget.customImageBase64 != null && widget.customImageBase64!.isNotEmpty) {
      content = Image.memory(
        base64Decode(widget.customImageBase64!),
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _iconFallback(),
      );
    } else if (widget.localAsset != null && widget.localAsset!.isNotEmpty) {
      content = Image.asset(
        widget.localAsset!,
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _iconFallback(),
      );
    } else if (widget.serverImageUrl != null && widget.serverImageUrl!.isNotEmpty) {
      content = Image.network(
        '${ApiService.baseUrl.replaceAll('/api', '')}${widget.serverImageUrl}',
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _iconFallback(),
      );
    } else {
      content = _iconFallback();
    }

    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: content);
    }
    return content;
  }

  /// ما في محاولة جلب صورة عشوائية من الإنترنت — لو ما رفع الأدمن صورة يدوية
  /// (أو صورة محلية جاهزة بالمشروع)، بيظهر أيقونة ولون مميز بدل صورة غير مرتبطة.
  Widget _iconFallback() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.fallbackColor,
            widget.fallbackColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(widget.fallbackIcon, color: Colors.white, size: 36),
      ),
    );
  }
}
