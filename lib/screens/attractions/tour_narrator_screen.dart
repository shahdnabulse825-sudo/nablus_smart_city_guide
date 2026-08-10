import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../theme/app_typography.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/themed_image.dart';
import '../subscription/premium_screen.dart';
import 'attractions_screen.dart' show AttractionData, attractionsSeedData;

/// شاشة "راوي الجولات" — تختاري معلم حقيقي (أو "البلدة القديمة" كجولة كاملة)
/// وبيحوّل بياناته الحقيقية (تاريخ/عمارة/موقع) لقصة سردية ممتعة، بدل وصف جاف.
class TourNarratorScreen extends StatelessWidget {
  const TourNarratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final oldCityPlaces =
        attractionsSeedData.where((a) => a.categories.contains('oldCity')).toList();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: AppColors.sidebarDark,
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Icon(Icons.arrow_back, color: AppColors.textWhite),
                    ),
                    SizedBox(width: 12),
                    Text(
                      app.t('راوي الجولات', 'Tour Narrator'),
                      textDirection: app.dir,
                      style: AppTypography.title(AppColors.textWhite),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    Text(
                      app.t(
                        'اختاري معلم حقيقي وبنحوّل قصته لرواية ممتعة تحسي فيها إنك ماشية جواه.',
                        "Pick a real landmark and we'll turn its story into an engaging narrative, as if you're walking through it.",
                      ),
                      textDirection: app.dir,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.5),
                    ),
                    SizedBox(height: 18),
                    if (oldCityPlaces.length > 1)
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TourStoryScreen(
                              titleAr: 'البلدة القديمة',
                              titleEn: 'Old City',
                              message:
                                  'احكيلي قصة البلدة القديمة بنابلس وأنا ماشية فيها، بأسلوب سردي حسي وممتع',
                            ),
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.primaryGradient),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.auto_stories_rounded, color: Colors.white, size: 32),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      app.t('جولة البلدة القديمة الكاملة', 'Full Old City Tour'),
                                      textDirection: app.dir,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      app.t(
                                        'قصة واحدة تجمع أبرز معالمها',
                                        'One story weaving its top landmarks together',
                                      ),
                                      textDirection: app.dir,
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ),
                    Text(
                      app.t('أو اختاري معلم محدد', 'Or pick a specific landmark'),
                      textDirection: app.dir,
                      style: AppTypography.label(AppColors.textGrey),
                    ),
                    SizedBox(height: 10),
                    for (final a in attractionsSeedData)
                      _AttractionTile(
                        attraction: a,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TourStoryScreen(
                              titleAr: a.nameAr,
                              titleEn: a.nameEn,
                              message:
                                  'احكيلي قصة ${a.nameAr} بنابلس وأنا ماشية فيه، بأسلوب سردي حسي وممتع',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttractionTile extends StatelessWidget {
  final AttractionData attraction;
  final VoidCallback onTap;
  const _AttractionTile({required this.attraction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: ThemedImage(
                query: 'nablus landmark',
                fallbackSeed: attraction.nameEn,
                height: 64,
                localAsset: attraction.image,
                customImageBase64: attraction.customImageBase64,
                serverImageUrl: attraction.serverImageUrl,
                fallbackIcon: attraction.placeholderIcon,
                fallbackColor: attraction.placeholderColor,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.isArabic ? attraction.nameAr : attraction.nameEn,
                    textDirection: app.dir,
                    style: AppTypography.label(AppColors.textWhite).copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    app.isArabic ? attraction.locationAr : attraction.locationEn,
                    textDirection: app.dir,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textGrey, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12, right: 4),
              child: Icon(Icons.auto_stories_outlined, color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

/// بتبعت طلب رواية القصة للمساعد الذكي (نفس /api/ai-chat اللي وراه كشف تلقائي
/// لطلبات الرواية وتعليمات خاصة تخلي الرد قصة سردية مش نقاط جافة) وبتعرض
/// النتيجة بشكل منسّق، مش شكل شات.
class TourStoryScreen extends StatefulWidget {
  final String titleAr;
  final String titleEn;
  final String message;
  const TourStoryScreen({
    super.key,
    required this.titleAr,
    required this.titleEn,
    required this.message,
  });

  @override
  State<TourStoryScreen> createState() => _TourStoryScreenState();
}

class _TourStoryScreenState extends State<TourStoryScreen> {
  bool _loading = true;
  String? _result;
  String? _error;
  bool _quotaExceeded = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioLoading = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _narrate();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _narrate() async {
    final app = AppState.instance;
    setState(() {
      _loading = true;
      _result = null;
      _error = null;
      _quotaExceeded = false;
    });
    await _audioPlayer.stop();
    final lang = app.isArabic ? 'ar' : 'en';
    final result = await ApiService.askAiAssistant(
      widget.message,
      lang: lang,
      token: AuthService.instance.userToken,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['ok'] == true) {
        _result = (app.isArabic ? result['textAr'] : result['textEn']) as String?;
      } else if (result['quotaExceeded'] == true) {
        _quotaExceeded = true;
        _error = (result['error'] as String?) ??
            app.t('وصلتِ حد الاستخدام المجاني اليوم', "You've hit today's free usage limit");
      } else {
        _error = app.t(
          'تعذّر جلب القصة الآن — تأكدي إنه في اتصال بالسيرفر وحاولي بعد شوي',
          'Could not fetch the story right now — make sure the server is reachable and try again',
        );
      }
    });
  }

  Future<void> _toggleListen() async {
    final app = AppState.instance;
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }
    if (_audioPlayer.state == PlayerState.paused) {
      await _audioPlayer.resume();
      return;
    }
    if (_result == null || _result!.isEmpty) return;
    setState(() => _audioLoading = true);
    final ttsResult = await ApiService.textToSpeech(
      _result!,
      token: AuthService.instance.userToken,
    );
    if (!mounted) return;
    setState(() => _audioLoading = false);
    if (ttsResult['ok'] != true) {
      final serverError = ttsResult['error'] as String?;
      final quotaExceeded = ttsResult['quotaExceeded'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            serverError ??
                app.t('تعذّر توليد الصوت الآن، حاولي بعد شوي', "Couldn't generate audio right now, try again"),
          ),
          backgroundColor: AppColors.red,
          action: quotaExceeded
              ? SnackBarAction(
                  label: app.t('اشتركي', 'Subscribe'),
                  textColor: AppColors.gold,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PremiumScreen()),
                  ),
                )
              : null,
        ),
      );
      return;
    }
    final audioBytes = ttsResult['bytes'] as List<int>;
    await _audioPlayer.play(BytesSource(Uint8List.fromList(audioBytes)));
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final title = app.isArabic ? widget.titleAr : widget.titleEn;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: AppColors.sidebarDark,
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Icon(Icons.arrow_back, color: AppColors.textWhite),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        app.t('قصة $title', '$title\'s Story'),
                        textDirection: app.dir,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title(AppColors.textWhite),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 16),
                            Text(
                              app.t('عم نحضّر قصتك...', 'Preparing your story...'),
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_error != null)
                              Container(
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      _error!,
                                      textDirection: app.dir,
                                      style: TextStyle(color: AppColors.red),
                                    ),
                                    if (_quotaExceeded) ...[
                                      SizedBox(height: 10),
                                      OutlinedButton.icon(
                                        onPressed: () => Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => const PremiumScreen()),
                                        ),
                                        icon: Icon(Icons.workspace_premium_rounded, size: 18, color: AppColors.gold),
                                        label: Text(
                                          app.t('اشتركي بالبريميوم', 'Subscribe to Premium'),
                                          style: TextStyle(color: AppColors.gold),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            if (_result != null)
                              Container(
                                padding: EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppColors.cardDark,
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(color: AppColors.borderColor),
                                  boxShadow: AppColors.cardShadow,
                                ),
                                child: Text(
                                  _result!,
                                  textDirection: app.dir,
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 14.5,
                                    height: 1.8,
                                  ),
                                ),
                              ),
                            SizedBox(height: 16),
                            if (_result != null && app.isArabic)
                              SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: _audioLoading ? null : _toggleListen,
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                  icon: _audioLoading
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          _isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                                          color: Colors.white,
                                        ),
                                  label: Text(
                                    _audioLoading
                                        ? app.t('عم نحضّر الصوت...', 'Preparing audio...')
                                        : (_isPlaying
                                            ? app.t('إيقاف مؤقت', 'Pause')
                                            : app.t('اسمعي القصة', 'Listen to the story')),
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            SizedBox(height: 10),
                            if (!_loading)
                              OutlinedButton.icon(
                                onPressed: _narrate,
                                icon: Icon(Icons.refresh_rounded, size: 18),
                                label: Text(app.t('جرّبي رواية تانية', 'Try another telling')),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
