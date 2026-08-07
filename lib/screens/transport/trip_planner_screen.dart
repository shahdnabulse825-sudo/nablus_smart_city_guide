import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../theme/app_typography.dart';
import '../../services/location_service.dart';
import '../map/map_screen.dart';
import '../category/category_data.dart' show transportData;

/// مكان معروف تقدر حاسبة الرحلة تحسب منه/إليه. كل مكان إله نص موقع حقيقي
/// (locationAr/En) مطابق لأسماء أحياء/شوارع نابلس المتحقق منها فعليًا بقاعدة
/// إحداثيات الخريطة (_areaCoords بـ map_screen.dart) — مش بس اسم العرض —
/// حتى حساب "أقرب مكان لموقعي" يكون دقيق بدل ما ينحصر بمكانين بس.
class KnownPlace {
  final String key;
  final String labelAr;
  final String labelEn;
  final String locationAr;
  final String locationEn;
  final bool isLocal; // false = وجهة بين مدن (رام الله)، ما تنحسب كـ"أقرب مكان" بالـ GPS المحلي
  const KnownPlace({
    required this.key,
    required this.labelAr,
    required this.labelEn,
    required this.locationAr,
    required this.locationEn,
    this.isLocal = true,
  });
}

const List<KnownPlace> tripPlannerPlaces = [
  KnownPlace(
    key: 'martyrs',
    labelAr: 'دوار الشهداء (وسط البلد)',
    labelEn: 'Martyrs Circle (Downtown)',
    locationAr: 'دوار الشهداء',
    locationEn: 'Martyrs Circle',
  ),
  KnownPlace(
    key: 'rafidia',
    labelAr: 'رفيديا',
    labelEn: 'Rafidia',
    locationAr: 'رفيديا',
    locationEn: 'Rafidia',
  ),
  KnownPlace(
    key: 'oldCity',
    labelAr: 'البلدة القديمة',
    labelEn: 'Old City',
    locationAr: 'البلدة القديمة',
    locationEn: 'Old City',
  ),
  KnownPlace(
    key: 'university',
    labelAr: 'جامعة النجاح',
    labelEn: 'An-Najah University',
    // "شارع الجامعة" هو المفتاح المتحقق منه بقاعدة إحداثيات الخريطة، فبنستخدمه
    // كموقع فعلي بدل "جامعة النجاح" اللي ما إلها إحداثيات مسجّلة مباشرة.
    locationAr: 'شارع الجامعة',
    locationEn: 'University St.',
  ),
  KnownPlace(
    key: 'balata',
    labelAr: 'بلاطة',
    labelEn: 'Balata',
    locationAr: 'بلاطة',
    locationEn: 'Balata',
  ),
  KnownPlace(
    key: 'askar',
    labelAr: 'عسكر',
    labelEn: 'Askar',
    locationAr: 'عسكر',
    locationEn: 'Askar',
  ),
  KnownPlace(
    key: 'ramallah',
    labelAr: 'رام الله',
    labelEn: 'Ramallah',
    locationAr: 'رام الله',
    locationEn: 'Ramallah',
    isLocal: false,
  ),
];

/// خط مباشر حقيقي بين مكانين — كل رحلة هون مبنية على نفس بيانات المواقف
/// الموجودة بقسم المواصلات. التكلفة "تقديرية" بوضوح لأنه ما في تسعيرة رسمية
/// منشورة نقدر نتأكد منها؛ لازم تتأكد من السائق وقت الركوب.
class TripConnection {
  final String fromKey;
  final String toKey;
  final String stationNameEn; // الموقف اللي بتركبي منه هالخط
  final String modeAr;
  final String modeEn;
  final int durationMinutes;
  final String costEstimateAr;
  final String costEstimateEn;
  const TripConnection({
    required this.fromKey,
    required this.toKey,
    required this.stationNameEn,
    required this.modeAr,
    required this.modeEn,
    required this.durationMinutes,
    required this.costEstimateAr,
    required this.costEstimateEn,
  });
}

