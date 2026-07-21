import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../services/local_db_service.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../widgets/themed_image.dart';
import '../auth/login_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../services/feedback_service.dart';
import '../../theme/app_typography.dart';
import '../../widgets/responsive.dart';
import '../map/map_screen.dart' show nablusCenter;
import '../../widgets/app_toggle_bar.dart';
import '../../widgets/keyboard_scrollable.dart';

enum AdminSchema {
  restaurant,
  hotel,
  pharmacy,
  attraction,
  shoppingVenue,
  listing,
  news,
  events,
}

// الأقسام اللي إلها موقع حقيقي على الخريطة يقدر الأدمن يحدده بالضغط (كل الأقسام
// الغنية الخمسة، بعكس الأقسام العامة/الأخبار اللي ما إلها موقع جغرافي فعليًا)
const _locationCapableSchemas = {
  AdminSchema.restaurant,
  AdminSchema.hotel,
  AdminSchema.pharmacy,
  AdminSchema.attraction,
  AdminSchema.shoppingVenue,
};

// الأقسام اللي عندها عمود isFeatured فعليًا بقاعدة البيانات
const _featuredCapableSchemas = {
  AdminSchema.hotel,
  AdminSchema.pharmacy,
  AdminSchema.attraction,
  AdminSchema.shoppingVenue,
};

enum _FieldType { text, multiline, number, toggle, dropdown }

class _FieldConfig {
  final String key;
  final String labelAr;
  final String labelEn;
  final _FieldType type;
  final List<String>? options;
  const _FieldConfig(
    this.key,
    this.labelAr,
    this.labelEn, {
    this.type = _FieldType.text,
  }) : options = null;
  const _FieldConfig.dropdown(
    this.key,
    this.labelAr,
    this.labelEn,
    this.options,
  ) : type = _FieldType.dropdown;
}

const _restaurantFields = [
  _FieldConfig('nameAr', 'الاسم (عربي)', 'Name (Arabic)'),
  _FieldConfig('nameEn', 'الاسم (إنجليزي)', 'Name (English)'),
  _FieldConfig('categoryAr', 'التصنيف (عربي)', 'Category (Arabic)'),
  _FieldConfig('categoryEn', 'التصنيف (إنجليزي)', 'Category (English)'),
  _FieldConfig.dropdown('cuisineKey', 'نوع المطبخ', 'Cuisine Type', [
    'traditional',
    'eastern',
    'cafe',
    'fastfood',
    'sweets',
    'italian',
  ]),
  _FieldConfig('locationAr', 'الموقع (عربي)', 'Location (Arabic)'),
  _FieldConfig('locationEn', 'الموقع (إنجليزي)', 'Location (English)'),
  _FieldConfig(
    'rating',
    'التقييم (مثلاً 4.5)',
    'Rating (e.g. 4.5)',
    type: _FieldType.number,
  ),
  _FieldConfig(
    'reviews',
    'عدد التقييمات',
    'Number of reviews',
    type: _FieldType.number,
  ),
  _FieldConfig(
    'priceRange',
    'نطاق السعر (مثلاً 20-30 ₪)',
    'Price range (e.g. 20-30 ₪)',
  ),
  _FieldConfig.dropdown('priceTier', 'فئة السعر', 'Price Tier', [
    'cheap',
    'medium',
    'high',
  ]),
  _FieldConfig('time', 'وقت التحضير/التوصيل', 'Prep/delivery time'),
  _FieldConfig('phone', 'رقم الهاتف', 'Phone number'),
  _FieldConfig(
    'aboutAr',
    'نبذة (عربي)',
    'About (Arabic)',
    type: _FieldType.multiline,
  ),
  _FieldConfig(
    'aboutEn',
    'نبذة (إنجليزي)',
    'About (English)',
    type: _FieldType.multiline,
  ),
];

const _hotelFields = [
  _FieldConfig('nameAr', 'الاسم (عربي)', 'Name (Arabic)'),
  _FieldConfig('nameEn', 'الاسم (إنجليزي)', 'Name (English)'),
  _FieldConfig('typeAr', 'النوع (عربي) - مثلاً فندق 4 نجوم', 'Type (Arabic)'),
  _FieldConfig('typeEn', 'النوع (إنجليزي)', 'Type (English)'),
  _FieldConfig('locationAr', 'الموقع (عربي)', 'Location (Arabic)'),
  _FieldConfig('locationEn', 'الموقع (إنجليزي)', 'Location (English)'),
  _FieldConfig(
    'rating',
    'التقييم (مثلاً 4.5)',
    'Rating (e.g. 4.5)',
    type: _FieldType.number,
  ),
  _FieldConfig(
    'reviews',
    'عدد التقييمات',
    'Number of reviews',
    type: _FieldType.number,
  ),
  _FieldConfig(
    'priceInfoAr',
    'السعر (عربي) - مثلاً 180-250 ₪ / ليلة',
    'Price (Arabic)',
  ),
  _FieldConfig('priceInfoEn', 'السعر (إنجليزي)', 'Price (English)'),
  _FieldConfig.dropdown('priceTier', 'فئة السعر', 'Price Tier', [
    'cheap',
    'medium',
    'high',
  ]),
  _FieldConfig('hoursAr', 'أوقات الاستقبال (عربي)', 'Reception hours (Arabic)'),
  _FieldConfig(
    'hoursEn',
    'أوقات الاستقبال (إنجليزي)',
    'Reception hours (English)',
  ),
  _FieldConfig('phone', 'رقم الهاتف', 'Phone number'),
  _FieldConfig(
    'gallery',
    'صور إضافية (مفصولة بفواصل)',
    'Extra photos (comma-separated)',
  ),
  _FieldConfig(
    'amenities',
    'الخدمات - wifi,parking,restaurant,roomService',
    'Amenities (comma-separated)',
  ),
  _FieldConfig('tags', 'وسوم (مفصولة بفواصل)', 'Tags (comma-separated)'),
  _FieldConfig(
    'aboutAr',
    'نبذة (عربي)',
    'About (Arabic)',
    type: _FieldType.multiline,
  ),
  _FieldConfig(
    'aboutEn',
    'نبذة (إنجليزي)',
    'About (English)',
    type: _FieldType.multiline,
  ),
];

