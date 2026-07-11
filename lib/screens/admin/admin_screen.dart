import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../services/local_db_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/themed_image.dart';
import '../auth/login_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../services/feedback_service.dart';
import '../../theme/app_typography.dart';
import '../../widgets/responsive.dart';

enum AdminSchema { restaurant, listing, news }

class _FieldConfig {
  final String key;
  final String labelAr;
  final String labelEn;
  final bool multiline;
  final bool isNumber;
  const _FieldConfig(
    this.key,
    this.labelAr,
    this.labelEn, {
    this.multiline = false,
    this.isNumber = false,
  });
}

const _restaurantFields = [
  _FieldConfig('nameAr', 'الاسم (عربي)', 'Name (Arabic)'),
  _FieldConfig('nameEn', 'الاسم (إنجليزي)', 'Name (English)'),
  _FieldConfig('categoryAr', 'التصنيف (عربي)', 'Category (Arabic)'),
  _FieldConfig('categoryEn', 'التصنيف (إنجليزي)', 'Category (English)'),
  _FieldConfig(
    'cuisineKey',
    'مفتاح النوع (traditional/eastern/cafe/fastfood/sweets/italian)',
    'Cuisine key (traditional/eastern/cafe/fastfood/sweets/italian)',
  ),
  _FieldConfig('locationAr', 'الموقع (عربي)', 'Location (Arabic)'),
  _FieldConfig('locationEn', 'الموقع (إنجليزي)', 'Location (English)'),
  _FieldConfig(
    'rating',
    'التقييم (مثلاً 4.5)',
    'Rating (e.g. 4.5)',
    isNumber: true,
  ),
  _FieldConfig('reviews', 'عدد التقييمات', 'Number of reviews', isNumber: true),
  _FieldConfig(
    'priceRange',
    'نطاق السعر (مثلاً 20-30 ₪)',
    'Price range (e.g. 20-30 ₪)',
  ),
  _FieldConfig(
    'priceTier',
    'فئة السعر (cheap/medium/high)',
    'Price tier (cheap/medium/high)',
  ),
  _FieldConfig('time', 'وقت التحضير/التوصيل', 'Prep/delivery time'),
  _FieldConfig('aboutAr', 'نبذة (عربي)', 'About (Arabic)', multiline: true),
  _FieldConfig('aboutEn', 'نبذة (إنجليزي)', 'About (English)', multiline: true),
];

const _listingFields = [
  _FieldConfig('nameAr', 'الاسم (عربي)', 'Name (Arabic)'),
  _FieldConfig('nameEn', 'الاسم (إنجليزي)', 'Name (English)'),
  _FieldConfig('typeAr', 'النوع (عربي)', 'Type (Arabic)'),
  _FieldConfig('typeEn', 'النوع (إنجليزي)', 'Type (English)'),
  _FieldConfig('locationAr', 'الموقع (عربي)', 'Location (Arabic)'),
  _FieldConfig('locationEn', 'الموقع (إنجليزي)', 'Location (English)'),
  _FieldConfig(
    'rating',
    'التقييم (مثلاً 4.5)',
    'Rating (e.g. 4.5)',
    isNumber: true,
  ),
  _FieldConfig('reviews', 'عدد التقييمات', 'Number of reviews', isNumber: true),
  _FieldConfig(
    'infoLabelAr',
    'معلومة إضافية (عربي) - السعر/ساعات العمل',
    'Extra info (Arabic) - price/hours',
  ),
  _FieldConfig(
    'infoLabelEn',
    'معلومة إضافية (إنجليزي)',
    'Extra info (English)',
  ),
  _FieldConfig('phone', 'رقم الهاتف', 'Phone number'),
  _FieldConfig(
    'photoQuery',
    'كلمة بحث الصورة الاحتياطية (إنجليزي، مثلاً hotel exterior)',
    'Fallback photo search keyword (English)',
  ),
  _FieldConfig('aboutAr', 'نبذة (عربي)', 'About (Arabic)', multiline: true),
  _FieldConfig('aboutEn', 'نبذة (إنجليزي)', 'About (English)', multiline: true),
];