const List<TripConnection> tripConnections = [
  TripConnection(
    fromKey: 'rafidia',
    toKey: 'oldCity',
    stationNameEn: 'Rafidia Service Taxi Stand',
    modeAr: '🚐 سرفيس',
    modeEn: '🚐 Service Taxi',
    durationMinutes: 10,
    costEstimateAr: '٢-٣ ₪ (تقديري)',
    costEstimateEn: '2-3 NIS (estimated)',
  ),
  TripConnection(
    fromKey: 'rafidia',
    toKey: 'balata',
    stationNameEn: 'Rafidia Service Taxi Stand',
    modeAr: '🚐 سرفيس',
    modeEn: '🚐 Service Taxi',
    durationMinutes: 12,
    costEstimateAr: '٢-٣ ₪ (تقديري)',
    costEstimateEn: '2-3 NIS (estimated)',
  ),
  TripConnection(
    fromKey: 'rafidia',
    toKey: 'university',
    stationNameEn: 'Rafidia Service Taxi Stand',
    modeAr: '🚐 سرفيس',
    modeEn: '🚐 Service Taxi',
    durationMinutes: 8,
    costEstimateAr: '٢-٣ ₪ (تقديري)',
    costEstimateEn: '2-3 NIS (estimated)',
  ),
  TripConnection(
    fromKey: 'rafidia',
    toKey: 'askar',
    stationNameEn: 'Rafidia Service Taxi Stand',
    modeAr: '🚐 سرفيس',
    modeEn: '🚐 Service Taxi',
    durationMinutes: 15,
    costEstimateAr: '٣-٤ ₪ (تقديري)',
    costEstimateEn: '3-4 NIS (estimated)',
  ),
  TripConnection(
    fromKey: 'martyrs',
    toKey: 'rafidia',
    stationNameEn: 'Martyrs Circle Service Taxi Stand',
    modeAr: '🚐 سرفيس',
    modeEn: '🚐 Service Taxi',
    durationMinutes: 10,
    costEstimateAr: '٢-٣ ₪ (تقديري)',
    costEstimateEn: '2-3 NIS (estimated)',
  ),
  TripConnection(
    fromKey: 'martyrs',
    toKey: 'university',
    stationNameEn: 'Martyrs Circle Service Taxi Stand',
    modeAr: '🚐 سرفيس',
    modeEn: '🚐 Service Taxi',
    durationMinutes: 8,
    costEstimateAr: '٢-٣ ₪ (تقديري)',
    costEstimateEn: '2-3 NIS (estimated)',
  ),
  TripConnection(
    fromKey: 'martyrs',
    toKey: 'oldCity',
    stationNameEn: 'Martyrs Circle Service Taxi Stand',
    modeAr: '🚶 سرفيس/مشي',
    modeEn: '🚶 Service Taxi/Walk',
    durationMinutes: 5,
    costEstimateAr: '١-٢ ₪ (تقديري) أو مشي',
    costEstimateEn: '1-2 NIS (estimated) or walk',
  ),
  TripConnection(
    fromKey: 'martyrs',
    toKey: 'balata',
    stationNameEn: 'Central Bus Station',
    modeAr: '🚌 باص/سرفيس',
    modeEn: '🚌 Bus/Service',
    durationMinutes: 12,
    costEstimateAr: '٢-٣ ₪ (تقديري)',
    costEstimateEn: '2-3 NIS (estimated)',
  ),
  TripConnection(
    fromKey: 'martyrs',
    toKey: 'askar',
    stationNameEn: 'Central Bus Station',
    modeAr: '🚌 باص/سرفيس',
    modeEn: '🚌 Bus/Service',
    durationMinutes: 15,
    costEstimateAr: '٣-٤ ₪ (تقديري)',
    costEstimateEn: '3-4 NIS (estimated)',
  ),
  TripConnection(
    fromKey: 'martyrs',
    toKey: 'ramallah',
    stationNameEn: 'Nablus - Ramallah Bus Line',
    modeAr: '🚌 باص بين مدن',
    modeEn: '🚌 Intercity Bus',
    durationMinutes: 45,
    costEstimateAr: '١٥-٢٠ ₪ (تقديري)',
    costEstimateEn: '15-20 NIS (estimated)',
  ),
];

