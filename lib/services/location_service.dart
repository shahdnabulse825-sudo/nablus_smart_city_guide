import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../screens/home/home_screen.dart' show AppState;
import '../screens/map/map_screen.dart' show resolveMapPoint;

/// يوحّد تدفّق إذن/تحديد الموقع الموجود أصلًا بشاشة الصيدليات (pharmacies_screen.dart)
/// بمكان واحد قابل لإعادة الاستخدام من أي شاشة (زي "الأماكن القريبة"). بيرمي
/// رسالة نصية ثنائية اللغة عند الفشل (نفس أسلوب pharmacies_screen.dart بالضبط).
class LocationService {
  LocationService._internal();
  static final LocationService instance = LocationService._internal();

  Future<Position> getCurrentPosition() async {
    final app = AppState.instance;
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw app.t(
        'خدمة الموقع غير مفعّلة على جهازك',
        'Location services are disabled on your device',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw app.t(
        'تم رفض إذن الوصول للموقع',
        'Location permission was denied',
      );
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(timeLimit: Duration(seconds: 10)),
    );
    // بعض المنصات (زي سطح مكتب ويندوز بدون GPS حقيقي) ممكن ترجّع إحداثيات
    // غير صالحة (NaN/Infinity) بدل ما ترمي خطأ — لو استخدمناها متل ما هي بتكسر
    // حسابات المسافة وخرائط flutter_map بشكل متكرر. نتعامل معها كفشل عادي.
    if (!position.latitude.isFinite || !position.longitude.isFinite) {
      throw app.t(
        'تعذّر تحديد موقعك الحالي على هذا الجهاز',
        'Could not determine your current location on this device',
      );
    }
    return position;
  }

  double distanceKm(LatLng from, LatLng to) =>
      Geolocator.distanceBetween(from.latitude, from.longitude, to.latitude, to.longitude) / 1000;

  /// تقدير تقريبي (مش عبر مسار حقيقي) — مشي بمعدّل ~5 كم/سا
  int walkingMinutes(double km) => _safeMinutes(km, 5);

  /// تقدير تقريبي (مش عبر مسار حقيقي) — قيادة بمعدّل ~30 كم/سا داخل المدينة
  int drivingMinutes(double km) => _safeMinutes(km, 30);

  int _safeMinutes(double km, double speedKmh) {
    final minutes = km / speedKmh * 60;
    if (!minutes.isFinite) return 1;
    return minutes.round().clamp(1, 999);
  }
}

// ==================== أقرب عنصر لنقطة معيّنة (مشتركة بين شاشة المعالم والخريطة) ====================
class NearestResult<T> {
  final T item;
  final double distanceKm;
  NearestResult(this.item, this.distanceKm);
}

/// يحسب المسافة (كم) من موقع المستخدم الحالي لأي مكان (مطعم/فندق/صيدلية/معلم/
/// محل...) اعتمادًا على نفس الحقول المشتركة بين كل نماذج البيانات بالتطبيق —
/// حتى تقدر أي شاشة تستخدمه مباشرة بدل ما تعيد كتابة نفس المنطق.
double? distanceKmFromUser(
  Position? userPosition, {
  required String nameAr,
  required String nameEn,
  required String locationAr,
  required String locationEn,
  double? lat,
  double? lng,
}) {
  if (userPosition == null) return null;
  final point = resolveMapPoint(
    nameAr: nameAr,
    nameEn: nameEn,
    locationAr: locationAr,
    locationEn: locationEn,
    lat: lat,
    lng: lng,
  );
  final meters = Geolocator.distanceBetween(
    userPosition.latitude,
    userPosition.longitude,
    point.latitude,
    point.longitude,
  );
  return meters / 1000;
}

NearestResult<T>? findNearest<T>(
  List<T> candidates,
  LatLng from,
  LatLng Function(T) pointOf,
) {
  NearestResult<T>? best;
  for (final c in candidates) {
    final p = pointOf(c);
    final meters = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      p.latitude,
      p.longitude,
    );
    final km = meters / 1000;
    if (best == null || km < best.distanceKm) {
      best = NearestResult(c, km);
    }
  }
  return best;
}