const _pharmacyFields = [
  _FieldConfig('nameAr', 'الاسم (عربي)', 'Name (Arabic)'),
  _FieldConfig('nameEn', 'الاسم (إنجليزي)', 'Name (English)'),
  _FieldConfig('locationAr', 'الموقع (عربي)', 'Location (Arabic)'),
  _FieldConfig('locationEn', 'الموقع (إنجليزي)', 'Location (English)'),
  _FieldConfig(
    'rating',
    'التقييم (مثلاً 4.5)',
    'Rating (e.g. 4.5)',
    type: _FieldType.number,
  ),
  _FieldConfig(
    'reviews',
    'عدد التقييمات',
    'Number of reviews',
    type: _FieldType.number,
  ),
  _FieldConfig('hoursAr', 'ساعات العمل (عربي)', 'Working hours (Arabic)'),
  _FieldConfig('hoursEn', 'ساعات العمل (إنجليزي)', 'Working hours (English)'),
  _FieldConfig(
    'is24Hours',
    'تعمل 24 ساعة',
    'Open 24 hours',
    type: _FieldType.toggle,
  ),
  _FieldConfig(
    'hasDelivery',
    'يوجد توصيل',
    'Has delivery',
    type: _FieldType.toggle,
  ),
  _FieldConfig('phone', 'رقم الهاتف', 'Phone number'),
  _FieldConfig(
    'tags',
    'وسوم - nearHospital,nearUniversity',
    'Tags (comma-separated)',
  ),
  _FieldConfig(
    'aboutAr',
    'نبذة (عربي)',
    'About (Arabic)',
    type: _FieldType.multiline,
  ),
  _FieldConfig(
    'aboutEn',
    'نبذة (إنجليزي)',
    'About (English)',
    type: _FieldType.multiline,
  ),
];

const _attractionFields = [
  _FieldConfig('nameAr', 'الاسم (عربي)', 'Name (Arabic)'),
  _FieldConfig('nameEn', 'الاسم (إنجليزي)', 'Name (English)'),
  _FieldConfig(
    'categories',
    'التصنيفات - historical,religious,nature,oldCity,culture',
    'Categories (comma-separated)',
  ),
  _FieldConfig('locationAr', 'الموقع (عربي)', 'Location (Arabic)'),
  _FieldConfig('locationEn', 'الموقع (إنجليزي)', 'Location (English)'),
  _FieldConfig(
    'rating',
    'التقييم (مثلاً 4.5)',
    'Rating (e.g. 4.5)',
    type: _FieldType.number,
  ),
  _FieldConfig(
    'reviews',
    'عدد التقييمات',
    'Number of reviews',
    type: _FieldType.number,
  ),
  _FieldConfig('visitHoursAr', 'أوقات الزيارة (عربي)', 'Visit hours (Arabic)'),
  _FieldConfig(
    'visitHoursEn',
    'أوقات الزيارة (إنجليزي)',
    'Visit hours (English)',
  ),
  _FieldConfig('entryFeeAr', 'رسوم الدخول (عربي)', 'Entry fee (Arabic)'),
  _FieldConfig('entryFeeEn', 'رسوم الدخول (إنجليزي)', 'Entry fee (English)'),
  _FieldConfig(
    'aboutAr',
    'نبذة تاريخية (عربي)',
    'Historical overview (Arabic)',
    type: _FieldType.multiline,
  ),
  _FieldConfig(
    'aboutEn',
    'نبذة تاريخية (إنجليزي)',
    'Historical overview (English)',
    type: _FieldType.multiline,
  ),
];

const _shoppingVenueFields = [
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
    type: _FieldType.number,
  ),
  _FieldConfig(
    'reviews',
    'عدد التقييمات',
    'Number of reviews',
    type: _FieldType.number,
  ),
  _FieldConfig('hoursAr', 'ساعات العمل (عربي)', 'Working hours (Arabic)'),
  _FieldConfig('hoursEn', 'ساعات العمل (إنجليزي)', 'Working hours (English)'),
  _FieldConfig('phone', 'رقم الهاتف', 'Phone number'),
  _FieldConfig(
    'aboutAr',
    'نبذة (عربي)',
    'About (Arabic)',
    type: _FieldType.multiline,
  ),
  _FieldConfig(
    'aboutEn',
    'نبذة (إنجليزي)',
    'About (English)',
    type: _FieldType.multiline,
  ),
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
    type: _FieldType.number,
  ),
  _FieldConfig(
    'reviews',
    'عدد التقييمات',
    'Number of reviews',
    type: _FieldType.number,
  ),
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
  _FieldConfig(
    'aboutAr',
    'نبذة (عربي)',
    'About (Arabic)',
    type: _FieldType.multiline,
  ),
  _FieldConfig(
    'aboutEn',
    'نبذة (إنجليزي)',
    'About (English)',
    type: _FieldType.multiline,
  ),
];

