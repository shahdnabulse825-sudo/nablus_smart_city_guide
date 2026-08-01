import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../common/detail_screen.dart';
import '../../theme/app_typography.dart';
import '../../widgets/responsive.dart';
import '../../widgets/app_toggle_bar.dart';
import '../../services/location_service.dart';
import '../places/all_places_screen.dart' show allPlaces, UniversalPlace;

// MapPlace.categoryKey يستخدم مفردات مختلفة عن categoryKey بباقي الشاشات
// (UniversalPlace) — هاي بتحوّلها لنفس المفردة الموحّدة حتى تقييمات نفس
// المكان تنعرض صح بغض النظر من وين انفتحت شاشة تفاصيله. بترجع null للفئات
// الزخرفية البحتة (معلم عام/حديقة) اللي مالها مراجعات أصلًا.
String? reviewPlaceTypeFor(String mapCategoryKey) {
  const map = {
    'restaurants': 'restaurant',
    'hotels': 'hotel',
    'pharmacies': 'pharmacy',
    'attractions': 'attraction',
    'shopping': 'shopping',
  };
  return map[mapCategoryKey];
}

// ==================== بيانات نقطة على الخريطة (إحداثيات حقيقية) ====================
class MapPlace {
  final String nameAr;
  final String nameEn;
  final String categoryAr;
  final String categoryEn;
  final String categoryKey; // landmark / park / restaurants / hotels / pharmacies / attractions / shopping
  final double lat;
  final double lng;
  final IconData icon;
  final Color color;
  final double rating;
  final String locationAr;
  final String locationEn;
  final bool is24Hours;

  MapPlace({
    required this.nameAr,
    required this.nameEn,
    required this.categoryAr,
    required this.categoryEn,
    required this.categoryKey,
    required this.lat,
    required this.lng,
    required this.icon,
    required this.color,
    required this.rating,
    this.locationAr = '',
    this.locationEn = '',
    this.is24Hours = false,
  });

  LatLng get point => LatLng(lat, lng);
}

// أيقونة/لون كل تصنيف حقيقي (نفس التصنيفات المستخدمة بباقي التطبيق) — تُستخدم
// عند تحويل بيانات الأماكن الحقيقية (allPlaces) لعلامات على الخريطة.
const Map<String, IconData> _realCategoryIcons = {
  'restaurants': Icons.restaurant,
  'hotels': Icons.hotel,
  'pharmacies': Icons.local_pharmacy,
  'attractions': Icons.account_balance,
  'shopping': Icons.shopping_bag,
};
const Map<String, Color> _realCategoryColors = {
  'restaurants': Color(0xFFE85D5D),
  'hotels': Color(0xFF6C5CE7),
  'pharmacies': Color(0xFF22C55E),
  'attractions': Color(0xFFC9A227),
  'shopping': Color(0xFF3B82F6),
};

/// تحوّل مكان حقيقي (من قاعدة البيانات المحلية/السيرفر) لنقطة على الخريطة —
/// حتى الخريطة تعرض كل الأماكن الحقيقية مش بس اللائحة المنسّقة القديمة يدويًا.
MapPlace mapPlaceFromUniversal(UniversalPlace p) {
  final point = resolveMapPoint(
    nameAr: p.nameAr,
    nameEn: p.nameEn,
    locationAr: p.locationAr,
    locationEn: p.locationEn,
    lat: p.lat,
    lng: p.lng,
  );
  return MapPlace(
    nameAr: p.nameAr,
    nameEn: p.nameEn,
    categoryAr: p.typeAr,
    categoryEn: p.typeEn,
    categoryKey: p.categoryKey,
    lat: point.latitude,
    lng: point.longitude,
    icon: _realCategoryIcons[p.categoryKey] ?? p.icon,
    color: _realCategoryColors[p.categoryKey] ?? p.color,
    rating: p.rating,
    locationAr: p.locationAr,
    locationEn: p.locationEn,
    is24Hours: p.is24Hours,
  );
}

// إحداثيات حقيقية داخل مدينة نابلس، فلسطين — تم التحقق منها عبر خدمة
// OpenStreetMap Nominatim (بحث جغرافي حقيقي بدون مفتاح API)، وليست تقديرية.
final LatLng nablusCenter = LatLng(
  32.2211,
  35.2608,
); // دوار الشهداء - مركز المدينة

