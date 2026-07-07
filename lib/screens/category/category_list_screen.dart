import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../map/map_screen.dart';
import 'category_data.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة عامة قابلة لإعادة الاستخدام لعرض أي تصنيف (فنادق، سياحة، تسوق، مواصلات، صحة، صيدليات)
/// نفس التصميم بالضبط، بس البيانات والعنوان يختلفوا حسب التصنيف المُمرَّر.
class CategoryListScreen extends StatefulWidget {
  final String titleAr;
  final String titleEn;
  final String bannerSubtitleAr;
  final String bannerSubtitleEn;
  final IconData icon;
  final String boxName; // اسم صندوق قاعدة البيانات: hotels / attractions / shopping / transport / health / pharmacies
  final List<ListingItem> seedData; // بيانات ابتدائية تُستخدم أول مرة فقط لو الصندوق فاضي

  CategoryListScreen({
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
  Set<int> favorites = {};
  String searchQuery = '';
  double minRating = 0;

  bool _loaded = false;
  List<ListingItem> _liveItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = LocalDbService.instance;
    await db.seedIfEmpty(widget.boxName, widget.seedData.map(listingToMap).toList());
    final entries = db.getAll(widget.boxName);
    setState(() {
      _liveItems = entries.map((e) => mapToListing(e.value)).toList();
      _loaded = true;
    });
  }

  List<ListingItem> get _filtered {
    return _liveItems.where((it) {
      final matchesSearch = searchQuery.isEmpty ||
          it.nameAr.contains(searchQuery) ||
          it.nameEn.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesRating = it.rating >= minRating;
      return matchesSearch && matchesRating;
    }).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    if (!_loaded) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColors.bgDark,
          body: Center(child: CircularProgressIndicator(color: AppColors.blue)),
        ),
      );
    }
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final filtered = _filtered;
        final selected =
            filtered.isEmpty ? null : filtered[selectedIndex.clamp(0, filtered.length - 1)];
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(titleAr: widget.titleAr, titleEn: widget.titleEn, icon: widget.icon),
                  _Banner(
                    titleAr: widget.titleAr,
                    titleEn: widget.titleEn,
                    subtitleAr: widget.bannerSubtitleAr,
                    subtitleEn: widget.bannerSubtitleEn,
                    seed: widget.titleEn,
                  ),
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 240,
                          child: _FiltersSidebar(
                            onSearchChanged: (v) => setState(() => searchQuery = v),
                            minRating: minRating,
                            onRatingTap: (v) =>
                                setState(() => minRating = minRating == v ? 0 : v),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _ResultsGrid(
                            items: filtered,
                            selected: selected,
                            favorites: favorites,
                            onSelect: (it) =>
                                setState(() => selectedIndex = filtered.indexOf(it)),
                            onFavorite: (it) => setState(() {
                              final idx = _liveItems.indexOf(it);
                              if (favorites.contains(idx)) {
                                favorites.remove(idx);
                              } else {
                                favorites.add(idx);
                              }
                            }),
                          ),
                        ),
                        SizedBox(width: 20),
                        SizedBox(
                          width: 320,
                          child: selected == null
                              ? _EmptyPanel()
                              : _DetailPanel(
                                  item: selected,
                                  isFavorite: favorites.contains(_liveItems.indexOf(selected)),
                                  onFavorite: () => setState(() {
                                    final idx = _liveItems.indexOf(selected);
                                    if (favorites.contains(idx)) {
                                      favorites.remove(idx);
                                    } else {
                                      favorites.add(idx);
                                    }
                                  }),
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
      },
    );
  }
}

