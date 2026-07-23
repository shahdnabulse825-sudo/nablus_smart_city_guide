import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../../widgets/responsive.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../services/favorites_service.dart';
import '../../services/api_service.dart';
import '../map/map_screen.dart';
import '../../theme/app_typography.dart';
import '../restaurants/restaurants_screen.dart';
import '../attractions/attractions_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_toggle_bar.dart';
import '../../widgets/keyboard_scrollable.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/sort_toggle.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../ai_assistant/ai_assistant_screen.dart';
import '../../services/location_service.dart';
import '../../widgets/nearest_to_me_chip.dart';

// ==================== بيانات مركز تجاري (مكان حقيقي) ====================
class ShoppingVenueData {
  final String nameAr;
  final String nameEn;
  final String typeAr;
  final String typeEn;
  final String locationAr;
  final String locationEn;
  final double rating;
  final int reviews;
  final String hoursAr;
  final String hoursEn;
  final String aboutAr;
  final String aboutEn;
  final String phone;
  final String image;
  final IconData placeholderIcon;
  final Color placeholderColor;
  final String? customImageBase64;
  final bool isFeatured;
  final double? lat;
  final double? lng;
  final String? serverImageUrl;
  final String subCategory; // fashion | shoes | electronics | cosmetics | jewelry | books | entertainment
  final String website; // رابط الموقع أو صفحة التواصل الاجتماعي (اختياري)

  ShoppingVenueData({
    required this.nameAr,
    required this.nameEn,
    required this.typeAr,
    required this.typeEn,
    required this.locationAr,
    required this.locationEn,
    required this.rating,
    required this.reviews,
    this.hoursAr = '',
    this.hoursEn = '',
    required this.aboutAr,
    required this.aboutEn,
    this.phone = '',
    this.image = '',
    required this.placeholderIcon,
    required this.placeholderColor,
    this.customImageBase64,
    this.isFeatured = false,
    this.lat,
    this.lng,
    this.serverImageUrl,
    this.subCategory = '',
    this.website = '',
  });
}

// فلاتر أقسام المراكز التجارية — تُستخدم بشاشة "المراكز التجارية" لتصفية المحلات.
const List<(String, String, String, String)> shoppingSubCategories = [
  ('fashion', '🛍️', 'أزياء', 'Fashion'),
  ('shoes', '👟', 'أحذية', 'Shoes'),
  ('electronics', '📱', 'إلكترونيات', 'Electronics'),
  ('cosmetics', '💄', 'مستحضرات تجميل', 'Cosmetics'),
  ('jewelry', '💍', 'مجوهرات', 'Jewelry'),
  ('books', '📚', 'مكتبات', 'Bookstores'),
  ('entertainment', '🎮', 'ترفيه', 'Entertainment'),
];

// أسماء عناصر كانت وهمية/تقريبية بجولة سابقة واستُبدلت بمحلات حقيقية موثّقة —
// تُستخدم فقط لتنظيف أي نسخة محلية قديمة مخزّنة على جهاز المستخدم (انظر
// [purgeByName] بالأسفل)، وليست جزءًا من البيانات الحالية.
const Set<String> retiredShoppingVenueNames = {
  'Rafidia Commercial Complex',
  'Rafidia Galleria',
  'Al-Maidan Shopping Center',
  'Central Vegetable Market',
  'University Commercial Complex',
  'Old Textile Market',
  'Hanna Style Fashion',
  'Al-Lamsa Elegant Boutique',
  'Golden Shoes Gallery',
  'Modern Footwear House',
  'Modern Electronics Showroom',
  'Mobile Point',
  'Beauty & Perfumes Center',
  'Royal Cosmetics Shop',
  'Al-Amana Jewelry',
  'Luxury Gold Gallery',
  'Al-Furqan Bookstore',
  'Modern Knowledge Bookstore',
  'Fun Zone Arcade',
  'City Indoor Playland',
  'Ce Line Fashion',
  'Balena Shoes',
  'Ahmad Khanfar Telecom',
  'Assid Telecom',
  'Hamzawi Cosmetics',
  'Al-Kharouf Trading',
  'Mamlakat Al-Otoor',
  'Al-Nujoom Gallery',
  'Fetyan Library',
  'Al-Arabiya Library',
  'Al-Furqan Library',
  'Star Toys',
  'Nablus Mall',
  'Nablus Gold Souq',
  'Al-Taj Jewelry',
};

