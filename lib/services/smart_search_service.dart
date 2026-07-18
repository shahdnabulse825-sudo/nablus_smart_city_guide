import '../screens/places/all_places_screen.dart';

/// الفلاتر/النية اللي استنتجناها من كلمات البحث (مثل "أفضل"، "رخيص"، "24 ساعة").
class SearchIntent {
  final String? categoryKey;
  final String? cuisineKey;
  final String? priceTier;
  final bool? is24Hours;
  final Set<String> attractionCategories;
  final bool familyFriendly;
  final bool sortByRatingDesc;
  final bool openNowRequested;

  const SearchIntent({
    this.categoryKey,
    this.cuisineKey,
    this.priceTier,
    this.is24Hours,
    this.attractionCategories = const {},
    this.familyFriendly = false,
    this.sortByRatingDesc = false,
    this.openNowRequested = false,
  });

  bool get isEmpty =>
      categoryKey == null &&
      cuisineKey == null &&
      priceTier == null &&
      is24Hours == null &&
      attractionCategories.isEmpty &&
      !familyFriendly &&
      !sortByRatingDesc &&
      !openNowRequested;

  SearchIntent mergeWith(SearchIntent other) => SearchIntent(
    categoryKey: other.categoryKey ?? categoryKey,
    cuisineKey: other.cuisineKey ?? cuisineKey,
    priceTier: other.priceTier ?? priceTier,
    is24Hours: other.is24Hours ?? is24Hours,
    attractionCategories: {...attractionCategories, ...other.attractionCategories},
    familyFriendly: familyFriendly || other.familyFriendly,
    sortByRatingDesc: sortByRatingDesc || other.sortByRatingDesc,
    openNowRequested: openNowRequested || other.openNowRequested,
  );

  /// شرائح (بالعربي/الإنجليزي) لعرض الفلاتر المكتشفة تلقائيًا فوق نتائج البحث.
  List<(String, String)> describe() {
    final chips = <(String, String)>[];
    if (sortByRatingDesc) chips.add(('الأعلى تقييمًا', 'Top rated'));
    if (categoryKey != null) {
      chips.add((_categoryLabelsAr[categoryKey] ?? categoryKey!, _categoryLabelsEn[categoryKey] ?? categoryKey!));
    }
    if (priceTier == 'cheap') chips.add(('اقتصادي', 'Budget-friendly'));
    if (priceTier == 'high') chips.add(('فاخر', 'Luxury'));
    if (cuisineKey == 'cafe') chips.add(('مقاهي', 'Cafes'));
    if (is24Hours == true) chips.add(('24 ساعة', '24-hour'));
    if (attractionCategories.isNotEmpty) chips.add(('تاريخي', 'Historical'));
    if (familyFriendly) chips.add(('عائلي', 'Family-friendly'));
    return chips;
  }
}

// كلمات/عبارات مفتاحية (عربي وإنجليزي) وما تدل عليه من نية بحث. بنفحص القيمة
// كـ substring داخل الاستعلام كامل بدل مطابقة كلمة-بكلمة، حتى نغطي عبارات
// من أكثر من كلمة زي "24 hour" أو "أفضل مطاعم" بدون تعقيد إضافي.
final Map<String, SearchIntent> _keywordIntents = {
  'best': const SearchIntent(sortByRatingDesc: true),
  'top': const SearchIntent(sortByRatingDesc: true),
  'أفضل': const SearchIntent(sortByRatingDesc: true),
  'احسن': const SearchIntent(sortByRatingDesc: true),
  'cheap': const SearchIntent(priceTier: 'cheap'),
  'رخيص': const SearchIntent(priceTier: 'cheap'),
  'اقتصادي': const SearchIntent(priceTier: 'cheap'),
  'luxury': const SearchIntent(priceTier: 'high'),
  'فاخر': const SearchIntent(priceTier: 'high'),
  'coffee': const SearchIntent(categoryKey: 'restaurant', cuisineKey: 'cafe'),
  'cafe': const SearchIntent(categoryKey: 'restaurant', cuisineKey: 'cafe'),
  'قهوة': const SearchIntent(categoryKey: 'restaurant', cuisineKey: 'cafe'),
  'كافيه': const SearchIntent(categoryKey: 'restaurant', cuisineKey: 'cafe'),
  '24 hour': const SearchIntent(categoryKey: 'pharmacy', is24Hours: true),
  '24-hour': const SearchIntent(categoryKey: 'pharmacy', is24Hours: true),
  '24 ساعة': const SearchIntent(categoryKey: 'pharmacy', is24Hours: true),
  'hotels': const SearchIntent(categoryKey: 'hotel'),
  'hotel': const SearchIntent(categoryKey: 'hotel'),
  'فنادق': const SearchIntent(categoryKey: 'hotel'),
  'فندق': const SearchIntent(categoryKey: 'hotel'),
  'restaurants': const SearchIntent(categoryKey: 'restaurant'),
  'restaurant': const SearchIntent(categoryKey: 'restaurant'),
  'مطاعم': const SearchIntent(categoryKey: 'restaurant'),
  'مطعم': const SearchIntent(categoryKey: 'restaurant'),
  'historical': const SearchIntent(categoryKey: 'attraction', attractionCategories: {'historical', 'oldCity'}),
  'historic': const SearchIntent(categoryKey: 'attraction', attractionCategories: {'historical', 'oldCity'}),
  'تاريخي': const SearchIntent(categoryKey: 'attraction', attractionCategories: {'historical', 'oldCity'}),
  'أثري': const SearchIntent(categoryKey: 'attraction', attractionCategories: {'historical', 'oldCity'}),
  'kids': const SearchIntent(familyFriendly: true),
  'family': const SearchIntent(familyFriendly: true),
  'أطفال': const SearchIntent(familyFriendly: true),
  'عائلي': const SearchIntent(familyFriendly: true),
  'shopping': const SearchIntent(categoryKey: 'shopping'),
  'تسوق': const SearchIntent(categoryKey: 'shopping'),
  'pharmacy': const SearchIntent(categoryKey: 'pharmacy'),
  'صيدلية': const SearchIntent(categoryKey: 'pharmacy'),
  'صيدليات': const SearchIntent(categoryKey: 'pharmacy'),
  'open now': const SearchIntent(openNowRequested: true),
  'مفتوح الآن': const SearchIntent(openNowRequested: true),
  'مفتوح الان': const SearchIntent(openNowRequested: true),
};

