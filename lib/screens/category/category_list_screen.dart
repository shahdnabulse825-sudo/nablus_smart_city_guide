import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../services/favorites_service.dart';
import '../map/map_screen.dart';
import 'category_data.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/responsive.dart';
import '../common/detail_screen.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_toggle_bar.dart';
import '../../widgets/keyboard_scrollable.dart';

/// شاشة عامة قابلة لإعادة الاستخدام لعرض أي تصنيف (فنادق، سياحة، تسوق، مواصلات، صحة، صيدليات)
/// نفس التصميم بالضبط، بس البيانات والعنوان يختلفوا حسب التصنيف المُمرَّر.
class CategoryListScreen extends StatefulWidget {
  final String titleAr;
  final String titleEn;
  final String bannerSubtitleAr;
  final String bannerSubtitleEn;
  final IconData icon;
  final String
  boxName; // اسم صندوق قاعدة البيانات: hotels / attractions / shopping / transport / health / pharmacies
  final List<ListingItem>
  seedData; // بيانات ابتدائية تُستخدم أول مرة فقط لو الصندوق فاضي

  const CategoryListScreen({
    super.key,
    required this.titleAr,
    required this.titleEn,
    required this.bannerSubtitleAr,
    required this.bannerSubtitleEn,
    required this.icon,
    required this.boxName,
    required this.seedData,
  });

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  int selectedIndex = 0;
  String searchQuery = '';
  double minRating = 0;