// كل المحلات بالأسفل حقيقية وموجودة فعليًا بنابلس (تم التحقق من الاسم والموقع
// ورقم الهاتف حيث توفّر عبر أدلة أعمال فلسطينية: يلو بيجز، شوبدك، نابلس سيتي...
// رقم الهاتف يُترك فارغًا لو ما انأكد من مصدر موثوق بدل اختلاقه).
final List<ShoppingVenueData> shoppingVenuesSeedData = [
  // ---------- مراكز ومجمّعات تجارية معروفة ----------
  ShoppingVenueData(
    nameAr: 'سيتي مول نابلس',
    nameEn: 'City Mall Nablus',
    typeAr: 'مركز تسوق',
    typeEn: 'Shopping Mall',
    locationAr: 'آخر شارع سفيان، خلف بنك فلسطين - نابلس',
    locationEn: 'End of Sufyan St., behind Palestine Bank - Nablus',
    rating: 4.5,
    reviews: 287,
    hoursAr: 'يفتح 10ص - 11م',
    hoursEn: 'Open 10AM - 11PM',
    aboutAr: 'أكبر مول بفلسطين، بعلامات تجارية عالمية، مطاعم، وسينما.',
    aboutEn:
        'The largest mall in Palestine, with international brands, restaurants, and a cinema.',
    website: 'https://www.facebook.com/CityMallPS/',
    image: 'assets/images/shopping/سيتي مول.jpeg',
    placeholderIcon: Icons.shopping_bag,
    placeholderColor: Color(0xFF6C5CE7),
    isFeatured: true,
  ),
  ShoppingVenueData(
    nameAr: 'سوق البلدة القديمة',
    nameEn: 'Old City Souq',
    typeAr: 'سوق شعبي',
    typeEn: 'Traditional Market',
    locationAr: 'البلدة القديمة - نابلس',
    locationEn: 'Old City - Nablus',
    rating: 4.7,
    reviews: 512,
    hoursAr: 'يفتح 8ص - 8م',
    hoursEn: 'Open 8AM - 8PM',
    aboutAr:
        'سوق تاريخي عريق داخل البلدة القديمة يبيع التوابل والحلويات النابلسية والصابون البلدي والمنتجات التقليدية.',
    aboutEn:
        'A historic market inside the Old City selling spices, Nabulsi sweets, traditional soap, and local handmade products.',
    placeholderIcon: Icons.storefront,
    placeholderColor: Color(0xFFB5651D),
    image: 'assets/images/shopping/سوق البلدة القديمة1.jpg',
    isFeatured: true,
  ),

  // ---------- 🛍️ أزياء ----------
  ShoppingVenueData(
    nameAr: 'ريد روز فاشن',
    nameEn: 'Red Rose Fashion',
    typeAr: 'محل أزياء نسائية',
    typeEn: "Women's Fashion Store",
    locationAr: 'شارع رفيديا، قرب بيتزا العطعوط - نابلس',
    locationEn: 'Rafidia St., near Pizza Al-Ataout - Nablus',
    rating: 4.3,
    reviews: 58,
    hoursAr: 'يفتح 10ص - 9م',
    hoursEn: 'Open 10AM - 9PM',
    aboutAr: 'محل أزياء نسائية معروف على شارع رفيديا الرئيسي بنابلس.',
    aboutEn: "A well-known women's fashion store on Rafidia's main street in Nablus.",
    phone: '+970 56 901 1000',
    website: 'https://www.facebook.com/RedRoseNablus/',
    image: 'assets/images/shopping/ريد روز.jpg',
    placeholderIcon: Icons.checkroom,
    placeholderColor: Color(0xFFEF6F53),
    subCategory: 'fashion',
  ),
  ShoppingVenueData(
    nameAr: 'السيد للألبسة',
    nameEn: 'Al-Sayed Fashion',
    typeAr: 'محل أزياء رجالية ونسائية',
    typeEn: "Men's & Women's Fashion Store",
    locationAr: 'شارع سفيان، عمارة الشنار - نابلس',
    locationEn: 'Sufyan St., Al-Shannar Building - Nablus',
    rating: 4.3,
    reviews: 40,
    hoursAr: 'يفتح 10ص - 9م',
    hoursEn: 'Open 10AM - 9PM',
    aboutAr: 'محل أزياء رجالية ونسائية، بفرعين: شارع سفيان (عمارة الشنار) ورفيديا قرب مسجد الروضة.',
    aboutEn: "Men's and women's fashion store, with two branches: Sufyan St. (Al-Shannar Building) and Rafidia near Al-Rawda Mosque.",
    website: 'https://www.facebook.com/ALSayedfashion/',
    image: 'assets/images/shopping/السيد.jpg',
    placeholderIcon: Icons.checkroom,
    placeholderColor: Color(0xFF6C5CE7),
    subCategory: 'fashion',
  ),
  ShoppingVenueData(
    nameAr: 'شوك فاشن',
    nameEn: 'SOK Fashion',
    typeAr: 'محل أزياء نسائية',
    typeEn: "Women's Fashion Store",
    locationAr: 'رفيديا - رمزون البدوي - نابلس',
    locationEn: 'Rafidia - Ramzon Al-Badawi - Nablus',
    rating: 4.1,
    reviews: 27,
    hoursAr: 'يفتح 10ص - 9م',
    hoursEn: 'Open 10AM - 9PM',
    aboutAr: 'محل أزياء نسائية عصرية بمنطقة رفيديا، مع توصيل لعدة مدن.',
    aboutEn: "A modern women's fashion store in Rafidia, with delivery to several cities.",
    website: 'https://www.instagram.com/sok_fashion_ps/',
    image: 'assets/images/shopping/شوك.jpg',
    placeholderIcon: Icons.checkroom,
    placeholderColor: Color(0xFFD4A017),
    subCategory: 'fashion',
  ),

  // ---------- 👟 أحذية ----------
  ShoppingVenueData(
    nameAr: 'ميلانو للأحذية والحقائب',
    nameEn: 'Milano Shoes',
    typeAr: 'محل أحذية وحقائب',
    typeEn: 'Shoes & Bags Store',
    locationAr: 'شارع غرناطة، قرب المسلماني للمكسرات - نابلس',
    locationEn: 'Gharnatah St., near Al-Muslimani Nuts - Nablus',
    rating: 4.2,
    reviews: 48,
    hoursAr: 'يفتح 10ص - 9م',
    hoursEn: 'Open 10AM - 9PM',
    aboutAr: 'محل أحذية وحقائب على شارع غرناطة بنابلس، بخبرة تمتد لأكثر من 60 عامًا.',
    aboutEn: 'A shoes and bags store on Gharnatah St. in Nablus, with over 60 years of experience.',
    website: 'https://www.facebook.com/milano.shoes.nablus0/',
    image: 'assets/images/shopping/milano.jpg',
    placeholderIcon: Icons.directions_walk,
    placeholderColor: Color(0xFF3B82F6),
    subCategory: 'shoes',
  ),
  ShoppingVenueData(
    nameAr: 'لايكي شوز',
    nameEn: 'Layki Shoes',
    typeAr: 'محل أحذية طبية',
    typeEn: 'Medical Shoe Store',
    locationAr: 'المعاجين، قرب جامعة القدس المفتوحة - نابلس',
    locationEn: "Al-Ma'ajin, near Al-Quds Open University - Nablus",
    rating: 4.4,
    reviews: 45,
    hoursAr: 'يفتح 9ص - 7م',
    hoursEn: 'Open 9AM - 7PM',
    aboutAr: 'أحذية طبية وعادية، فرع نابلس بمنطقة المعاجين.',
    aboutEn: "Medical and everyday shoes, Nablus branch in the Al-Ma'ajin area.",
    phone: '+970 56 960 0634',
    website: 'https://www.laykishoes.ps/',
    image: 'assets/images/shopping/لايكي.jpg',
    placeholderIcon: Icons.directions_walk,
    placeholderColor: Color(0xFF14B8A6),
    subCategory: 'shoes',
  ),
  ShoppingVenueData(
    nameAr: 'بيبلوس للأحذية والشنط',
    nameEn: 'Peploes Shoes & Bags',
    typeAr: 'محل أحذية وشنط',
    typeEn: 'Shoes & Bags Store',
    locationAr: 'نابلس، الدوار، عمارة فيضي، دخلة واصف الخياط',
    locationEn: 'Nablus, Al-Dawwar, Feidi Building, Wassef Al-Khayat entrance',
    rating: 4.0,
    reviews: 29,
    hoursAr: 'يفتح 9ص - 8م',
    hoursEn: 'Open 9AM - 8PM',
    aboutAr: 'أحذية وشنط نسائية ورجالية قرب الدوار بوسط نابلس، لصاحبه تيسير لبادة وأولاده.',
    aboutEn: "Men's and women's shoes and bags near Al-Dawwar in central Nablus.",
    phone: '+970 9 237 4824',
    website: 'https://www.facebook.com/peploes.shoes/',
    image: 'assets/images/shopping/بيبلوس.jpg',
    placeholderIcon: Icons.directions_walk,
    placeholderColor: Color(0xFFEF6F53),
    subCategory: 'shoes',
  ),
  ShoppingVenueData(
    nameAr: 'جيوكس - بيت الرياضة',
    nameEn: 'Geox - Sport House',
    typeAr: 'محل أحذية',
    typeEn: 'Shoe Store',
    locationAr: 'شارع حيفا - نابلس',
    locationEn: 'Haifa St. - Nablus',
    rating: 4.3,
    reviews: 22,
    hoursAr: 'يفتح 9ص - 8م',
    hoursEn: 'Open 9AM - 8PM',
    aboutAr: 'أحذية جيوكس الإيطالية الأصلية، عبر معرض بيت الرياضة على شارع حيفا.',
    aboutEn: 'Genuine Italian Geox shoes, via the Sport House showroom on Haifa St.',
    image: 'assets/images/shopping/geox.jpeg',
    placeholderIcon: Icons.directions_walk,
    placeholderColor: Color(0xFF22C55E),
    subCategory: 'shoes',
  ),

  // ---------- 📱 إلكترونيات ----------
  ShoppingVenueData(
    nameAr: 'يا هلا للاتصالات',
    nameEn: 'Ya Hala Telecom',
    typeAr: 'محل اتصالات وهواتف',
    typeEn: 'Telecom & Mobile Store',
    locationAr: 'شارع الشهداء، قرب المسجد العمري - نابلس',
    locationEn: 'Al-Shuhada St., near Al-Omari Mosque - Nablus',
    rating: 4.2,
    reviews: 33,
    hoursAr: 'يفتح 9ص - 8م',
    hoursEn: 'Open 9AM - 8PM',
    aboutAr: 'هواتف وخطوط اتصال وإكسسوارات موبايل.',
    aboutEn: 'Phones, telecom lines, and mobile accessories.',
    phone: '+970 9 258 4322',
    image: 'assets/images/shopping/يا هلا.jpg',
    placeholderIcon: Icons.smartphone,
    placeholderColor: Color(0xFF3B82F6),
    subCategory: 'electronics',
  ),
  ShoppingVenueData(
    nameAr: 'أبو زهرة الكترونيك',
    nameEn: 'Abu Zahra Electronic (AtoZ)',
    typeAr: 'محل إلكترونيات واتصالات',
    typeEn: 'Electronics & Telecom Store',
    locationAr: 'شارع سفيان، عمارة يعيش، الطابق السابع - نابلس',
    locationEn: 'Sufyan St., Yaeesh Building, 7th Floor - Nablus',
    rating: 4.5,
    reviews: 96,
    hoursAr: 'يفتح 9ص - 8م',
    hoursEn: 'Open 9AM - 8PM',
    aboutAr: 'شركة رائدة بالإلكترونيات والاتصالات بفلسطين، تأسست 1988، بعدة فروع بنابلس ورام الله.',
    aboutEn: 'A leading electronics and telecom company in Palestine, founded in 1988, with several branches in Nablus and Ramallah.',
    website: 'https://www.facebook.com/ABU.ZAHRA.ELECTRONICS/',
    image: 'assets/images/shopping/ابو زهرة الكترونيك.jpg',
    placeholderIcon: Icons.smartphone,
    placeholderColor: Color(0xFF22C55E),
    subCategory: 'electronics',
  ),
  ShoppingVenueData(
    nameAr: 'تكنولاب',
    nameEn: 'TechnoLab Electronics',
    typeAr: 'محل قطع إلكترونية وحلول تقنية',
    typeEn: 'Electronic Components & Tech Solutions',
    locationAr: 'نابلس',
    locationEn: 'Nablus',
    rating: 4.2,
    reviews: 17,
    hoursAr: 'يفتح 9ص - 6م',
    hoursEn: 'Open 9AM - 6PM',
    aboutAr: 'قطع إلكترونية وحلول تقنية للمشاريع البرمجية والتقنية، وخدمات طباعة ثلاثية الأبعاد.',
    aboutEn: 'Electronic components and technical solutions for tech projects, plus 3D printing services.',
    website: 'https://www.facebook.com/technolab.electronics/',
    image: 'assets/images/shopping/تكنو لاب.jpg',
    placeholderIcon: Icons.smartphone,
    placeholderColor: Color(0xFF14B8A6),
    subCategory: 'electronics',
  ),

  // ---------- 💄 مستحضرات تجميل ----------
  ShoppingVenueData(
    nameAr: 'محلات نبالشي التجارية',
    nameEn: 'Nibalshi Stores',
    typeAr: 'محل عطور ومستحضرات تجميل',
    typeEn: 'Perfumes & Cosmetics Store',
    locationAr: 'شارع سفيان، سوق الحميدية التجاري - نابلس',
    locationEn: 'Sufyan St., Al-Hamidiyah Commercial Market - Nablus',
    rating: 4.4,
    reviews: 52,
    hoursAr: 'يفتح 9ص - 8م',
    hoursEn: 'Open 9AM - 8PM',
    aboutAr: 'محلات معروفة بمستحضرات التجميل والعطور ولوازم الصالونات، بعدة فروع بنابلس.',
    aboutEn: 'A well-known chain for cosmetics, perfumes, and salon supplies, with several branches in Nablus.',
    phone: '+970 9 233 3202',
    website: 'https://www.facebook.com/nibalshi/',
    image: 'assets/images/shopping/نبالشي.jpg',
    placeholderIcon: Icons.spa,
    placeholderColor: Color(0xFFEF6F53),
    subCategory: 'cosmetics',
  ),
  ShoppingVenueData(
    nameAr: 'فلورمار',
    nameEn: 'Flormar',
    typeAr: 'محل مستحضرات تجميل',
    typeEn: 'Cosmetics Store',
    locationAr: 'سيتي مول نابلس، شارع سفيان - نابلس',
    locationEn: 'City Mall Nablus, Sufyan St. - Nablus',
    rating: 4.3,
    reviews: 35,
    hoursAr: 'يفتح 10ص - 10م',
    hoursEn: 'Open 10AM - 10PM',
    aboutAr: 'ماركة مستحضرات تجميل تركية عالمية، فرع نابلس داخل سيتي مول.',
    aboutEn: 'A global Turkish cosmetics brand, Nablus branch inside City Mall.',
    website: 'https://www.instagram.com/flormar_ps/',
    image: 'assets/images/shopping/flormar.jpeg',
    placeholderIcon: Icons.face_retouching_natural,
    placeholderColor: Color(0xFFFBBF24),
    subCategory: 'cosmetics',
  ),
  ShoppingVenueData(
    nameAr: 'لايف ستايل',
    nameEn: 'Life Style',
    typeAr: 'محل عطور ومستحضرات تجميل',
    typeEn: 'Perfumes & Cosmetics Store',
    locationAr: 'العنبتاوي، شارع حطين - نابلس',
    locationEn: 'Al-Anbatawi, Hattin St. - Nablus',
    rating: 4.2,
    reviews: 20,
    hoursAr: 'يفتح 9ص - 8م',
    hoursEn: 'Open 9AM - 8PM',
    aboutAr: 'وكيل معتمد لماركات عطور ومستحضرات تجميل وعناية بالبشرة عالمية بفلسطين.',
    aboutEn: 'An authorized agent for international perfume, cosmetics, and skincare brands in Palestine.',
    website: 'https://lifestyle.ps/',
    image: 'assets/images/shopping/life style.jpg',
    // إحداثيات دقيقة (مؤكّدة عبر Nominatim: سوبر ماركت العنبتاوي، شارع حطين) —
    // نفس منطقة "الأنباطاوي" المذكورة كموقع الفرع.
    lat: 32.2197,
    lng: 35.2628,
    placeholderIcon: Icons.spa,
    placeholderColor: Color(0xFFD4A017),
    subCategory: 'cosmetics',
  ),
  ShoppingVenueData(
    nameAr: 'بيرفيومري سامي الشكعة',
    nameEn: 'Perfumery Sami',
    typeAr: 'محل عطور ومستحضرات تجميل',
    typeEn: 'Perfumes & Cosmetics Store',
    locationAr: 'شارع رفيديا، مقابل مدخل مبنى الاتصالات - نابلس',
    locationEn: 'Rafidia St., opposite the telecom building entrance - Nablus',
    rating: 4.4,
    reviews: 31,
    hoursAr: 'يفتح 10ص - 9م',
    hoursEn: 'Open 10AM - 9PM',
    aboutAr: 'عطور ومستحضرات تجميل على شارع رفيديا الرئيسي.',
    aboutEn: "Perfumes and cosmetics on Rafidia's main street.",
    website: 'https://www.instagram.com/perfumerysami/',
    image: 'assets/images/shopping/sami perfurem.webp',
    placeholderIcon: Icons.spa,
    placeholderColor: Color(0xFF6C5CE7),
    subCategory: 'cosmetics',
  ),

  // ---------- 💍 مجوهرات ----------
  ShoppingVenueData(
    nameAr: 'مجوهرات حواء',
    nameEn: 'Hawwa Jewelry',
    typeAr: 'محل مجوهرات',
    typeEn: 'Jewelry Store',
    locationAr: 'الدوار، المركز التجاري - نابلس',
    locationEn: 'Al-Dawwar, Commercial Center - Nablus',
    rating: 4.3,
    reviews: 40,
    hoursAr: 'يفتح 9ص - 8م',
    hoursEn: 'Open 9AM - 8PM',
    aboutAr: 'ذهب ومجوهرات بالمركز التجاري بنابلس.',
    aboutEn: 'Gold and jewelry at the Commercial Center in Nablus.',
    phone: '+970 9 238 6415',
    website: 'https://www.facebook.com/hawwa.jewelry/',
    image: 'assets/images/shopping/مجوهرات حوا.jpg',
    placeholderIcon: Icons.diamond_outlined,
    placeholderColor: Color(0xFFD4A017),
    subCategory: 'jewelry',
  ),
  ShoppingVenueData(
    nameAr: 'دايموند سنتر للمجوهرات',
    nameEn: 'Diamond Center Jewelry',
    typeAr: 'محل مجوهرات',
    typeEn: 'Jewelry Store',
    locationAr: 'سوق الذهب، الدوار، المركز التجاري - نابلس',
    locationEn: 'Gold Souq, Al-Dawwar, Commercial Center - Nablus',
    rating: 4.3,
    reviews: 24,
    hoursAr: 'يفتح 9ص - 8م',
    hoursEn: 'Open 9AM - 8PM',
    aboutAr: 'ذهب ومجوهرات بسوق الذهب النابلسي.',
    aboutEn: 'Gold and jewelry in the Nablus Gold Souq.',
    website: 'https://www.instagram.com/diamond_center17/',
    image: 'assets/images/shopping/iomand.jpg',
    placeholderIcon: Icons.diamond_outlined,
    placeholderColor: Color(0xFFB5651D),
    subCategory: 'jewelry',
  ),

  // ---------- 📚 مكتبات ----------
  ShoppingVenueData(
    nameAr: 'مكتبة النصر - الحجاوي',
    nameEn: 'An-Nasr - Al-Hijjawi Stationery',
    typeAr: 'مكتبة وقرطاسية',
    typeEn: 'Bookstore & Stationery',
    locationAr: 'المركز التجاري، شارع العدل - نابلس',
    locationEn: 'Commercial Center, Al-Adel St. - Nablus',
    rating: 4.4,
    reviews: 47,
    hoursAr: 'يفتح 8ص - 7م',
    hoursEn: 'Open 8AM - 7PM',
    aboutAr: 'شركة رائدة بتجارة الورق والقرطاسية بفلسطين، تأسست 1935.',
    aboutEn: 'A leading paper and stationery trading company in Palestine, founded in 1935.',
    phone: '+970 9 231 1867',
    website: 'https://www.alhijjawi.ps/',
    image: 'assets/images/shopping/مكتبة نصر.jpg',
    placeholderIcon: Icons.menu_book,
    placeholderColor: Color(0xFF3B82F6),
    subCategory: 'books',
  ),
  ShoppingVenueData(
    nameAr: 'مكتبة الكمال',
    nameEn: 'Al-Kamal Library',
    typeAr: 'مكتبة وقرطاسية',
    typeEn: 'Bookstore & Stationery',
    locationAr: 'شارع فلسطين - وسط البلد - نابلس',
    locationEn: 'Falastin St. - Downtown - Nablus',
    rating: 4.2,
    reviews: 29,
    hoursAr: 'يفتح 8ص - 7م',
    hoursEn: 'Open 8AM - 7PM',
    aboutAr: 'كتب وقرطاسية بشارع فلسطين بوسط نابلس.',
    aboutEn: 'Books and stationery on Falastin St. in downtown Nablus.',
    phone: '+970 9 234 1665',
    website: 'https://www.facebook.com/alkamal.bookshop/',
    image: 'assets/images/shopping/مكتبة الكمال.jpg',
    placeholderIcon: Icons.menu_book,
    placeholderColor: Color(0xFF6C5CE7),
    subCategory: 'books',
  ),
  ShoppingVenueData(
    nameAr: 'مكتبة الإتحاد',
    nameEn: 'Al-Ittihad Bookshop',
    typeAr: 'مكتبة وقرطاسية',
    typeEn: 'Bookstore & Stationery',
    locationAr: 'شارع فلسطين - نابلس',
    locationEn: 'Falastin St. - Nablus',
    rating: 4.3,
    reviews: 33,
    hoursAr: 'يفتح 8ص - 7م',
    hoursEn: 'Open 8AM - 7PM',
    aboutAr: 'مكتبة وقرطاسية وخدمات طباعة على شارع فلسطين بنابلس.',
    aboutEn: 'Bookstore, stationery, and printing services on Falastin St. in Nablus.',
    phone: '+970 9 237 0117',
    website: 'https://www.facebook.com/AL.ITIHAD.BOOKSHOP/',
    image: 'assets/images/shopping/مكتبة الاتحاد.jpg',
    placeholderIcon: Icons.menu_book,
    placeholderColor: Color(0xFFD4A017),
    subCategory: 'books',
  ),

  // ---------- 🎮 ترفيه ----------
  ShoppingVenueData(
    nameAr: 'مدفع لاند',
    nameEn: "Madfa' Land",
    typeAr: 'مدينة ألعاب داخلية',
    typeEn: 'Indoor Amusement City',
    locationAr: 'شارع بيت إيبا الرئيسي - نابلس',
    locationEn: 'Beit Iba Main St. - Nablus',
    rating: 4.4,
    reviews: 210,
    hoursAr: 'يفتح 11ص - 11م',
    hoursEn: 'Open 11AM - 11PM',
    aboutAr: 'من أكبر مدن الألعاب الترفيهية الداخلية بفلسطين، على شارع بيت إيبا.',
    aboutEn: 'One of the largest indoor amusement cities in Palestine, on Beit Iba St.',
    website: 'https://www.facebook.com/MadfaaLand/',
    image: 'assets/images/shopping/مدفع لاند.jpg',
    placeholderIcon: Icons.videogame_asset,
    placeholderColor: Color(0xFF6C5CE7),
    subCategory: 'entertainment',
  ),
  ShoppingVenueData(
    nameAr: 'لالا لاند',
    nameEn: 'LaLaLand',
    typeAr: 'مركز ألعاب أطفال',
    typeEn: "Kids' Entertainment Center",
    locationAr: 'دوار زواتة، قرب LC Waikiki - نابلس',
    locationEn: 'Zawata Roundabout, near LC Waikiki - Nablus',
    rating: 4.2,
    reviews: 88,
    hoursAr: 'يفتح 11ص - 10م',
    hoursEn: 'Open 11AM - 10PM',
    aboutAr: 'مركز ألعاب وترفيه للأطفال عند دوار زواتة.',
    aboutEn: "A kids' games and entertainment center at Zawata Roundabout.",
    website: 'https://www.facebook.com/kids.lalaland/',
    image: 'assets/images/shopping/لالا لاند.jpg',
    placeholderIcon: Icons.attractions,
    placeholderColor: Color(0xFFEF6F53),
    subCategory: 'entertainment',
  ),
  ShoppingVenueData(
    nameAr: 'جابر لاند',
    nameEn: 'Jaber Land',
    typeAr: 'مدينة ألعاب ترفيهية',
    typeEn: 'Amusement Park',
    locationAr: 'رفيديا، شارع تونس - نابلس',
    locationEn: 'Rafidia, Tunisia St. - Nablus',
    rating: 4.3,
    reviews: 66,
    hoursAr: 'يفتح 11ص - 11م',
    hoursEn: 'Open 11AM - 11PM',
    aboutAr: 'من أكبر مراكز الترفيه بمدينة نابلس لمختلف الأعمار، مع كافيتريا وجلسات خارجية.',
    aboutEn: "One of the largest entertainment centers in Nablus for all ages, with a cafeteria and outdoor seating.",
    phone: '+970 59 970 2690',
    website: 'https://www.facebook.com/JaberLandNablus/',
    image: 'assets/images/shopping/جابر لاند.jpg',
    placeholderIcon: Icons.videogame_asset,
    placeholderColor: Color(0xFF3B82F6),
    subCategory: 'entertainment',
  ),
];

