import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/unsplash_service.dart';
import '../services/wikimedia_service.dart';

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

  const ThemedImage({
    super.key,
    required this.query,
    required this.fallbackSeed,
    required this.height,
    this.borderRadius,
    this.fallbackIcon = Icons.image,
    this.fallbackColor = const Color(0xFF6C5CE7),
    this.customImageBase64,
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
    if (widget.customImageBase64 == null || widget.customImageBase64!.isEmpty) {
      _load();
    } else {
      _loading = false;
    }
  }

  Future<void> _load() async {
    var url = await UnsplashService.instance.getPhotoUrl(widget.query);
    url ??= await WikimediaService.instance.getPhotoUrl(widget.query);
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

    if (widget.customImageBase64 != null && widget.customImageBase64!.isNotEmpty) {
      content = Image.memory(
        base64Decode(widget.customImageBase64!),
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _relatedPhotoFallback(),
      );
    } else if (_loading) {
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

  /// محاولة أخيرة قبل Picsum: LoremFlickr بكلمة وحيدة فقط (أكثر استقرارًا بكثير من
  /// عدة كلمات معًا، اللي بيرجّع خطأ من خادمهم بمعظم الأحيان).
  Widget _relatedPhotoFallback() {
    final firstWord = widget.query
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .trim()
        .split(RegExp(r'\s+'))
        .firstWhere((t) => t.isNotEmpty, orElse: () => '');
    if (firstWord.isEmpty) return _picsumFallback();
    final lock = widget.fallbackSeed.hashCode.abs() % 100000;
    final url =
        'https://loremflickr.com/640/480/${Uri.encodeComponent(firstWord)}?lock=$lock';
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
      ),
    );
  }
}