final List<MapPlace> mapPlaces = [
  MapPlace(
    nameAr: 'البلدة القديمة',
    nameEn: 'Old City',
    categoryAr: 'معلم تاريخي',
    categoryEn: 'Historic Landmark',
    categoryKey: 'landmark',
    lat: 32.2202,
    lng: 35.2588,
    icon: Icons.account_balance,
    color: Color(0xFFC9A227),
    rating: 4.8,
  ),
  MapPlace(
    nameAr: 'جبل جرزيم',
    nameEn: 'Mount Gerizim',
    categoryAr: 'معلم طبيعي',
    categoryEn: 'Natural Landmark',
    categoryKey: 'landmark',
    lat: 32.2009,
    lng: 35.2731,
    icon: Icons.terrain,
    color: Color(0xFF4C8C4A),
    rating: 4.7,
  ),
  MapPlace(
    nameAr: 'ميدان الشهداء',
    nameEn: 'Martyrs Square',
    categoryAr: 'ميدان',
    categoryEn: 'Square',
    categoryKey: 'landmark',
    lat: 32.2211,
    lng: 35.2608,
    icon: Icons.location_city,
    color: Color(0xFF9C6B30),
    rating: 4.6,
  ),
  MapPlace(
    nameAr: 'جامع الساطون',
    nameEn: 'Al-Satoun Mosque',
    categoryAr: 'معلم ديني',
    categoryEn: 'Religious Landmark',
    categoryKey: 'landmark',
    lat: 32.2206,
    lng: 35.2593,
    icon: Icons.mosque,
    color: Color(0xFFB5651D),
    rating: 4.7,
  ),
  MapPlace(
    nameAr: 'مطعم البيت النابلسي',
    nameEn: 'Al-Bait Al-Nabulsi Restaurant',
    categoryAr: 'مطعم',
    categoryEn: 'Restaurant',
    categoryKey: 'restaurants',
    lat: 32.2220,
    lng: 35.2570,
    icon: Icons.restaurant,
    color: Color(0xFFE85D5D),
    rating: 4.8,
  ),
  MapPlace(
    nameAr: 'حديقة التعاون',
    nameEn: 'Al-Taawon Park',
    categoryAr: 'حديقة',
    categoryEn: 'Park',
    categoryKey: 'park',
    lat: 32.2245,
    lng: 35.2670,
    icon: Icons.park,
    color: Color(0xFF22C55E),
    rating: 4.4,
  ),
  MapPlace(
    nameAr: 'مركز نابلس مول',
    nameEn: 'Nablus Mall',
    categoryAr: 'تسوق',
    categoryEn: 'Shopping',
    categoryKey: 'shopping',
    lat: 32.2281,
    lng: 35.2370,
    icon: Icons.shopping_bag,
    color: Color(0xFF3B82F6),
    rating: 4.4,
  ),
];

final Map<String, IconData> _categoryIcons = {
  'all': Icons.apps,
  'landmark': Icons.account_balance,
  'restaurants': Icons.restaurant,
  'hotels': Icons.hotel,
  'pharmacies': Icons.local_pharmacy,
  'attractions': Icons.account_balance,
  'park': Icons.park,
  'shopping': Icons.shopping_bag,
};

Future<void> openInExternalMaps(MapPlace p) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${p.lat},${p.lng}',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// يفتح تطبيق خرائط خارجي بوضع الاتجاهات (Directions) مباشرة للوصول لنقطة
/// معيّنة عبر GPS، بدل مجرد عرض دبّوس الموقع.
Future<void> openDirectionsInExternalMaps(LatLng point) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=${point.latitude},${point.longitude}',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// يبحث عن مكان موجود مسبقًا بالقائمة المنسّقة (بإحداثيات دقيقة) بالاسم.
MapPlace? findCuratedPlace(String nameAr, String nameEn) {
  for (final p in mapPlaces) {
    if ((nameAr.isNotEmpty && p.nameAr == nameAr) ||
        (nameEn.isNotEmpty && p.nameEn == nameEn)) {
      return p;
    }
  }
  return null;
}