// كلمة بحث إنجليزية مناسبة لصورة المركز التجاري، لما ما توجد صورة محلية.
String shoppingVenuePhotoQuery(ShoppingVenueData v) {
  final text = '${v.nameAr} ${v.nameEn} ${v.typeAr} ${v.typeEn}'.toLowerCase();
  if (text.contains('سوق') ||
      text.contains('بازار') ||
      text.contains('bazaar') ||
      text.contains('market')) {
    return 'traditional market bazaar';
  }
  if (text.contains('مجمع') || text.contains('complex')) {
    return 'shopping complex storefront';
  }
  return 'shopping mall interior';
}

// سؤال جاهز يُرسل تلقائيًا للمساعد الذكي عند الضغط على "اسأل الذكاء الاصطناعي عن هذا المحل"،
// مبني على قسم المحل (subCategory) حتى يتعرف المساعد على القسم ويقترح محلات مشابهة/قريبة.
String aiQueryForShoppingVenue(ShoppingVenueData v) {
  final sub = shoppingSubCategories.where((c) => c.$1 == v.subCategory);
  if (sub.isEmpty) {
    return 'اقترحلي محلات مشابهة لـ ${v.nameAr} بالمراكز التجارية';
  }
  final labelAr = sub.first.$3;
  return 'اقترحلي محلات $labelAr مشابهة لـ ${v.nameAr}';
}

