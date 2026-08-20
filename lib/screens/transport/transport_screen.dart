import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors (AppCard مضمّن فيها)
import '../../widgets/themed_image.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive.dart';
import '../../widgets/app_toggle_bar.dart';
import '../../widgets/keyboard_scrollable.dart';
import '../../widgets/nearest_to_me_chip.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../services/favorites_service.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_typography.dart';
import '../../widgets/skeleton_card.dart';
import '../map/map_screen.dart';
import '../ai_assistant/ai_assistant_screen.dart';
import '../hotels/hotels_screen.dart';
import '../category/category_data.dart';
import 'trip_planner_screen.dart';

// ==================== أقسام وسائل النقل (فلتر) ====================
const List<(String, String, String, IconData)> transportVehicleFilters = [
  ('bus', '🚌 باص', '🚌 Bus', Icons.directions_bus_rounded),
  ('service', '🚐 سرفيس', '🚐 Service', Icons.airport_shuttle_rounded),
  ('taxi', '🚖 تاكسي', '🚖 Taxi', Icons.local_taxi_rounded),
  ('carRental', '🚗 تأجير سيارات', '🚗 Car Rental', Icons.car_rental_rounded),
];

// ==================== الحواجز (Checkpoints) ====================
// بيانات وصفية تُدار يدويًا من الإدارة فقط — التطبيق ما عنده أي مصدر بيانات حي/GPS
// لحالة الحواجز الفعلية، فبنعرض حالتها كـ "غير محدّثة" افتراضيًا لحد ما أدمن حقيقي
// يتحقق ويحدّثها بنفسه، بدل ما نفترض حالة (مفتوح/مغلق) ممكن تكون غلط وتوقع حدا
// بموقف صعب. هاي المعلومة حساسة وبتخص سلامة الناس الفعلية.
enum CheckpointStatus { unknown, open, congested, closed }

extension CheckpointStatusX on CheckpointStatus {
  Color get color {
    switch (this) {
      case CheckpointStatus.open:
        return AppColors.green;
      case CheckpointStatus.congested:
        return AppColors.gold;
      case CheckpointStatus.closed:
        return AppColors.red;
      case CheckpointStatus.unknown:
        return AppColors.textGrey;
    }
  }

  String labelAr(AppState app) {
    switch (this) {
      case CheckpointStatus.open:
        return 'مفتوح';
      case CheckpointStatus.congested:
        return 'ازدحام';
      case CheckpointStatus.closed:
        return 'مغلق';
      case CheckpointStatus.unknown:
        return 'غير محدّثة';
    }
  }

  String labelEn() {
    switch (this) {
      case CheckpointStatus.open:
        return 'Open';
      case CheckpointStatus.congested:
        return 'Congested';
      case CheckpointStatus.closed:
        return 'Closed';
      case CheckpointStatus.unknown:
        return 'Not updated';
    }
  }
}

CheckpointStatus checkpointStatusFromKey(String? key) {
  switch (key) {
    case 'open':
      return CheckpointStatus.open;
    case 'congested':
      return CheckpointStatus.congested;
    case 'closed':
      return CheckpointStatus.closed;
    default:
      return CheckpointStatus.unknown;
  }
}

class CheckpointData {
  final String nameAr;
  final String nameEn;
  final String locationAr;
  final String locationEn;
  final CheckpointStatus status;
  final String? altRouteAr;
  final String? altRouteEn;
  final String? apiId; // معرّف السطر بالسيرفر — لازم لأي تحديث حالة فعلي
  const CheckpointData({
    required this.nameAr,
    required this.nameEn,
    required this.locationAr,
    required this.locationEn,
    this.status = CheckpointStatus.unknown,
    this.altRouteAr,
    this.altRouteEn,
    this.apiId,
  });
}

