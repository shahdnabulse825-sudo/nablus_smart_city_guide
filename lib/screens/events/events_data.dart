import 'package:flutter/material.dart';

/// حدث/فعالية قادمة في المدينة.
class EventItem {
  final String titleAr;
  final String titleEn;
  final String venueAr;
  final String venueEn;
  final String day;
  final String monthAr;
  final String monthEn;
  final String timeAr;
  final String timeEn;
  final String aboutAr;
  final String aboutEn;
  final String photoQuery;
  final IconData icon;
  final Color color;

  const EventItem({
    required this.titleAr,
    required this.titleEn,
    required this.venueAr,
    required this.venueEn,
    required this.day,
    required this.monthAr,
    required this.monthEn,
    required this.timeAr,
    required this.timeEn,
    required this.aboutAr,
    required this.aboutEn,
    required this.photoQuery,
    required this.icon,
    required this.color,
  });
}

final List<EventItem> eventsData = [
  EventItem(
    titleAr: 'مهرجان التسوق السنوي',
    titleEn: 'Annual Shopping Festival',
    venueAr: 'مركز المدينة',
    venueEn: 'City Center',
    day: '15',
    monthAr: 'يونيو',
    monthEn: 'Jun',
    timeAr: '4:00م - 10:00م',
    timeEn: '4:00PM - 10:00PM',
    aboutAr: 'تخفيضات وعروض من محلات المدينة مع فقرات ترفيهية للعائلات طوال أيام المهرجان.',
    aboutEn: 'Discounts and offers from city shops with family entertainment throughout the festival.',
    photoQuery: 'shopping festival crowd',
    icon: Icons.shopping_bag,
    color: Color(0xFF3B82F6),
  ),
  EventItem(
    titleAr: 'معرض نابلس للكتاب',
    titleEn: 'Nablus Book Fair',
    venueAr: 'مركز المعارض',
    venueEn: 'Exhibition Center',
    day: '22',
    monthAr: 'يونيو',
    monthEn: 'Jun',
    timeAr: '10:00ص - 8:00م',
    timeEn: '10:00AM - 8:00PM',
    aboutAr: 'أكبر تجمع لدور النشر المحلية والعربية مع جلسات نقاش وتوقيع كتب.',
    aboutEn: 'The largest gathering of local and Arab publishers, with discussion panels and book signings.',
    photoQuery: 'book fair exhibition',
    icon: Icons.menu_book,
    color: Color(0xFFC9A227),
  ),
  EventItem(
    titleAr: 'مهرجان الموسيقى التراثية',
    titleEn: 'Heritage Music Festival',
    venueAr: 'المسرح الوطني',
    venueEn: 'National Theater',
    day: '30',
    monthAr: 'يونيو',
    monthEn: 'Jun',
    timeAr: '7:00م - 11:00م',
    timeEn: '7:00PM - 11:00PM',
    aboutAr: 'أمسيات فنية تحيي التراث الموسيقي الفلسطيني بمشاركة فرق محلية.',
    aboutEn: 'Evenings celebrating Palestinian musical heritage with local performing groups.',
    photoQuery: 'traditional music concert',
    icon: Icons.music_note,
    color: Color(0xFF6C5CE7),
  ),
  EventItem(
    titleAr: 'مهرجان الطعام النابلسي',
    titleEn: 'Nablus Food Festival',
    venueAr: 'حديقة التعاون',
    venueEn: 'Al-Taawon Park',
    day: '6',
    monthAr: 'يوليو',
    monthEn: 'Jul',
    timeAr: '5:00م - 11:00م',
    timeEn: '5:00PM - 11:00PM',
    aboutAr: 'أشهى الأطباق النابلسية من أفضل المطاعم المحلية بأجواء عائلية في الهواء الطلق.',
    aboutEn: 'The finest Nabulsi dishes from the best local restaurants, in an outdoor family atmosphere.',
    photoQuery: 'street food festival',
    icon: Icons.restaurant,
    color: Color(0xFFE85D5D),
  ),
  EventItem(
    titleAr: 'ماراثون نابلس الخيري',
    titleEn: 'Nablus Charity Marathon',
    venueAr: 'شارع الجامعة',
    venueEn: 'University St.',
    day: '12',
    monthAr: 'يوليو',
    monthEn: 'Jul',
    timeAr: '7:00ص - 11:00ص',
    timeEn: '7:00AM - 11:00AM',
    aboutAr: 'سباق جري خيري لدعم مبادرات مجتمعية، مفتوح لجميع الأعمار.',
    aboutEn: 'A charity run supporting community initiatives, open to all ages.',
    photoQuery: 'marathon runners street',
    icon: Icons.directions_run,
    color: Color(0xFF22C55E),
  ),
  EventItem(
    titleAr: 'معرض الحرف اليدوية',
    titleEn: 'Handicrafts Exhibition',
    venueAr: 'خان الوكالة',
    venueEn: 'Khan Al-Wakala',
    day: '19',
    monthAr: 'يوليو',
    monthEn: 'Jul',
    timeAr: '11:00ص - 9:00م',
    timeEn: '11:00AM - 9:00PM',
    aboutAr: 'عرض وبيع منتجات الحرفيين المحليين من فخار ونسيج وصابون نابلسي.',
    aboutEn: 'Local artisans display and sell pottery, textiles, and Nabulsi soap.',
    photoQuery: 'handicraft market pottery',
    icon: Icons.palette,
    color: Color(0xFFB5651D),
  ),
];
