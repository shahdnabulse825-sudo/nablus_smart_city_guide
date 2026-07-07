import 'package:flutter/material.dart';
import '../services/unsplash_service.dart';

/// ودجت يعرض صورة حقيقية مرتبطة بموضوع معيّن (query)، مثلاً "mosque" أو "burger".
/// لو المفتاح مش مفعّل أو الطلب فشل، بيعرض تلقائيًا صورة بديلة من Picsum (عشوائية بس مستقرة)
/// وإذا فشلت هاي كمان، بيعرض أيقونة ولون مميز.
class ThemedImage extends StatefulWidget {
  final String query; // الكلمة المفتاحية بالإنجليزي، مثلاً "mosque", "burger", "hotel exterior"
  final String fallbackSeed; // اسم فريد يُستخدم كـ seed للصورة البديلة
  final double height;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color fallbackColor;

  const ThemedImage({
    super.key,
    required this.query,
    required this.fallbackSeed,
    required this.height,
    this.borderRadius,
    this.fallbackIcon = Icons.image,
    this.fallbackColor = const Color(0xFF6C5CE7),
  });

  @override
  State<ThemedImage> createState() => _ThemedImageState();
}

class _ThemedImageState extends State<ThemedImage> {
  String? _url;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final url = await UnsplashService.instance.getPhotoUrl(widget.query);
    if (mounted) {
      setState(() {
        _url = url;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_loading) {
      content = Container(
        height: widget.height,
        color: const Color(0xFF17233B),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else if (_url != null) {
      content = Image.network(
        _url!,
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _relatedPhotoFallback(),
      );
    } else {
      content = _relatedPhotoFallback();
    }

    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: content);
    }
    return content;
  }

  /// صورة حقيقية مرتبطة بموضوع الـ query (بدون أي مفتاح API) عبر LoremFlickr،
  /// والذي يرجع صورًا فعلية من Flickr مطابقة للكلمات المفتاحية. لو فشلت، نرجع لـ Picsum.
  Widget _relatedPhotoFallback() {
    final tags = widget.query
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .take(3)
        .join(',');
    if (tags.isEmpty) return _picsumFallback();
    final lock = widget.fallbackSeed.hashCode.abs() % 100000;
    final url = 'https://loremflickr.com/640/480/${Uri.encodeComponent(tags)}?lock=$lock';
    return Image.network(
      url,
      height: widget.height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _picsumFallback(),
    );
  }

  Widget _picsumFallback() {
    return Image.network(
      'https://picsum.photos/seed/${Uri.encodeComponent(widget.fallbackSeed)}/500/400',
      height: widget.height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.fallbackColor, widget.fallbackColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(child: Icon(widget.fallbackIcon, color: Colors.white, size: 36)),
      ),
    );
  }
}