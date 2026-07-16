import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../common/detail_screen.dart';
import '../../widgets/themed_image.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../services/api_service.dart';
import '../../theme/app_typography.dart';
import '../../widgets/responsive.dart';
import '../../widgets/app_toggle_bar.dart';
import '../../widgets/keyboard_scrollable.dart';

// كلمة بحث إنجليزية مناسبة لصورة كل خبر حسب تصنيفه
final Map<String, String> _newsPhotoQueryByCategory = {
  'development': 'urban development construction',
  'tourism': 'tourists sightseeing',
  'culture': 'cultural event celebration',
  'events': 'street festival crowd',
};

class NewsArticle {
  final String titleAr;
  final String titleEn;
  final String dateAr;
  final String dateEn;
  final String categoryAr;
  final String categoryEn;
  final String categoryKey; // tourism / events / development / culture
  final String summaryAr;
  final String summaryEn;
  final String bodyAr;
  final String bodyEn;
  final String?
  customImageBase64; // صورة رفعها الأدمن يدويًا لهذا الخبر تحديدًا

  NewsArticle({
    required this.titleAr,
    required this.titleEn,
    required this.dateAr,
    required this.dateEn,
    required this.categoryAr,
    required this.categoryEn,
    required this.categoryKey,
    required this.summaryAr,
    required this.summaryEn,
    required this.bodyAr,
    required this.bodyEn,
    this.customImageBase64,
  });
}

