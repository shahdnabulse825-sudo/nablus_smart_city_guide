import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../common/detail_screen.dart';
import '../places/all_places_screen.dart';
import '../map/map_screen.dart' show resolveMapPoint;
import '../../services/location_service.dart';
import '../../theme/app_typography.dart';

const List<String> _nearbyCategoryOrder = [
  'all',
  'restaurant',
  'hotel',
  'pharmacy',
  'health',
  'bank',
  'attraction',
  'shopping',
];

const Map<String, IconData> _nearbyCategoryIcons = {
  'all': Icons.apps,
  'restaurant': Icons.restaurant,
  'hotel': Icons.bed,
  'pharmacy': Icons.local_pharmacy,
  'health': Icons.favorite,
  'bank': Icons.account_balance,
  'attraction': Icons.mosque,
  'shopping': Icons.shopping_bag,
};

const Map<String, String> _nearbyCategoryLabelsAr = {
  'all': 'الكل',
  'restaurant': 'مطاعم',
  'hotel': 'فنادق',
  'pharmacy': 'صيدليات',
  'health': 'صحة',
  'bank': 'بنوك',
  'attraction': 'سياحة ومعالم',
  'shopping': 'تسوق',
};

const Map<String, String> _nearbyCategoryLabelsEn = {
  'all': 'All',
  'restaurant': 'Restaurants',
  'hotel': 'Hotels',
  'pharmacy': 'Pharmacies',
  'health': 'Health',
  'bank': 'Banks',
  'attraction': 'Attractions',
  'shopping': 'Shopping',
};

class _NearbyPlace {
  final UniversalPlace place;
  final double distanceKm;
  const _NearbyPlace(this.place, this.distanceKm);
}

/// شاشة "قريب مني": كل الأماكن (مطاعم، فنادق، صيدليات، صحة، بنوك، معالم، تسوق)
/// مرتبة حسب المسافة الفعلية من موقع المستخدم، مع تقدير وقت المشي/القيادة.
class NearbyPlacesScreen extends StatefulWidget {
  const NearbyPlacesScreen({super.key});

  @override
  State<NearbyPlacesScreen> createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  Position? _userPosition;
  bool _locating = true;
  String? _error;
  bool _permanentlyDenied = false;
  String categoryFilter = 'all';