// ==================== بطاقة دليل صنف (معلومات، مش مكان مخزّن) ====================
class ShoppingProductGuide {
  final String emoji;
  final String categoryKey; // heritage | localProducts
  final String titleAr;
  final String titleEn;
  final String descAr;
  final String descEn;
  final VoidCallback Function(BuildContext)? buildAction; // null = بدون زر
  ShoppingProductGuide({
    required this.emoji,
    required this.categoryKey,
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
    this.buildAction,
  });
}

final List<ShoppingProductGuide> shoppingProductGuides = [
  // ---------- تراث وهدايا ----------
  ShoppingProductGuide(
    emoji: '🧼',
    categoryKey: 'heritage',
    titleAr: 'الصابون النابلسي',
    titleEn: 'Nabulsi Soap',
    descAr: 'صناعة نابلسية عريقة بزيت الزيتون، من أشهر منتجات المدينة عالميًا.',
    descEn:
        'A time-honored Nablus craft made from olive oil, one of the city\'s most famous products worldwide.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AttractionsScreen(initialCategory: 'oldCity'),
          ),
        ),
  ),
  ShoppingProductGuide(
    emoji: '🧀',
    categoryKey: 'heritage',
    titleAr: 'الجبنة النابلسية',
    titleEn: 'Nabulsi Cheese',
    descAr:
        'جبنة بيضاء تقليدية تحمل اسم المدينة، تستخدم بالكنافة وأطباق فلسطينية كثيرة.',
    descEn:
        'A traditional white cheese bearing the city\'s name, used in kunafa and many Palestinian dishes.',
  ),
  ShoppingProductGuide(
    emoji: '🪡',
    categoryKey: 'heritage',
    titleAr: 'التطريز الفلسطيني',
    titleEn: 'Palestinian Embroidery',
    descAr:
        'فن التطريز اليدوي (التطريز الفلسطيني) بزخارفه وألوانه التراثية المميزة.',
    descEn:
        'The traditional Palestinian hand-embroidery craft, known for its distinctive patterns and colors.',
  ),
  ShoppingProductGuide(
    emoji: '💍',
    categoryKey: 'heritage',
    titleAr: 'الحلي والمشغولات الفضية',
    titleEn: 'Silver Jewelry & Crafts',
    descAr:
        'مشغولات فضية وحلي تقليدية بلمسة يدوية، هدية مميزة تفتكر بيها زيارتك.',
    descEn:
        'Handcrafted silver jewelry and traditional pieces, a distinctive gift to remember your visit.',
  ),
  ShoppingProductGuide(
    emoji: '🎁',
    categoryKey: 'heritage',
    titleAr: 'التحف والهدايا التذكارية',
    titleEn: 'Antiques & Souvenirs',
    descAr: 'قطع تذكارية وتحف صغيرة تحمل طابع نابلس وتاريخها.',
    descEn:
        'Small souvenir pieces and antiques carrying the character and history of Nablus.',
  ),

  // ---------- منتجات نابلس المحلية ----------
  ShoppingProductGuide(
    emoji: '🍰',
    categoryKey: 'localProducts',
    titleAr: 'الكنافة النابلسية',
    titleEn: 'Nabulsi Kunafa',
    descAr: 'الحلوى الأشهر باسم المدينة، جبنة ساخنة مغطاة بقطر وقشطة القطايف.',
    descEn:
        'The most famous sweet bearing the city\'s name — hot cheese topped with syrup and shredded pastry.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RestaurantsScreen(initialCuisine: 'sweets'),
          ),
        ),
  ),
  ShoppingProductGuide(
    emoji: '🍬',
    categoryKey: 'localProducts',
    titleAr: 'الحلويات',
    titleEn: 'Sweets',
    descAr: 'محلات الحلويات النابلسية بتشكيلة واسعة إلى جانب الكنافة.',
    descEn: 'Nablus sweet shops offering a wide variety alongside kunafa.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RestaurantsScreen(initialCuisine: 'sweets'),
          ),
        ),
  ),
  ShoppingProductGuide(
    emoji: '🫒',
    categoryKey: 'localProducts',
    titleAr: 'زيت الزيتون',
    titleEn: 'Olive Oil',
    descAr: 'زيت زيتون فلسطيني بجودة عالية، من أهم منتجات المنطقة الزراعية.',
    descEn:
        'High-quality Palestinian olive oil, one of the region\'s most important agricultural products.',
  ),
  ShoppingProductGuide(
    emoji: '☕',
    categoryKey: 'localProducts',
    titleAr: 'القهوة والمكسرات',
    titleEn: 'Coffee & Nuts',
    descAr: 'محامص القهوة العربية والمكسرات المحمصة الطازجة، نكهة محلية أصيلة.',
    descEn:
        'Arabic coffee roasteries and freshly roasted nuts, an authentic local flavor.',
  ),
  ShoppingProductGuide(
    emoji: '🌿',
    categoryKey: 'localProducts',
    titleAr: 'الزعتر والسماق والتوابل',
    titleEn: 'Za\'atar, Sumac & Spices',
    descAr: 'أعشاب وتوابل بلدية أصيلة، أشهرها الزعتر والسماق الفلسطيني.',
    descEn:
        'Authentic local herbs and spices, most famously Palestinian za\'atar and sumac.',
    buildAction: (context) =>
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AttractionsScreen(initialCategory: 'oldCity'),
          ),
        ),
  ),
];