const _newsFields = [
  _FieldConfig('titleAr', 'العنوان (عربي)', 'Title (Arabic)'),
  _FieldConfig('titleEn', 'العنوان (إنجليزي)', 'Title (English)'),
  _FieldConfig('dateAr', 'التاريخ (عربي)', 'Date (Arabic)'),
  _FieldConfig('dateEn', 'التاريخ (إنجليزي)', 'Date (English)'),
  _FieldConfig('categoryAr', 'التصنيف (عربي)', 'Category (Arabic)'),
  _FieldConfig('categoryEn', 'التصنيف (إنجليزي)', 'Category (English)'),
  _FieldConfig(
    'categoryKey',
    'مفتاح التصنيف (tourism/events/development/culture)',
    'Category key (tourism/events/development/culture)',
  ),
  _FieldConfig('summaryAr', 'ملخص (عربي)', 'Summary (Arabic)', multiline: true),
  _FieldConfig(
    'summaryEn',
    'ملخص (إنجليزي)',
    'Summary (English)',
    multiline: true,
  ),
  _FieldConfig(
    'bodyAr',
    'نص الخبر الكامل (عربي)',
    'Full article body (Arabic)',
    multiline: true,
  ),
  _FieldConfig(
    'bodyEn',
    'نص الخبر الكامل (إنجليزي)',
    'Full article body (English)',
    multiline: true,
  ),
];

List<_FieldConfig> _fieldsFor(AdminSchema schema) {
  switch (schema) {
    case AdminSchema.restaurant:
      return _restaurantFields;
    case AdminSchema.listing:
      return _listingFields;
    case AdminSchema.news:
      return _newsFields;
  }
}

String _titleFieldValue(Map<String, dynamic> item, AdminSchema schema) {
  if (schema == AdminSchema.news) return item['titleAr'] ?? '';
  return item['nameAr'] ?? '';
}

String _subtitleFieldValue(Map<String, dynamic> item, AdminSchema schema) {
  switch (schema) {
    case AdminSchema.restaurant:
      return item['categoryAr'] ?? '';
    case AdminSchema.listing:
      return item['typeAr'] ?? '';
    case AdminSchema.news:
      return item['dateAr'] ?? '';
  }
}

