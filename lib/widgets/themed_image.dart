import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/wikimedia_service.dart';
import '../services/unsplash_service.dart';

/// يفتح الصورة بحجم كامل مع إمكانية التكبير/التصغير باللمس، ويُغلق بالضغط
/// على الخلفية أو زر الإغلاق. استخدمها بأي مكان عندك فيه ThemedImage رئيسية
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
  bool tryRealPhoto = false,
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
          tryRealPhoto: tryRealPhoto,
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
  final bool tryRealPhoto;
  const _ImageZoomScreen({
    required this.query,
    required this.fallbackSeed,
    this.customImageBase64,
    this.localAsset,
    this.serverImageUrl,
    required this.fallbackIcon,
    required this.fallbackColor,
    this.tryRealPhoto = false,
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
                      tryRealPhoto: tryRealPhoto,
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
/// وإلا — فقط لو [tryRealPhoto] مفعّلة — يجرّب صورة حقيقية من Wikimedia Commons.
/// [tryRealPhoto] لازم تُفعّل بس لمعالم حقيقية معروفة بالاسم (query فيه اسم المكان
/// نفسه)، مش لأعمال محلية (مطاعم/فنادق..) اللي مستحيل يكون إلها صور حقيقية هناك —
/// غير هيك بترجع صور عشوائية غير مرتبطة. إذا فشل الجلب أو تعطّل، بيعرض أيقونة ولون.
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
  final bool tryRealPhoto; // فعّليها فقط لمعالم حقيقية معروفة بالاسم (شوف التعليق فوق)

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
    this.tryRealPhoto = false,
  });

  @override
  State<ThemedImage> createState() => _ThemedImageState();
}

class _ThemedImageState extends State<ThemedImage> {
  String? _fetchedUrl;

  bool get _hasOwnImage =>
      (widget.customImageBase64?.isNotEmpty ?? false) ||
      (widget.localAsset?.isNotEmpty ?? false) ||
      (widget.serverImageUrl?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _fetchPhoto();
  }

  @override
  void didUpdateWidget(covariant ThemedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _fetchedUrl = null;
      _fetchPhoto();
    }
  }

  /// يجرّب صورة حقيقية بترتيب أولوية:
  /// 1. Wikimedia بحث دقيق (فقط لو [tryRealPhoto] مفعّلة — لمعالم حقيقية معروفة بالاسم)
  /// 2. Unsplash (لو مفتاحه مُفعّل) — لأي مضمون وصفي عام، مثل فعاليات أو أطباق
  /// 3. Wikimedia بحث عام (بدون أي مفتاح API) — احتياطي أخير لأي مضمون وصفي
  ///    لو Unsplash مش مُفعّل أو فشل، أفضل من عدم عرض أي صورة حقيقية أبدًا
  Future<void> _fetchPhoto() async {
    if (_hasOwnImage || widget.query.isEmpty) return;

    if (widget.tryRealPhoto) {
      final wikiUrl = await WikimediaService.instance.getPhotoUrl(widget.query);
      if (wikiUrl != null) {
        if (mounted) setState(() => _fetchedUrl = wikiUrl);
        return;
      }
    }

    if (UnsplashService.instance.isConfigured) {
      final unsplashUrl = await UnsplashService.instance.getPhotoUrl(widget.query);
      if (unsplashUrl != null) {
        if (mounted) setState(() => _fetchedUrl = unsplashUrl);
        return;
      }
    }

    final fallbackWikiUrl = await WikimediaService.instance.getPhotoUrl(widget.query);
    if (fallbackWikiUrl != null && mounted) {
      setState(() => _fetchedUrl = fallbackWikiUrl);
    }
  }

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
    } else if (_fetchedUrl != null) {
      content = Image.network(
        _fetchedUrl!,
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

  /// لو ما رفع الأدمن صورة يدوية، ولا [tryRealPhoto] مفعّلة، ولا لقينا صورة
  /// حقيقية بعد (لسا عم تحمّل أو فشل الجلب)، بيظهر أيقونة ولون مميز بدل مكان فاضي.
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
