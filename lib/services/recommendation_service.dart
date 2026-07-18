import '../screens/places/all_places_screen.dart';
import 'recent_activity_service.dart';
import 'favorites_service.dart';

/// دلاء الاهتمامات السبعة اللي بنستنتجها من فئات/تصنيفات الأماكن الموجودة أصلًا
/// بالتطبيق (مش حقل جديد بالبيانات — استنتاج من الحقول الحالية).
const Map<String, String> interestLabelsAr = {
  'restaurants': 'مطاعم',
  'historical': 'أماكن تاريخية',
  'shopping': 'تسوق',
  'nature': 'طبيعة',
  'cafes': 'مقاهي',
  'entertainment': 'ترفيه',
  'religious': 'أماكن دينية',
};

const Map<String, String> interestLabelsEn = {
  'restaurants': 'Restaurants',
  'historical': 'Historical Places',
  'shopping': 'Shopping',
  'nature': 'Nature',
  'cafes': 'Cafes',
  'entertainment': 'Entertainment',
  'religious': 'Religious Places',
};

/// خدمة توصيات حقيقية مبنية على سلوك المستخدم الفعلي (مفضلة + مشاهدات) بدل
/// بيانات ثابتة. كل الدوال هون sync وبتقرأ مباشرة من Hive عبر allPlaces —
/// نفس أسلوب FavoritePlacesSection الموجود أصلًا، بدون أي حالة تحميل/انتظار.
class RecommendationService {
  RecommendationService._();

  static UniversalPlace? _byName(String nameEn) =>
      allPlaces.where((p) => p.nameEn == nameEn).firstOrNull;

  static List<UniversalPlace> _sortedByFeatured(List<UniversalPlace> list) {
    final sorted = List.of(list);
    sorted.sort((a, b) {
      if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
      return b.rating.compareTo(a.rating);
    });
    return sorted;
  }

  /// الأماكن الأكثر مشاهدة حاليًا (على مستوى الجهاز). لو ما في أي نشاط متتبَّع
  /// بعد (تنصيب جديد)، بترجع نفس ترتيب "المميز" الحالي حتى القسم ما يضل فاضي.
  static List<UniversalPlace> trendingToday({int limit = 6}) {
    final names = RecentActivityService.instance.getMostViewedNames(limit: limit * 2);
    final places = names.map(_byName).whereType<UniversalPlace>().take(limit).toList();
    if (places.isNotEmpty) return places;
    return _sortedByFeatured(allPlaces).take(limit).toList();
  }

  /// أماكن مشابهة لسلوك المستخدم (مفضلة + مشاهدات حديثة) — بنجمع فئات الأماكن
  /// اللي تفاعل معها وبنرجع أماكن تانية بنفس الفئات الأكثر تكرارًا.
  static List<UniversalPlace> recommendedForYou({
    int limit = 6,
    Set<String> exclude = const {},
  }) {
    final favoriteNames = FavoritesService.instance.getFavoriteNames();
    final viewedNames = RecentActivityService.instance.getRecentlyViewedNames(limit: 10);
    final signalNames = {...favoriteNames, ...viewedNames};
    final signalPlaces = signalNames.map(_byName).whereType<UniversalPlace>().toList();

    if (signalPlaces.isEmpty) {
      return _sortedByFeatured(allPlaces)
          .where((p) => !exclude.contains(p.nameEn))
          .take(limit)
          .toList();
    }

    final categoryCounts = <String, int>{};
    for (final p in signalPlaces) {
      categoryCounts[p.categoryKey] = (categoryCounts[p.categoryKey] ?? 0) + 1;
    }
    final topCategories = (categoryCounts.keys.toList()
      ..sort((a, b) => categoryCounts[b]!.compareTo(categoryCounts[a]!))).take(2).toSet();

    final favoriteSet = favoriteNames.toSet();
    final candidates = allPlaces
        .where(
          (p) =>
              topCategories.contains(p.categoryKey) &&
              !favoriteSet.contains(p.nameEn) &&
              !exclude.contains(p.nameEn),
        )
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return candidates.take(limit).toList();
  }

  /// يستنتج دلو الاهتمام (من الدلاء السبعة أعلاه) لمكان معيّن، أو null لو
  /// ما بينطبق على أي دلو منها (فنادق، صيدليات...).
  static String? _inferInterest(UniversalPlace p) {
    switch (p.categoryKey) {
      case 'restaurant':
        final match = liveRestaurantsForSearch()
            .where((r) => r.nameEn == p.nameEn)
            .firstOrNull;
        return match?.cuisineKey == 'cafe' ? 'cafes' : 'restaurants';
      case 'attraction':
        final match = liveAttractionsForSearch()
            .where((a) => a.nameEn == p.nameEn)
            .firstOrNull;
        final categories = match?.categories ?? const <String>[];
        if (categories.contains('religious')) return 'religious';
        if (categories.contains('nature')) return 'nature';
        if (categories.contains('historical') ||
            categories.contains('oldCity') ||
            categories.contains('culture')) {
          return 'historical';
        }
        return 'historical';
      case 'shopping':
        return 'shopping';
      case 'entertainment':
        return 'entertainment';
      default:
        return null;
    }
  }

  /// أماكن بنفس اهتمام المستخدم الأكثر تكرارًا (من مفضلاته ومشاهداته). لو ما
  /// في أي إشارة اهتمام واضحة، بترجع قائمة فاضية عمدًا — القسم بختفي كليًا
  /// بهاي الحالة بدل ما يعرض بديل عام مش له معنى.
  static List<UniversalPlace> basedOnYourInterests({
    int limit = 6,
    Set<String> exclude = const {},
  }) {
    final favoriteNames = FavoritesService.instance.getFavoriteNames();
    final viewedNames = RecentActivityService.instance.getRecentlyViewedNames(limit: 10);
    final signalPlaces = {...favoriteNames, ...viewedNames}
        .map(_byName)
        .whereType<UniversalPlace>()
        .toList();

    final interestCounts = <String, int>{};
    for (final p in signalPlaces) {
      final interest = _inferInterest(p);
      if (interest == null) continue;
      interestCounts[interest] = (interestCounts[interest] ?? 0) + 1;
    }
    if (interestCounts.isEmpty) return [];

    final topInterests = (interestCounts.keys.toList()
      ..sort((a, b) => interestCounts[b]!.compareTo(interestCounts[a]!))).take(2).toSet();

    final candidates = allPlaces
        .where((p) => !exclude.contains(p.nameEn) && topInterests.contains(_inferInterest(p)))
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return candidates.take(limit).toList();
  }
}