const List<(String, String, String)> shoppingCategoryOrder = [
  ('heritage', '🎁 تراث وهدايا', '🎁 Heritage & Gifts'),
  ('localProducts', '🧺 منتجات نابلس المحلية', '🧺 Local Nablus Products'),
  ('commercial', '🏬 المراكز التجارية', '🏬 Commercial Centers'),
];

const Map<String, String> shoppingCategoryImages = {
  'heritage': 'assets/images/shopping/تراث وهدايا.jpg',
  'localProducts': 'assets/images/shopping/منتجات نابلس المحلية.jpg',
  'commercial': 'assets/images/shopping/مراكز تجارية.jpeg',
};

// ==================== شاشة التصنيفات (نقطة الدخول) ====================
class ShoppingCategoriesScreen extends StatefulWidget {
  const ShoppingCategoriesScreen({super.key});

  @override
  State<ShoppingCategoriesScreen> createState() =>
      _ShoppingCategoriesScreenState();
}

class _ShoppingCategoriesScreenState extends State<ShoppingCategoriesScreen> {
  bool _loaded = false;
  List<ShoppingVenueData> _liveVenues = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = LocalDbService.instance;
    await db.syncSeed(
      'shopping',
      shoppingVenuesSeedData.map(shoppingVenueToMap).toList(),
    );
    await ApiService.syncShopping();
    // لازم تُنفَّذ بعد المزامنة مع السيرفر (مش قبلها)، وإلا أي عنصر متقاعد لسا
    // موجود بقاعدة بيانات السيرفر رح يرجع يتزامن محليًا فورًا بعد الحذف.
    await db.purgeByName('shopping', retiredShoppingVenueNames);
    final entries = db.getAll('shopping');
    setState(() {
      _liveVenues = entries.map((e) => mapToShoppingVenue(e.value)).toList();
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    if (!_loaded) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColors.bgDark,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
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
                    _ShoppingTopBar(titleAr: 'تسوق', titleEn: 'Shopping'),
                    _ShoppingBanner(),
                    Padding(
                      padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: shoppingCategoryOrder.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: responsiveGridColumns(
                            context,
                            wide: 3,
                            narrow: 2,
                          ),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.05,
                        ),
                        itemBuilder: (context, i) {
                          final def = shoppingCategoryOrder[i];
                          final key = def.$1;
                          final count = key == 'commercial'
                              ? _liveVenues.length
                              : shoppingProductGuides
                                    .where((p) => p.categoryKey == key)
                                    .length;
                          return _ShoppingCategoryCard(
                            titleAr: def.$2,
                            titleEn: def.$3,
                            count: count,
                            imageAsset: shoppingCategoryImages[key],
                            onTap: () {
                              if (key == 'commercial') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ShoppingVenuesScreen(),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ShoppingProductGuideScreen(
                                          categoryKey: key,
                                        ),
                                  ),
                                );
                              }
                            },
                          );
                        },
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
}