class TripLeg {
  final TripConnection connection;
  final bool reversed; // true لو الرحلة الفعلية بعكس اتجاه الخط المسجّل
  const TripLeg(this.connection, this.reversed);
}

class TripPlanResult {
  final List<TripLeg> legs;
  const TripPlanResult(this.legs);

  bool get requiresTransfer => legs.length > 1;
  int get totalMinutes => legs.fold(0, (sum, l) => sum + l.connection.durationMinutes);
}

TripPlanResult? planTrip(String fromKey, String toKey) {
  if (fromKey == toKey) return null;
  for (final c in tripConnections) {
    if (c.fromKey == fromKey && c.toKey == toKey) {
      return TripPlanResult([TripLeg(c, false)]);
    }
    if (c.fromKey == toKey && c.toKey == fromKey) {
      return TripPlanResult([TripLeg(c, true)]);
    }
  }
  // ما في خط مباشر — نجرّب نوصل عن طريق دوار الشهداء (المحور الرئيسي لشبكة السرفيس)
  if (fromKey != 'martyrs' && toKey != 'martyrs') {
    TripConnection? leg1;
    bool leg1Reversed = false;
    for (final c in tripConnections) {
      if (c.fromKey == fromKey && c.toKey == 'martyrs') {
        leg1 = c;
        break;
      }
      if (c.fromKey == 'martyrs' && c.toKey == fromKey) {
        leg1 = c;
        leg1Reversed = true;
        break;
      }
    }
    TripConnection? leg2;
    bool leg2Reversed = false;
    for (final c in tripConnections) {
      if (c.fromKey == 'martyrs' && c.toKey == toKey) {
        leg2 = c;
        break;
      }
      if (c.fromKey == toKey && c.toKey == 'martyrs') {
        leg2 = c;
        leg2Reversed = true;
        break;
      }
    }
    if (leg1 != null && leg2 != null) {
      return TripPlanResult([
        TripLeg(leg1, leg1Reversed),
        TripLeg(leg2, leg2Reversed),
      ]);
    }
  }
  return null;
}

/// بترجع أقرب "مكان معروف" فعليًا لموقعك الحالي (GPS)، بمقارنة المسافة الحقيقية
/// لموقعك مع *كل* الأماكن المحلية (isLocal) بقائمة tripPlannerPlaces — مش بس
/// اثنين منها — عشان ما ينحاز الحساب لمكان واحد بغض النظر وين موقعك فعليًا.
/// رام الله مستثناة لأنها مدينة تانية، مش هدف واقعي لـ"أقرب مكان" بالـ GPS المحلي.
String? nearestPlaceKeyToPosition(Position position) {
  String? bestKey;
  double? bestKm;
  for (final place in tripPlannerPlaces) {
    if (!place.isLocal) continue;
    final km = distanceKmFromUser(
      position,
      nameAr: place.labelAr,
      nameEn: place.labelEn,
      locationAr: place.locationAr,
      locationEn: place.locationEn,
    );
    if (km != null && (bestKm == null || km < bestKm)) {
      bestKm = km;
      bestKey = place.key;
    }
  }
  return bestKey;
}

/// مسافة المشي الحقيقية (كم) من موقعك الحالي للموقف اللي بتركبي منه هالخط،
/// بالاعتماد على الموقع الفعلي المسجّل لهاد الموقف بـ transportData (مش نقطة فاضية).
double? walkDistanceKmToStation(Position position, String stationNameEn) {
  final station = transportData.firstWhere(
    (it) => it.nameEn == stationNameEn,
    orElse: () => transportData.first,
  );
  return distanceKmFromUser(
    position,
    nameAr: station.nameAr,
    nameEn: station.nameEn,
    locationAr: station.locationAr,
    locationEn: station.locationEn,
    lat: station.lat,
    lng: station.lng,
  );
}