// ==================== شريط علوي ====================
class _TopBar extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  final IconData icon;
  const _TopBar({required this.titleAr, required this.titleEn, required this.icon});

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
            child: Icon(Icons.arrow_back, color: AppColors.textWhite),
          ),
          SizedBox(width: 10),
          Icon(icon, color: AppColors.blue, size: 18),
          SizedBox(width: 8),
          Text(app.t(titleAr, titleEn),
              textDirection: app.dir,
              style: TextStyle(
                  color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
          Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => app.toggleLanguage(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration:
                  BoxDecoration(color: AppColors.cardDark2, borderRadius: BorderRadius.circular(20)),
              child: Text(app.isArabic ? 'عربي  EN' : 'EN  عربي',
                  style: TextStyle(color: AppColors.textWhite, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== بانر عنوان الصفحة ====================
class _Banner extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final String seed;
  const _Banner({
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.seed,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
      height: 190,
      margin: EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/nablus_bg.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Image.network(
              'https://picsum.photos/seed/${Uri.encodeComponent(seed)}-banner/1200/400',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(color: AppColors.cardDark2),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(app.t(titleAr, titleEn),
                    textDirection: app.dir,
                    style: TextStyle(
                        color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(app.t(subtitleAr, subtitleEn),
                    textDirection: app.dir,
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 16, color: AppColors.blue),
              SizedBox(width: 6),
              Text(app.t('تصفية النتائج', 'Filter Results'),
                  textDirection: app.dir,
                  style: TextStyle(
                      color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 38,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.cardDark2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: AppColors.textGrey),
                SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    onChanged: onSearchChanged,
                    style: TextStyle(color: AppColors.textWhite, fontSize: 12),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: app.t('ابحث...', 'Search...'),
                      hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          Text(app.t('التقييم', 'Rating'),
              textDirection: app.dir,
              style: TextStyle(
                  color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.bold)),
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
              color: selected ? AppColors.blue : AppColors.textGrey,
            ),
            SizedBox(width: 8),
            Row(
              children: List.generate(
                  5,
                  (i) => Icon(Icons.star,
                      size: 12,
                      color: i < value.floor() ? AppColors.gold : AppColors.borderColor)),
            ),
            SizedBox(width: 6),
            Text('$value فأكثر', style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
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
  final Set<int> favorites;
  final void Function(ListingItem) onSelect;
  final void Function(ListingItem) onFavorite;
  const _ResultsGrid({
    required this.items,
    required this.selected,
    required this.favorites,
    required this.onSelect,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(app.t('${items.length} نتيجة', '${items.length} results'),
            style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
        SizedBox(height: 16),
        if (items.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Text(app.t('لا توجد نتائج مطابقة', 'No matching results'),
                  style: TextStyle(color: AppColors.textGrey)),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
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
                  isFavorite: favorites.contains(i),
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
  const _ItemCard(
      {required this.item,
      required this.isFavorite,
      required this.isSelected,
      required this.onFavorite});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final name = app.isArabic ? item.nameAr : item.nameEn;
    final type = app.isArabic ? item.typeAr : item.typeEn;
    final location = app.isArabic ? item.locationAr : item.locationEn;
    final infoLabel = app.isArabic ? item.infoLabelAr : item.infoLabelEn;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isSelected ? AppColors.blue : AppColors.borderColor,
            width: isSelected ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ThemedImage(
                query: item.photoQuery,
                fallbackSeed: item.nameEn,
                height: 110,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                fallbackIcon: item.placeholderIcon,
                fallbackColor: item.placeholderColor,
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration:
                      BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.white),
                      SizedBox(width: 3),
                      Text('${item.rating}',
                          style: TextStyle(
                              color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 14, color: isFavorite ? AppColors.red : AppColors.textGrey),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(name,
                    textDirection: app.dir,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text(type,
                    textDirection: app.dir, style: TextStyle(color: AppColors.textGrey, fontSize: 10)),
                SizedBox(height: 6),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(Icons.location_on, size: 12, color: AppColors.textGrey),
                    SizedBox(width: 3),
                    Expanded(
                      child: Text(location,
                          textDirection: app.dir,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.textGrey, fontSize: 9)),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(infoLabel,
                    textDirection: app.dir,
                    style: TextStyle(color: AppColors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
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
  const _DetailPanel({required this.item, required this.isFavorite, required this.onFavorite});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final it = item;
    final name = app.isArabic ? it.nameAr : it.nameEn;
    final type = app.isArabic ? it.typeAr : it.typeEn;
    final location = app.isArabic ? it.locationAr : it.locationEn;
    final about = app.isArabic ? it.aboutAr : it.aboutEn;
    final infoLabel = app.isArabic ? it.infoLabelAr : it.infoLabelEn;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ThemedImage(
                query: it.photoQuery,
                fallbackSeed: it.nameEn,
                height: 170,
                fallbackIcon: it.placeholderIcon,
                fallbackColor: it.placeholderColor,
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
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16, color: isFavorite ? AppColors.red : Colors.black87),
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
                      decoration:
                          BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.white),
                          SizedBox(width: 3),
                          Text('${it.rating}', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('(${it.reviews} ${app.t('تقييم', 'reviews')})',
                        style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                  ],
                ),
                SizedBox(height: 8),
                Text(name,
                    textDirection: app.dir,
                    style:
                        TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(type, textDirection: app.dir, style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                SizedBox(height: 4),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(Icons.location_on, size: 13, color: AppColors.textGrey),
                    SizedBox(width: 4),
                    Text(location,
                        textDirection: app.dir, style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColors.cardDark2, borderRadius: BorderRadius.circular(8)),
                  child: Text(infoLabel,
                      textDirection: app.dir,
                      style: TextStyle(color: AppColors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionIcon(context, Icons.call, app.t('اتصال', 'Call'), onTap: () async {
                      await launchUrl(Uri.parse('tel:${it.phone}'));
                    }),
                    _actionIcon(context, Icons.location_on, app.t('الموقع', 'Location'),
                        onTap: () {
                      final point = resolveMapPoint(
                        nameAr: it.nameAr,
                        nameEn: it.nameEn,
                        locationAr: it.locationAr,
                        locationEn: it.locationEn,
                      );
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MapScreen(
                          focusPoint: point,
                          focusNameAr: it.nameAr,
                          focusNameEn: it.nameEn,
                          focusCategoryAr: it.typeAr,
                          focusCategoryEn: it.typeEn,
                          focusRating: it.rating,
                        ),
                      ));
                    }),
                    _actionIcon(context, Icons.share, app.t('المشاركة', 'Share')),
                  ],
                ),
                SizedBox(height: 18),
                Text(app.t('نبذة', 'Overview'),
                    textDirection: app.dir,
                    style: TextStyle(
                        color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(about,
                    textDirection: app.dir,
                    textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12, height: 1.6)),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final point = resolveMapPoint(
                        nameAr: it.nameAr,
                        nameEn: it.nameEn,
                        locationAr: it.locationAr,
                        locationEn: it.locationEn,
                      );
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MapScreen(
                          focusPoint: point,
                          focusNameAr: it.nameAr,
                          focusNameEn: it.nameEn,
                          focusCategoryAr: it.typeAr,
                          focusCategoryEn: it.typeEn,
                          focusRating: it.rating,
                        ),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(Icons.map, size: 16, color: Colors.white),
                    label: Text(app.t('عرض على الخريطة', 'Show on Map'),
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    final app = AppState.instance;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(app.t('$label قيد التطوير', '$label coming soon')),
                  duration: Duration(seconds: 2)),
            );
          },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.cardDark2, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AppColors.blue),
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
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Center(
        child: Text(app.t('اختر عنصرًا لعرض تفاصيله', 'Select an item to see details'),
            textAlign: TextAlign.center,
            textDirection: app.dir,
            style: TextStyle(color: AppColors.textGrey)),
      ),
    );
  }
}