// إحداثيات حقيقية لأبرز شوارع وأحياء نابلس (مُتحقق منها عبر Nominatim/OpenStreetMap
// حيثما أمكن)، تُستخدم لوضع أي مكان (مطعم، فندق، صيدلية...) بموقع واقعي على
// الخريطة حتى لو ما كان بالقائمة المنسّقة.
final Map<String, LatLng> _areaCoords = {
  'البلدة القديمة': LatLng(32.2202, 35.2588), // مؤكّد: Nominatim (suburb)
  'old city': LatLng(32.2202, 35.2588),
  'رفيديا': LatLng(
    32.2281,
    35.2370,
  ), // مؤكّد تقريبيًا: Nominatim (رفيديا البلد)
  'rafidia': LatLng(32.2281, 35.2370),
  'الرابية': LatLng(
    32.2281,
    35.2223,
  ), // مؤكّد: حرم جامعة النجاح الجديد بالرابية
  'rabya': LatLng(32.2281, 35.2223),
  'شارع الجامعة': LatLng(
    32.2245,
    35.2615,
  ), // شارع مركزي قرب وسط البلد (وليس الحرم الجديد البعيد)
  'university': LatLng(32.2245, 35.2615),
  'وسط البلد': LatLng(32.2211, 35.2608), // مؤكّد: دوار الشهداء
  'downtown': LatLng(32.2211, 35.2608),
  'دوار الشهداء': LatLng(32.2211, 35.2608), // مؤكّد: Nominatim (نافورة الدوار)
  'martyrs': LatLng(32.2211, 35.2608),
  'الدوار': LatLng(32.2211, 35.2608), // الاسم الشائع محليًا لدوار الشهداء (نفس النقطة)
  'al-dawwar': LatLng(32.2211, 35.2608),
  'شارع فيصل': LatLng(32.2231, 35.2618), // مؤكّد: Nominatim (شارع الملك فيصل)
  'faisal': LatLng(32.2231, 35.2618),
  'شارع عمان': LatLng(32.2144, 35.2794), // مؤكّد: Nominatim (شارع عمان)
  'amman': LatLng(32.2144, 35.2794),
  'شارع سفيان': LatLng(32.2220, 35.2570),
  'sufyan': LatLng(32.2220, 35.2570),
  'المساكن الشعبية': LatLng(32.2175, 35.2600),
  'popular housing': LatLng(32.2175, 35.2600),
  'بيت وزان': LatLng(
    32.2103,
    35.2536,
  ), // تقريبي: حي بيت وزان جنوب غرب نابلس عند سفح جبل جرزيم
  'beit wazan': LatLng(32.2103, 35.2536),
  'سوق الحدادين': LatLng(32.2202, 35.2588), // داخل البلدة القديمة
  'souq al-hadadeen': LatLng(32.2202, 35.2588),
  'شارع عمر المختار': LatLng(32.2226, 35.2601), // تقريبي: وسط نابلس
  'omar al-mukhtar': LatLng(32.2226, 35.2601),
  'شارع الاتحاد': LatLng(32.2258, 35.2589), // تقريبي: قرب مستشفى الاتحاد
  'al-ittihad': LatLng(32.2258, 35.2589),
  'بيت إيبا': LatLng(32.2374, 35.2106), // مؤكّد: Nominatim (قرية بيت إيبا)
  'بيت ايبا': LatLng(32.2374, 35.2106),
  'beit iba': LatLng(32.2374, 35.2106),
  'زواتة': LatLng(32.2463, 35.2269), // مؤكّد: Nominatim (قرية زواتا)
  'زواتا': LatLng(32.2463, 35.2269),
  'zawata': LatLng(32.2463, 35.2269),
  'عسكر': LatLng(32.2106, 35.2989), // تقريبي: Nominatim (مخيم عسكر)
  'askar': LatLng(32.2106, 35.2989),
  'شارع حيفا': LatLng(32.2339, 35.2363), // مؤكّد: Nominatim (رفيديا البلد)
  'haifa': LatLng(32.2339, 35.2363),
  'شارع فلسطين': LatLng(32.2211, 35.2608), // تقريبي: مصادر متعددة تضعه بوسط البلد قرب الحسبة
  'falastin': LatLng(32.2211, 35.2608),
};

/// إحداثيات تقريبية واقعية لمنطقة معيّنة داخل نابلس بناءً على اسم الشارع/الحي
/// النصي، مع إزاحة بسيطة وثابتة (حسب اسم المكان) حتى لا تتطابق كل الأماكن
/// بنفس الشارع على نفس النقطة تمامًا.
LatLng approxAreaPoint(String locationText, String seed) {
  final key = locationText.toLowerCase();
  LatLng base = nablusCenter;
  for (final entry in _areaCoords.entries) {
    if (key.contains(entry.key.toLowerCase())) {
      base = entry.value;
      break;
    }
  }
  final h = seed.hashCode;
  final dLat = ((h % 100) - 50) / 120000.0; // إزاحة صغيرة ثابتة حسب الاسم
  final dLng = (((h ~/ 100) % 100) - 50) / 120000.0;
  return LatLng(base.latitude + dLat, base.longitude + dLng);
}

