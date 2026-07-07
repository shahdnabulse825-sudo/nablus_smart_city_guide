import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../common/detail_screen.dart';

// ==================== بيانات نقطة على الخريطة (إحداثيات حقيقية) ====================
class MapPlace {
  final String nameAr;
  final String nameEn;
  final String categoryAr;
  final String categoryEn;
  final String categoryKey; // landmark / restaurant / hotel / park / shopping
  final double lat;
  final double lng;
  final IconData icon;
  final Color color;
  final double rating;

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
  });

  LatLng get point => LatLng(lat, lng);
}

// إحداثيات حقيقية تقريبية داخل مدينة نابلس، فلسطين
final LatLng nablusCenter = LatLng(32.2211, 35.2544);

final List<MapPlace> mapPlaces = [
  MapPlace(
    nameAr: 'البلدة القديمة',
    nameEn: 'Old City',
    categoryAr: 'معلم تاريخي',
    categoryEn: 'Historic Landmark',
    categoryKey: 'landmark',
    lat: 32.2214,
    lng: 35.2597,
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
    lat: 32.1978,
    lng: 35.2723,
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
    lat: 32.2226,
    lng: 35.2534,
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
    lat: 32.2199,
    lng: 35.2609,
    icon: Icons.mosque,
    color: Color(0xFFB5651D),
    rating: 4.7,
  ),
  MapPlace(
    nameAr: 'مطعم البيت النابلسي',
    nameEn: 'Al-Bait Al-Nabulsi Restaurant',
    categoryAr: 'مطعم',
    categoryEn: 'Restaurant',
    categoryKey: 'restaurant',
    lat: 32.2237,
    lng: 35.2569,
    icon: Icons.restaurant,
    color: Color(0xFFE85D5D),
    rating: 4.8,
  ),
  MapPlace(
    nameAr: 'فندق قصر نابلس',
    nameEn: 'Nablus Palace Hotel',
    categoryAr: 'فندق',
    categoryEn: 'Hotel',
    categoryKey: 'hotel',
    lat: 32.2279,
    lng: 35.2611,
    icon: Icons.hotel,
    color: Color(0xFF6C5CE7),
    rating: 4.5,
  ),
  MapPlace(
    nameAr: 'حديقة التعاون',
    nameEn: 'Al-Taawon Park',
    categoryAr: 'حديقة',
    categoryEn: 'Park',
    categoryKey: 'park',
    lat: 32.2258,
    lng: 35.2661,
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
    lat: 32.2296,
    lng: 35.2398,
    icon: Icons.shopping_bag,
    color: Color(0xFF3B82F6),
    rating: 4.4,
  ),
];

final Map<String, IconData> _categoryIcons = {
  'all': Icons.apps,
  'landmark': Icons.account_balance,
  'restaurant': Icons.restaurant,
  'hotel': Icons.hotel,
  'park': Icons.park,
  'shopping': Icons.shopping_bag,
};