final List<NewsArticle> newsSeedData = [
  NewsArticle(
    titleAr: 'افتتاح مشروع تطوير البلدة القديمة',
    titleEn: 'Old City Development Project Launched',
    dateAr: '10 مايو 2025',
    dateEn: 'May 10, 2025',
    categoryAr: 'تطوير',
    categoryEn: 'Development',
    categoryKey: 'development',
    summaryAr:
        'مشروع جديد لترميم وتطوير أزقة البلدة القديمة والحفاظ على طابعها التراثي.',
    summaryEn:
        'A new project to restore and develop the Old City alleys while preserving its heritage character.',
    bodyAr:
        'أعلنت بلدية نابلس عن انطلاق مشروع شامل لتطوير البلدة القديمة يهدف إلى ترميم الأبنية التاريخية وتحسين البنية التحتية مع الحفاظ على الطابع المعماري الأصيل. يتضمن المشروع تحسين الإنارة، رصف الأزقة بالحجر الطبيعي، وإعادة تأهيل الأسواق القديمة لجذب مزيد من الزوار والسياح.',
    bodyEn:
        'Nablus Municipality announced the launch of a comprehensive project to develop the Old City, aiming to restore historic buildings and improve infrastructure while preserving the original architectural character. The project includes improved lighting, natural stone paving for the alleys, and rehabilitation of the old markets to attract more visitors and tourists.',
  ),
  NewsArticle(
    titleAr: 'نابلس تستضيف المؤتمر السياحي الدولي',
    titleEn: 'Nablus Hosts International Tourism Conference',
    dateAr: '8 مايو 2025',
    dateEn: 'May 8, 2025',
    categoryAr: 'سياحة',
    categoryEn: 'Tourism',
    categoryKey: 'tourism',
    summaryAr:
        'استضافت المدينة مؤتمرًا دوليًا لبحث سبل تعزيز السياحة الداخلية والخارجية.',
    summaryEn:
        'The city hosted an international conference to discuss ways to promote domestic and international tourism.',
    bodyAr:
        'شهدت نابلس هذا الأسبوع فعاليات المؤتمر السياحي الدولي بمشاركة خبراء ومختصين من عدة دول، حيث تم بحث استراتيجيات تطوير القطاع السياحي وجذب المزيد من الزوار عبر تحسين الخدمات والبنية التحتية السياحية بالمدينة.',
    bodyEn:
        'Nablus witnessed this week the International Tourism Conference with the participation of experts from several countries, discussing strategies to develop the tourism sector and attract more visitors by improving tourism services and infrastructure in the city.',
  ),
  NewsArticle(
    titleAr: 'تحسن حركة السياحة في نابلس',
    titleEn: 'Tourism Activity Improves in Nablus',
    dateAr: '5 مايو 2025',
    dateEn: 'May 5, 2025',
    categoryAr: 'سياحة',
    categoryEn: 'Tourism',
    categoryKey: 'tourism',
    summaryAr:
        'ارتفاع ملحوظ بعدد الزوار خلال الأشهر الأخيرة مقارنة بالعام الماضي.',
    summaryEn:
        'A noticeable increase in visitor numbers over recent months compared to last year.',
    bodyAr:
        'أظهرت إحصائيات حديثة ارتفاعًا ملحوظًا في أعداد الزوار القادمين إلى نابلس خلال الأشهر الأخيرة، ويعزو المختصون هذا التحسن إلى الحملات الترويجية الأخيرة وتحسين الخدمات السياحية في المدينة.',
    bodyEn:
        'Recent statistics showed a noticeable increase in the number of visitors coming to Nablus in recent months. Experts attribute this improvement to recent promotional campaigns and improved tourism services in the city.',
  ),
  NewsArticle(
    titleAr: 'فعاليات ثقافية جديدة في المدينة',
    titleEn: 'New Cultural Events in the City',
    dateAr: '2 مايو 2025',
    dateEn: 'May 2, 2025',
    categoryAr: 'ثقافة',
    categoryEn: 'Culture',
    categoryKey: 'culture',
    summaryAr:
        'سلسلة فعاليات ثقافية وفنية تنطلق هذا الشهر في عدة مواقع بالمدينة.',
    summaryEn:
        'A series of cultural and artistic events kicks off this month at several locations in the city.',
    bodyAr:
        'تنطلق هذا الشهر سلسلة من الفعاليات الثقافية والفنية في نابلس، تشمل معارض فنية وأمسيات شعرية وعروض موسيقية تراثية، بهدف إحياء التراث الثقافي المحلي وتشجيع السياحة الثقافية بالمدينة.',
    bodyEn:
        'A series of cultural and artistic events kicks off this month in Nablus, including art exhibitions, poetry evenings, and traditional music performances, aiming to revive local cultural heritage and encourage cultural tourism in the city.',
  ),
  NewsArticle(
    titleAr: 'مهرجان نابلس للتسوق ينطلق الشهر القادم',
    titleEn: 'Nablus Shopping Festival Launches Next Month',
    dateAr: '28 أبريل 2025',
    dateEn: 'April 28, 2025',
    categoryAr: 'فعاليات',
    categoryEn: 'Events',
    categoryKey: 'events',
    summaryAr:
        'استعدادات مكثفة لانطلاق مهرجان التسوق السنوي بمشاركة عشرات المحال التجارية.',
    summaryEn:
        'Intensive preparations underway for the annual shopping festival with dozens of participating stores.',
    bodyAr:
        'تجري الاستعدادات على قدم وساق لانطلاق مهرجان نابلس للتسوق السنوي الذي يشارك فيه عشرات المحال التجارية بعروض وتخفيضات خاصة، إلى جانب فعاليات ترفيهية للعائلات طوال أيام المهرجان.',
    bodyEn:
        'Preparations are in full swing for the launch of the annual Nablus Shopping Festival, with dozens of stores participating with special offers and discounts, alongside family entertainment activities throughout the festival days.',
  ),
  NewsArticle(
    titleAr: 'توسعة شبكة المواصلات العامة داخل المدينة',
    titleEn: 'Expansion of Public Transportation Network in the City',
    dateAr: '20 أبريل 2025',
    dateEn: 'April 20, 2025',
    categoryAr: 'تطوير',
    categoryEn: 'Development',
    categoryKey: 'development',
    summaryAr:
        'خطوط جديدة للمواصلات العامة لتسهيل الوصول لمختلف أحياء المدينة.',
    summaryEn:
        'New public transportation lines to facilitate access to different neighborhoods of the city.',
    bodyAr:
        'أعلنت الجهات المختصة عن توسعة شبكة المواصلات العامة داخل نابلس بإضافة خطوط جديدة تربط الأحياء السكنية بمركز المدينة والمعالم السياحية الرئيسية، بهدف تسهيل التنقل للسكان والزوار على حد سواء.',
    bodyEn:
        'Authorities announced the expansion of the public transportation network within Nablus by adding new lines connecting residential neighborhoods to the city center and major tourist landmarks, aiming to facilitate movement for both residents and visitors.',
  ),
];

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String categoryFilter = 'all';
  String searchQuery = '';

  bool _loaded = false;
  List<NewsArticle> _liveArticles = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = LocalDbService.instance;
    await db.seedIfEmpty('news', newsSeedData.map(newsToMap).toList());
    await ApiService.syncNews();
    final entries = db.getAll('news');
    setState(() {
      _liveArticles = entries.map((e) => mapToNews(e.value)).toList();
      _loaded = true;
    });
  }

  List<NewsArticle> get _filtered {
    return _liveArticles.where((a) {
      final matchesCategory =
          categoryFilter == 'all' || a.categoryKey == categoryFilter;
      final matchesSearch =
          searchQuery.isEmpty ||
          a.titleAr.contains(searchQuery) ||
          a.titleEn.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    if (!_loaded) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColors.bgDark,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final filtered = _filtered;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    color: AppColors.sidebarDark,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.textWhite,
                              size: 18,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.primaryGradient,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.article_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            app.t('آخر الأخبار', 'Latest News'),
                            textDirection: app.dir,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title(
                              AppColors.textWhite,
                            ).copyWith(fontSize: 16),
                          ),
                        ),
                        AppToggleBar(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: KeyboardScrollable(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // شريط البحث
                            Container(
                              height: 48,
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                ),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (v) =>
                                          setState(() => searchQuery = v),
                                      style: AppTypography.body(
                                        AppColors.textWhite,
                                      ).copyWith(fontSize: 13),
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        border: InputBorder.none,
                                        hintText: app.t(
                                          'ابحث في الأخبار...',
                                          'Search news...',
                                        ),
                                        hintStyle: AppTypography.caption(
                                          AppColors.textGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            // فلاتر التصنيف
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _catChip('all', app.t('الكل', 'All')),
                                  SizedBox(width: 8),
                                  _catChip(
                                    'tourism',
                                    app.t('سياحة', 'Tourism'),
                                  ),
                                  SizedBox(width: 8),
                                  _catChip(
                                    'events',
                                    app.t('فعاليات', 'Events'),
                                  ),
                                  SizedBox(width: 8),
                                  _catChip(
                                    'development',
                                    app.t('تطوير', 'Development'),
                                  ),
                                  SizedBox(width: 8),
                                  _catChip(
                                    'culture',
                                    app.t('ثقافة', 'Culture'),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            if (filtered.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 60),
                                child: Center(
                                  child: Text(
                                    app.t(
                                      'لا توجد أخبار مطابقة',
                                      'No matching news found',
                                    ),
                                    style: AppTypography.body(
                                      AppColors.textGrey,
                                    ),
                                  ),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: filtered.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: responsiveGridColumns(
                                        context,
                                        wide: 3,
                                        narrow: 2,
                                      ),
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.85,
                                    ),
                                itemBuilder: (context, i) =>
                                    _ArticleCard(article: filtered[i]),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _catChip(String key, String label) {
    final selected = categoryFilter == key;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => categoryFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: AppColors.primaryGradient)
              : null,
          color: selected ? null : AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.label(
            selected ? Colors.white : AppColors.textWhite,
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final NewsArticle article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final a = article;
    final title = app.isArabic ? a.titleAr : a.titleEn;
    final date = app.isArabic ? a.dateAr : a.dateEn;
    final category = app.isArabic ? a.categoryAr : a.categoryEn;
    final summary = app.isArabic ? a.summaryAr : a.summaryEn;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              titleAr: a.titleAr,
              titleEn: a.titleEn,
              subtitleAr: a.categoryAr,
              subtitleEn: a.categoryEn,
              extraInfo: date,
              descriptionAr: a.bodyAr,
              descriptionEn: a.bodyEn,
              customImageBase64: a.customImageBase64,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ThemedImage(
                  query:
                      _newsPhotoQueryByCategory[a.categoryKey] ??
                      'nablus palestine city',
                  fallbackSeed: a.titleEn,
                  height: double.infinity,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  customImageBase64: a.customImageBase64,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: AppTypography.caption(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textDirection: app.dir,
                  textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  summary,
                  textDirection: app.dir,
                  textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(AppColors.textGrey),
                ),
                SizedBox(height: 6),
                Text(date, style: AppTypography.caption(AppColors.textGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