// ==================== شاشة حاسبة الرحلة ====================
class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  String? _fromKey;
  String? _toKey;
  TripPlanResult? _result;
  bool _searched = false;

  Position? _userPosition;
  bool _locatingUser = false;
  double? _walkDistanceMeters;

  Future<void> _useCurrentLocation() async {
    setState(() => _locatingUser = true);
    try {
      final position = await LocationService.instance.getCurrentPosition();
      debugPrint(
        '📍 GPS raw position: lat=${position.latitude}, lng=${position.longitude}, '
        'accuracy=${position.accuracy}m (Nablus real center ≈ 32.2211, 35.2608)',
      );
      final nearestKey = nearestPlaceKeyToPosition(position);
      if (!mounted) return;
      if (nearestKey == null) {
        setState(() => _locatingUser = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppState.instance.t(
                'تعذّر تحديد أقرب موقف لموقعك الحالي',
                "Couldn't determine the nearest stand to your current location",
              ),
            ),
          ),
        );
        return;
      }
      setState(() {
        _userPosition = position;
        _fromKey = nearestKey; // أقرب موقف فعلي لموقعك الحالي الحقيقي (GPS)، مش قيمة ثابتة
        _locatingUser = false;
      });
    } catch (e) {
      setState(() => _locatingUser = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e is String ? e : e.toString())));
    }
  }

  void _calculate() {
    if (_fromKey == null || _toKey == null) return;
    final result = planTrip(_fromKey!, _toKey!);
    setState(() {
      _result = result;
      _searched = true;
      _walkDistanceMeters = (_userPosition != null && result != null)
          ? _walkDistanceToStation(result.legs.first.connection.stationNameEn)
          : null;
    });
  }

  double? _walkDistanceToStation(String stationNameEn) {
    if (_userPosition == null) return null;
    final km = walkDistanceKmToStation(_userPosition!, stationNameEn);
    return km == null ? null : km * 1000;
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
                          child: Icon(Icons.calculate_rounded, color: Colors.white, size: 16),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            app.t('حاسبة الرحلة', 'Trip Planner'),
                            textDirection: app.dir,
                            style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 16),
                          ),
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
                            app.t('من', 'From'),
                            textDirection: app.dir,
                            style: AppTypography.label(AppColors.textWhite),
                          ),
                          SizedBox(height: 6),
                          _PlaceDropdown(
                            value: _fromKey,
                            onChanged: (v) => setState(() {
                              _fromKey = v;
                              _userPosition = null; // اختيار يدوي بيلغي "موقعي الحالي" السابق
                            }),
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _locatingUser ? null : _useCurrentLocation,
                              icon: _locatingUser
                                  ? SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                    )
                                  : Icon(Icons.my_location_rounded, size: 14, color: AppColors.primary),
                              label: Text(
                                app.t('استخدم موقعي الحالي', 'Use my current location'),
                                style: AppTypography.caption(AppColors.primary),
                              ),
                            ),
                          ),
                          if (_userPosition != null) ...[
                            SizedBox(height: 2),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                app.t(
                                  '📍 الإحداثيات المكتشفة: ${_userPosition!.latitude.toStringAsFixed(4)}, ${_userPosition!.longitude.toStringAsFixed(4)} (دقّة ${_userPosition!.accuracy.round()} م)',
                                  '📍 Detected coordinates: ${_userPosition!.latitude.toStringAsFixed(4)}, ${_userPosition!.longitude.toStringAsFixed(4)} (accuracy ${_userPosition!.accuracy.round()} m)',
                                ),
                                textDirection: app.dir,
                                style: TextStyle(color: AppColors.textGrey, fontSize: 10),
                              ),
                            ),
                          ],
                          SizedBox(height: 14),
                          Text(
                            app.t('إلى', 'To'),
                            textDirection: app.dir,
                            style: AppTypography.label(AppColors.textWhite),
                          ),
                          SizedBox(height: 6),
                          _PlaceDropdown(
                            value: _toKey,
                            onChanged: (v) => setState(() => _toKey = v),
                          ),
                          SizedBox(height: 20),
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
                                onPressed: (_fromKey != null && _toKey != null) ? _calculate : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                ),
                                child: Text(
                                  app.t('احسب الرحلة', 'Calculate Trip'),
                                  style: AppTypography.title(Colors.white).copyWith(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          if (_searched) ...[
                            SizedBox(height: 24),
                            if (_result == null)
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardDark2,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(color: AppColors.borderColor),
                                ),
                                child: Text(
                                  app.t(
                                    'ما لقيت خط مباشر أو عبر دوار الشهداء بين هالمكانين بالبيانات الحالية. جرّب تسأل المساعد الذكي.',
                                    'No direct route or connection via Martyrs Circle was found between these places in the current data. Try asking the AI assistant.',
                                  ),
                                  textDirection: app.dir,
                                  style: AppTypography.body(AppColors.textGrey),
                                ),
                              )
                            else
                              _TripResultCard(
                                result: _result!,
                                walkDistanceMeters: _walkDistanceMeters,
                              ),
                          ],
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
}