const Map<String, String> _categoryLabelsAr = {
  'restaurant': 'مطاعم',
  'hotel': 'فنادق',
  'attraction': 'سياحة ومعالم',
  'shopping': 'تسوق',
  'pharmacy': 'صيدليات',
};
const Map<String, String> _categoryLabelsEn = {
  'restaurant': 'Restaurants',
  'hotel': 'Hotels',
  'attraction': 'Attractions',
  'shopping': 'Shopping',
  'pharmacy': 'Pharmacies',
};

class SmartSearchResult {
  final List<UniversalPlace> places;
  final SearchIntent intent;
  const SmartSearchResult({required this.places, required this.intent});
}

/// بحث ذكي: بيفهم عبارات زي "أفضل مطاعم"، "فنادق رخيصة"، "صيدلية 24 ساعة"،
/// "قهوة"، "أماكن تاريخية"، "عائلي" — وبيرجع لنفس سلوك البحث النصي البسيط
/// (مطابقة جزئية بالاسم) لو ما انطبقت أي نية معروفة، حتى ما ينكسر البحث القديم.
SmartSearchResult smartSearch(String rawQuery, List<UniversalPlace> pool) {
  final query = rawQuery.trim().toLowerCase();
  if (query.isEmpty) {
    return const SmartSearchResult(places: [], intent: SearchIntent());
  }

  var intent = const SearchIntent();
  var remaining = query;
  for (final entry in _keywordIntents.entries) {
    if (remaining.contains(entry.key)) {
      intent = intent.mergeWith(entry.value);
      remaining = remaining.replaceAll(entry.key, ' ');
    }
  }
  final freeTextTokens = remaining
      .split(RegExp(r'\s+'))
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  Iterable<UniversalPlace> candidates = pool;

  if (intent.familyFriendly) {
    final familyHotelNames = liveHotelsForSearch()
        .where((h) => h.tags.contains('familyFriendly'))
        .map((h) => h.nameEn)
        .toSet();
    candidates = candidates.where(
      (p) => p.categoryKey == 'entertainment' || familyHotelNames.contains(p.nameEn),
    );
  } else if (intent.categoryKey != null) {
    candidates = candidates.where((p) => p.categoryKey == intent.categoryKey);
  }
  if (intent.priceTier != null) {
    candidates = candidates.where((p) => p.priceTier == intent.priceTier);
  }
  if (intent.is24Hours == true) {
    candidates = candidates.where((p) => p.is24Hours);
  }
  if (intent.cuisineKey != null) {
    final matchNames = liveRestaurantsForSearch()
        .where((r) => r.cuisineKey == intent.cuisineKey)
        .map((r) => r.nameEn)
        .toSet();
    candidates = candidates.where((p) => matchNames.contains(p.nameEn));
  }
  if (intent.attractionCategories.isNotEmpty) {
    final matchNames = liveAttractionsForSearch()
        .where((a) => a.categories.any(intent.attractionCategories.contains))
        .map((a) => a.nameEn)
        .toSet();
    candidates = candidates.where((p) => matchNames.contains(p.nameEn));
  }

  var results = candidates.toList();

  if (freeTextTokens.isNotEmpty) {
    final scored = <MapEntry<UniversalPlace, int>>[
      for (final p in results) MapEntry(p, _score(p, freeTextTokens)),
    ];
    if (intent.isEmpty) {
      // ولا نية واضحة انطبقت: نفس سلوك البحث النصي البسيط القديم بالظبط، حتى
      // ما ينكسر أي استعلام عادي كان شغال قبل.
      results = pool
          .where(
            (p) =>
                p.nameAr.contains(rawQuery) ||
                p.nameEn.toLowerCase().contains(rawQuery.toLowerCase()),
          )
          .toList();
      return SmartSearchResult(places: results, intent: intent);
    }
    scored.sort((a, b) {
      final scoreCompare = b.value.compareTo(a.value);
      if (scoreCompare != 0) return scoreCompare;
      return b.key.rating.compareTo(a.key.rating);
    });
    results = scored.map((e) => e.key).toList();
  } else {
    results.sort((a, b) => b.rating.compareTo(a.rating));
  }

  return SmartSearchResult(places: results, intent: intent);
}

int _score(UniversalPlace p, List<String> tokens) {
  var score = 0;
  final name = '${p.nameAr} ${p.nameEn}'.toLowerCase();
  final typeLocation = '${p.typeAr} ${p.typeEn} ${p.locationAr} ${p.locationEn}'.toLowerCase();
  final about = '${p.aboutAr} ${p.aboutEn}'.toLowerCase();
  for (final token in tokens) {
    if (name.contains(token)) score += 3;
    if (typeLocation.contains(token)) score += 2;
    if (about.contains(token)) score += 1;
  }
  return score;
}