Future<void> openInExternalMaps(MapPlace p) async {
  final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${p.lat},${p.lng}');
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

// إحداثيات حقيقية تقريبية لأبرز شوارع وأحياء نابلس، تُستخدم لوضع أي مكان
// (مطعم، فندق، صيدلية...) بموقع واقعي على الخريطة حتى لو ما كان بالقائمة المنسّقة.
final Map<String, LatLng> _areaCoords = {
  'البلدة القديمة': LatLng(32.2214, 35.2597),
  'old city': LatLng(32.2214, 35.2597),
  'رفيديا': LatLng(32.2296, 35.2410),
  'rafidia': LatLng(32.2296, 35.2410),
  'الرابية': LatLng(32.2320, 35.2450),
  'rabya': LatLng(32.2320, 35.2450),
  'شارع الجامعة': LatLng(32.2279, 35.2611),
  'university': LatLng(32.2279, 35.2611),
  'وسط البلد': LatLng(32.2226, 35.2534),
  'downtown': LatLng(32.2226, 35.2534),
  'دوار الشهداء': LatLng(32.2226, 35.2534),
  'martyrs': LatLng(32.2226, 35.2534),
  'شارع فيصل': LatLng(32.2245, 35.2575),
  'faisal': LatLng(32.2245, 35.2575),
  'شارع عمان': LatLng(32.2255, 35.2520),
  'amman': LatLng(32.2255, 35.2520),
  'شارع سفيان': LatLng(32.2231, 35.2557),
  'sufyan': LatLng(32.2231, 35.2557),
  'المساكن الشعبية': LatLng(32.2183, 35.2528),
  'popular housing': LatLng(32.2183, 35.2528),
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

/// يحدد أنسب موقع حقيقي لأي مكان: من القائمة المنسّقة أولاً، وإلا تقريبًا
/// حسب اسم الشارع/الحي المذكور في بياناته.
LatLng resolveMapPoint({
  required String nameAr,
  required String nameEn,
  String locationAr = '',
  String locationEn = '',
}) {
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

  MapScreen({
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

  @override
  void initState() {
    super.initState();
    _allPlaces = List.of(mapPlaces);
    if (widget.focusPoint != null) {
      final existing = findCuratedPlace(widget.focusNameAr ?? '', widget.focusNameEn ?? '');
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
          color: AppColors.blue,
          rating: widget.focusRating ?? 0,
        );
        _allPlaces.add(_focusPlace!);
      }
      selected = _focusPlace;
    }
  }

  List<MapPlace> get _filtered {
    return _allPlaces.where((p) {
      final matchesCategory = categoryFilter == 'all' || p.categoryKey == categoryFilter;
      final matchesSearch = searchQuery.isEmpty ||
          p.nameAr.contains(searchQuery) ||
          p.nameEn.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _focusOn(MapPlace p) {
    setState(() => selected = p);
    _mapController.move(p.point, 16);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
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
                  _TopBarSimple(
                    titleAr: 'الخريطة التفاعلية',
                    titleEn: 'Interactive Map',
                    icon: Icons.map,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==== الشريط الجانبي: بحث + فلاتر + قائمة الأماكن ====
                        Container(
                          width: 280,
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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
                                        onChanged: (v) => setState(() => searchQuery = v),
                                        style: TextStyle(
                                            color: AppColors.textWhite, fontSize: 12),
                                        decoration: InputDecoration(
                                          isCollapsed: true,
                                          border: InputBorder.none,
                                          hintText: app.t('ابحث عن مكان...', 'Search a place...'),
                                          hintStyle:
                                              TextStyle(color: AppColors.textGrey, fontSize: 11),
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
                                  _catChip('restaurant', app.t('مطاعم', 'Restaurants')),
                                  _catChip('hotel', app.t('فنادق', 'Hotels')),
                                  _catChip('park', app.t('حدائق', 'Parks')),
                                  _catChip('shopping', app.t('تسوق', 'Shopping')),
                                ],
                              ),
                              SizedBox(height: 12),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) => SizedBox(height: 8),
                                  itemBuilder: (context, i) {
                                    final p = filtered[i];
                                    final isSelected = p == selected;
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _focusOn(p),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.blue.withOpacity(0.15)
                                              : AppColors.cardDark2,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                              color: isSelected
                                                  ? AppColors.blue
                                                  : AppColors.borderColor),
                                        ),
                                        child: Row(
                                          textDirection: TextDirection.rtl,
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: p.color.withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(p.icon, size: 16, color: p.color),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(app.isArabic ? p.nameAr : p.nameEn,
                                                      textDirection: app.dir,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: AppColors.textWhite,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold)),
                                                  Text(
                                                      app.isArabic
                                                          ? p.categoryAr
                                                          : p.categoryEn,
                                                      textDirection: app.dir,
                                                      style: TextStyle(
                                                          color: AppColors.textGrey,
                                                          fontSize: 10)),
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
                        ),
                        // ==== منطقة الخريطة الحقيقية (OpenStreetMap) ====
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 16, 16, 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderColor),
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
                                    onTap: (_, __) => setState(() => selected = null),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName:
                                          'com.nablus.smart_city_guide',
                                    ),
                                    MarkerLayer(
                                      markers: filtered.map((p) {
                                        final isSelected = p == selected;
                                        return Marker(
                                          point: p.point,
                                          width: isSelected ? 46 : 36,
                                          height: isSelected ? 46 : 36,
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () => _focusOn(p),
                                            child: Icon(Icons.location_on,
                                                color: isSelected
                                                    ? AppColors.blue
                                                    : p.color,
                                                size: isSelected ? 44 : 34),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                // أزرار التكبير/التصغير
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Column(
                                    children: [
                                      _zoomButton(Icons.add, () {
                                        _mapController.move(_mapController.camera.center,
                                            _mapController.camera.zoom + 1);
                                      }),
                                      SizedBox(height: 8),
                                      _zoomButton(Icons.remove, () {
                                        _mapController.move(_mapController.camera.center,
                                            _mapController.camera.zoom - 1);
                                      }),
                                    ],
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
                                      onClose: () => setState(() => selected = null),
                                    ),
                                  ),
                              ],
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
      },
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor),
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : AppColors.cardDark2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.blue : AppColors.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_categoryIcons[key], size: 12, color: selected ? Colors.white : AppColors.textGrey),
            SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : AppColors.textWhite, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _SelectedPlaceCard extends StatelessWidget {
  final MapPlace place;
  final VoidCallback onClose;
  const _SelectedPlaceCard({required this.place, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final p = place;
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12)],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: p.color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(p.icon, color: p.color, size: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(app.isArabic ? p.nameAr : p.nameEn,
                    textDirection: app.dir,
                    style: TextStyle(
                        color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(Icons.star, size: 12, color: AppColors.gold),
                    SizedBox(width: 3),
                    Text('${p.rating}',
                        style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                    SizedBox(width: 8),
                    Text(app.isArabic ? p.categoryAr : p.categoryEn,
                        style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                  ],
                ),
              ],
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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderColor)),
              child: Icon(Icons.directions, size: 16, color: AppColors.blue),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DetailScreen(
                  titleAr: p.nameAr,
                  titleEn: p.nameEn,
                  subtitleAr: p.categoryAr,
                  subtitleEn: p.categoryEn,
                  rating: p.rating,
                ),
              ));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(8)),
              child: Text(app.t('التفاصيل', 'Details'),
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: Icon(Icons.close, color: AppColors.textGrey, size: 18),
          ),
        ],
      ),
    );
  }
}

// ==================== شريط علوي بسيط قابل لإعادة الاستخدام ====================
class _TopBarSimple extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  final IconData icon;
  const _TopBarSimple({required this.titleAr, required this.titleEn, required this.icon});

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