class _ShoppingCategoryCard extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  final int count;
  final VoidCallback onTap;
  final String? imageAsset;
  const _ShoppingCategoryCard({
    required this.titleAr,
    required this.titleEn,
    required this.count,
    required this.onTap,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.sidebarDark,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const SizedBox(),
              ),
            if (imageAsset != null)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    app.t(titleAr, titleEn),
                    textAlign: TextAlign.center,
                    textDirection: app.dir,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    app.t('$count', '$count'),
                    style: TextStyle(
                      color: imageAsset != null
                          ? Colors.white70
                          : AppColors.textGrey,
                      fontSize: 11,
                    ),
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

// ==================== الشريط العلوي (مشترك) ====================
class _ShoppingTopBar extends StatelessWidget {
  final String titleAr;
  final String titleEn;
  const _ShoppingTopBar({required this.titleAr, required this.titleEn});

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
            child: Icon(Icons.shopping_bag, color: Colors.white, size: 16),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              app.t(titleAr, titleEn),
              textDirection: app.dir,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(
                AppColors.textWhite,
              ).copyWith(fontSize: 16),
            ),
          ),
          AppToggleBar(),
        ],
      ),
    );
  }
}

// ==================== بانر ترحيبي ====================
class _ShoppingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
      height: 190,
      margin: EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => showImageZoom(
              context,
              query: 'traditional market bazaar gifts',
              fallbackSeed: 'nablus-shopping-banner',
              fallbackIcon: Icons.shopping_bag,
            ),
            child: ThemedImage(
              query: 'traditional market bazaar gifts',
              fallbackSeed: 'nablus-shopping-banner',
              height: 190,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.6),
                  AppColors.primaryDark.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          Center(
            child: Text(
              app.t('تسوّقي من نابلس', 'Shop from Nablus'),
              textDirection: app.dir,
              textAlign: TextAlign.center,
              style: AppTypography.display(Colors.white).copyWith(fontSize: 26),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== شاشة دليل الأصناف ====================
class ShoppingProductGuideScreen extends StatelessWidget {
  final String categoryKey;
  const ShoppingProductGuideScreen({super.key, required this.categoryKey});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final items = shoppingProductGuides
        .where((p) => p.categoryKey == categoryKey)
        .toList();
    final label = shoppingCategoryOrder.firstWhere((c) => c.$1 == categoryKey);

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
                  _ShoppingTopBar(titleAr: label.$2, titleEn: label.$3),
                  Padding(
                    padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: items
                          .map(
                            (p) => Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: p.buildAction?.call(context),
                                child: Container(
                                  padding: EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.sidebarDark,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                    ),
                                  ),
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Text(
                                        p.emoji,
                                        style: TextStyle(fontSize: 28),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              app.t(p.titleAr, p.titleEn),
                                              textDirection: app.dir,
                                              style: TextStyle(
                                                color: AppColors.textWhite,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              app.t(p.descAr, p.descEn),
                                              textDirection: app.dir,
                                              textAlign: app.isArabic
                                                  ? TextAlign.right
                                                  : TextAlign.left,
                                              style: TextStyle(
                                                color: AppColors.textGrey,
                                                fontSize: 11,
                                              ),
                                            ),
                                            if (p.buildAction != null) ...[
                                              SizedBox(height: 8),
                                              Text(
                                                app.t(
                                                  'أين أجدها؟ ←',
                                                  'Where to find it ←',
                                                ),
                                                textDirection: app.dir,
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
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

// ==================== شاشة المراكز التجارية ====================
class ShoppingVenuesScreen extends StatefulWidget {
  const ShoppingVenuesScreen({super.key});

  @override
  State<ShoppingVenuesScreen> createState() => _ShoppingVenuesScreenState();
}

class _ShoppingVenuesScreenState extends State<ShoppingVenuesScreen> {
  bool _loaded = false;
  List<ShoppingVenueData> _liveVenues = [];
  bool isGridView = true;
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';
  double minRating = 0;
  int sortMode = 0;
  int currentPage = 0;
  String selectedSubCategory = 'all';
  static const int perPage = 9;

  Position? _userPosition;
  bool _locating = false;
  bool _nearestActive = false;

  @override
  void initState() {
    super.initState();
    _loadData();
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

  double? _distanceKmTo(ShoppingVenueData v) => distanceKmFromUser(
    _userPosition,
    nameAr: v.nameAr,
    nameEn: v.nameEn,
    locationAr: v.locationAr,
    locationEn: v.locationEn,
    lat: v.lat,
    lng: v.lng,
  );

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = LocalDbService.instance;
    await db.syncSeed(
      'shopping',
      shoppingVenuesSeedData.map(shoppingVenueToMap).toList(),
    );
    await ApiService.syncShopping();
    // لازم تُنفَّذ بعد المزامنة مع السيرفر (مش قبلها)، وإلا أي عنصر متقاعد لسا
    // موجود بقاعدة بيانات السيرفر رح يرجع يتزامن محليًا فورًا بعد الحذف.
    await db.purgeByName('shopping', retiredShoppingVenueNames);
    final entries = db.getAll('shopping');
    setState(() {
      _liveVenues = entries.map((e) => mapToShoppingVenue(e.value)).toList();
      _loaded = true;
    });
  }

  List<ShoppingVenueData> get _filtered {
    var list = _liveVenues.where((v) {
      final matchesSearch = searchQuery.isEmpty ||
          v.nameAr.contains(searchQuery) ||
          v.nameEn.toLowerCase().contains(searchQuery.toLowerCase()) ||
          v.locationAr.contains(searchQuery) ||
          v.locationEn.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesSubCategory =
          selectedSubCategory == 'all' || v.subCategory == selectedSubCategory;
      return matchesSearch && matchesSubCategory && v.rating >= minRating;
    }).toList();
    if (_nearestActive && _userPosition != null) {
      list.sort((a, b) => _distanceKmTo(a)!.compareTo(_distanceKmTo(b)!));
    } else if (sortMode == 1) {
      list.sort((a, b) => b.reviews.compareTo(a.reviews));
    } else if (sortMode == 2) {
      list.sort((a, b) => a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()));
    } else {
      list.sort((a, b) {
        if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
        return b.rating.compareTo(a.rating);
      });
    }
    return list;
  }

  List<ShoppingVenueData> get _paged {
    final list = _filtered;
    final start = (currentPage * perPage).clamp(0, list.length);
    final end = (start + perPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get _pageCount {
    final len = _filtered.length;
    return len == 0 ? 1 : ((len - 1) ~/ perPage) + 1;
  }

  void _openDetail(BuildContext context, ShoppingVenueData v) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShoppingVenueDetailScreen(venue: v),
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
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
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
                    _ShoppingTopBar(
                      titleAr: 'المراكز التجارية',
                      titleEn: 'Commercial Centers',
                    ),
                    Padding(
                      padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 44,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark2,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
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
                                    controller: searchController,
                                    onChanged: (v) => setState(() {
                                      searchQuery = v;
                                      currentPage = 0;
                                    }),
                                    style: AppTypography.body(
                                      AppColors.textWhite,
                                    ).copyWith(fontSize: 13),
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      border: InputBorder.none,
                                      hintText: app.t(
                                        'ابحث عن مركز تجاري...',
                                        'Search for a commercial center...',
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
                          SizedBox(height: 12),
                          _SubCategoryFiltersRow(
                            selected: selectedSubCategory,
                            onTap: (key) => setState(() {
                              selectedSubCategory =
                                  selectedSubCategory == key ? 'all' : key;
                              currentPage = 0;
                            }),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              NearestToMeChip(
                                active: _nearestActive,
                                loading: _locating,
                                onTap: () async {
                                  if (_nearestActive) {
                                    setState(() => _nearestActive = false);
                                  } else {
                                    await _activateNearestToMe();
                                  }
                                },
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _RatingFiltersRow(
                                  minRating: minRating,
                                  onRatingTap: (v) => setState(() {
                                    minRating = minRating == v ? 0 : v;
                                    currentPage = 0;
                                  }),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: [
                              Text(
                                selectedSubCategory == 'all'
                                    ? app.t(
                                        '${filtered.length} مركز',
                                        '${filtered.length} centers',
                                      )
                                    : app.t(
                                        '${filtered.length} محل',
                                        '${filtered.length} shops',
                                      ),
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 12),
                              SortToggle(
                                activeIndex: sortMode,
                                labelsAr: const ['الأعلى تقييماً', 'الأكثر مراجعة', 'أبجدياً'],
                                labelsEn: const ['Top Rated', 'Most Reviewed', 'A–Z'],
                                isArabic: app.isArabic,
                                onChanged: (m) => setState(() => sortMode = m),
                              ),
                              Spacer(),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => setState(() => isGridView = false),
                                child: Icon(
                                  Icons.view_list,
                                  size: 20,
                                  color: isGridView
                                      ? AppColors.textGrey
                                      : AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 8),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => setState(() => isGridView = true),
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isGridView
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.grid_view,
                                    size: 16,
                                    color: isGridView
                                        ? Colors.white
                                        : AppColors.textGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          if (filtered.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: Center(
                                child: Text(
                                  app.t(
                                    'لا توجد مراكز مطابقة',
                                    'No matching centers',
                                  ),
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                              ),
                            )
                          else if (isGridView)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _paged.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: responsiveGridColumns(
                                      context,
                                      wide: 4,
                                      narrow: 2,
                                    ),
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.75,
                                  ),
                              itemBuilder: (context, i) {
                                final v = _paged[i];
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _openDetail(context, v),
                                  child: _ShoppingVenueCard(
                                    venue: v,
                                    isFavorite: FavoritesService.instance
                                        .isFavorite(v.nameEn),
                                    onFavorite: () async {
                                      await FavoritesService.instance
                                          .toggleFavorite(v.nameEn);
                                      setState(() {});
                                    },
                                  ),
                                );
                              },
                            )
                          else
                            Column(
                              children: _paged
                                  .map(
                                    (v) => Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _openDetail(context, v),
                                        child: _ShoppingVenueListTile(
                                          venue: v,
                                          isFavorite: FavoritesService.instance
                                              .isFavorite(v.nameEn),
                                          onFavorite: () async {
                                            await FavoritesService.instance
                                                .toggleFavorite(v.nameEn);
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          if (filtered.isNotEmpty) ...[
                            SizedBox(height: 18),
                            PaginationBar(
                              currentPage: currentPage,
                              pageCount: _pageCount,
                              onPageChange: (p) => setState(() => currentPage = p),
                            ),
                          ],
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
}

// ==================== فلتر أقسام المحلات (أزياء، أحذية، إلكترونيات...) ====================
class _SubCategoryFiltersRow extends StatelessWidget {
  final String selected;
  final void Function(String) onTap;
  const _SubCategoryFiltersRow({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in shoppingSubCategories)
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(c.$1),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected == c.$1
                        ? AppColors.primary
                        : AppColors.cardDark2,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: selected == c.$1
                          ? Colors.transparent
                          : AppColors.borderColor,
                    ),
                  ),
                  child: Text(
                    '${c.$2} ${app.t(c.$3, c.$4)}',
                    textDirection: app.dir,
                    style: TextStyle(
                      color: selected == c.$1
                          ? Colors.white
                          : AppColors.textWhite,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== فلتر التقييم ====================
class _RatingFiltersRow extends StatelessWidget {
  final double minRating;
  final void Function(double) onRatingTap;
  const _RatingFiltersRow({required this.minRating, required this.onRatingTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final r in [4.5, 4.0, 3.5])
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onRatingTap(r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: minRating == r ? AppColors.primary : AppColors.cardDark2,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: minRating == r ? Colors.transparent : AppColors.borderColor,
                    ),
                  ),
                  child: Text(
                    '⭐ $r+',
                    style: TextStyle(
                      color: minRating == r ? Colors.white : AppColors.textWhite,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== كرت المركز التجاري (Grid) ====================
class _ShoppingVenueCard extends StatelessWidget {
  final ShoppingVenueData venue;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const _ShoppingVenueCard({
    required this.venue,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final v = venue;
    final name = app.isArabic ? v.nameAr : v.nameEn;
    final location = app.isArabic ? v.locationAr : v.locationEn;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ThemedImage(
                  query: shoppingVenuePhotoQuery(v),
                  fallbackSeed: v.nameEn,
                  height: double.infinity,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  fallbackIcon: v.placeholderIcon,
                  fallbackColor: v.placeholderColor,
                  customImageBase64: v.customImageBase64,
                  serverImageUrl: v.serverImageUrl,
                  localAsset: v.image,
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.white),
                        SizedBox(width: 3),
                        Text(
                          '${v.rating}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (v.isFeatured)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 10, color: Colors.white),
                          SizedBox(width: 2),
                          Text(
                            app.t('مميز', 'Featured'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onFavorite,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: isFavorite ? AppColors.red : AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.textGrey,
                    ),
                    SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        location,
                        textDirection: app.dir,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 9,
                        ),
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

// ==================== بطاقة قائمة المركز التجاري (List) ====================
class _ShoppingVenueListTile extends StatelessWidget {
  final ShoppingVenueData venue;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const _ShoppingVenueListTile({
    required this.venue,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final v = venue;
    final name = app.isArabic ? v.nameAr : v.nameEn;
    final location = app.isArabic ? v.locationAr : v.locationEn;

    return AppCard(
      padding: EdgeInsets.all(10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: ThemedImage(
              query: shoppingVenuePhotoQuery(v),
              fallbackSeed: v.nameEn,
              height: 70,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              fallbackIcon: v.placeholderIcon,
              fallbackColor: v.placeholderColor,
              customImageBase64: v.customImageBase64,
              serverImageUrl: v.serverImageUrl,
              localAsset: v.image,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.textGrey,
                    ),
                    SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        location,
                        textDirection: app.dir,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.star, size: 12, color: AppColors.gold),
                  SizedBox(width: 3),
                  Text(
                    '${v.rating}',
                    style: TextStyle(color: AppColors.textWhite, fontSize: 11),
                  ),
                ],
              ),
              SizedBox(height: 4),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onFavorite,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isFavorite ? AppColors.red : AppColors.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== شاشة تفاصيل المركز التجاري ====================
class ShoppingVenueDetailScreen extends StatefulWidget {
  final ShoppingVenueData venue;
  const ShoppingVenueDetailScreen({super.key, required this.venue});

  @override
  State<ShoppingVenueDetailScreen> createState() =>
      _ShoppingVenueDetailScreenState();
}

class _ShoppingVenueDetailScreenState
    extends State<ShoppingVenueDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final v = widget.venue;
    final name = app.isArabic ? v.nameAr : v.nameEn;
    final type = app.isArabic ? v.typeAr : v.typeEn;
    final location = app.isArabic ? v.locationAr : v.locationEn;
    final hours = app.isArabic ? v.hoursAr : v.hoursEn;
    final about = app.isArabic ? v.aboutAr : v.aboutEn;
    final point = resolveMapPoint(
      nameAr: v.nameAr,
      nameEn: v.nameEn,
      locationAr: v.locationAr,
      locationEn: v.locationEn,
      lat: v.lat,
      lng: v.lng,
    );

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
                      GestureDetector(
                        onTap: () => showImageZoom(
                          context,
                          query: shoppingVenuePhotoQuery(v),
                          fallbackSeed: v.nameEn,
                          fallbackIcon: v.placeholderIcon,
                          fallbackColor: v.placeholderColor,
                          customImageBase64: v.customImageBase64,
                          serverImageUrl: v.serverImageUrl,
                          localAsset: v.image,
                        ),
                        child: ThemedImage(
                          query: shoppingVenuePhotoQuery(v),
                          fallbackSeed: v.nameEn,
                          height: 260,
                          fallbackIcon: v.placeholderIcon,
                          fallbackColor: v.placeholderColor,
                          customImageBase64: v.customImageBase64,
                          serverImageUrl: v.serverImageUrl,
                          localAsset: v.image,
                        ),
                      ),
                      Container(
                        height: 260,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
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
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 44,
                        right: 16,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            await FavoritesService.instance.toggleFavorite(
                              v.nameEn,
                            );
                            setState(() {});
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(
                              FavoritesService.instance.isFavorite(v.nameEn)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: FavoritesService.instance.isFavorite(
                                v.nameEn,
                              )
                                  ? AppColors.red
                                  : Colors.white,
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
                              style: AppTypography.display(
                                Colors.white,
                              ).copyWith(fontSize: 22),
                            ),
                            Text(
                              type,
                              textDirection: app.dir,
                              style: AppTypography.body(Colors.white70),
                            ),
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
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    '${v.rating}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '(${v.reviews} ${app.t('تقييم', 'reviews')})',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 13,
                              color: AppColors.textGrey,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                textDirection: app.dir,
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (hours.isNotEmpty) ...[
                          SizedBox(height: 6),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 13,
                                color: AppColors.textGrey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                hours,
                                textDirection: app.dir,
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 18),
                        Text(
                          app.t('نبذة', 'Overview'),
                          textDirection: app.dir,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          about,
                          textDirection: app.dir,
                          textAlign: app.isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 22),
                        if (v.phone.isNotEmpty) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  launchUrl(Uri.parse('tel:${v.phone}')),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.borderColor),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                              ),
                              icon: Icon(
                                Icons.call,
                                size: 16,
                                color: AppColors.textWhite,
                              ),
                              label: Text(
                                app.t('اتصال: ${v.phone}', 'Call: ${v.phone}'),
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
                              gradient: LinearGradient(
                                colors: AppColors.primaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: AppColors.glowShadow,
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  openDirectionsInExternalMaps(point),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                              ),
                              icon: Icon(
                                Icons.directions_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                app.t('الاتجاهات (GPS)', 'Directions (GPS)'),
                                style: AppTypography.title(
                                  Colors.white,
                                ).copyWith(fontSize: 14),
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
                                builder: (context) => MapScreen(
                                  focusPoint: point,
                                  focusNameAr: v.nameAr,
                                  focusNameEn: v.nameEn,
                                  focusCategoryAr: v.typeAr,
                                  focusCategoryEn: v.typeEn,
                                  focusRating: v.rating,
                                ),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.borderColor),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.map_rounded,
                              size: 16,
                              color: AppColors.textWhite,
                            ),
                            label: Text(
                              app.t('عرض على الخريطة', 'Show on Map'),
                              style: AppTypography.label(AppColors.textWhite),
                            ),
                          ),
                        ),
                        if (v.website.isNotEmpty) ...[
                          SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => launchUrl(
                                Uri.parse(
                                  v.website.startsWith('http')
                                      ? v.website
                                      : 'https://${v.website}',
                                ),
                                mode: LaunchMode.externalApplication,
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.borderColor),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                              ),
                              icon: Icon(
                                Icons.language,
                                size: 16,
                                color: AppColors.textWhite,
                              ),
                              label: Text(
                                app.t('الموقع الإلكتروني', 'Website'),
                                style: AppTypography.label(
                                  AppColors.textWhite,
                                ),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Share.share('$name (${v.rating}⭐) — $location'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.borderColor),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.share,
                              size: 16,
                              color: AppColors.textWhite,
                            ),
                            label: Text(
                              app.t('مشاركة', 'Share'),
                              style: AppTypography.label(AppColors.textWhite),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.purple, AppColors.primary],
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: AppColors.glowShadow,
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AiAssistantScreen(
                                    initialQuery: aiQueryForShoppingVenue(v),
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                              ),
                              icon: Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                app.t(
                                  'اسأل الذكاء الاصطناعي عن هذا المحل',
                                  'Ask AI about this store',
                                ),
                                style: AppTypography.title(
                                  Colors.white,
                                ).copyWith(fontSize: 13),
                              ),
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