// حواجز حقيقية معروفة قرب نابلس (الأسماء فقط موثّقة — الحالة تُترك "غير محدّثة"
// حتى تدخلها الإدارة يدويًا بعد التحقق الفعلي، وليست بيانات حية).
final List<CheckpointData> checkpointsSeedData = [
  CheckpointData(
    nameAr: 'حاجز حوارة',
    nameEn: 'Huwara Checkpoint',
    locationAr: 'جنوب نابلس، طريق رام الله',
    locationEn: 'South of Nablus, Ramallah road',
  ),
  CheckpointData(
    nameAr: 'حاجز بيت فوريك',
    nameEn: 'Beit Furik Checkpoint',
    locationAr: 'شرق نابلس',
    locationEn: 'East of Nablus',
  ),
  CheckpointData(
    nameAr: 'حاجز عورتا',
    nameEn: 'Awarta Checkpoint',
    locationAr: 'جنوب شرق نابلس',
    locationEn: 'Southeast of Nablus',
  ),
];

Map<String, dynamic> checkpointToMap(CheckpointData c) => {
  'nameAr': c.nameAr,
  'nameEn': c.nameEn,
  'locationAr': c.locationAr,
  'locationEn': c.locationEn,
  'status': c.status.name,
  'altRouteAr': c.altRouteAr,
  'altRouteEn': c.altRouteEn,
};

CheckpointData mapToCheckpoint(Map<String, dynamic> m) => CheckpointData(
  nameAr: m['nameAr'] ?? '',
  nameEn: m['nameEn'] ?? '',
  locationAr: m['locationAr'] ?? '',
  locationEn: m['locationEn'] ?? '',
  status: checkpointStatusFromKey(m['status'] as String?),
  altRouteAr: m['altRouteAr'],
  altRouteEn: m['altRouteEn'],
  apiId: m['apiId'] as String?,
);