/// يحدد أنسب موقع حقيقي لأي مكان: إحداثيات دقيقة حدّدها الأدمن بالضغط على
/// الخريطة أولاً (لو موجودة)، وإلا من القائمة المنسّقة، وإلا تقريبًا حسب اسم
/// الشارع/الحي المذكور في بياناته.
LatLng resolveMapPoint({
  required String nameAr,
  required String nameEn,
  String locationAr = '',
  String locationEn = '',
  double? lat,
  double? lng,
}) {
  if (lat != null && lng != null) return LatLng(lat, lng);
  final curated = findCuratedPlace(nameAr, nameEn);
  if (curated != null) return curated.point;
  final locationText = locationEn.isNotEmpty ? locationEn : locationAr;
  return approxAreaPoint(locationText, nameEn.isNotEmpty ? nameEn : nameAr);
}

class MapScreen extends StatefulWidget {
  final LatLng? focusPoint;
  final String? focusNameAr;
  final String? focusNameEn;
  final String? focusCategoryAr;
  final String? focusCategoryEn;
  final double? focusRating;

  const MapScreen({
    super.key,
    this.focusPoint,
    this.focusNameAr,
    this.focusNameEn,
    this.focusCategoryAr,
    this.focusCategoryEn,
    this.focusRating,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapPlace? selected;
  String categoryFilter = 'all';
  String searchQuery = '';
  final MapController _mapController = MapController();
  late final List<MapPlace> _allPlaces;
  MapPlace? _focusPlace;

  LatLng? _userLocation;
  bool _locatingUser = false;
  bool _openNowOnly = false;
  List<LatLng>? _routePoints;
  double? _routeDistanceKm;
  int? _routeWalkingMin;
  int? _routeDrivingMin;
  String _travelMode = 'walking'; // 'walking' | 'driving'
  bool _routingLoading = false;
  MapPlace? _routeDestination;
  String _mapStyle = 'street'; // 'street' | 'satellite' | 'dark'

  @override
  void initState() {
    super.initState();
    // نبلش باللائحة المنسّقة يدويًا (معالم/حدائق ما إلها مصدر بيانات ثاني)،
    // وبعدين نضيف كل الأماكن الحقيقية من قاعدة البيانات (مطاعم/فنادق/صيدليات/
    // معالم سياحية/تسوق) حتى الخريطة تعرض كل شي حقيقي مش لائحة مصغّرة بس —
    // مع تفادي التكرار لو نفس المكان موجود بالقائمتين (مثل "البلدة القديمة").
    final curatedNames = mapPlaces.map((p) => p.nameEn).toSet();
    _allPlaces = [
      ...mapPlaces,
      for (final p in allPlaces)
        if (!curatedNames.contains(p.nameEn)) mapPlaceFromUniversal(p),
    ];
    if (widget.focusPoint != null) {
      final existing = findCuratedPlace(
        widget.focusNameAr ?? '',
        widget.focusNameEn ?? '',
      );
      if (existing != null) {
        _focusPlace = existing;
      } else {
        _focusPlace = MapPlace(
          nameAr: widget.focusNameAr ?? '',
          nameEn: widget.focusNameEn ?? '',
          categoryAr: widget.focusCategoryAr ?? '',
          categoryEn: widget.focusCategoryEn ?? '',
          categoryKey: 'landmark',
          lat: widget.focusPoint!.latitude,
          lng: widget.focusPoint!.longitude,
          icon: Icons.place,
          color: AppColors.primary,
          rating: widget.focusRating ?? 0,
        );
        _allPlaces.add(_focusPlace!);
      }
      selected = _focusPlace;
    } else {
      // ما في مكان محدّد سلفًا (فتحنا الخريطة مباشرة) — نطلب موقع المستخدم فورًا
      // حتى نمركز الخريطة عليه ونقدر نلاقيلها أقرب مكان من كل نوع.
      _requestUserLocation();
    }
  }

  Future<void> _requestUserLocation() async {
    setState(() => _locatingUser = true);
    try {
      final position = await LocationService.instance.getCurrentPosition();
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLocation = point;
        _locatingUser = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(point, 15);
      });
    } catch (e) {
      if (!mounted) return;
      // ما لازم نمنع استخدام الخريطة لو فشل تحديد الموقع (رفض إذن، خدمة الموقع
      // مقفولة...) — بنكمل بالمركز الافتراضي، وبس بنعرض السبب بإشعار خفيف.
      final message = e is String ? e : e.toString();
      setState(() => _locatingUser = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// ألاقي أقرب مكان (من التصنيف الحالي المختار) لموقع المستخدم، وأركّز الخريطة عليه.
  void _focusNearest(AppState app) {
    if (_userLocation == null) {
      _requestUserLocation();
      return;
    }
    final candidates = _filtered;
    if (candidates.isEmpty) return;
    final nearest = findNearest<MapPlace>(
      candidates,
      _userLocation!,
      (p) => p.point,
    );
    if (nearest == null) return;
    _focusOn(nearest.item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          app.t(
            'أقرب مكان: ${nearest.item.nameAr} (${nearest.distanceKm.toStringAsFixed(1)} كم)',
            'Nearest: ${nearest.item.nameEn} (${nearest.distanceKm.toStringAsFixed(1)} km)',
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<MapPlace> get _filtered {
    final q = searchQuery.trim().toLowerCase();
    final list = _allPlaces.where((p) {
      final matchesCategory =
          categoryFilter == 'all' || p.categoryKey == categoryFilter;
      // بحث ذكي: بيدوّر بالاسم والتصنيف والموقع النصي مع بعض، مش بالاسم بس —
      // هيك كتابة "مطعم" أو "البلدة القديمة" بتلاقي نتائج حتى بدون اختيار الفلتر.
      final matchesSearch =
          q.isEmpty ||
          p.nameAr.contains(q) ||
          p.nameEn.toLowerCase().contains(q) ||
          p.categoryAr.contains(q) ||
          p.categoryEn.toLowerCase().contains(q) ||
          p.locationAr.contains(q) ||
          p.locationEn.toLowerCase().contains(q);
      final matchesOpenNow = !_openNowOnly || p.is24Hours;
      return matchesCategory && matchesSearch && matchesOpenNow;
    }).toList();
    // فلترة ذكية: لو عندنا موقع المستخدم، رتّبي حسب الأقرب أولًا دايمًا —
    // مش بس زر "أقرب مكان" المنفصل يلي بيركّز على واحد بس.
    if (_userLocation != null) {
      list.sort(
        (a, b) => const Distance()
            .as(LengthUnit.Kilometer, _userLocation!, a.point)
            .compareTo(const Distance().as(LengthUnit.Kilometer, _userLocation!, b.point)),
      );
    }
    return list;
  }

  static String _tileUrlFor(String style) {
    switch (style) {
      case 'satellite':
        // Esri World Imagery — بلاطات أقمار صناعية حقيقية، مجانية وبدون مفتاح API.
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case 'dark':
        // CartoDB Dark Matter — تصميم داكن أنيق يتناسق مع ثيم التطبيق الغامق.
        return 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
      case 'street':
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  static const _mapStyleOrder = ['street', 'satellite', 'dark'];

  static IconData _mapStyleIcon(String style) {
    switch (style) {
      case 'satellite':
        return Icons.satellite_alt_rounded;
      case 'dark':
        return Icons.dark_mode_rounded;
      case 'street':
      default:
        return Icons.map_rounded;
    }
  }

  void _cycleMapStyle() {
    final i = _mapStyleOrder.indexOf(_mapStyle);
    final next = _mapStyleOrder[(i + 1) % _mapStyleOrder.length];
    setState(() => _mapStyle = next);
  }

  void _focusOn(MapPlace p) {
    setState(() {
      selected = p;
      _routePoints = null;
      _routeDistanceKm = null;
      _routeWalkingMin = null;
      _routeDrivingMin = null;
    });
    _mapController.move(p.point, 16);
  }

  /// بتجيب مسار حقيقي (فوق شبكة الطرق الفعلية) بين موقع المستخدم والمكان
  /// المختار — عبر خدمة OSRM عامة حقيقية بملفّات طرق منفصلة فعليًا للمشي
  /// والسيارات (routing.openstreetmap.de، مستضافة من جمعية FOSSGIS الألمانية
  /// لـ OpenStreetMap، مجانية وبدون مفتاح API)، فمسار المشي بيختلف عن مسار
  /// السيارة فعليًا (بياخد أزقة وممرات ما بتقدر تدخلها سيارة مثلًا)، مش بس
  /// وقت مختلف لنفس الخط متل قبل.
  Future<void> _fetchRouteTo(MapPlace destination, AppState app) async {
    if (_userLocation == null) {
      await _requestUserLocation();
      if (_userLocation == null) return;
    }
    _routeDestination = destination;
    setState(() => _routingLoading = true);
    try {
      final from = _userLocation!;
      final to = destination.point;
      final profile = _travelMode == 'walking' ? 'foot' : 'car';
      final uri = Uri.parse(
        'https://routing.openstreetmap.de/routed-$profile/route/v1/$profile/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) throw Exception('bad status');
      final decoded = jsonDecode(res.body);
      final routes = decoded['routes'] as List?;
      if (routes == null || routes.isEmpty) throw Exception('no route');
      final route = routes.first as Map;
      final coords = (route['geometry']['coordinates'] as List)
          .map((c) => LatLng((c as List)[1] as double, c[0] as double))
          .toList();
      final distanceKm = (route['distance'] as num) / 1000.0;
      final minutes = ((route['duration'] as num) / 60).round();
      if (!mounted) return;
      setState(() {
        _routePoints = coords;
        _routeDistanceKm = distanceKm;
        if (_travelMode == 'walking') {
          _routeWalkingMin = minutes;
        } else {
          _routeDrivingMin = minutes;
        }
        _routingLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _routingLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            app.t('تعذّر جلب المسار — تأكدي من الاتصال بالإنترنت', 'Could not fetch route — check your internet connection'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final filtered = _filtered;
        final mobile = isMobile(context);
        final mapArea = Container(
          margin: EdgeInsets.fromLTRB(
            mobile ? 0 : 0,
            mobile ? 0 : 16,
            mobile ? 0 : 16,
            mobile ? 0 : 16,
          ),
          decoration: BoxDecoration(
            borderRadius: mobile ? null : BorderRadius.circular(AppRadius.lg),
            border: mobile ? null : Border.all(color: AppColors.borderColor),
            boxShadow: mobile ? null : AppColors.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: widget.focusPoint ?? nablusCenter,
                  initialZoom: widget.focusPoint != null ? 16 : 14,
                  minZoom: 10,
                  maxZoom: 18,
                  onTap: (_, _) => setState(() => selected = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: _tileUrlFor(_mapStyle),
                    userAgentPackageName: 'com.nablus.smart_city_guide',
                  ),
                  if (_routePoints != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints!,
                          strokeWidth: 5,
                          color: AppColors.primary,
                          borderStrokeWidth: 2,
                          borderColor: Colors.white,
                        ),
                      ],
                    ),
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 45,
                      disableClusteringAtZoom: 17,
                      size: const Size(38, 38),
                      markers: filtered.map((p) {
                        final isSelected = p == selected;
                        return Marker(
                          point: p.point,
                          width: isSelected ? 46 : 36,
                          height: isSelected ? 46 : 36,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _focusOn(p),
                            child: _MapMarkerBadge(place: p, isSelected: isSelected),
                          ),
                        );
                      }).toList(),
                      builder: (context, markers) => _ClusterBadge(count: markers.length),
                    ),
                  ),
                  if (_userLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _userLocation!,
                          width: 22,
                          height: 22,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              // أزرار التكبير/التصغير + تحديد موقعي + أقرب مكان
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  children: [
                    _zoomButton(Icons.add_rounded, () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    }),
                    SizedBox(height: 8),
                    _zoomButton(Icons.remove_rounded, () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    }),
                    SizedBox(height: 8),
                    _locatingUser
                        ? Container(
                            width: 36,
                            height: 36,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : _zoomButton(Icons.my_location_rounded, _requestUserLocation),
                    SizedBox(height: 8),
                    _zoomButton(Icons.near_me_rounded, () => _focusNearest(app)),
                    SizedBox(height: 8),
                    _zoomButton(_mapStyleIcon(_mapStyle), _cycleMapStyle),
                  ],
                ),
              ),
              if (mobile)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showPlacesSheet(context, app),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: AppColors.glowShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.list_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            app.t('الأماكن', 'Places'),
                            style: AppTypography.label(Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // بطاقة معلومات المكان المختار
              if (selected != null)
                Positioned(
                  bottom: 16,
                  right: 16,
                  left: 16,
                  child: _SelectedPlaceCard(
                    place: selected!,
                    onClose: () => setState(() {
                      selected = null;
                      _routePoints = null;
                    }),
                    onDirections: () => _fetchRouteTo(selected!, app),
                    routingLoading: _routingLoading,
                    routeDistanceKm: _routeDistanceKm,
                    routeWalkingMin: _routeWalkingMin,
                    routeDrivingMin: _routeDrivingMin,
                    travelMode: _travelMode,
                    onTravelModeChanged: (m) {
                      setState(() => _travelMode = m);
                      // لو في وجهة محدّدة سلفًا، اجلبي مسارها الحقيقي بالوضع
                      // الجديد فورًا (مش بس بدّلي رقم الوقت) — لأنه المسار
                      // نفسه بيختلف بين المشي والسيارة هلق.
                      if (_routeDestination != null) {
                        _fetchRouteTo(_routeDestination!, app);
                      }
                    },
                  ),
                ),
            ],
          ),
        );

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SafeArea(
              child: Column(
                children: [
                  _TopBarSimple(
                    titleAr: 'الخريطة التفاعلية',
                    titleEn: 'Interactive Map',
                    icon: Icons.map_rounded,
                  ),
                  Expanded(
                    child: mobile
                        ? mapArea
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ==== الشريط الجانبي: بحث + فلاتر + قائمة الأماكن ====
                              Container(
                                width: 280,
                                margin: EdgeInsets.all(16),
                                child: _placesSidebar(app, filtered),
                              ),
                              // ==== منطقة الخريطة الحقيقية (OpenStreetMap) ====
                              Expanded(child: mapArea),
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

  void _showPlacesSheet(BuildContext context, AppState app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.75,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Expanded(
                child: _placesSidebar(
                  app,
                  _filtered,
                  onPickPlace: () => Navigator.of(sheetContext).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placesSidebar(
    AppState app,
    List<MapPlace> filtered, {
    VoidCallback? onPickPlace,
  }) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: onPickPlace == null ? AppColors.cardShadow : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                    onChanged: (v) => setState(() => searchQuery = v),
                    style: AppTypography.body(
                      AppColors.textWhite,
                    ).copyWith(fontSize: 12),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: app.t(
                        'ابحث بالاسم أو التصنيف أو الحي...',
                        'Search by name, category, or area...',
                      ),
                      hintStyle: AppTypography.caption(AppColors.textGrey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _catChip('all', app.t('الكل', 'All')),
              _catChip('landmark', app.t('معالم', 'Landmarks')),
              _catChip('restaurants', app.t('مطاعم', 'Restaurants')),
              _catChip('hotels', app.t('فنادق', 'Hotels')),
              _catChip('pharmacies', app.t('صيدليات', 'Pharmacies')),
              _catChip('attractions', app.t('سياحة', 'Attractions')),
              _catChip('park', app.t('حدائق', 'Parks')),
              _catChip('shopping', app.t('تسوق', 'Shopping')),
            ],
          ),
          SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _openNowOnly = !_openNowOnly),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: _openNowOnly ? LinearGradient(colors: AppColors.primaryGradient) : null,
                color: _openNowOnly ? null : AppColors.cardDark2,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: _openNowOnly ? Colors.transparent : AppColors.borderColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: _openNowOnly ? Colors.white : AppColors.textGrey,
                  ),
                  SizedBox(width: 4),
                  Text(
                    app.t('مفتوح 24 ساعة فقط', 'Open 24h only'),
                    style: AppTypography.caption(
                      _openNowOnly ? Colors.white : AppColors.textWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, _) => SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = filtered[i];
                final isSelected = p == selected;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _focusOn(p);
                    onPickPlace?.call();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.cardDark2,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderColor,
                      ),
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: p.color.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(p.icon, size: 16, color: p.color),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                app.isArabic ? p.nameAr : p.nameEn,
                                textDirection: app.dir,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label(AppColors.textWhite),
                              ),
                              Text(
                                app.isArabic ? p.categoryAr : p.categoryEn,
                                textDirection: app.dir,
                                style: AppTypography.caption(
                                  AppColors.textGrey,
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
          ),
        ],
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: AppColors.cardShadow,
        ),
        child: Icon(icon, size: 18, color: AppColors.textWhite),
      ),
    );
  }

  Widget _catChip(String key, String label) {
    final selected = categoryFilter == key;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => categoryFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: AppColors.primaryGradient)
              : null,
          color: selected ? null : AppColors.cardDark2,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _categoryIcons[key],
              size: 12,
              color: selected ? Colors.white : AppColors.textGrey,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption(
                selected ? Colors.white : AppColors.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== شكل علامة احترافي (شارة دائرية متدرّجة اللون + أيقونة) ====================
// بدل الدبوس المسطّح القديم (Icons.location_on_rounded) — تصميم أوضح وأقرب
// لتطبيقات الخرائط الاحترافية، ونفس أسلوب الدائرة المتدرّجة المستخدم أصلًا
// ببطاقة المكان المختار (_SelectedPlaceCard) حتى الشكل موحّد بكل الشاشة.
class _MapMarkerBadge extends StatelessWidget {
  final MapPlace place;
  final bool isSelected;
  const _MapMarkerBadge({required this.place, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final size = isSelected ? 44.0 : 34.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [place.color, place.color.withValues(alpha: 0.75)],
        ),
        border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(place.icon, color: Colors.white, size: size * 0.5),
    );
  }
}

/// شارة تجميع (cluster) لمجموعة علامات متقاربة — بترجّع كل شي مرقّم بدل ما
/// تتكدّس عشرات الأيقونات فوق بعض عند التصغير (zoom out).
class _ClusterBadge extends StatelessWidget {
  final int count;
  const _ClusterBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: AppColors.primaryGradient),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

class _SelectedPlaceCard extends StatelessWidget {
  final MapPlace place;
  final VoidCallback onClose;
  final VoidCallback onDirections;
  final bool routingLoading;
  final double? routeDistanceKm;
  final int? routeWalkingMin;
  final int? routeDrivingMin;
  final String travelMode;
  final ValueChanged<String> onTravelModeChanged;
  const _SelectedPlaceCard({
    required this.place,
    required this.onClose,
    required this.onDirections,
    this.routingLoading = false,
    this.routeDistanceKm,
    this.routeWalkingMin,
    this.routeDrivingMin,
    this.travelMode = 'walking',
    required this.onTravelModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final p = place;
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [p.color, p.color.withValues(alpha: 0.7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(p.icon, color: Colors.white, size: 22),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      app.isArabic ? p.nameAr : p.nameEn,
                      textDirection: app.dir,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(
                        AppColors.textWhite,
                      ).copyWith(fontSize: 14),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
                        SizedBox(width: 3),
                        Text(
                          '${p.rating}',
                          style: AppTypography.caption(AppColors.textGrey),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            app.isArabic ? p.categoryAr : p.categoryEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption(AppColors.textGrey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: routingLoading ? null : onDirections,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  margin: EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark2,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: routingLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          travelMode == 'walking'
                              ? Icons.directions_walk_rounded
                              : Icons.directions_car_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => openInExternalMaps(p),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  margin: EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark2,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        titleAr: p.nameAr,
                        titleEn: p.nameEn,
                        subtitleAr: p.categoryAr,
                        subtitleEn: p.categoryEn,
                        rating: p.rating,
                        placeType: reviewPlaceTypeFor(p.categoryKey),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    app.t('التفاصيل', 'Details'),
                    style: AppTypography.caption(Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textGrey,
                  size: 18,
                ),
              ),
            ],
          ),
          if (routeDistanceKm != null &&
              routeWalkingMin != null &&
              routeDrivingMin != null) ...[
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  _travelModeButton(
                    icon: Icons.directions_walk_rounded,
                    mode: 'walking',
                    active: travelMode == 'walking',
                  ),
                  SizedBox(width: 6),
                  _travelModeButton(
                    icon: Icons.directions_car_rounded,
                    mode: 'driving',
                    active: travelMode == 'driving',
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      travelMode == 'walking'
                          ? app.t(
                              'مشيًا: ${routeDistanceKm!.toStringAsFixed(1)} كم — تقريبًا $routeWalkingMin د',
                              'Walking: ${routeDistanceKm!.toStringAsFixed(1)} km — about $routeWalkingMin min',
                            )
                          : app.t(
                              'بالسيارة: ${routeDistanceKm!.toStringAsFixed(1)} كم — تقريبًا $routeDrivingMin د',
                              'Driving: ${routeDistanceKm!.toStringAsFixed(1)} km — about $routeDrivingMin min',
                            ),
                      style: AppTypography.caption(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _travelModeButton({
    required IconData icon,
    required String mode,
    required bool active,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTravelModeChanged(mode),
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 15, color: active ? Colors.white : AppColors.primary),
      ),
    );
  }
}

// ==================== شريط علوي بسيط قابل لإعادة الاستخدام ====================
class _TopBarSimple extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  final IconData icon;
  const _TopBarSimple({
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
          Text(
            app.t(titleAr, titleEn),
            textDirection: app.dir,
            style: AppTypography.title(
              AppColors.textWhite,
            ).copyWith(fontSize: 16),
          ),
          Spacer(),
          AppToggleBar(),
        ],
      ),
    );
  }
}