// ==================== الشاشة الرئيسية للإدارة: لوحة تحكم بأقسام البيانات ====================
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  static const List<Map<String, dynamic>> _sections = [
    {
      'boxName': 'restaurants',
      'titleAr': 'المطاعم',
      'titleEn': 'Restaurants',
      'icon': Icons.restaurant,
      'color': AppColors.red,
      'schema': AdminSchema.restaurant,
      'photoQuery': 'Nablus restaurant',
    },
    {
      'boxName': 'hotels',
      'titleAr': 'الفنادق',
      'titleEn': 'Hotels',
      'icon': Icons.hotel,
      'color': AppColors.purple,
      'schema': AdminSchema.listing,
      'photoQuery': 'Nablus hotel',
    },
    {
      'boxName': 'attractions',
      'titleAr': 'سياحة ومعالم',
      'titleEn': 'Attractions',
      'icon': Icons.mosque,
      'color': AppColors.gold,
      'schema': AdminSchema.listing,
      'photoQuery': 'Nablus old city',
    },
    {
      'boxName': 'shopping',
      'titleAr': 'تسوق',
      'titleEn': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': AppColors.primary,
      'schema': AdminSchema.listing,
      'photoQuery': 'Nablus market',
    },
    {
      'boxName': 'transport',
      'titleAr': 'مواصلات',
      'titleEn': 'Transport',
      'icon': Icons.directions_bus,
      'color': AppColors.teal,
      'schema': AdminSchema.listing,
      'photoQuery': 'Nablus street',
    },
    {
      'boxName': 'health',
      'titleAr': 'صحة',
      'titleEn': 'Health',
      'icon': Icons.favorite,
      'color': AppColors.teal,
      'schema': AdminSchema.listing,
      'photoQuery': 'Nablus hospital',
    },
    {
      'boxName': 'pharmacies',
      'titleAr': 'صيدليات',
      'titleEn': 'Pharmacies',
      'icon': Icons.local_pharmacy,
      'color': AppColors.primary,
      'schema': AdminSchema.listing,
      'photoQuery': 'Nablus pharmacy',
    },
    {
      'boxName': 'education',
      'titleAr': 'تعليم',
      'titleEn': 'Education',
      'icon': Icons.school,
      'color': AppColors.purple,
      'schema': AdminSchema.listing,
      'photoQuery': 'An-Najah University campus',
    },
    {
      'boxName': 'banks',
      'titleAr': 'بنوك وصرافة',
      'titleEn': 'Banks & Exchange',
      'icon': Icons.account_balance,
      'color': AppColors.teal,
      'schema': AdminSchema.listing,
      'photoQuery': 'Bank of Palestine',
    },
    {
      'boxName': 'entertainment',
      'titleAr': 'ترفيه',
      'titleEn': 'Entertainment',
      'icon': Icons.attractions,
      'color': AppColors.red,
      'schema': AdminSchema.listing,
      'photoQuery': 'Nablus panorama',
    },
    {
      'boxName': 'government',
      'titleAr': 'خدمات حكومية',
      'titleEn': 'Government Services',
      'icon': Icons.apartment,
      'color': AppColors.gold,
      'schema': AdminSchema.listing,
      'photoQuery': 'Nablus panorama',
    },
    {
      'boxName': 'news',
      'titleAr': 'الأخبار',
      'titleEn': 'News',
      'icon': Icons.article,
      'color': AppColors.primary,
      'schema': AdminSchema.news,
      'photoQuery': 'Nablus panorama',
    },
  ];

  int _countFor(String boxName) => LocalDbService.instance.getAll(boxName).length;

  Future<void> _openSection(BuildContext context, Map<String, dynamic> s) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminCollectionScreen(
          boxName: s['boxName'],
          titleAr: s['titleAr'],
          titleEn: s['titleEn'],
          schema: s['schema'],
        ),
      ),
    );
    // نعيد بناء الشاشة عند الرجوع حتى تنعكس التعديلات فورًا على عدّادات العناصر
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final totalItems = _sections.fold<int>(0, (sum, s) => sum + _countFor(s['boxName']));
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.sidebarDark, AppColors.cardDark2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppColors.cardDark, shape: BoxShape.circle),
                            child: Icon(Icons.arrow_back_rounded, color: AppColors.textWhite, size: 18),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.primaryGradient),
                            shape: BoxShape.circle,
                            boxShadow: AppColors.glowShadow,
                          ),
                          child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 17),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            app.t('لوحة إدارة البيانات', 'Data Admin Panel'),
                            textDirection: app.dir,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 16),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => NotificationsScreen()),
                            );
                            if (mounted) setState(() {});
                          },
                          child: Stack(
                            children: [
                              Icon(Icons.notifications_none_rounded, color: AppColors.textWhite, size: 22),
                              if (FeedbackService.instance.unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(3),
                                    decoration:
                                        BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                                    child: Text(
                                        '${FeedbackService.instance.unreadCount}',
                                        style: TextStyle(color: Colors.white, fontSize: 8)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: isMobile(context) ? 10 : 16),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => app.toggleTheme(),
                          child: Icon(app.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              color: AppColors.textWhite, size: 20),
                        ),
                        SizedBox(width: isMobile(context) ? 10 : 16),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => app.toggleLanguage(),
                          child: isMobile(context)
                              ? Text(app.isArabic ? 'EN' : 'AR',
                                  style: AppTypography.label(AppColors.textWhite))
                              : Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardDark2,
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                  ),
                                  child: Text(app.isArabic ? 'عربي  EN' : 'EN  عربي',
                                      style: AppTypography.label(AppColors.textWhite)),
                                ),
                        ),
                        SizedBox(width: isMobile(context) ? 10 : 16),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _confirmLogout(context),
                          child: Icon(Icons.logout_rounded, color: AppColors.red, size: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.dataset,
                                  color: AppColors.primary,
                                  labelAr: 'إجمالي العناصر',
                                  labelEn: 'Total Items',
                                  value: '$totalItems',
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.category,
                                  color: AppColors.purple,
                                  labelAr: 'الأقسام',
                                  labelEn: 'Sections',
                                  value: '${_sections.length}',
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.image,
                                  color: AppColors.teal,
                                  labelAr: 'الصور المرفوعة',
                                  labelEn: 'Uploaded Photos',
                                  value: '${_sections.fold<int>(0, (sum, s) => sum + LocalDbService.instance.getAll(s['boxName']).where((e) => (e.value['customImageBase64'] ?? '').toString().isNotEmpty).length)}',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Text(
                            app.t('أقسام البيانات', 'Data Sections'),
                            textDirection: app.dir,
                            style: AppTypography.headline(AppColors.textWhite).copyWith(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            app.t(
                              'اختاري قسمًا لإضافة أو تعديل أو حذف عناصره، وارفعي صورة حقيقية لأي عنصر مباشرة.',
                              'Choose a section to add, edit, or delete its items, and upload a real photo for any item directly.',
                            ),
                            textDirection: app.dir,
                            style: AppTypography.body(AppColors.textGrey).copyWith(fontSize: 12),
                          ),
                          SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _sections.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: responsiveGridColumns(context, wide: 4, narrow: 2),
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 1.05,
                            ),
                            itemBuilder: (context, i) {
                              final s = _sections[i];
                              final count = _countFor(s['boxName']);
                              final color = s['color'] as Color;
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _openSection(context, s),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.borderColor),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ThemedImage(
                                        query: s['photoQuery'] as String,
                                        fallbackSeed: s['boxName'] as String,
                                        height: double.infinity,
                                        fallbackIcon: s['icon'],
                                        fallbackColor: color,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withValues(alpha: 0.35),
                                              Colors.black.withValues(alpha: 0.75),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 38,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                    color: color.withValues(alpha: 0.85),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Icon(s['icon'], color: Colors.white, size: 19),
                                                ),
                                                Spacer(),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.5),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text('$count',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold)),
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            Text(
                                              app.t(s['titleAr'], s['titleEn']),
                                              textDirection: app.dir,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              app.t('$count عنصر', '$count items'),
                                              style: TextStyle(color: Colors.white70, fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    final app = AppState.instance;
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: app.dir,
        child: AlertDialog(
          backgroundColor: AppColors.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(app.t('تسجيل الخروج', 'Log Out'),
              textDirection: app.dir,
              style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
          content: Text(
              app.t('هل أنت متأكد من رغبتك بتسجيل الخروج؟',
                  'Are you sure you want to log out?'),
              textDirection: app.dir,
              style: TextStyle(color: AppColors.textGrey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(app.t('إلغاء', 'Cancel'),
                  style: TextStyle(color: AppColors.textGrey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await AuthService.instance.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(app.t('تسجيل الخروج', 'Log Out'),
                  style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String labelAr;
  final String labelEn;
  final String value;
  const _StatCard({
    required this.icon,
    required this.color,
    required this.labelAr,
    required this.labelEn,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return AppCard(
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 18)),
                Text(app.t(labelAr, labelEn),
                    textDirection: app.dir,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption(AppColors.textGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== قائمة عناصر قسم معيّن مع أزرار تعديل/حذف/إضافة ====================
class AdminCollectionScreen extends StatefulWidget {
  final String boxName;
  final String titleAr;
  final String titleEn;
  final AdminSchema schema;
  const AdminCollectionScreen({
    super.key,
    required this.boxName,
    required this.titleAr,
    required this.titleEn,
    required this.schema,
  });

  @override
  State<AdminCollectionScreen> createState() => _AdminCollectionScreenState();
}

class _AdminCollectionScreenState extends State<AdminCollectionScreen> {
  List<MapEntry<dynamic, Map<String, dynamic>>> _items = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _items = LocalDbService.instance.getAll(widget.boxName);
    });
  }

  Future<void> _delete(dynamic key) async {
    await LocalDbService.instance.delete(widget.boxName, key);
    _refresh();
  }

  List<MapEntry<dynamic, Map<String, dynamic>>> get _filtered {
    if (searchQuery.isEmpty) return _items;
    final q = searchQuery.toLowerCase();
    return _items
        .where((e) => _titleFieldValue(e.value, widget.schema).toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final filtered = _filtered;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            floatingActionButton: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: AppColors.glowShadow,
              ),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AdminFormScreen(schema: widget.schema),
                    ),
                  );
                  if (result != null) {
                    await LocalDbService.instance.add(widget.boxName, result);
                    _refresh();
                  }
                },
                icon: Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  app.t('إضافة', 'Add'),
                  style: AppTypography.title(Colors.white).copyWith(fontSize: 14),
                ),
              ),
            ),
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
                            decoration: BoxDecoration(color: AppColors.cardDark, shape: BoxShape.circle),
                            child: Icon(Icons.arrow_back_rounded, color: AppColors.textWhite, size: 18),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            app.t(widget.titleAr, widget.titleEn),
                            textDirection: app.dir,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 16),
                          ),
                        ),
                        Text(
                          '${_items.length} ${app.t('عنصر', 'items')}',
                          style: AppTypography.caption(AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      height: 42,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.borderColor),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, size: 16, color: AppColors.textGrey),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => searchQuery = v),
                              style: AppTypography.body(AppColors.textWhite).copyWith(fontSize: 13),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: app.t('ابحث بالاسم...', 'Search by name...'),
                                hintStyle: AppTypography.caption(AppColors.textGrey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              app.t('لا يوجد عناصر بعد', 'No items yet'),
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final entry = filtered[i];
                              final item = entry.value;
                              final customImage = (item['customImageBase64'] ?? '') as String;
                              return AppCard(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: customImage.isNotEmpty
                                          ? Image.memory(
                                              base64Decode(customImage),
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 44,
                                              height: 44,
                                              color: AppColors.cardDark2,
                                              child: Icon(Icons.image_not_supported,
                                                  size: 18, color: AppColors.textGrey),
                                            ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  _titleFieldValue(
                                                    item,
                                                    widget.schema,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: AppColors.textWhite,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (item['isFeatured'] == true) ...[
                                                SizedBox(width: 6),
                                                Icon(
                                                  Icons.bolt,
                                                  size: 14,
                                                  color: Color(0xFFF5A623),
                                                ),
                                              ],
                                            ],
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            _subtitleFieldValue(
                                              item,
                                              widget.schema,
                                            ),
                                            style: TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () async {
                                        final result =
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AdminFormScreen(
                                                      schema: widget.schema,
                                                      initialValues: item,
                                                    ),
                                              ),
                                            );
                                        if (result != null) {
                                          await LocalDbService.instance.update(
                                            widget.boxName,
                                            entry.key,
                                            result,
                                          );
                                          _refresh();
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        margin: EdgeInsets.only(left: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.cardDark2,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () =>
                                          _confirmDelete(context, entry.key),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.cardDark2,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: AppColors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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

  void _confirmDelete(BuildContext context, dynamic key) {
    final app = AppState.instance;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          app.t('تأكيد الحذف', 'Confirm Delete'),
          style: TextStyle(color: AppColors.textWhite),
        ),
        content: Text(
          app.t(
            'هل أنت متأكدة من حذف هذا العنصر؟',
            'Are you sure you want to delete this item?',
          ),
          style: TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              app.t('إلغاء', 'Cancel'),
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _delete(key);
            },
            child: Text(
              app.t('حذف', 'Delete'),
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== شاشة نموذج الإضافة/التعديل ====================
class AdminFormScreen extends StatefulWidget {
  final AdminSchema schema;
  final Map<String, dynamic>? initialValues;
  const AdminFormScreen({super.key, required this.schema, this.initialValues});

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final Map<String, TextEditingController> _controllers = {};
  String? _imageBase64;
  bool _pickingImage = false;
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    for (final field in _fieldsFor(widget.schema)) {
      final initial = widget.initialValues?[field.key];
      _controllers[field.key] = TextEditingController(
        text: initial?.toString() ?? '',
      );
    }
    final existingImage = widget.initialValues?['customImageBase64'] as String?;
    if (existingImage != null && existingImage.isNotEmpty) {
      _imageBase64 = existingImage;
    }
    _isFeatured = widget.initialValues?['isFeatured'] == true;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _pickingImage = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );
      final bytes = result?.files.single.bytes;
      if (bytes != null) {
        setState(() => _imageBase64 = base64Encode(bytes));
      }
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  void _save() {
    final Map<String, dynamic> result = {};
    for (final field in _fieldsFor(widget.schema)) {
      final text = _controllers[field.key]!.text.trim();
      if (field.isNumber) {
        result[field.key] = double.tryParse(text) ?? 0;
      } else {
        result[field.key] = text;
      }
    }
    // نحافظ على أي حقول تقنية (أيقونة/لون) من القيمة الأصلية لو كانت موجودة، وإلا نعطي قيم افتراضية
    result['iconCodePoint'] =
        widget.initialValues?['iconCodePoint'] ?? Icons.place.codePoint;
    result['colorValue'] = widget.initialValues?['colorValue'] ?? 0xFF3B82F6;
    if (widget.schema == AdminSchema.restaurant) {
      result['image'] =
          widget.initialValues?['image'] ??
          'assets/images/restaurants/custom.jpg';
    }
    result['customImageBase64'] = _imageBase64 ?? '';
    result['isFeatured'] = _isFeatured;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final isEditing = widget.initialValues != null;
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
                        decoration: BoxDecoration(color: AppColors.cardDark, shape: BoxShape.circle),
                        child: Icon(Icons.arrow_back_rounded, color: AppColors.textWhite, size: 18),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      isEditing
                          ? app.t('تعديل عنصر', 'Edit Item')
                          : app.t('إضافة عنصر جديد', 'Add New Item'),
                      style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        app.t('الصورة', 'Photo'),
                        style: AppTypography.label(AppColors.textGrey).copyWith(fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: 8),
                      _buildImagePicker(app),
                      SizedBox(height: 20),
                      for (final field in _fieldsFor(widget.schema)) ...[
                        Text(
                          app.t(field.labelAr, field.labelEn),
                          style: AppTypography.label(AppColors.textGrey).copyWith(fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 6),
                        TextField(
                          controller: _controllers[field.key],
                          maxLines: field.multiline ? 4 : 1,
                          keyboardType: field.isNumber
                              ? TextInputType.number
                              : TextInputType.text,
                          style: AppTypography.body(AppColors.textWhite),
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.cardDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide(
                                color: AppColors.borderColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide(
                                color: AppColors.borderColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                      AppCard(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.bolt_rounded, size: 18, color: AppColors.gold),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.t('عنصر مميز', 'Featured item'),
                                    style: AppTypography.label(AppColors.textWhite).copyWith(fontSize: 13),
                                  ),
                                  Text(
                                    app.t(
                                      'يظهر أولًا وبشارة "مميز" بكل القوائم',
                                      'Shown first with a "Featured" badge everywhere',
                                    ),
                                    style: AppTypography.caption(AppColors.textGrey),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isFeatured,
                              activeThumbColor: AppColors.primary,
                              onChanged: (v) => setState(() => _isFeatured = v),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.primaryGradient),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            boxShadow: AppColors.glowShadow,
                          ),
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            child: Text(
                              app.t('حفظ', 'Save'),
                              style: AppTypography.title(Colors.white),
                            ),
                          ),
                        ),
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

  Widget _buildImagePicker(AppState app) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (_imageBase64 != null && _imageBase64!.isNotEmpty)
            Image.memory(
              base64Decode(_imageBase64!),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: AppColors.textGrey, size: 30),
                  SizedBox(height: 6),
                  Text(
                    app.t('لا توجد صورة مرفوعة بعد', 'No photo uploaded yet'),
                    style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickingImage ? null : _pickImage,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderColor),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: _pickingImage
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          )
                        : Icon(Icons.upload, size: 16, color: AppColors.primary),
                    label: Text(
                      _imageBase64 != null && _imageBase64!.isNotEmpty
                          ? app.t('تغيير الصورة', 'Change Photo')
                          : app.t('اختر صورة', 'Choose Photo'),
                      style: TextStyle(color: AppColors.textWhite, fontSize: 12),
                    ),
                  ),
                ),
                if (_imageBase64 != null && _imageBase64!.isNotEmpty) ...[
                  SizedBox(width: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _imageBase64 = null),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_outline, size: 16, color: AppColors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