// ==================== شاشة المواصلات الرئيسية ====================
class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  bool _loaded = false;
  List<ListingItem> _liveStations = [];
  List<CheckpointData> _checkpoints = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _vehicleFilter = 'all';

  Position? _userPosition;
  bool _locating = false;
  bool _nearestActive = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = LocalDbService.instance;
    await db.syncSeedExact('transport', transportData.map(listingToMap).toList());
    await ApiService.syncBox('transport');
    await db.syncSeedExact(
      'checkpoints',
      checkpointsSeedData.map(checkpointToMap).toList(),
    );
    // لازم بعد المزامنة مع السيرفر (مش قبلها)، حتى تحديثات الأدمن الحقيقية
    // (الحالة) تكتب فوق البيانات المحلية الافتراضية بدل ما تنمسح بيها.
    await ApiService.syncCheckpoints();
    await ApiService.syncTrafficAlert();
    final entries = db.getAll('transport');
    final checkpointEntries = db.getAll('checkpoints');
    setState(() {
      _liveStations = entries.map((e) => mapToListing(e.value)).toList();
      _checkpoints = checkpointEntries
          .map((e) => mapToCheckpoint(e.value))
          .toList();
      _loaded = true;
    });
  }

  Future<void> _activateNearestToMe() async {
    setState(() => _locating = true);
    try {
      final position = await LocationService.instance.getCurrentPosition();
      setState(() {
        _userPosition = position;
        _nearestActive = true;
        _locating = false;
      });
    } catch (e) {
      setState(() => _locating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e is String ? e : e.toString())));
    }
  }

  double? _distanceKmTo(ListingItem it) => distanceKmFromUser(
    _userPosition,
    nameAr: it.nameAr,
    nameEn: it.nameEn,
    locationAr: it.locationAr,
    locationEn: it.locationEn,
    lat: it.lat,
    lng: it.lng,
  );

  List<ListingItem> get _filtered {
    final list = _liveStations.where((it) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          it.nameAr.contains(_searchQuery) ||
          it.nameEn.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesVehicle =
          _vehicleFilter == 'all' || it.subTypeKey == _vehicleFilter;
      return matchesSearch && matchesVehicle;
    }).toList();
    if (_nearestActive && _userPosition != null) {
      list.sort((a, b) => _distanceKmTo(a)!.compareTo(_distanceKmTo(b)!));
    } else {
      list.sort((a, b) {
        if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
        return b.rating.compareTo(a.rating);
      });
    }
    return list;
  }

  void _openStationDetail(ListingItem it) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransportStationDetailScreen(station: it),
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
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SkeletonGrid(count: 6),
            ),
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
            body: KeyboardScrollable(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TransportTopBar(),
                    Padding(
                      padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            app.t('👋 أهلًا فيك', '👋 Welcome'),
                            textDirection: app.dir,
                            style: AppTypography.headline(AppColors.textWhite),
                          ),
                          SizedBox(height: 4),
                          Text(
                            app.t(
                              '🚍 دوري على أفضل وسيلة مواصلات',
                              '🚍 Find the Best Transportation',
                            ),
                            textDirection: app.dir,
                            style: AppTypography.body(AppColors.textGrey),
                          ),
                          SizedBox(height: 16),
                          Container(
                            height: 46,
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark2,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(color: AppColors.borderColor),
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
                                    onChanged: (v) => setState(() => _searchQuery = v),
                                    style: AppTypography.body(AppColors.textWhite),
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      border: InputBorder.none,
                                      hintText: app.t(
                                        'ابحث عن وجهة أو موقف...',
                                        'Search destination or stand...',
                                      ),
                                      hintStyle: AppTypography.caption(AppColors.textGrey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => TripPlannerScreen()),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                              icon: Icon(Icons.calculate_rounded, size: 17, color: AppColors.primary),
                              label: Text(
                                app.t('🧮 حاسبة الرحلة', '🧮 Trip Planner'),
                                style: AppTypography.label(AppColors.primary),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          _MapPreviewCard(
                            onNearestTap: () async {
                              if (_nearestActive) {
                                setState(() => _nearestActive = false);
                              } else {
                                await _activateNearestToMe();
                              }
                            },
                            nearestActive: _nearestActive,
                            nearestLoading: _locating,
                          ),
                          SizedBox(height: 22),
                          _TrafficAlertBanner(),
                          SizedBox(height: 22),
                          Text(
                            app.t('اختر وسيلة المواصلات', 'Choose Transportation'),
                            textDirection: app.dir,
                            style: AppTypography.headline(
                              AppColors.textWhite,
                            ).copyWith(fontSize: 15),
                          ),
                          SizedBox(height: 12),
                          _VehicleFiltersRow(
                            selected: _vehicleFilter,
                            onTap: (key) => setState(
                              () => _vehicleFilter = _vehicleFilter == key ? 'all' : key,
                            ),
                          ),
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Text(
                                app.t('المواقف القريبة', 'Nearby Stations'),
                                textDirection: app.dir,
                                style: AppTypography.headline(
                                  AppColors.textWhite,
                                ).copyWith(fontSize: 15),
                              ),
                              Spacer(),
                              Text(
                                app.t('${filtered.length} نتيجة', '${filtered.length} results'),
                                style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          if (filtered.isEmpty)
                            EmptyState(
                              titleAr: 'لا توجد نتائج مطابقة',
                              titleEn: 'No matching results',
                            )
                          else
                            ...filtered.map(
                              (it) => Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: _StationCard(
                                  station: it,
                                  distanceKm: _distanceKmTo(it),
                                  isFavorite: FavoritesService.instance.isFavorite(it.nameEn),
                                  onFavorite: () async {
                                    await FavoritesService.instance.toggleFavorite(it.nameEn);
                                    setState(() {});
                                  },
                                  onTap: () => _openStationDetail(it),
                                ),
                              ),
                            ),
                          SizedBox(height: 24),
                          Text(
                            app.t('مسارات مقترحة', 'Suggested Routes'),
                            textDirection: app.dir,
                            style: AppTypography.headline(
                              AppColors.textWhite,
                            ).copyWith(fontSize: 15),
                          ),
                          SizedBox(height: 12),
                          _SuggestedRoutesCard(),
                          SizedBox(height: 24),
                          Text(
                            app.t('🚧 الحواجز', 'Checkpoints'),
                            textDirection: app.dir,
                            style: AppTypography.headline(
                              AppColors.textWhite,
                            ).copyWith(fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            app.t(
                              'حالة يدوية من الإدارة (مش مباشرة/GPS) — تحقق دائمًا من مصدر رسمي قبل السفر.',
                              'Manually set by admins (not live/GPS) — always verify with an official source before traveling.',
                            ),
                            textDirection: app.dir,
                            style: AppTypography.caption(AppColors.textGrey),
                          ),
                          SizedBox(height: 12),
                          ..._checkpoints.map(
                            (c) => Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: _CheckpointCard(
                                checkpoint: c,
                                onStatusChanged: AuthService.instance.isAdmin
                                    ? (status) => _updateCheckpointStatus(c, status)
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            app.t('طوارئ', 'Emergency'),
                            textDirection: app.dir,
                            style: AppTypography.headline(
                              AppColors.textWhite,
                            ).copyWith(fontSize: 15),
                          ),
                          SizedBox(height: 12),
                          _EmergencyRow(),
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

  Future<void> _updateCheckpointStatus(
    CheckpointData c,
    CheckpointStatus status,
  ) async {
    final db = LocalDbService.instance;
    final entries = db.getAll('checkpoints');
    final match = entries.firstWhere(
      (e) => e.value['nameEn'] == c.nameEn,
      orElse: () => entries.first,
    );
    final updated = Map<String, dynamic>.from(match.value);
    updated['status'] = status.name;
    await db.update('checkpoints', match.key, updated);

    final apiId = match.value['apiId'] as String?;
    final token = AuthService.instance.adminToken;
    var pushedToServer = false;
    if (apiId != null && token != null) {
      pushedToServer = await ApiService.updateCheckpoint(token, apiId, {
        'status': status.name,
      });
    }

    final refreshed = db.getAll('checkpoints');
    setState(() {
      _checkpoints = refreshed.map((e) => mapToCheckpoint(e.value)).toList();
    });

    if (!pushedToServer && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppState.instance.t(
              'اتحدثت محليًا بس، ما وصلت للسيرفر — تحقّقي من الاتصال بالإنترنت',
              'Updated locally only — could not reach the server, check your connection',
            ),
          ),
        ),
      );
    }
  }
}

// ==================== الشريط العلوي ====================
class _TransportTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
      color: AppColors.sidebarDark,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        // start (مش center) حتى زر الرجوع وزر AR/الوضع الليلي ينزلوا لتحت
        // عن اللوجو والعنوان عالموبايل، بعيد عن شريط الحالة يلي بيغطّي عليهم.
        crossAxisAlignment: isMobile(context)
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: isMobile(context) ? 63 : 0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.cardDark, shape: BoxShape.circle),
                child: Icon(Icons.arrow_back_rounded, color: AppColors.textWhite, size: 18),
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
            child: Icon(Icons.directions_bus_rounded, color: Colors.white, size: 16),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              app.t('مواصلات', 'Transportation'),
              textDirection: app.dir,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 16),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: isMobile(context) ? 63 : 0),
            child: AppToggleBar(),
          ),
        ],
      ),
    );
  }
}