  @override
  void initState() {
    super.initState();
    _locate();
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _error = null;
      _permanentlyDenied = false;
    });
    try {
      final position = await LocationService.instance.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _userPosition = position;
        _locating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        _error = e is String ? e : e.toString();
        _permanentlyDenied = e.toString().contains('رفض') || e.toString().contains('denied');
      });
    }
  }

  List<_NearbyPlace> get _nearby {
    final userPosition = _userPosition;
    if (userPosition == null) return [];
    final candidates = allPlaces.where((p) {
      if (!_nearbyCategoryIcons.keys.contains(p.categoryKey)) return false;
      return categoryFilter == 'all' || p.categoryKey == categoryFilter;
    });
    final withDistance = candidates.map((p) {
      final point = resolveMapPoint(
        nameAr: p.nameAr,
        nameEn: p.nameEn,
        locationAr: p.locationAr,
        locationEn: p.locationEn,
        lat: p.lat,
        lng: p.lng,
      );
      final km = LocationService.instance.distanceKm(
        LatLng(userPosition.latitude, userPosition.longitude),
        point,
      );
      return _NearbyPlace(p, km);
    }).toList();
    withDistance.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return withDistance;
  }

  void _openDetail(UniversalPlace p) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          titleAr: p.nameAr,
          titleEn: p.nameEn,
          subtitleAr: p.typeAr,
          subtitleEn: p.typeEn,
          descriptionAr: p.aboutAr,
          descriptionEn: p.aboutEn,
          rating: p.rating,
          locationAr: p.locationAr,
          locationEn: p.locationEn,
          customImageBase64: p.customImageBase64,
          localAsset: p.image,
        ),
      ),
    );
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
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(app),
                  _buildCategoryChips(app),
                  Expanded(child: _buildBody(app)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppState app) {
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
              decoration: BoxDecoration(color: AppColors.cardDark, shape: BoxShape.circle),
              child: Icon(Icons.arrow_back_rounded, color: AppColors.textWhite, size: 18),
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
            child: Icon(Icons.near_me_rounded, color: Colors.white, size: 16),
          ),
          SizedBox(width: 10),
          Text(
            app.t('قريب مني', 'Nearby'),
            textDirection: app.dir,
            style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 16),
          ),
          Spacer(),
          if (!_locating)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _locate,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.cardDark, shape: BoxShape.circle),
                child: Icon(Icons.refresh_rounded, color: AppColors.textWhite, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(AppState app) {
    return Container(
      color: AppColors.sidebarDark,
      padding: EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _nearbyCategoryOrder.map((key) {
            final selected = categoryFilter == key;
            return Padding(
              padding: EdgeInsets.only(left: 8),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => categoryFilter = key),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected ? LinearGradient(colors: AppColors.primaryGradient) : null,
                    color: selected ? null : AppColors.cardDark2,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: selected ? Colors.transparent : AppColors.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _nearbyCategoryIcons[key],
                        size: 13,
                        color: selected ? Colors.white : AppColors.textGrey,
                      ),
                      SizedBox(width: 6),
                      Text(
                        app.t(_nearbyCategoryLabelsAr[key]!, _nearbyCategoryLabelsEn[key]!),
                        style: AppTypography.caption(selected ? Colors.white : AppColors.textWhite),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody(AppState app) {
    if (_locating) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off_rounded, color: AppColors.textGrey, size: 40),
              SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                textDirection: app.dir,
                style: AppTypography.body(AppColors.textGrey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _permanentlyDenied ? Geolocator.openAppSettings : _locate,
                child: Text(
                  _permanentlyDenied
                      ? app.t('فتح الإعدادات', 'Open Settings')
                      : app.t('إعادة المحاولة', 'Retry'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final nearby = _nearby;
    if (nearby.isEmpty) {
      return Center(
        child: Text(
          app.t('لا توجد نتائج بهذا التصنيف', 'No results in this category'),
          style: AppTypography.body(AppColors.textGrey),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: nearby.length,
      itemBuilder: (context, i) => _nearbyRow(app, nearby[i]),
    );
  }

  Widget _nearbyRow(AppState app, _NearbyPlace entry) {
    final p = entry.place;
    final name = app.isArabic ? p.nameAr : p.nameEn;
    final type = app.isArabic ? p.typeAr : p.typeEn;
    final distanceLabel = entry.distanceKm < 1
        ? '${(entry.distanceKm * 1000).round()} ${app.t('م', 'm')}'
        : '${entry.distanceKm.toStringAsFixed(1)} ${app.t('كم', 'km')}';
    final walkMin = LocationService.instance.walkingMinutes(entry.distanceKm);
    final driveMin = LocationService.instance.drivingMinutes(entry.distanceKm);

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: EdgeInsets.all(10),
        onTap: () => _openDetail(p),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: ThemedImage(
                query: p.photoQuery,
                fallbackSeed: p.nameEn,
                height: 64,
                fallbackIcon: p.icon,
                fallbackColor: p.color,
                customImageBase64: p.customImageBase64,
                localAsset: p.image,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    name,
                    textDirection: app.dir,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(AppColors.textWhite),
                  ),
                  Text(
                    type,
                    textDirection: app.dir,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption(AppColors.textGrey),
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _badge(Icons.near_me, distanceLabel),
                      _badge(Icons.directions_walk_rounded, '~$walkMin ${app.t('د', 'min')}'),
                      _badge(Icons.directions_car_rounded, '~$driveMin ${app.t('د', 'min')}'),
                      if (p.categoryKey == 'pharmacy' && p.is24Hours)
                        _badge(Icons.access_time_filled_rounded, app.t('24 ساعة', '24h')),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(Icons.star_rounded, size: 13, color: AppColors.gold),
                Text('${p.rating}', style: AppTypography.label(AppColors.textWhite)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.textGrey),
        SizedBox(width: 3),
        Text(label, style: AppTypography.caption(AppColors.textGrey)),
      ],
    );
  }
}