const _newsFields = [
  _FieldConfig('titleAr', 'العنوان (عربي)', 'Title (Arabic)'),
  _FieldConfig('titleEn', 'العنوان (إنجليزي)', 'Title (English)'),
  _FieldConfig('dateAr', 'التاريخ (عربي)', 'Date (Arabic)'),
  _FieldConfig('dateEn', 'التاريخ (إنجليزي)', 'Date (English)'),
  _FieldConfig('categoryAr', 'التصنيف (عربي)', 'Category (Arabic)'),
  _FieldConfig('categoryEn', 'التصنيف (إنجليزي)', 'Category (English)'),
  _FieldConfig.dropdown('categoryKey', 'مفتاح التصنيف', 'Category Key', [
    'tourism',
    'events',
    'development',
    'culture',
  ]),
  _FieldConfig(
    'summaryAr',
    'ملخص (عربي)',
    'Summary (Arabic)',
    type: _FieldType.multiline,
  ),
  _FieldConfig(
    'summaryEn',
    'ملخص (إنجليزي)',
    'Summary (English)',
    type: _FieldType.multiline,
  ),
  _FieldConfig(
    'bodyAr',
    'نص الخبر الكامل (عربي)',
    'Full article body (Arabic)',
    type: _FieldType.multiline,
  ),
  _FieldConfig(
    'bodyEn',
    'نص الخبر الكامل (إنجليزي)',
    'Full article body (English)',
    type: _FieldType.multiline,
  ),
];

const _eventFields = [
  _FieldConfig('titleAr', 'العنوان (عربي)', 'Title (Arabic)'),
  _FieldConfig('titleEn', 'العنوان (إنجليزي)', 'Title (English)'),
  _FieldConfig('venueAr', 'المكان (عربي)', 'Venue (Arabic)'),
  _FieldConfig('venueEn', 'المكان (إنجليزي)', 'Venue (English)'),
  _FieldConfig('day', 'اليوم (رقم)', 'Day (number)'),
  _FieldConfig('monthAr', 'الشهر (عربي)', 'Month (Arabic)'),
  _FieldConfig('monthEn', 'الشهر (إنجليزي)', 'Month (English)'),
  _FieldConfig('timeAr', 'الوقت (عربي)', 'Time (Arabic)'),
  _FieldConfig('timeEn', 'الوقت (إنجليزي)', 'Time (English)'),
  _FieldConfig(
    'aboutAr',
    'وصف الفعالية (عربي)',
    'Event description (Arabic)',
    type: _FieldType.multiline,
  ),
  _FieldConfig(
    'aboutEn',
    'وصف الفعالية (إنجليزي)',
    'Event description (English)',
    type: _FieldType.multiline,
  ),
];

List<_FieldConfig> _fieldsFor(AdminSchema schema) {
  switch (schema) {
    case AdminSchema.restaurant:
      return _restaurantFields;
    case AdminSchema.hotel:
      return _hotelFields;
    case AdminSchema.pharmacy:
      return _pharmacyFields;
    case AdminSchema.attraction:
      return _attractionFields;
    case AdminSchema.shoppingVenue:
      return _shoppingVenueFields;
    case AdminSchema.listing:
      return _listingFields;
    case AdminSchema.news:
      return _newsFields;
    case AdminSchema.events:
      return _eventFields;
  }
}

String _titleFieldValue(Map<String, dynamic> item, AdminSchema schema) {
  if (schema == AdminSchema.news || schema == AdminSchema.events) {
    return item['titleAr'] ?? '';
  }
  return item['nameAr'] ?? '';
}