// ==================== بطاقة الخريطة التفاعلية ====================
class _MapPreviewCard extends StatelessWidget {
  final bool nearestActive;
  final bool nearestLoading;
  final VoidCallback onNearestTap;
  const _MapPreviewCard({
    required this.nearestActive,
    required this.nearestLoading,
    required this.onNearestTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => MapScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ThemedImage(
            query: 'city map streets navigation',
            fallbackSeed: 'transport-map-preview',
            height: 130,
            fallbackIcon: Icons.map_rounded,
            fallbackColor: AppColors.primary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(Icons.map_rounded, size: 15, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      app.t('خريطة تفاعلية', 'Interactive Map'),
                      textDirection: app.dir,
                      style: AppTypography.label(AppColors.textWhite),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: NearestToMeChip(
                        active: nearestActive,
                        loading: nearestLoading,
                        onTap: onNearestTap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== تنبيه ازدحام (توضيحي/تجريبي، مش بيانات حية) ====================
// ما في مصدر بيانات مرورية حي حقيقي متاح للتطبيق، فبدل ما نختلق حالة ازدحام
// وهمية بتضلل حدا، هاد البانر بيعرض بس تنبيهًا حقيقيًا كتبته الإدارة يدويًا (زي
// منشور)، وبيكون مخفي تمامًا لو ما في تنبيه فعّال حاليًا.
class _TrafficAlertBanner extends StatefulWidget {
  @override
  State<_TrafficAlertBanner> createState() => _TrafficAlertBannerState();
}

class _TrafficAlertBannerState extends State<_TrafficAlertBanner> {
  Map<String, dynamic>? _alert;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final entry = LocalDbService.instance.get('traffic_alerts', 'current');
    setState(() {
      _alert = (entry != null && entry['active'] == true) ? entry : null;
      _loaded = true;
    });
  }

  Future<void> _editAlert() async {
    final app = AppState.instance;
    final textController = TextEditingController(text: _alert?['textAr'] ?? '');
    final altController = TextEditingController(text: _alert?['altRouteAr'] ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: app.dir,
        child: AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: Text(
            app.t('تنبيه ازدحام', 'Traffic Alert'),
            style: AppTypography.title(AppColors.textWhite),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                textDirection: app.dir,
                style: TextStyle(color: AppColors.textWhite),
                decoration: InputDecoration(
                  labelText: app.t('نص التنبيه', 'Alert text'),
                  labelStyle: TextStyle(color: AppColors.textGrey),
                ),
              ),
              TextField(
                controller: altController,
                textDirection: app.dir,
                style: TextStyle(color: AppColors.textWhite),
                decoration: InputDecoration(
                  labelText: app.t('مسار بديل مقترح (اختياري)', 'Suggested alt. route (optional)'),
                  labelStyle: TextStyle(color: AppColors.textGrey),
                ),
              ),
            ],
          ),
          actions: [
            if (_alert != null)
              TextButton(
                onPressed: () async {
                  const fields = {'active': false};
                  await LocalDbService.instance.update('traffic_alerts', 'current', fields);
                  final token = AuthService.instance.adminToken;
                  if (token != null) {
                    await ApiService.setTrafficAlert(token, fields);
                  }
                  if (context.mounted) Navigator.of(context).pop(true);
                },
                child: Text(app.t('إزالة', 'Remove'), style: TextStyle(color: AppColors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(app.t('إلغاء', 'Cancel'), style: TextStyle(color: AppColors.textGrey)),
            ),
            TextButton(
              onPressed: () async {
                if (textController.text.trim().isEmpty) return;
                final fields = {
                  'active': true,
                  'textAr': textController.text.trim(),
                  'textEn': textController.text.trim(),
                  'altRouteAr': altController.text.trim(),
                  'altRouteEn': altController.text.trim(),
                };
                await LocalDbService.instance.update('traffic_alerts', 'current', fields);
                final token = AuthService.instance.adminToken;
                if (token != null) {
                  await ApiService.setTrafficAlert(token, fields);
                }
                if (context.mounted) Navigator.of(context).pop(true);
              },
              child: Text(app.t('نشر', 'Publish'), style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final isAdmin = AuthService.instance.isAdmin;
    if (!_loaded) return SizedBox.shrink();
    if (_alert == null) {
      if (!isAdmin) return SizedBox.shrink();
      return OutlinedButton.icon(
        onPressed: _editAlert,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
        icon: Icon(Icons.add_alert_rounded, size: 15, color: AppColors.textGrey),
        label: Text(
          app.t('نشر تنبيه ازدحام (أدمن)', 'Publish traffic alert (admin)'),
          style: AppTypography.caption(AppColors.textGrey),
        ),
      );
    }
    final text = app.isArabic ? _alert!['textAr'] : _alert!['textEn'];
    final altRoute = app.isArabic ? _alert!['altRouteAr'] : _alert!['altRouteEn'];
    return GestureDetector(
      onTap: isAdmin ? _editAlert : null,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.gold),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '⚠️ ${text ?? ''}',
                    textDirection: app.dir,
                    style: AppTypography.label(AppColors.textWhite),
                  ),
                  if (altRoute != null && (altRoute as String).isNotEmpty) ...[
                    SizedBox(height: 2),
                    Text(
                      altRoute,
                      textDirection: app.dir,
                      style: AppTypography.caption(AppColors.textGrey),
                    ),
                  ],
                  SizedBox(height: 3),
                  Text(
                    app.t('تنبيه من إدارة التطبيق', 'Posted by app admins'),
                    style: TextStyle(color: AppColors.textGrey, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== فلاتر وسيلة النقل ====================
class _VehicleFiltersRow extends StatelessWidget {
  final String selected;
  final void Function(String) onTap;
  const _VehicleFiltersRow({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: transportVehicleFilters.map((f) {
          final isSelected = selected == f.$1;
          return Padding(
            padding: EdgeInsets.only(left: 10),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(f.$1),
              child: Container(
                width: 80,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.cardDark2,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.borderColor,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      f.$4,
                      size: 22,
                      color: isSelected ? Colors.white : AppColors.textGrey,
                    ),
                    SizedBox(height: 6),
                    Text(
                      app.t(f.$2, f.$3),
                      textAlign: TextAlign.center,
                      textDirection: app.dir,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textWhite,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ==================== كرت موقف/محطة ====================
class _StationCard extends StatelessWidget {
  final ListingItem station;
  final double? distanceKm;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  const _StationCard({
    required this.station,
    required this.distanceKm,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final s = station;
    final name = app.isArabic ? s.nameAr : s.nameEn;
    final location = app.isArabic ? s.locationAr : s.locationEn;
    final extras = transportStationExtras[s.nameEn];
    final waiting = extras == null
        ? null
        : (app.isArabic ? extras.waitingTimeAr : extras.waitingTimeEn);
    return AppCard(
      padding: EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: ThemedImage(
              query: s.photoQuery,
              fallbackSeed: s.nameEn,
              height: 56,
              customImageBase64: s.customImageBase64,
              serverImageUrl: s.serverImageUrl,
              localAsset: s.image,
              fallbackIcon: s.placeholderIcon,
              fallbackColor: s.placeholderColor,
            ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(Icons.location_on, size: 12, color: AppColors.primary),
                    SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        name,
                        textDirection: app.dir,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(AppColors.textWhite),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
                    SizedBox(width: 2),
                    Text('${s.rating}', style: AppTypography.caption(AppColors.textWhite)),
                    SizedBox(width: 10),
                    if (waiting != null) ...[
                      Icon(Icons.access_time, size: 12, color: AppColors.textGrey),
                      SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          waiting,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption(AppColors.textGrey),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      distanceKm != null
                          ? '${(distanceKm! * 1000).round()} م'
                          : location,
                      textDirection: app.dir,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 10.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onFavorite,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: isFavorite ? AppColors.red : AppColors.textGrey,
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final point = resolveMapPoint(
                    nameAr: s.nameAr,
                    nameEn: s.nameEn,
                    locationAr: s.locationAr,
                    locationEn: s.locationEn,
                    lat: s.lat,
                    lng: s.lng,
                  );
                  openDirectionsInExternalMaps(point);
                },
                child: Icon(Icons.directions_rounded, size: 18, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== مسارات مقترحة ====================
// المسارات هون مبنية مباشرة على بيانات المواقف الحقيقية (transportStationExtras)
// بدل أرقام خطوط مُختلَقة — نابلس ما إلها نظام أرقام خطوط رسمي متل الباص العادي؛
// السرفيس بيشتغل بنظام "من محطة لوجهة" (بينادي عليها السائق)، فهاد التمثيل أصدق.
class _SuggestedRoutesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final routes = <(String from, String to, String via, String waiting)>[];
    transportStationExtras.forEach((stationNameEn, extras) {
      final pairs = app.isArabic ? extras.servicesAr : extras.servicesEn;
      for (final p in pairs) {
        routes.add((
          p.$1,
          p.$2,
          stationNameEn,
          app.isArabic ? extras.waitingTimeAr : extras.waitingTimeEn,
        ));
      }
    });
    return AppCard(
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < routes.length; i++) ...[
            if (i > 0) Divider(color: AppColors.borderColor, height: 16),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.place_rounded, size: 15, color: AppColors.primary),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${routes[i].$1} ← ${routes[i].$2}',
                    textDirection: app.dir,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(AppColors.textWhite),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.timer_outlined, size: 12, color: AppColors.textGrey),
                SizedBox(width: 3),
                Text(
                  routes[i].$4,
                  style: AppTypography.caption(AppColors.textGrey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== كرت حاجز ====================
class _CheckpointCard extends StatelessWidget {
  final CheckpointData checkpoint;
  final void Function(CheckpointStatus)? onStatusChanged;
  const _CheckpointCard({required this.checkpoint, this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final c = checkpoint;
    final name = app.isArabic ? c.nameAr : c.nameEn;
    final location = app.isArabic ? c.locationAr : c.locationEn;
    return AppCard(
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: c.status.color, shape: BoxShape.circle),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  textDirection: app.dir,
                  style: AppTypography.label(AppColors.textWhite),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: c.status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  app.isArabic ? c.status.labelAr(app) : c.status.labelEn(),
                  style: TextStyle(
                    color: c.status.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            location,
            textDirection: app.dir,
            style: AppTypography.caption(AppColors.textGrey),
          ),
          if (c.status == CheckpointStatus.closed) ...[
            SizedBox(height: 8),
            Text(
              app.isArabic
                  ? (c.altRouteAr ?? 'ننصح بالتحقق من مسار بديل، أو البحث عن أقرب فندق للمبيت.')
                  : (c.altRouteEn ?? 'We recommend checking an alternate route, or finding the nearest hotel to stay.'),
              textDirection: app.dir,
              style: AppTypography.caption(AppColors.gold),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => HotelsScreen()),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.borderColor),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                icon: Icon(Icons.hotel_rounded, size: 15, color: AppColors.textWhite),
                label: Text(
                  app.t('أقرب فنادق نابلس', 'Nearest Hotels in Nablus'),
                  style: AppTypography.label(AppColors.textWhite),
                ),
              ),
            ),
          ],
          if (onStatusChanged != null) ...[
            SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: CheckpointStatus.values.map((s) {
                final active = s == c.status;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onStatusChanged!(s),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: active ? s.color.withValues(alpha: 0.2) : AppColors.cardDark2,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: active ? s.color : AppColors.borderColor),
                    ),
                    child: Text(
                      app.isArabic ? s.labelAr(app) : s.labelEn(),
                      style: TextStyle(color: active ? s.color : AppColors.textGrey, fontSize: 10),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== صف الطوارئ ====================
class _EmergencyRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.red, Color(0xFFEF6F53)]),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppColors.glowShadow,
              ),
              child: ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse('tel:100')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                icon: Icon(Icons.local_taxi_rounded, size: 17, color: Colors.white),
                label: Text(
                  app.t('طلب تاكسي الآن', 'Taxi Now'),
                  style: AppTypography.title(Colors.white).copyWith(fontSize: 13),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => launchUrl(Uri.parse('tel:100')),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              icon: Icon(Icons.call_rounded, size: 16, color: AppColors.textWhite),
              label: Text(
                app.t('اتصال مواصلات', 'Call Transportation'),
                style: AppTypography.label(AppColors.textWhite),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== شاشة تفاصيل الموقف ====================
class TransportStationDetailScreen extends StatefulWidget {
  final ListingItem station;
  const TransportStationDetailScreen({super.key, required this.station});

  @override
  State<TransportStationDetailScreen> createState() =>
      _TransportStationDetailScreenState();
}

class _TransportStationDetailScreenState
    extends State<TransportStationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final s = widget.station;
    final name = app.isArabic ? s.nameAr : s.nameEn;
    final type = app.isArabic ? s.typeAr : s.typeEn;
    final location = app.isArabic ? s.locationAr : s.locationEn;
    final about = app.isArabic ? s.aboutAr : s.aboutEn;
    final extras = transportStationExtras[s.nameEn];
    final point = resolveMapPoint(
      nameAr: s.nameAr,
      nameEn: s.nameEn,
      locationAr: s.locationAr,
      locationEn: s.locationEn,
      lat: s.lat,
      lng: s.lng,
    );
    final isFavorite = FavoritesService.instance.isFavorite(s.nameEn);

    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      ThemedImage(
                        query: s.photoQuery,
                        fallbackSeed: s.nameEn,
                        height: 220,
                        customImageBase64: s.customImageBase64,
                        serverImageUrl: s.serverImageUrl,
                        localAsset: s.image,
                        fallbackIcon: s.placeholderIcon,
                        fallbackColor: s.placeholderColor,
                      ),
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 44,
                        left: 16,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 44,
                        right: 16,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            await FavoritesService.instance.toggleFavorite(s.nameEn);
                            setState(() {});
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? AppColors.red : Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              name,
                              textDirection: app.dir,
                              style: AppTypography.display(Colors.white).copyWith(fontSize: 22),
                            ),
                            Text(type, textDirection: app.dir, style: AppTypography.body(Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 15, color: AppColors.gold),
                            SizedBox(width: 4),
                            Text('${s.rating}', style: AppTypography.label(AppColors.textWhite)),
                            Spacer(),
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Icon(Icons.access_time, size: 13, color: AppColors.textGrey),
                                SizedBox(width: 4),
                                Text(
                                  extras?.is24Hours == true
                                      ? app.t('يعمل 24 ساعة', 'Open 24 Hours')
                                      : (app.isArabic ? s.infoLabelAr : s.infoLabelEn),
                                  textDirection: app.dir,
                                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(Icons.location_on, size: 13, color: AppColors.textGrey),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                textDirection: app.dir,
                                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        if (extras != null) ...[
                          SizedBox(height: 18),
                          Text(
                            app.t('🚐 الخدمات المتاحة', '🚐 Available Services'),
                            textDirection: app.dir,
                            style: AppTypography.headline(AppColors.textWhite).copyWith(fontSize: 15),
                          ),
                          SizedBox(height: 8),
                          ...List.generate(extras.servicesAr.length, (i) {
                            final pair = app.isArabic ? extras.servicesAr[i] : extras.servicesEn[i];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Icon(Icons.arrow_back_rounded, size: 13, color: AppColors.primary),
                                  SizedBox(width: 6),
                                  Text(
                                    '${pair.$1} ← ${pair.$2}',
                                    textDirection: app.dir,
                                    style: AppTypography.body(AppColors.textGrey),
                                  ),
                                ],
                              ),
                            );
                          }),
                          SizedBox(height: 14),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  app.t('وقت الانتظار التقريبي', 'Approx. Waiting Time'),
                                  textDirection: app.dir,
                                  style: AppTypography.label(AppColors.textWhite),
                                ),
                                Spacer(),
                                Text(
                                  app.isArabic ? extras.waitingTimeAr : extras.waitingTimeEn,
                                  style: AppTypography.label(AppColors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 18),
                        Text(
                          app.t('نبذة', 'Overview'),
                          textDirection: app.dir,
                          style: AppTypography.headline(AppColors.textWhite).copyWith(fontSize: 15),
                        ),
                        SizedBox(height: 8),
                        Text(
                          about,
                          textDirection: app.dir,
                          textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                          style: TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.6),
                        ),
                        SizedBox(height: 22),
                        if (s.phone.isNotEmpty) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => launchUrl(Uri.parse('tel:${s.phone}')),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.borderColor),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                              icon: Icon(Icons.local_taxi_rounded, size: 16, color: AppColors.textWhite),
                              label: Text(
                                app.t('اتصال تاكسي', 'Call Taxi'),
                                style: AppTypography.label(AppColors.textWhite),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: AppColors.primaryGradient),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: AppColors.glowShadow,
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => openDirectionsInExternalMaps(point),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                              icon: Icon(Icons.directions_rounded, size: 16, color: Colors.white),
                              label: Text(
                                app.t('فتح على الخريطة', 'Open in Map'),
                                style: AppTypography.title(Colors.white).copyWith(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AiAssistantScreen(
                                  initialQuery: app.t(
                                    'كيف أوصل من ${s.nameAr}؟',
                                    'How do I get around from ${s.nameEn}?',
                                  ),
                                ),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.borderColor),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            icon: Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.textWhite),
                            label: Text(
                              app.t('اسأل المساعد الذكي', 'Ask the AI Assistant'),
                              style: AppTypography.label(AppColors.textWhite),
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
}