  bool _loaded = false;
  List<ListingItem> _liveItems = [];
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
    await db.seedIfEmpty(
      widget.boxName,
      widget.seedData.map(listingToMap).toList(),
    );
    final entries = db.getAll(widget.boxName);
    setState(() {
      _liveItems = entries.map((e) => mapToListing(e.value)).toList();
      _loaded = true;
    });
  }

  List<ListingItem> get _filtered {
    return _liveItems.where((it) {
      final matchesSearch =
          searchQuery.isEmpty ||
          it.nameAr.contains(searchQuery) ||
          it.nameEn.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesRating = it.rating >= minRating;
      return matchesSearch && matchesRating;
    }).toList()..sort((a, b) {
      if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
      return b.rating.compareTo(a.rating);
    });
  }

  void _openDetail(BuildContext context, ListingItem it) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          titleAr: it.nameAr,
          titleEn: it.nameEn,
          subtitleAr: it.typeAr,
          subtitleEn: it.typeEn,
          descriptionAr: it.aboutAr,
          descriptionEn: it.aboutEn,
          rating: it.rating,
          extraInfo: AppState.instance.isArabic
              ? it.infoLabelAr
              : it.infoLabelEn,
          locationAr: it.locationAr,
          locationEn: it.locationEn,
          customImageBase64: it.customImageBase64,
        ),
      ),
    );
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
        final selected = filtered.isEmpty
            ? null
            : filtered[selectedIndex.clamp(0, filtered.length - 1)];
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: KeyboardScrollable(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopBar(
                      titleAr: widget.titleAr,
                      titleEn: widget.titleEn,
                      icon: widget.icon,
                    ),
                    _Banner(
                      titleAr: widget.titleAr,
                      titleEn: widget.titleEn,
                      subtitleAr: widget.bannerSubtitleAr,
                      subtitleEn: widget.bannerSubtitleEn,
                      seed: widget.titleEn,
                      boxName: widget.boxName,
                    ),
                    Padding(
                      padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                      child: isMobile(context)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _FiltersSidebar(
                                  onSearchChanged: (v) =>
                                      setState(() => searchQuery = v),
                                  minRating: minRating,
                                  onRatingTap: (v) => setState(
                                    () => minRating = minRating == v ? 0 : v,
                                  ),
                                ),
                                SizedBox(height: 16),
                                _ResultsGrid(
                                  items: filtered,
                                  selected: null,
                                  onSelect: (it) => _openDetail(context, it),
                                  onFavorite: (it) async {
                                    await FavoritesService.instance
                                        .toggleFavorite(it.nameEn);
                                    setState(() {});
                                  },
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 240,
                                  child: _FiltersSidebar(
                                    onSearchChanged: (v) =>
                                        setState(() => searchQuery = v),
                                    minRating: minRating,
                                    onRatingTap: (v) => setState(
                                      () => minRating = minRating == v ? 0 : v,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: _ResultsGrid(
                                    items: filtered,
                                    selected: selected,
                                    onSelect: (it) => setState(
                                      () =>
                                          selectedIndex = filtered.indexOf(it),
                                    ),
                                    onFavorite: (it) async {
                                      await FavoritesService.instance
                                          .toggleFavorite(it.nameEn);
                                      setState(() {});
                                    },
                                  ),
                                ),
                                SizedBox(width: 20),
                                SizedBox(
                                  width: 320,
                                  child: selected == null
                                      ? _EmptyPanel()
                                      : _DetailPanel(
                                          item: selected,
                                          isFavorite: FavoritesService.instance
                                              .isFavorite(selected.nameEn),
                                          onFavorite: () async {
                                            await FavoritesService.instance
                                                .toggleFavorite(
                                                  selected.nameEn,
                                                );
                                            setState(() {});
                                          },
                                        ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== شريط علوي ====================
class _TopBar extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  final IconData icon;
  const _TopBar({
    required this.titleAr,
    required this.titleEn,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
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
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              app.t(titleAr, titleEn),
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
    );
  }
}

// كلمة بحث إنجليزية مناسبة لصورة بانر كل تصنيف
final Map<String, String> _bannerQueryByBox = {
  'hotels': 'Nablus hotel',
  'attractions': 'Nablus old city',
  'shopping': 'Nablus market',
  'transport': 'Nablus street',
  'health': 'Nablus hospital',
  'pharmacies': 'Nablus pharmacy',
  'education': 'An-Najah University campus',
  'banks': 'Bank of Palestine',
  'entertainment': 'Nablus panorama',
  'government': 'Nablus panorama',
};

// ==================== بانر عنوان الصفحة ====================
class _Banner extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final String seed;
  final String boxName;
  const _Banner({
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.seed,
    required this.boxName,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
      height: 200,
      margin: EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => showImageZoom(
              context,
              query: _bannerQueryByBox[boxName] ?? 'nablus palestine city',
              fallbackSeed: '$seed-banner',
            ),
            child: ThemedImage(
              query: _bannerQueryByBox[boxName] ?? 'nablus palestine city',
              fallbackSeed: '$seed-banner',
              height: 200,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.6),
                  AppColors.primaryDark.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  app.t(titleAr, titleEn),
                  textDirection: app.dir,
                  style: AppTypography.display(
                    Colors.white,
                  ).copyWith(fontSize: 28),
                ),
                SizedBox(height: 8),
                Text(
                  app.t(subtitleAr, subtitleEn),
                  textDirection: app.dir,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== الفلاتر الجانبية (عامة: بحث + تقييم) ====================
class _FiltersSidebar extends StatelessWidget {
  final void Function(String) onSearchChanged;
  final double minRating;
  final void Function(double) onRatingTap;
  const _FiltersSidebar({
    required this.onSearchChanged,
    required this.minRating,
    required this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return AppCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                app.t('تصفية النتائج', 'Filter Results'),
                textDirection: app.dir,
                style: AppTypography.title(
                  AppColors.textWhite,
                ).copyWith(fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.cardDark2,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 16, color: AppColors.textGrey),
                SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    onChanged: onSearchChanged,
                    style: AppTypography.body(
                      AppColors.textWhite,
                    ).copyWith(fontSize: 12),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: app.t('ابحث...', 'Search...'),
                      hintStyle: AppTypography.caption(AppColors.textGrey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          Text(
            app.t('التقييم', 'Rating'),
            textDirection: app.dir,
            style: AppTypography.label(AppColors.textWhite),
          ),
          SizedBox(height: 8),
          _ratingRow(4.5, minRating == 4.5, () => onRatingTap(4.5)),
          _ratingRow(4.0, minRating == 4.0, () => onRatingTap(4.0)),
          _ratingRow(3.5, minRating == 3.5, () => onRatingTap(3.5)),
        ],
      ),
    );
  }

  Widget _ratingRow(double value, bool selected, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: selected ? AppColors.primary : AppColors.textGrey,
            ),
            SizedBox(width: 8),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  Icons.star,
                  size: 12,
                  color: i < value.floor()
                      ? AppColors.gold
                      : AppColors.borderColor,
                ),
              ),
            ),
            SizedBox(width: 6),
            Text(
              '$value فأكثر',
              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== شبكة النتائج ====================
class _ResultsGrid extends StatelessWidget {
  final List<ListingItem> items;
  final ListingItem? selected;
  final void Function(ListingItem) onSelect;
  final void Function(ListingItem) onFavorite;
  const _ResultsGrid({
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          app.t('${items.length} نتيجة', '${items.length} results'),
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        SizedBox(height: 16),
        if (items.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Text(
                app.t('لا توجد نتائج مطابقة', 'No matching results'),
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsiveGridColumns(
                context,
                wide: 4,
                narrow: 2,
              ),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, i) {
              final it = items[i];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(it),
                child: _ItemCard(
                  item: it,
                  isFavorite: FavoritesService.instance.isFavorite(it.nameEn),
                  isSelected: it == selected,
                  onFavorite: () => onFavorite(it),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ListingItem item;
  final bool isFavorite;
  final bool isSelected;
  final VoidCallback onFavorite;
  const _ItemCard({
    required this.item,
    required this.isFavorite,
    required this.isSelected,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final name = app.isArabic ? item.nameAr : item.nameEn;
    final type = app.isArabic ? item.typeAr : item.typeEn;
    final location = app.isArabic ? item.locationAr : item.locationEn;
    final infoLabel = app.isArabic ? item.infoLabelAr : item.infoLabelEn;

    return AppCard(
      padding: EdgeInsets.zero,
      border: Border.all(
        color: isSelected ? AppColors.primary : AppColors.borderColor,
        width: isSelected ? 2 : 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ThemedImage(
                  query: item.photoQuery,
                  fallbackSeed: item.nameEn,
                  height: double.infinity,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  fallbackIcon: item.placeholderIcon,
                  fallbackColor: item.placeholderColor,
                  customImageBase64: item.customImageBase64,
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.white),
                        SizedBox(width: 3),
                        Text(
                          '${item.rating}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (item.isFeatured)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 10, color: Colors.white),
                          SizedBox(width: 2),
                          Text(
                            app.t('مميز', 'Featured'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onFavorite,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: isFavorite ? AppColors.red : AppColors.textGrey,
                      ),
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
                  name,
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  type,
                  textDirection: app.dir,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 10),
                ),
                SizedBox(height: 6),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.textGrey,
                    ),
                    SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        location,
                        textDirection: app.dir,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  infoLabel,
                  textDirection: app.dir,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== بانل التفاصيل ====================
class _DetailPanel extends StatelessWidget {
  final ListingItem item;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const _DetailPanel({
    required this.item,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final it = item;
    final name = app.isArabic ? it.nameAr : it.nameEn;
    final type = app.isArabic ? it.typeAr : it.typeEn;
    final location = app.isArabic ? it.locationAr : it.locationEn;
    final about = app.isArabic ? it.aboutAr : it.aboutEn;
    final infoLabel = app.isArabic ? it.infoLabelAr : it.infoLabelEn;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => showImageZoom(
                  context,
                  query: it.photoQuery,
                  fallbackSeed: it.nameEn,
                  fallbackIcon: it.placeholderIcon,
                  fallbackColor: it.placeholderColor,
                  customImageBase64: it.customImageBase64,
                ),
                child: ThemedImage(
                  query: it.photoQuery,
                  fallbackSeed: it.nameEn,
                  height: 170,
                  fallbackIcon: it.placeholderIcon,
                  fallbackColor: it.placeholderColor,
                  customImageBase64: it.customImageBase64,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onFavorite,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isFavorite ? AppColors.red : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            '${it.rating}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '(${it.reviews} ${app.t('تقييم', 'reviews')})',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  name,
                  textDirection: app.dir,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  type,
                  textDirection: app.dir,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
                SizedBox(height: 4),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 13,
                      color: AppColors.textGrey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      location,
                      textDirection: app.dir,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    infoLabel,
                    textDirection: app.dir,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionIcon(
                      context,
                      Icons.call,
                      app.t('اتصال', 'Call'),
                      onTap: () async {
                        await launchUrl(Uri.parse('tel:${it.phone}'));
                      },
                    ),
                    _actionIcon(
                      context,
                      Icons.location_on,
                      app.t('الموقع', 'Location'),
                      onTap: () {
                        final point = resolveMapPoint(
                          nameAr: it.nameAr,
                          nameEn: it.nameEn,
                          locationAr: it.locationAr,
                          locationEn: it.locationEn,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              focusPoint: point,
                              focusNameAr: it.nameAr,
                              focusNameEn: it.nameEn,
                              focusCategoryAr: it.typeAr,
                              focusCategoryEn: it.typeEn,
                              focusRating: it.rating,
                            ),
                          ),
                        );
                      },
                    ),
                    _actionIcon(
                      context,
                      Icons.share,
                      app.t('المشاركة', 'Share'),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Text(
                  app.t('نبذة', 'Overview'),
                  textDirection: app.dir,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  about,
                  textDirection: app.dir,
                  textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: AppColors.glowShadow,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final point = resolveMapPoint(
                          nameAr: it.nameAr,
                          nameEn: it.nameEn,
                          locationAr: it.locationAr,
                          locationEn: it.locationEn,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              focusPoint: point,
                              focusNameAr: it.nameAr,
                              focusNameEn: it.nameEn,
                              focusCategoryAr: it.typeAr,
                              focusCategoryEn: it.typeEn,
                              focusRating: it.rating,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      icon: Icon(
                        Icons.map_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        app.t('عرض على الخريطة', 'Show on Map'),
                        style: AppTypography.title(
                          Colors.white,
                        ).copyWith(fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    final app = AppState.instance;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  app.t('$label قيد التطوير', '$label coming soon'),
                ),
                duration: Duration(seconds: 2),
              ),
            );
          },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardDark2,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: AppColors.textGrey, fontSize: 9)),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return AppCard(
      padding: EdgeInsets.all(30),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_rounded, color: AppColors.textGrey, size: 28),
            SizedBox(height: 10),
            Text(
              app.t(
                'اختر عنصرًا لعرض تفاصيله',
                'Select an item to see details',
              ),
              textAlign: TextAlign.center,
              textDirection: app.dir,
              style: AppTypography.body(AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