String _subtitleFieldValue(Map<String, dynamic> item, AdminSchema schema) {
  switch (schema) {
    case AdminSchema.restaurant:
      return item['categoryAr'] ?? '';
    case AdminSchema.hotel:
    case AdminSchema.shoppingVenue:
      return item['typeAr'] ?? '';
    case AdminSchema.pharmacy:
    case AdminSchema.attraction:
      return item['locationAr'] ?? '';
    case AdminSchema.listing:
      return item['typeAr'] ?? '';
    case AdminSchema.news:
      return item['dateAr'] ?? '';
    case AdminSchema.events:
      return item['venueAr'] ?? '';
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
      'photoQuery': 'restaurant food table Nablus',
      'localAsset': 'assets/images/category_icons/restaurants.jpg',
    },
    {
      'boxName': 'hotels',
      'titleAr': 'الفنادق',
      'titleEn': 'Hotels',
      'icon': Icons.hotel,
      'color': AppColors.purple,
      'schema': AdminSchema.hotel,
      'photoQuery': 'hotel room bed Nablus',
      'localAsset': 'assets/images/category_icons/hotels.jpg',
    },
    {
      'boxName': 'attractions',
      'titleAr': 'سياحة ومعالم',
      'titleEn': 'Attractions',
      'icon': Icons.mosque,
      'color': AppColors.gold,
      'schema': AdminSchema.attraction,
      'photoQuery': 'landmark old city alley Nablus',
      'localAsset': 'assets/images/category_icons/attractions.jpg',
    },
    {
      'boxName': 'shopping',
      'titleAr': 'تسوق',
      'titleEn': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': AppColors.primary,
      'schema': AdminSchema.shoppingVenue,
      'photoQuery': 'market shopping bags Nablus',
      'localAsset': 'assets/images/category_icons/shopping.avif',
    },
    {
      'boxName': 'transport',
      'titleAr': 'مواصلات',
      'titleEn': 'Transport',
      'icon': Icons.directions_bus,
      'color': AppColors.teal,
      'schema': AdminSchema.listing,
      'photoQuery': 'bus station transport Nablus',
      'localAsset': 'assets/images/category_icons/transport.png',
    },
    {
      'boxName': 'health',
      'titleAr': 'صحة',
      'titleEn': 'Health',
      'icon': Icons.favorite,
      'color': AppColors.teal,
      'schema': AdminSchema.listing,
      'photoQuery': 'hospital medical cross Nablus',
      'localAsset': 'assets/images/category_icons/health.png',
    },
    {
      'boxName': 'pharmacies',
      'titleAr': 'صيدليات',
      'titleEn': 'Pharmacies',
      'icon': Icons.local_pharmacy,
      'color': AppColors.primary,
      'schema': AdminSchema.pharmacy,
      'photoQuery': 'pharmacy medicine shelves Nablus',
      'localAsset': 'assets/images/category_icons/pharmacies.png',
    },
    {
      'boxName': 'education',
      'titleAr': 'تعليم',
      'titleEn': 'Education',
      'icon': Icons.school,
      'color': AppColors.purple,
      'schema': AdminSchema.listing,
      'photoQuery': 'university campus Nablus',
    },
    {
      'boxName': 'banks',
      'titleAr': 'بنوك وصرافة',
      'titleEn': 'Banks & Exchange',
      'icon': Icons.account_balance,
      'color': AppColors.teal,
      'schema': AdminSchema.listing,
      'photoQuery': 'bank building Nablus',
      'localAsset': 'assets/images/category_icons/banks.jpg',
    },
    {
      'boxName': 'entertainment',
      'titleAr': 'ترفيه',
      'titleEn': 'Entertainment',
      'icon': Icons.attractions,
      'color': AppColors.red,
      'schema': AdminSchema.listing,
      'photoQuery': 'entertainment amusement park Nablus',
      'localAsset': 'assets/images/category_icons/entertainment.webp',
    },
    {
      'boxName': 'government',
      'titleAr': 'خدمات حكومية',
      'titleEn': 'Government Services',
      'icon': Icons.apartment,
      'color': AppColors.gold,
      'schema': AdminSchema.listing,
      'photoQuery': 'government building Nablus',
      'localAsset': 'assets/images/category_icons/government.png',
    },
    {
      'boxName': 'news',
      'titleAr': 'الأخبار',
      'titleEn': 'News',
      'icon': Icons.article,
      'color': AppColors.primary,
      'schema': AdminSchema.news,
      'photoQuery': 'Nablus panorama',
      'localAsset': 'assets/images/category_icons/news.jpg',
    },
    {
      'boxName': 'events',
      'titleAr': 'الفعاليات القادمة',
      'titleEn': 'Upcoming Events',
      'icon': Icons.event,
      'color': AppColors.teal,
      'schema': AdminSchema.events,
      'photoQuery': 'street festival crowd',
      'localAsset': 'assets/images/category_icons/events.webp',
    },
  ];

  bool? _serverOk; // null = لسا عم يفحص
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkServer() async {
    final ok = await ApiService.isServerReachable();
    if (mounted) setState(() => _serverOk = ok);
  }

  bool _syncingAll = false;

  /// بينشئ على السيرفر أي عنصر موجود محليًا بس (عليه أيقونة الغيمة المشطوبة —
  /// apiId فاضي) بكل الأقسام دفعة وحدة، حتى يصير الكل متزامن ومقدور تعديله
  /// بشكل صحيح (تحديث حقيقي مش نسخة جديدة كل مرة).
  Future<void> _syncAllLocalToServer(BuildContext context) async {
    final app = AppState.instance;
    final token = AuthService.instance.adminToken;
    if (token == null) {
      _showSnack(
        context,
        app.t(
          'انتهت جلسة الدخول — سجّلي دخول أدمن من جديد',
          'Session expired — please log in as admin again',
        ),
      );
      return;
    }
    setState(() => _syncingAll = true);
    int created = 0;
    int failed = 0;
    for (final s in _sections) {
      final boxName = s['boxName'] as String;
      // نجيب أحدث نسخة من السيرفر أول شي حتى ما ننشئ عنصر موجود أصلًا بس
      // بأسماء مختلفة شوي (نفس منطق _refresh).
      await ApiService.syncBox(boxName);
      final items = LocalDbService.instance.getAll(boxName);
      for (final entry in items) {
        final apiId = entry.value['apiId'] as String?;
        if (apiId != null) continue; // متزامن أصلًا
        final fields = Map<String, dynamic>.from(entry.value)
          ..remove('apiId')
          ..remove('serverImageUrl')
          ..remove('customImageBase64')
          ..remove('image')
          ..remove('lat')
          ..remove('lng')
          ..remove('subTypeKey');
        final status = await ApiService.createItem(token, boxName, fields);
        if (status >= 200 && status < 300) {
          created++;
        } else {
          failed++;
        }
      }
      // نعيد المزامنة حتى العناصر يلي انضافت هلأ تاخد apiId الحقيقي محليًا
      await ApiService.syncBox(boxName);
    }
    if (!mounted) return;
    setState(() {
      _syncingAll = false;
      _serverOk = true;
    });
    if (context.mounted) {
      _showSnack(
        context,
        app.t(
          'تمت المزامنة: أُضيف $created عنصر جديد للسيرفر${failed > 0 ? ' (فشل $failed)' : ''}',
          'Sync complete: $created new items added to the server${failed > 0 ? ' ($failed failed)' : ''}',
        ),
        isError: failed > 0,
      );
    }
  }

  void _showSnack(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.red : AppColors.teal,
      ),
    );
  }

  int _countFor(String boxName) =>
      LocalDbService.instance.getAll(boxName).length;

  /// نتائج البحث الموحّد عبر كل أقسام البيانات دفعة وحدة (اسم العنصر بالعربي أو الإنجليزي)
  List<Map<String, dynamic>> get _searchResults {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return [];
    final results = <Map<String, dynamic>>[];
    for (final s in _sections) {
      for (final entry in LocalDbService.instance.getAll(s['boxName'])) {
        final title = _titleFieldValue(entry.value, s['schema']);
        if (title.toLowerCase().contains(q)) {
          results.add({'section': s, 'title': title, 'item': entry.value});
        }
      }
    }
    return results.take(30).toList();
  }

  Future<void> _openSection(
    BuildContext context,
    Map<String, dynamic> s,
  ) async {
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
    final totalItems = _sections.fold<int>(
      0,
      (sum, s) => sum + _countFor(s['boxName']),
    );
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
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.primaryGradient,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: AppColors.glowShadow,
                          ),
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            app.t('لوحة إدارة البيانات', 'Data Admin Panel'),
                            textDirection: app.dir,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title(
                              AppColors.textWhite,
                            ).copyWith(fontSize: 16),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NotificationsScreen(),
                              ),
                            );
                            if (mounted) setState(() {});
                          },
                          child: Stack(
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                color: AppColors.textWhite,
                                size: 22,
                              ),
                              if (FeedbackService.instance.unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: AppColors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${FeedbackService.instance.unreadCount}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: isMobile(context) ? 10 : 16),
                        AppToggleBar(),
                        SizedBox(width: isMobile(context) ? 10 : 16),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _confirmLogout(context),
                          child: Icon(
                            Icons.logout_rounded,
                            color: AppColors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_serverOk == false)
                    Container(
                      width: double.infinity,
                      color: AppColors.red.withValues(alpha: 0.15),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 16,
                            color: AppColors.red,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              app.t(
                                'السيرفر مو شغال — التعديلات ما رح تنحفظ لحد ما تشغّليه (npm run dev بمجلد backend)',
                                'Server is not running — changes won\'t be saved until you start it (npm run dev in the backend folder)',
                              ),
                              textDirection: app.dir,
                              style: TextStyle(
                                color: AppColors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() {
                              _serverOk = null;
                              _checkServer();
                            }),
                            child: Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: AppColors.red,
                            ),
                          ),
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
                                    icon: Icons.dns_rounded,
                                    color: _serverOk == true
                                        ? AppColors.teal
                                        : AppColors.red,
                                    labelAr: 'حالة السيرفر',
                                    labelEn: 'Server Status',
                                    value: _serverOk == null
                                        ? app.t('...', '...')
                                        : (_serverOk!
                                              ? app.t('شغال', 'Online')
                                              : app.t('مقفول', 'Offline')),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _syncingAll
                                    ? null
                                    : () => _syncAllLocalToServer(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.borderColor),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                ),
                                icon: _syncingAll
                                    ? SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : Icon(
                                        Icons.cloud_upload_rounded,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                label: Text(
                                  _syncingAll
                                      ? app.t(
                                          'جارِ المزامنة...',
                                          'Syncing...',
                                        )
                                      : app.t(
                                          'مزامنة كل العناصر المحلية مع السيرفر',
                                          'Sync all local-only items to the server',
                                        ),
                                  style: TextStyle(color: AppColors.textWhite),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            Container(
                              height: 44,
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
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
                                    color: AppColors.textGrey,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (v) =>
                                          setState(() => _searchQuery = v),
                                      style: AppTypography.body(
                                        AppColors.textWhite,
                                      ).copyWith(fontSize: 13),
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        border: InputBorder.none,
                                        hintText: app.t(
                                          'ابحث باسم أي عنصر بكل الأقسام...',
                                          'Search any item across all sections...',
                                        ),
                                        hintStyle: AppTypography.caption(
                                          AppColors.textGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty)
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => setState(() {
                                        _searchQuery = '';
                                        _searchController.clear();
                                      }),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_searchQuery.trim().isNotEmpty) ...[
                              SizedBox(height: 14),
                              Builder(
                                builder: (context) {
                                  final results = _searchResults;
                                  if (results.isEmpty) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      child: Center(
                                        child: Text(
                                          app.t(
                                            'ما في نتائج مطابقة',
                                            'No matching results',
                                          ),
                                          style: AppTypography.body(
                                            AppColors.textGrey,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      for (final r in results) ...[
                                        _SearchResultTile(
                                          section: r['section'],
                                          title: r['title'],
                                          onTap: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AdminCollectionScreen(
                                                      boxName:
                                                          r['section']['boxName'],
                                                      titleAr:
                                                          r['section']['titleAr'],
                                                      titleEn:
                                                          r['section']['titleEn'],
                                                      schema:
                                                          r['section']['schema'],
                                                      initialSearchQuery:
                                                          r['title'],
                                                    ),
                                              ),
                                            );
                                            if (mounted) setState(() {});
                                          },
                                        ),
                                        SizedBox(height: 8),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ] else ...[
                              SizedBox(height: 24),
                              Text(
                                app.t('أقسام البيانات', 'Data Sections'),
                                textDirection: app.dir,
                                style: AppTypography.headline(
                                  AppColors.textWhite,
                                ).copyWith(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                app.t(
                                  'اختاري قسمًا لإضافة أو تعديل أو حذف عناصره، وارفعي صورة حقيقية لأي عنصر مباشرة — كل تعديل بينحفظ على قاعدة البيانات الحقيقية فورًا.',
                                  'Choose a section to add, edit, or delete its items, and upload a real photo for any item directly — every change is saved to the real database instantly.',
                                ),
                                textDirection: app.dir,
                                style: AppTypography.body(
                                  AppColors.textGrey,
                                ).copyWith(fontSize: 12),
                              ),
                              SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _sections.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: responsiveGridColumns(
                                        context,
                                        wide: 4,
                                        narrow: 2,
                                      ),
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
                                        border: Border.all(
                                          color: AppColors.borderColor,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.15,
                                            ),
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
                                            localAsset: s['localAsset'] as String?,
                                            fallbackSeed:
                                                s['boxName'] as String,
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
                                                  Colors.black.withValues(
                                                    alpha: 0.35,
                                                  ),
                                                  Colors.black.withValues(
                                                    alpha: 0.75,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(14),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 38,
                                                      height: 38,
                                                      decoration: BoxDecoration(
                                                        color: color.withValues(
                                                          alpha: 0.85,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        s['icon'],
                                                        color: Colors.white,
                                                        size: 19,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 3,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '$count',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                Text(
                                                  app.t(
                                                    s['titleAr'],
                                                    s['titleEn'],
                                                  ),
                                                  textDirection: app.dir,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  app.t(
                                                    '$count عنصر',
                                                    '$count items',
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10,
                                                  ),
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

  void _confirmLogout(BuildContext context) {
    final app = AppState.instance;
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: app.dir,
        child: AlertDialog(
          backgroundColor: AppColors.cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            app.t('تسجيل الخروج', 'Log Out'),
            textDirection: app.dir,
            style: TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            app.t(
              'هل أنت متأكد من رغبتك بتسجيل الخروج؟',
              'Are you sure you want to log out?',
            ),
            textDirection: app.dir,
            style: TextStyle(color: AppColors.textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                app.t('إلغاء', 'Cancel'),
                style: TextStyle(color: AppColors.textGrey),
              ),
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
              child: Text(
                app.t('تسجيل الخروج', 'Log Out'),
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// عنصر واحد بنتائج البحث الموحّد بلوحة الأدمن (اسم العنصر + القسم يلي هو فيه)
class _SearchResultTile extends StatelessWidget {
  final Map<String, dynamic> section;
  final String title;
  final VoidCallback onTap;
  const _SearchResultTile({
    required this.section,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final color = section['color'] as Color;
    return AppCard(
      padding: EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(section['icon'], color: Colors.white, size: 17),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 13),
                ),
                SizedBox(height: 2),
                Text(
                  app.t(section['titleAr'], section['titleEn']),
                  textDirection: app.dir,
                  style: AppTypography.caption(AppColors.textGrey),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left_rounded, color: AppColors.textGrey, size: 20),
        ],
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
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.title(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 18),
                ),
                Text(
                  app.t(labelAr, labelEn),
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(AppColors.textGrey),
                ),
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
  final String? initialSearchQuery;
  const AdminCollectionScreen({
    super.key,
    required this.boxName,
    required this.titleAr,
    required this.titleEn,
    required this.schema,
    this.initialSearchQuery,
  });

  @override
  State<AdminCollectionScreen> createState() => _AdminCollectionScreenState();
}

class _AdminCollectionScreenState extends State<AdminCollectionScreen> {
  List<MapEntry<dynamic, Map<String, dynamic>>> _items = [];
  String searchQuery = '';
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    searchQuery = widget.initialSearchQuery ?? '';
    _searchController = TextEditingController(text: searchQuery);
    _refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await ApiService.syncBox(
      widget.boxName,
    ); // نجيب أحدث نسخة من قاعدة البيانات أول شي
    if (!mounted) return;
    setState(() {
      _items = LocalDbService.instance.getAll(widget.boxName);
      _loading = false;
    });
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.red : AppColors.teal,
      ),
    );
  }

  Future<void> _saveItem(
    _AdminFormResult result, {
    dynamic existingKey,
    String? existingApiId,
  }) async {
    final token = AuthService.instance.adminToken;
    final app = AppState.instance;
    if (token == null) {
      _showMessage(
        app.t(
          'انتهت جلسة الدخول — سجّلي دخول أدمن من جديد',
          'Session expired — please log in as admin again',
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final status = existingApiId != null
        ? await ApiService.updateItem(
            token,
            widget.boxName,
            existingApiId,
            result.fields,
            imageBytes: result.imageBytes,
            imageFilename: result.imageFilename,
          )
        : await ApiService.createItem(
            token,
            widget.boxName,
            result.fields,
            imageBytes: result.imageBytes,
            imageFilename: result.imageFilename,
          );
    if (!mounted) return;
    setState(() => _saving = false);
    if (status < 200 || status >= 300) {
      if (status == 401 || status == 403) {
        AuthService.instance.adminToken = null;
        _showMessage(
          app.t(
            'انتهت جلسة الدخول — سجّلي خروج ودخول أدمن من جديد',
            'Session expired — please log out and log back in as admin',
          ),
        );
      } else if (status == -1) {
        _showMessage(
          app.t(
            'تعذّر الوصول للسيرفر — تأكدي إنه شغال (npm run dev)',
            'Could not reach the server — make sure it is running (npm run dev)',
          ),
        );
      } else {
        _showMessage(
          app.t(
            'فشل الحفظ — خطأ من السيرفر (كود $status)',
            'Save failed — server error (code $status)',
          ),
        );
      }
      return;
    }
    _showMessage(app.t('تم الحفظ بنجاح', 'Saved successfully'), isError: false);
    await _refresh();
  }

  Future<void> _deleteItemAt(dynamic key, String? apiId) async {
    final app = AppState.instance;
    if (apiId != null) {
      final token = AuthService.instance.adminToken;
      if (token == null) {
        _showMessage(
          app.t(
            'انتهت جلسة الدخول — سجّلي دخول أدمن من جديد',
            'Session expired — please log in as admin again',
          ),
        );
        return;
      }
      setState(() => _saving = true);
      final ok = await ApiService.deleteItem(token, widget.boxName, apiId);
      if (!mounted) return;
      setState(() => _saving = false);
      if (!ok) {
        _showMessage(
          app.t(
            'فشل الحذف — تأكدي إنه السيرفر شغال',
            'Delete failed — make sure the server is running',
          ),
        );
        return;
      }
    }
    await LocalDbService.instance.delete(widget.boxName, key);
    await _refresh();
  }

  List<MapEntry<dynamic, Map<String, dynamic>>> get _filtered {
    if (searchQuery.isEmpty) return _items;
    final q = searchQuery.toLowerCase();
    return _items
        .where(
          (e) => _titleFieldValue(
            e.value,
            widget.schema,
          ).toLowerCase().contains(q),
        )
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
                onPressed: _saving
                    ? null
                    : () async {
                        final result = await Navigator.of(context)
                            .push<_AdminFormResult>(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AdminFormScreen(schema: widget.schema),
                              ),
                            );
                        if (result != null) await _saveItem(result);
                      },
                icon: Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  app.t('إضافة', 'Add'),
                  style: AppTypography.title(
                    Colors.white,
                  ).copyWith(fontSize: 14),
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
                        Expanded(
                          child: Text(
                            app.t(widget.titleAr, widget.titleEn),
                            textDirection: app.dir,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title(
                              AppColors.textWhite,
                            ).copyWith(fontSize: 16),
                          ),
                        ),
                        if (_saving)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        else
                          Text(
                            '${_items.length} ${app.t('عنصر', 'items')}',
                            style: AppTypography.caption(AppColors.textGrey),
                          ),
                        SizedBox(width: 14),
                        AppToggleBar(),
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
                          Icon(
                            Icons.search_rounded,
                            size: 16,
                            color: AppColors.textGrey,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) => setState(() => searchQuery = v),
                              style: AppTypography.body(
                                AppColors.textWhite,
                              ).copyWith(fontSize: 13),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: app.t(
                                  'ابحث بالاسم...',
                                  'Search by name...',
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
                  ),
                  Expanded(
                    child: _loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : filtered.isEmpty
                        ? Center(
                            child: Text(
                              app.t('لا يوجد عناصر بعد', 'No items yet'),
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          )
                        : KeyboardScrollable(
                            controller: _scrollController,
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final entry = filtered[i];
                                final item = entry.value;
                                final apiId = item['apiId'] as String?;
                                return AppCard(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: ThemedImage(
                                          query:
                                              (item['photoQuery'] as String?)
                                                      ?.isNotEmpty ==
                                                  true
                                              ? item['photoQuery']
                                              : (item['typeEn'] ??
                                                    item['categoryEn'] ??
                                                    'nablus palestine city'),
                                          fallbackSeed:
                                              (item['nameEn'] as String?) ??
                                              _titleFieldValue(
                                                item,
                                                widget.schema,
                                              ),
                                          height: 44,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          customImageBase64:
                                              item['customImageBase64'],
                                          localAsset: item['image'],
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
                                                      color:
                                                          AppColors.textWhite,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                if (item['isFeatured'] ==
                                                    true) ...[
                                                  SizedBox(width: 6),
                                                  Icon(
                                                    Icons.bolt,
                                                    size: 14,
                                                    color: Color(0xFFF5A623),
                                                  ),
                                                ],
                                                if (apiId == null) ...[
                                                  SizedBox(width: 6),
                                                  Icon(
                                                    Icons.cloud_off_rounded,
                                                    size: 13,
                                                    color: AppColors.textGrey,
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
                                        onTap: _saving
                                            ? null
                                            : () async {
                                                final result =
                                                    await Navigator.of(
                                                      context,
                                                    ).push<_AdminFormResult>(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AdminFormScreen(
                                                              schema:
                                                                  widget.schema,
                                                              initialValues:
                                                                  item,
                                                            ),
                                                      ),
                                                    );
                                                if (result != null) {
                                                  await _saveItem(
                                                    result,
                                                    existingKey: entry.key,
                                                    existingApiId: apiId,
                                                  );
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
                                        onTap: _saving
                                            ? null
                                            : () => _confirmDelete(
                                                context,
                                                entry.key,
                                                apiId,
                                              ),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, dynamic key, String? apiId) {
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
              _deleteItemAt(key, apiId);
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

// ==================== نتيجة الفورم: الحقول + صورة جديدة (لو اختارت وحدة) ====================
class _AdminFormResult {
  final Map<String, dynamic> fields;
  final Uint8List? imageBytes;
  final String? imageFilename;
  _AdminFormResult({required this.fields, this.imageBytes, this.imageFilename});
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
  final Map<String, bool> _toggleValues = {};
  final Map<String, String> _dropdownValues = {};
  Uint8List? _newImageBytes;
  String? _newImageFilename;
  bool _pickingImage = false;
  bool _isFeatured = false;
  double? _lat;
  double? _lng;
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _lat = (widget.initialValues?['lat'] as num?)?.toDouble();
    _lng = (widget.initialValues?['lng'] as num?)?.toDouble();
    for (final field in _fieldsFor(widget.schema)) {
      final initial = widget.initialValues?[field.key];
      switch (field.type) {
        case _FieldType.toggle:
          _toggleValues[field.key] = initial == true;
          break;
        case _FieldType.dropdown:
          _dropdownValues[field.key] = (initial?.toString().isNotEmpty == true
              ? initial.toString()
              : field.options!.first);
          break;
        default:
          final text = initial is List
              ? initial.join(', ')
              : (initial?.toString() ?? '');
          _controllers[field.key] = TextEditingController(text: text);
      }
    }
    _isFeatured = widget.initialValues?['isFeatured'] == true;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _pickingImage = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );
      final file = result?.files.single;
      if (file?.bytes != null) {
        setState(() {
          _newImageBytes = file!.bytes;
          _newImageFilename = file.name;
        });
      }
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  void _save() {
    final Map<String, dynamic> fields = {};
    for (final field in _fieldsFor(widget.schema)) {
      switch (field.type) {
        case _FieldType.toggle:
          fields[field.key] = _toggleValues[field.key] ?? false;
          break;
        case _FieldType.dropdown:
          fields[field.key] = _dropdownValues[field.key];
          break;
        case _FieldType.number:
          fields[field.key] =
              double.tryParse(_controllers[field.key]!.text.trim()) ?? 0;
          break;
        default:
          fields[field.key] = _controllers[field.key]!.text.trim();
      }
    }
    if (_featuredCapableSchemas.contains(widget.schema)) {
      fields['isFeatured'] = _isFeatured;
    }
    if (_locationCapableSchemas.contains(widget.schema)) {
      fields['lat'] = _lat;
      fields['lng'] = _lng;
    }
    Navigator.of(context).pop(
      _AdminFormResult(
        fields: fields,
        imageBytes: _newImageBytes,
        imageFilename: _newImageFilename,
      ),
    );
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
                    Expanded(
                      child: Text(
                        isEditing
                            ? app.t('تعديل عنصر', 'Edit Item')
                            : app.t('إضافة عنصر جديد', 'Add New Item'),
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
                        Text(
                          app.t('الصورة', 'Photo'),
                          style: AppTypography.label(
                            AppColors.textGrey,
                          ).copyWith(fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 8),
                        _buildImagePicker(app),
                        SizedBox(height: 20),
                        if (_locationCapableSchemas.contains(
                          widget.schema,
                        )) ...[
                          Text(
                            app.t(
                              'الموقع على الخريطة (اختياري)',
                              'Location on Map (optional)',
                            ),
                            style: AppTypography.label(
                              AppColors.textGrey,
                            ).copyWith(fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 8),
                          _buildLocationPicker(app),
                          SizedBox(height: 20),
                        ],
                        for (final field in _fieldsFor(widget.schema)) ...[
                          _buildField(app, field),
                          SizedBox(height: 16),
                        ],
                        if (_featuredCapableSchemas.contains(
                          widget.schema,
                        )) ...[
                          AppCard(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 18,
                                  color: AppColors.gold,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app.t('عنصر مميز', 'Featured item'),
                                        style: AppTypography.label(
                                          AppColors.textWhite,
                                        ).copyWith(fontSize: 13),
                                      ),
                                      Text(
                                        app.t(
                                          'يظهر أولًا وبشارة "مميز" بكل القوائم',
                                          'Shown first with a "Featured" badge everywhere',
                                        ),
                                        style: AppTypography.caption(
                                          AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isFeatured,
                                  activeThumbColor: AppColors.primary,
                                  onChanged: (v) =>
                                      setState(() => _isFeatured = v),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.primaryGradient,
                              ),
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
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(AppState app, _FieldConfig field) {
    if (field.type == _FieldType.toggle) {
      return AppCard(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                app.t(field.labelAr, field.labelEn),
                style: AppTypography.label(
                  AppColors.textWhite,
                ).copyWith(fontSize: 13),
              ),
            ),
            Switch(
              value: _toggleValues[field.key] ?? false,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => _toggleValues[field.key] = v),
            ),
          ],
        ),
      );
    }

    if (field.type == _FieldType.dropdown) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            app.t(field.labelAr, field.labelEn),
            style: AppTypography.label(
              AppColors.textGrey,
            ).copyWith(fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _dropdownValues[field.key],
                isExpanded: true,
                dropdownColor: AppColors.cardDark,
                style: AppTypography.body(AppColors.textWhite),
                items: field.options!
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _dropdownValues[field.key] = v);
                },
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          app.t(field.labelAr, field.labelEn),
          style: AppTypography.label(
            AppColors.textGrey,
          ).copyWith(fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 6),
        TextField(
          controller: _controllers[field.key],
          maxLines: field.type == _FieldType.multiline ? 4 : 1,
          keyboardType: field.type == _FieldType.number
              ? TextInputType.number
              : TextInputType.text,
          style: AppTypography.body(AppColors.textWhite),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPicker(AppState app) {
    final hasPoint = _lat != null && _lng != null;
    final center = hasPoint ? LatLng(_lat!, _lng!) : nablusCenter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: hasPoint ? 15 : 13,
              minZoom: 10,
              maxZoom: 18,
              onTap: (tapPosition, point) => setState(() {
                _lat = point.latitude;
                _lng = point.longitude;
              }),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nablus.smart_city_guide',
              ),
              if (hasPoint)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_lat!, _lng!),
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 38,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                hasPoint
                    ? app.t(
                        'الموقع محدد (${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)})',
                        'Location set (${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)})',
                      )
                    : app.t(
                        'اضغطي على الخريطة لتحديد الموقع الدقيق',
                        'Tap the map to set the exact location',
                      ),
                textDirection: app.dir,
                style: AppTypography.caption(AppColors.textGrey),
              ),
            ),
            if (hasPoint)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() {
                  _lat = null;
                  _lng = null;
                }),
                child: Text(
                  app.t('مسح الموقع', 'Clear location'),
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePicker(AppState app) {
    final legacyBase64 = widget.initialValues?['customImageBase64'] as String?;
    final serverImageUrl = widget.initialValues?['serverImageUrl'] as String?;
    final localAsset = widget.initialValues?['image'] as String?;
    Widget? preview;
    if (_newImageBytes != null) {
      preview = Image.memory(
        _newImageBytes!,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (serverImageUrl != null && serverImageUrl.isNotEmpty) {
      preview = Image.network(
        '${ApiService.baseUrl.replaceAll('/api', '')}$serverImageUrl',
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
            Container(height: 160, color: AppColors.cardDark2),
      );
    } else if (legacyBase64 != null && legacyBase64.isNotEmpty) {
      preview = Image.memory(
        base64Decode(legacyBase64),
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (localAsset != null && localAsset.isNotEmpty) {
      preview = Image.asset(
        localAsset,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
            Container(height: 160, color: AppColors.cardDark2),
      );
    }

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
          if (preview != null)
            preview
          else
            Container(
              height: 120,
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.textGrey,
                    size: 30,
                  ),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: _pickingImage
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            Icons.upload,
                            size: 16,
                            color: AppColors.primary,
                          ),
                    label: Text(
                      preview != null
                          ? app.t('تغيير الصورة', 'Change Photo')
                          : app.t('اختر صورة', 'Choose Photo'),
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                if (_newImageBytes != null) ...[
                  SizedBox(width: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() {
                      _newImageBytes = null;
                      _newImageFilename = null;
                    }),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: AppColors.red,
                      ),
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
