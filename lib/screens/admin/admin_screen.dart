import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../services/local_db_service.dart';

enum AdminSchema { restaurant, listing, news }

class _FieldConfig {
  final String key;
  final String labelAr;
  final String labelEn;
  final bool multiline;
  final bool isNumber;
  const _FieldConfig(this.key, this.labelAr, this.labelEn,
      {this.multiline = false, this.isNumber = false});
}

const _restaurantFields = [
  _FieldConfig('nameAr', 'الاسم (عربي)', 'Name (Arabic)'),
  _FieldConfig('nameEn', 'الاسم (إنجليزي)', 'Name (English)'),
  _FieldConfig('categoryAr', 'التصنيف (عربي)', 'Category (Arabic)'),
  _FieldConfig('categoryEn', 'التصنيف (إنجليزي)', 'Category (English)'),
  _FieldConfig('cuisineKey', 'مفتاح النوع (traditional/eastern/cafe/fastfood/sweets/italian)',
      'Cuisine key (traditional/eastern/cafe/fastfood/sweets/italian)'),
  _FieldConfig('locationAr', 'الموقع (عربي)', 'Location (Arabic)'),
  _FieldConfig('locationEn', 'الموقع (إنجليزي)', 'Location (English)'),
  _FieldConfig('rating', 'التقييم (مثلاً 4.5)', 'Rating (e.g. 4.5)', isNumber: true),
  _FieldConfig('reviews', 'عدد التقييمات', 'Number of reviews', isNumber: true),
  _FieldConfig('priceRange', 'نطاق السعر (مثلاً 20-30 ₪)', 'Price range (e.g. 20-30 ₪)'),
  _FieldConfig('priceTier', 'فئة السعر (cheap/medium/high)', 'Price tier (cheap/medium/high)'),
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
  _FieldConfig('rating', 'التقييم (مثلاً 4.5)', 'Rating (e.g. 4.5)', isNumber: true),
  _FieldConfig('reviews', 'عدد التقييمات', 'Number of reviews', isNumber: true),
  _FieldConfig('infoLabelAr', 'معلومة إضافية (عربي) - السعر/ساعات العمل', 'Extra info (Arabic) - price/hours'),
  _FieldConfig('infoLabelEn', 'معلومة إضافية (إنجليزي)', 'Extra info (English)'),
  _FieldConfig('phone', 'رقم الهاتف', 'Phone number'),
  _FieldConfig('photoQuery', 'كلمة بحث الصورة (إنجليزي، مثلاً hotel exterior)', 'Photo search keyword (English)'),
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
  _FieldConfig('categoryKey', 'مفتاح التصنيف (tourism/events/development/culture)',
      'Category key (tourism/events/development/culture)'),
  _FieldConfig('summaryAr', 'ملخص (عربي)', 'Summary (Arabic)', multiline: true),
  _FieldConfig('summaryEn', 'ملخص (إنجليزي)', 'Summary (English)', multiline: true),
  _FieldConfig('bodyAr', 'نص الخبر الكامل (عربي)', 'Full article body (Arabic)', multiline: true),
  _FieldConfig('bodyEn', 'نص الخبر الكامل (إنجليزي)', 'Full article body (English)', multiline: true),
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

// ==================== الشاشة الرئيسية للإدارة: قائمة الأقسام ====================
class AdminHomeScreen extends StatelessWidget {
  AdminHomeScreen({super.key});

  final List<Map<String, dynamic>> _sections = const [
    {'boxName': 'restaurants', 'titleAr': 'المطاعم', 'titleEn': 'Restaurants', 'icon': Icons.restaurant, 'schema': AdminSchema.restaurant},
    {'boxName': 'hotels', 'titleAr': 'الفنادق', 'titleEn': 'Hotels', 'icon': Icons.hotel, 'schema': AdminSchema.listing},
    {'boxName': 'attractions', 'titleAr': 'سياحة ومعالم', 'titleEn': 'Attractions', 'icon': Icons.mosque, 'schema': AdminSchema.listing},
    {'boxName': 'shopping', 'titleAr': 'تسوق', 'titleEn': 'Shopping', 'icon': Icons.shopping_bag, 'schema': AdminSchema.listing},
    {'boxName': 'transport', 'titleAr': 'مواصلات', 'titleEn': 'Transport', 'icon': Icons.directions_bus, 'schema': AdminSchema.listing},
    {'boxName': 'health', 'titleAr': 'صحة', 'titleEn': 'Health', 'icon': Icons.favorite, 'schema': AdminSchema.listing},
    {'boxName': 'pharmacies', 'titleAr': 'صيدليات', 'titleEn': 'Pharmacies', 'icon': Icons.local_pharmacy, 'schema': AdminSchema.listing},
    {'boxName': 'news', 'titleAr': 'الأخبار', 'titleEn': 'News', 'icon': Icons.article, 'schema': AdminSchema.news},
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
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
                        Icon(Icons.admin_panel_settings, color: AppColors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(app.t('لوحة إدارة البيانات', 'Data Admin Panel'),
                            textDirection: app.dir,
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                        app.t('اختاري القسم اللي بدك تعدليه', 'Choose the section you want to edit'),
                        textDirection: app.dir,
                        style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _sections.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, i) {
                        final s = _sections[i];
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AdminCollectionScreen(
                                boxName: s['boxName'],
                                titleAr: s['titleAr'],
                                titleEn: s['titleEn'],
                                schema: s['schema'],
                              ),
                            ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(s['icon'], color: AppColors.blue, size: 28),
                                SizedBox(height: 10),
                                Text(app.t(s['titleAr'], s['titleEn']),
                                    textDirection: app.dir,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.textWhite, fontSize: 12)),
                              ],
                            ),
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
}

// ==================== قائمة عناصر قسم معيّن مع أزرار تعديل/حذف/إضافة ====================
class AdminCollectionScreen extends StatefulWidget {
  final String boxName;
  final String titleAr;
  final String titleEn;
  final AdminSchema schema;
  AdminCollectionScreen({
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

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: AppColors.blue,
              onPressed: () async {
                final result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AdminFormScreen(schema: widget.schema),
                ));
                if (result != null) {
                  await LocalDbService.instance.add(widget.boxName, result);
                  _refresh();
                }
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(app.t('إضافة', 'Add'), style: TextStyle(color: Colors.white)),
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
                          child: Icon(Icons.arrow_back, color: AppColors.textWhite),
                        ),
                        SizedBox(width: 10),
                        Text(app.t(widget.titleAr, widget.titleEn),
                            textDirection: app.dir,
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Spacer(),
                        Text('${_items.length} ${app.t('عنصر', 'items')}',
                            style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _items.isEmpty
                        ? Center(
                            child: Text(app.t('لا يوجد عناصر بعد', 'No items yet'),
                                style: TextStyle(color: AppColors.textGrey)),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.all(16),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final entry = _items[i];
                              final item = entry.value;
                              return Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardDark,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_titleFieldValue(item, widget.schema),
                                              style: TextStyle(
                                                  color: AppColors.textWhite,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 2),
                                          Text(_subtitleFieldValue(item, widget.schema),
                                              style:
                                                  TextStyle(color: AppColors.textGrey, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () async {
                                        final result = await Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => AdminFormScreen(
                                            schema: widget.schema,
                                            initialValues: item,
                                          ),
                                        ));
                                        if (result != null) {
                                          await LocalDbService.instance
                                              .update(widget.boxName, entry.key, result);
                                          _refresh();
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        margin: EdgeInsets.only(left: 8),
                                        decoration: BoxDecoration(
                                            color: AppColors.cardDark2,
                                            borderRadius: BorderRadius.circular(8)),
                                        child: Icon(Icons.edit, size: 16, color: AppColors.blue),
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _confirmDelete(context, entry.key),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: AppColors.cardDark2,
                                            borderRadius: BorderRadius.circular(8)),
                                        child: Icon(Icons.delete, size: 16, color: AppColors.red),
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
        title: Text(app.t('تأكيد الحذف', 'Confirm Delete'),
            style: TextStyle(color: AppColors.textWhite)),
        content: Text(app.t('هل أنت متأكدة من حذف هذا العنصر؟', 'Are you sure you want to delete this item?'),
            style: TextStyle(color: AppColors.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(app.t('إلغاء', 'Cancel'), style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _delete(key);
            },
            child: Text(app.t('حذف', 'Delete'), style: TextStyle(color: AppColors.red)),
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
  AdminFormScreen({super.key, required this.schema, this.initialValues});

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final field in _fieldsFor(widget.schema)) {
      final initial = widget.initialValues?[field.key];
      _controllers[field.key] = TextEditingController(text: initial?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
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
    result['iconCodePoint'] = widget.initialValues?['iconCodePoint'] ?? Icons.place.codePoint;
    result['colorValue'] = widget.initialValues?['colorValue'] ?? 0xFF3B82F6;
    if (widget.schema == AdminSchema.restaurant) {
      result['image'] =
          widget.initialValues?['image'] ?? 'assets/images/restaurants/custom.jpg';
    }
    if (widget.schema == AdminSchema.news) {
      result['image'] = widget.initialValues?['image'] ?? '';
    }
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
                      child: Icon(Icons.arrow_back, color: AppColors.textWhite),
                    ),
                    SizedBox(width: 10),
                    Text(
                        isEditing
                            ? app.t('تعديل عنصر', 'Edit Item')
                            : app.t('إضافة عنصر جديد', 'Add New Item'),
                        style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final field in _fieldsFor(widget.schema)) ...[
                        Text(app.t(field.labelAr, field.labelEn),
                            style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        SizedBox(height: 6),
                        TextField(
                          controller: _controllers[field.key],
                          maxLines: field.multiline ? 4 : 1,
                          keyboardType:
                              field.isNumber ? TextInputType.number : TextInputType.text,
                          style: TextStyle(color: AppColors.textWhite),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.cardDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: AppColors.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: AppColors.borderColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(app.t('حفظ', 'Save'), style: TextStyle(color: Colors.white)),
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
}