class _PlaceDropdown extends StatelessWidget {
  final String? value;
  final void Function(String?) onChanged;
  const _PlaceDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark2,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.cardDark,
          hint: Text(
            app.t('اختر مكانًا...', 'Select a place...'),
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          style: TextStyle(color: AppColors.textWhite, fontSize: 13),
          items: tripPlannerPlaces
              .map(
                (p) => DropdownMenuItem(
                  value: p.key,
                  child: Text(app.t(p.labelAr, p.labelEn)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TripResultCard extends StatelessWidget {
  final TripPlanResult result;
  final double? walkDistanceMeters;
  const _TripResultCard({required this.result, required this.walkDistanceMeters});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final firstLeg = result.legs.first;
    final firstStationEn = firstLeg.connection.stationNameEn;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.cardDark2],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (result.requiresTransfer) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                app.t('🔁 تحتاجي تبديل مواصلة (transfer)', '🔁 Requires a transfer'),
                style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 10),
          ],
          for (var i = 0; i < result.legs.length; i++) ...[
            if (i > 0) ...[
              SizedBox(height: 8),
              Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.textGrey),
              SizedBox(height: 8),
            ],
            _LegRow(leg: result.legs[i]),
          ],
          Divider(color: AppColors.borderColor, height: 26),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                app.t('⏱️ إجمالي الزمن: ${result.totalMinutes} دقيقة', '⏱️ Total time: ${result.totalMinutes} min'),
                style: AppTypography.label(AppColors.textWhite),
              ),
            ],
          ),
          if (walkDistanceMeters != null) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.directions_walk_rounded, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    app.t(
                      '🚶 مسافة المشي إلى الموقف: ${walkDistanceMeters!.round()} متر',
                      '🚶 Walk to the stand: ${walkDistanceMeters!.round()} m',
                    ),
                    style: AppTypography.label(AppColors.textWhite),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final station = transportData.firstWhere(
                  (it) => it.nameEn == firstStationEn,
                  orElse: () => transportData.first,
                );
                final point = resolveMapPoint(
                  nameAr: station.nameAr,
                  nameEn: station.nameEn,
                  locationAr: station.locationAr,
                  locationEn: station.locationEn,
                  lat: station.lat,
                  lng: station.lng,
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      focusPoint: point,
                      focusNameAr: station.nameAr,
                      focusNameEn: station.nameEn,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              icon: Icon(Icons.location_on_rounded, size: 15, color: AppColors.textWhite),
              label: Text(
                app.t('📍 مكان الموقف على الخريطة', '📍 Stand location on map'),
                style: AppTypography.label(AppColors.textWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegRow extends StatelessWidget {
  final TripLeg leg;
  const _LegRow({required this.leg});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final c = leg.connection;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.directions_transit_rounded, size: 16, color: AppColors.primary),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                app.t('أفضل وسيلة: ${c.modeAr}', 'Best option: ${c.modeEn}'),
                textDirection: app.dir,
                style: AppTypography.label(AppColors.textWhite),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.attach_money_rounded, size: 16, color: AppColors.green),
            SizedBox(width: 6),
            Text(
              app.t('التكلفة: ${c.costEstimateAr}', 'Cost: ${c.costEstimateEn}'),
              style: AppTypography.caption(AppColors.textGrey),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.place_outlined, size: 14, color: AppColors.textGrey),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                app.t('اركبي من: ${c.stationNameEn}', 'Board at: ${c.stationNameEn}'),
                style: AppTypography.caption(AppColors.textGrey),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
