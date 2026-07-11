import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../services/favorites_service.dart';
import '../map/map_screen.dart';
import '../news/news_screen.dart';
import '../ai_assistant/ai_assistant_screen.dart';
import '../category/category_list_screen.dart';
import '../category/category_data.dart';
import '../../widgets/responsive.dart';
import '../common/detail_screen.dart';
import '../../theme/app_typography.dart';

// ==================== بيانات المطعم ====================
class RestaurantData {
  final String nameAr;
  final String nameEn;
  final String categoryAr;
  final String categoryEn;
  final String
  cuisineKey; // للفلترة: traditional / eastern / fastfood / cafe / sweets / italian
  final String locationAr;
  final String locationEn;
  final double rating;
  final int reviews;
  final String priceRange;
  final String priceTier; // cheap / medium / high (للفلترة)
  final String time;
  final String aboutAr;
  final String aboutEn;
  final String image; // مسار صورة حقيقية (تقدر تستبدلها بصورتك الخاصة)
  final IconData placeholderIcon; // أيقونة بديلة إذا الصورة غير موجودة
  final Color placeholderColor; // لون بديل مميز لكل مطعم
  final String?
  customImageBase64; // صورة رفعها الأدمن يدويًا لهذا المطعم تحديدًا
  final bool isFeatured; // مطعم مميز/مروَّج له، يظهر أولًا وبشارة خاصة

  RestaurantData({
    required this.nameAr,
    required this.nameEn,
    required this.categoryAr,
    required this.categoryEn,
    required this.cuisineKey,
    required this.locationAr,
    required this.locationEn,
    required this.rating,
    required this.reviews,
    required this.priceRange,
    required this.priceTier,
    required this.time,
    required this.aboutAr,
    required this.aboutEn,
    required this.image,
    required this.placeholderIcon,
    required this.placeholderColor,
    this.customImageBase64,
    this.isFeatured = false,
  });
}

final List<RestaurantData> restaurantsSeedData = [
  RestaurantData(
    nameAr: 'مطعم البيت النابلسي',
    nameEn: 'Al-Bait Al-Nabulsi Restaurant',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr: 'شارع سفيان - نابلس',
    locationEn: 'Sufyan St. - Nablus',
    rating: 4.8,
    reviews: 256,
    priceRange: '25-35 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr:
        'مطعم تراثي نابلسي يقدم أشهى الأطباق الشعبية بنكهات أصيلة ومكونات طازجة من قلب نابلس.',
    aboutEn:
        'A traditional Nablus restaurant serving the finest local dishes with authentic flavors and fresh ingredients from the heart of Nablus.',
    image: 'assets/images/restaurants/r1.jpg',
    placeholderIcon: Icons.dinner_dining,
    placeholderColor: Color(0xFFB5651D),
    isFeatured: true,
  ),
  RestaurantData(
    nameAr: 'مطعم الأندلس',
    nameEn: 'Al-Andalus Restaurant',
    categoryAr: 'مأكولات شرقية',
    categoryEn: 'Eastern Food',
    cuisineKey: 'eastern',
    locationAr: 'شارع فيصل - نابلس',
    locationEn: 'Faisal St. - Nablus',
    rating: 4.6,
    reviews: 205,
    priceRange: '30-45 ₪',
    priceTier: 'medium',
    time: '25 دقيقة',
    aboutAr: 'أطباق شرقية متنوعة بأسلوب تقديم راقٍ ونكهات غنية.',
    aboutEn:
        'A variety of eastern dishes with elegant presentation and rich flavors.',
    image: 'assets/images/restaurants/r2.jpg',
    placeholderIcon: Icons.restaurant,
    placeholderColor: Color(0xFF8E5B3F),
  ),
  RestaurantData(
    nameAr: 'Burger Lounge',
    nameEn: 'Burger Lounge',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'دوار الشهداء - نابلس',
    locationEn: 'Martyrs Circle - Nablus',
    rating: 4.6,
    reviews: 180,
    priceRange: '20-35 ₪',
    priceTier: 'medium',
    time: '25 دقيقة',
    aboutAr: 'أشهى البرغر الطازج مع بطاطا مقرمشة وصوصات مميزة.',
    aboutEn:
        'The tastiest fresh burgers with crispy fries and signature sauces.',
    image: 'assets/images/restaurants/r3.jpg',
    placeholderIcon: Icons.lunch_dining,
    placeholderColor: Color(0xFFD4A017),
  ),
  RestaurantData(
    nameAr: 'كافية الريفة',
    nameEn: 'Al-Reefa Cafe',
    categoryAr: 'كافيهات',
    categoryEn: 'Cafes',
    cuisineKey: 'cafe',
    locationAr: 'منطقة الرابية - نابلس',
    locationEn: 'Al-Rabya Area - Nablus',
    rating: 4.4,
    reviews: 140,
    priceRange: '15-25 ₪',
    priceTier: 'cheap',
    time: '20 دقيقة',
    aboutAr: 'أجواء هادئة ومشروبات مختصة بمكونات مميزة.',
    aboutEn: 'A calm atmosphere with specialty drinks and premium ingredients.',
    image: 'assets/images/restaurants/r4.jpg',
    placeholderIcon: Icons.coffee,
    placeholderColor: Color(0xFF6F4E37),
  ),
  RestaurantData(
    nameAr: 'حلويات السلطان',
    nameEn: 'Al-Sultan Sweets',
    categoryAr: 'حلويات',
    categoryEn: 'Sweets',
    cuisineKey: 'sweets',
    locationAr: 'شارع رفيديا - نابلس',
    locationEn: 'Rafidia St. - Nablus',
    rating: 4.5,
    reviews: 210,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '20 دقيقة',
    aboutAr: 'أشهى الحلويات الشرقية الطازجة يوميًا.',
    aboutEn: 'The finest traditional sweets made fresh daily.',
    image: 'assets/images/restaurants/r5.jpg',
    placeholderIcon: Icons.cake,
    placeholderColor: Color(0xFFC9A227),
  ),
  RestaurantData(
    nameAr: 'بيتزا نابلس',
    nameEn: 'Nablus Pizza',
    categoryAr: 'إيطالي',
    categoryEn: 'Italian',
    cuisineKey: 'italian',
    locationAr: 'شارع الجامعة - نابلس',
    locationEn: 'University St. - Nablus',
    rating: 4.3,
    reviews: 260,
    priceRange: '20-30 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr: 'بيتزا إيطالية أصلية بعجينة طرية ومكونات فريدة.',
    aboutEn: 'Authentic Italian pizza with soft dough and unique toppings.',
    image: 'assets/images/restaurants/r6.jpg',
    placeholderIcon: Icons.local_pizza,
    placeholderColor: Color(0xFFB33A2E),
  ),
  RestaurantData(
    nameAr: 'شاورما نابلس',
    nameEn: 'Nablus Shawarma',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'شارع عمان - نابلس',
    locationEn: 'Amman St. - Nablus',
    rating: 4.2,
    reviews: 275,
    priceRange: '10-15 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr: 'شاورما طازجة يوميًا بنكهة لا تُنسى.',
    aboutEn: 'Fresh shawarma made daily with an unforgettable taste.',
    image: 'assets/images/restaurants/r7.jpg',
    placeholderIcon: Icons.kebab_dining,
    placeholderColor: Color(0xFF7A4B2A),
  ),
  RestaurantData(
    nameAr: 'كنافة نابلس',
    nameEn: 'Nablus Kunafa',
    categoryAr: 'حلويات',
    categoryEn: 'Sweets',
    cuisineKey: 'sweets',
    locationAr: 'المساكن الشعبية - نابلس',
    locationEn: 'Popular Housing - Nablus',
    rating: 4.2,
    reviews: 190,
    priceRange: '12-20 ₪',
    priceTier: 'cheap',
    time: '10 دقيقة',
    aboutAr: 'الكنافة النابلسية الأصلية بالجبن الطازج.',
    aboutEn: 'Authentic Nabulsi kunafa made with fresh cheese.',
    image: 'assets/images/restaurants/r8.jpg',
    placeholderIcon: Icons.bakery_dining,
    placeholderColor: Color(0xFFE8A33D),
  ),
  RestaurantData(
    nameAr: 'مطعم تنورين',
    nameEn: 'Tannourine Restaurant',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.5,
    reviews: 66,
    priceRange: '25-35 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr:
        'مطعم يقدم أشهى الأطباق الشعبية بنكهات أصيلة ومكونات طازجة من قلب نابلس.',
    aboutEn:
        'A restaurant serving the finest local dishes with authentic flavors and fresh ingredients from the heart of Nablus.',
    image: 'assets/images/restaurants/r9.jpg',
    placeholderIcon: Icons.dinner_dining,
    placeholderColor: Color(0xFFB5651D),
  ),
  RestaurantData(
    nameAr: 'مطعم المدينة',
    nameEn: 'Al-Madina Restaurant',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr: 'وسط البلد - نابلس',
    locationEn: 'Downtown - Nablus',
    rating: 4.1,
    reviews: 95,
    priceRange: '25-35 ₪',
    priceTier: 'medium',
    time: '10 دقيقة',
    aboutAr:
        'مطعم يقدم أشهى الأطباق الشعبية بنكهات أصيلة ومكونات طازجة من قلب نابلس.',
    aboutEn:
        'A restaurant serving the finest local dishes with authentic flavors and fresh ingredients from the heart of Nablus.',
    image: 'assets/images/restaurants/r10.jpg',
    placeholderIcon: Icons.dinner_dining,
    placeholderColor: Color(0xFF8E5B3F),
  ),
  RestaurantData(
    nameAr: 'مطعم ليفانت (Levant)',
    nameEn: 'Levant Restaurant',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr: 'شارع فيصل - نابلس',
    locationEn: 'Faisal St. - Nablus',
    rating: 4.5,
    reviews: 288,
    priceRange: '25-35 ₪',
    priceTier: 'medium',
    time: '30 دقيقة',
    aboutAr:
        'مطعم يقدم أشهى الأطباق الشعبية بنكهات أصيلة ومكونات طازجة من قلب نابلس.',
    aboutEn:
        'A restaurant serving the finest local dishes with authentic flavors and fresh ingredients from the heart of Nablus.',
    image: 'assets/images/restaurants/r11.jpg',
    placeholderIcon: Icons.dinner_dining,
    placeholderColor: Color(0xFFD4A017),
  ),
  RestaurantData(
    nameAr: 'مطعم الف ليلة وليلة',
    nameEn: 'Alf Layla wa Layla Restaurant',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.0,
    reviews: 168,
    priceRange: '25-35 ₪',
    priceTier: 'medium',
    time: '10 دقيقة',
    aboutAr:
        'مطعم يقدم أشهى الأطباق الشعبية بنكهات أصيلة ومكونات طازجة من قلب نابلس.',
    aboutEn:
        'A restaurant serving the finest local dishes with authentic flavors and fresh ingredients from the heart of Nablus.',
    image: 'assets/images/restaurants/r12.jpg',
    placeholderIcon: Icons.dinner_dining,
    placeholderColor: Color(0xFF6F4E37),
  ),
  RestaurantData(
    nameAr: 'W Restaurant',
    nameEn: 'W Restaurant',
    categoryAr: 'مأكولات شرقية',
    categoryEn: 'Eastern Food',
    cuisineKey: 'eastern',
    locationAr: 'شارع الجامعة - نابلس',
    locationEn: 'University St. - Nablus',
    rating: 3.9,
    reviews: 115,
    priceRange: '30-45 ₪',
    priceTier: 'medium',
    time: '15 دقيقة',
    aboutAr: 'أطباق شرقية متنوعة بأسلوب تقديم راقٍ ونكهات غنية.',
    aboutEn:
        'A variety of eastern dishes with elegant presentation and rich flavors.',
    image: 'assets/images/restaurants/r13.jpg',
    placeholderIcon: Icons.restaurant,
    placeholderColor: Color(0xFFC9A227),
  ),
  RestaurantData(
    nameAr: '1948 Restaurant',
    nameEn: '1948 Restaurant',
    categoryAr: 'مأكولات شرقية',
    categoryEn: 'Eastern Food',
    cuisineKey: 'eastern',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.4,
    reviews: 66,
    priceRange: '30-45 ₪',
    priceTier: 'medium',
    time: '30 دقيقة',
    aboutAr: 'أطباق شرقية متنوعة بأسلوب تقديم راقٍ ونكهات غنية.',
    aboutEn:
        'A variety of eastern dishes with elegant presentation and rich flavors.',
    image: 'assets/images/restaurants/r14.jpg',
    placeholderIcon: Icons.restaurant,
    placeholderColor: Color(0xFFB33A2E),
  ),
  RestaurantData(
    nameAr: 'Solido Restaurant',
    nameEn: 'Solido Restaurant',
    categoryAr: 'مأكولات شرقية',
    categoryEn: 'Eastern Food',
    cuisineKey: 'eastern',
    locationAr: 'شارع الجامعة - نابلس',
    locationEn: 'University St. - Nablus',
    rating: 4.1,
    reviews: 226,
    priceRange: '30-45 ₪',
    priceTier: 'medium',
    time: '30 دقيقة',
    aboutAr: 'أطباق شرقية متنوعة بأسلوب تقديم راقٍ ونكهات غنية.',
    aboutEn:
        'A variety of eastern dishes with elegant presentation and rich flavors.',
    image: 'assets/images/restaurants/r15.jpg',
    placeholderIcon: Icons.restaurant,
    placeholderColor: Color(0xFF7A4B2A),
  ),
  RestaurantData(
    nameAr: 'Ward Restaurant & Café',
    nameEn: 'Ward Restaurant & Café',
    categoryAr: 'مأكولات شرقية',
    categoryEn: 'Eastern Food',
    cuisineKey: 'eastern',
    locationAr: 'شارع عمان - نابلس',
    locationEn: 'Amman St. - Nablus',
    rating: 4.3,
    reviews: 174,
    priceRange: '30-45 ₪',
    priceTier: 'medium',
    time: '30 دقيقة',
    aboutAr: 'أطباق شرقية متنوعة بأسلوب تقديم راقٍ ونكهات غنية.',
    aboutEn:
        'A variety of eastern dishes with elegant presentation and rich flavors.',
    image: 'assets/images/restaurants/r16.jpg',
    placeholderIcon: Icons.restaurant,
    placeholderColor: Color(0xFFE8A33D),
  ),
  RestaurantData(
    nameAr: 'Rexos Café & Restaurant',
    nameEn: 'Rexos Café & Restaurant',
    categoryAr: 'مأكولات شرقية',
    categoryEn: 'Eastern Food',
    cuisineKey: 'eastern',
    locationAr: 'شارع فيصل - نابلس',
    locationEn: 'Faisal St. - Nablus',
    rating: 4.2,
    reviews: 282,
    priceRange: '30-45 ₪',
    priceTier: 'medium',
    time: '10 دقيقة',
    aboutAr: 'أطباق شرقية متنوعة بأسلوب تقديم راقٍ ونكهات غنية.',
    aboutEn:
        'A variety of eastern dishes with elegant presentation and rich flavors.',
    image: 'assets/images/restaurants/r17.jpg',
    placeholderIcon: Icons.restaurant,
    placeholderColor: Color(0xFF9C6B30),
  ),
  RestaurantData(
    nameAr: 'Pardo Café',
    nameEn: 'Pardo Café',
    categoryAr: 'كافيه',
    categoryEn: 'Cafe',
    cuisineKey: 'cafe',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.6,
    reviews: 100,
    priceRange: '15-25 ₪',
    priceTier: 'cheap',
    time: '25 دقيقة',
    aboutAr: 'أجواء هادئة ومشروبات مختصة بمكونات مميزة.',
    aboutEn: 'A calm atmosphere with specialty drinks and premium ingredients.',
    image: 'assets/images/restaurants/r18.jpg',
    placeholderIcon: Icons.coffee,
    placeholderColor: Color(0xFFA85E2C),
  ),
  RestaurantData(
    nameAr: 'Veranda Café',
    nameEn: 'Veranda Café',
    categoryAr: 'كافيه',
    categoryEn: 'Cafe',
    cuisineKey: 'cafe',
    locationAr: 'شارع الجامعة - نابلس',
    locationEn: 'University St. - Nablus',
    rating: 4.2,
    reviews: 99,
    priceRange: '15-25 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr: 'أجواء هادئة ومشروبات مختصة بمكونات مميزة.',
    aboutEn: 'A calm atmosphere with specialty drinks and premium ingredients.',
    image: 'assets/images/restaurants/r19.jpg',
    placeholderIcon: Icons.coffee,
    placeholderColor: Color(0xFFB5651D),
  ),
  RestaurantData(
    nameAr: 'Lemon W Nana',
    nameEn: 'Lemon W Nana',
    categoryAr: 'كافيه',
    categoryEn: 'Cafe',
    cuisineKey: 'cafe',
    locationAr: 'شارع عمان - نابلس',
    locationEn: 'Amman St. - Nablus',
    rating: 4.8,
    reviews: 146,
    priceRange: '15-25 ₪',
    priceTier: 'cheap',
    time: '10 دقيقة',
    aboutAr: 'أجواء هادئة ومشروبات مختصة بمكونات مميزة.',
    aboutEn: 'A calm atmosphere with specialty drinks and premium ingredients.',
    image: 'assets/images/restaurants/r20.jpg',
    placeholderIcon: Icons.coffee,
    placeholderColor: Color(0xFF8E5B3F),
  ),
  RestaurantData(
    nameAr: 'Nosha Café',
    nameEn: 'Nosha Café',
    categoryAr: 'كافيه',
    categoryEn: 'Cafe',
    cuisineKey: 'cafe',
    locationAr: 'شارع فيصل - نابلس',
    locationEn: 'Faisal St. - Nablus',
    rating: 4.0,
    reviews: 84,
    priceRange: '15-25 ₪',
    priceTier: 'cheap',
    time: '20 دقيقة',
    aboutAr: 'أجواء هادئة ومشروبات مختصة بمكونات مميزة.',
    aboutEn: 'A calm atmosphere with specialty drinks and premium ingredients.',
    image: 'assets/images/restaurants/r21.jpg',
    placeholderIcon: Icons.coffee,
    placeholderColor: Color(0xFFD4A017),
  ),
  RestaurantData(
    nameAr: 'Cedarz Gelato & Coffee House',
    nameEn: 'Cedarz Gelato & Coffee House',
    categoryAr: 'كافيه',
    categoryEn: 'Cafe',
    cuisineKey: 'cafe',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.7,
    reviews: 214,
    priceRange: '15-25 ₪',
    priceTier: 'cheap',
    time: '20 دقيقة',
    aboutAr: 'أجواء هادئة ومشروبات مختصة بمكونات مميزة.',
    aboutEn: 'A calm atmosphere with specialty drinks and premium ingredients.',
    image: 'assets/images/restaurants/r22.jpg',
    placeholderIcon: Icons.coffee,
    placeholderColor: Color(0xFF6F4E37),
  ),
  RestaurantData(
    nameAr: 'Pizza Inn',
    nameEn: 'Pizza Inn',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'شارع الجامعة - نابلس',
    locationEn: 'University St. - Nablus',
    rating: 4.6,
    reviews: 246,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '25 دقيقة',
    aboutAr: 'وجبات سريعة طازجة بنكهة لا تُنسى وخدمة سريعة.',
    aboutEn: 'Fresh fast food with an unforgettable taste and quick service.',
    image: 'assets/images/restaurants/r23.jpg',
    placeholderIcon: Icons.fastfood,
    placeholderColor: Color(0xFFC9A227),
  ),
  RestaurantData(
    nameAr: 'Mono Pizza',
    nameEn: 'Mono Pizza',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.4,
    reviews: 296,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '25 دقيقة',
    aboutAr: 'وجبات سريعة طازجة بنكهة لا تُنسى وخدمة سريعة.',
    aboutEn: 'Fresh fast food with an unforgettable taste and quick service.',
    image: 'assets/images/restaurants/r24.jpg',
    placeholderIcon: Icons.fastfood,
    placeholderColor: Color(0xFFB33A2E),
  ),
  RestaurantData(
    nameAr: 'Sawa Rbena',
    nameEn: 'Sawa Rbena',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'شارع عمان - نابلس',
    locationEn: 'Amman St. - Nablus',
    rating: 4.0,
    reviews: 135,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '30 دقيقة',
    aboutAr: 'وجبات سريعة طازجة بنكهة لا تُنسى وخدمة سريعة.',
    aboutEn: 'Fresh fast food with an unforgettable taste and quick service.',
    image: 'assets/images/restaurants/r25.jpg',
    placeholderIcon: Icons.fastfood,
    placeholderColor: Color(0xFF7A4B2A),
  ),
  RestaurantData(
    nameAr: 'Shawarma House',
    nameEn: 'Shawarma House',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'شارع سفيان - نابلس',
    locationEn: 'Sufyan St. - Nablus',
    rating: 4.7,
    reviews: 152,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '30 دقيقة',
    aboutAr: 'وجبات سريعة طازجة بنكهة لا تُنسى وخدمة سريعة.',
    aboutEn: 'Fresh fast food with an unforgettable taste and quick service.',
    image: 'assets/images/restaurants/r26.jpg',
    placeholderIcon: Icons.fastfood,
    placeholderColor: Color(0xFFE8A33D),
  ),
  RestaurantData(
    nameAr: 'بكداش للحلويات',
    nameEn: 'Bakdash Sweets',
    categoryAr: 'حلويات',
    categoryEn: 'Sweets',
    cuisineKey: 'sweets',
    locationAr: 'وسط البلد - نابلس',
    locationEn: 'Downtown - Nablus',
    rating: 4.1,
    reviews: 77,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '10 دقيقة',
    aboutAr: 'أشهى الحلويات الشرقية الطازجة يوميًا.',
    aboutEn: 'The finest traditional sweets made fresh daily.',
    image: 'assets/images/restaurants/r27.jpg',
    placeholderIcon: Icons.cake,
    placeholderColor: Color(0xFF9C6B30),
  ),
  RestaurantData(
    nameAr: 'كنافة الأقصى',
    nameEn: 'Al-Aqsa Kunafa',
    categoryAr: 'حلويات',
    categoryEn: 'Sweets',
    cuisineKey: 'sweets',
    locationAr: 'البلدة القديمة - نابلس',
    locationEn: 'Old City - Nablus',
    rating: 4.5,
    reviews: 257,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '20 دقيقة',
    aboutAr: 'أشهى الحلويات الشرقية الطازجة يوميًا.',
    aboutEn: 'The finest traditional sweets made fresh daily.',
    image: 'assets/images/restaurants/r28.jpg',
    placeholderIcon: Icons.cake,
    placeholderColor: Color(0xFFA85E2C),
  ),
  RestaurantData(
    nameAr: 'Becasse Bakery',
    nameEn: 'Becasse Bakery',
    categoryAr: 'حلويات',
    categoryEn: 'Sweets',
    cuisineKey: 'sweets',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.8,
    reviews: 278,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr: 'أشهى الحلويات الشرقية الطازجة يوميًا.',
    aboutEn: 'The finest traditional sweets made fresh daily.',
    image: 'assets/images/restaurants/r29.jpg',
    placeholderIcon: Icons.cake,
    placeholderColor: Color(0xFFB5651D),
  ),
  RestaurantData(
    nameAr: 'أبو سير للحلويات',
    nameEn: 'Abu Seir Sweets',
    categoryAr: 'حلويات',
    categoryEn: 'Sweets',
    cuisineKey: 'sweets',
    locationAr: 'شارع الجامعة - نابلس',
    locationEn: 'University St. - Nablus',
    rating: 4.7,
    reviews: 157,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '20 دقيقة',
    aboutAr: 'أشهى الحلويات الشرقية الطازجة يوميًا.',
    aboutEn: 'The finest traditional sweets made fresh daily.',
    image: 'assets/images/restaurants/r30.jpg',
    placeholderIcon: Icons.cake,
    placeholderColor: Color(0xFF8E5B3F),
  ),
  RestaurantData(
    nameAr: 'Pizza Inn',
    nameEn: 'Pizza Inn',
    categoryAr: 'إيطالي',
    categoryEn: 'Italian',
    cuisineKey: 'italian',
    locationAr: 'شارع الجامعة - نابلس',
    locationEn: 'University St. - Nablus',
    rating: 4.3,
    reviews: 273,
    priceRange: '25-40 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr: 'بيتزا وأطباق إيطالية أصلية بعجينة طرية ومكونات فريدة.',
    aboutEn:
        'Authentic Italian pizza and dishes with soft dough and unique toppings.',
    image: 'assets/images/restaurants/r31.jpg',
    placeholderIcon: Icons.local_pizza,
    placeholderColor: Color(0xFFD4A017),
  ),
  RestaurantData(
    nameAr: 'Mono Pizza',
    nameEn: 'Mono Pizza',
    categoryAr: 'إيطالي',
    categoryEn: 'Italian',
    cuisineKey: 'italian',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.0,
    reviews: 150,
    priceRange: '25-40 ₪',
    priceTier: 'medium',
    time: '15 دقيقة',
    aboutAr: 'بيتزا وأطباق إيطالية أصلية بعجينة طرية ومكونات فريدة.',
    aboutEn:
        'Authentic Italian pizza and dishes with soft dough and unique toppings.',
    image: 'assets/images/restaurants/r32.jpg',
    placeholderIcon: Icons.local_pizza,
    placeholderColor: Color(0xFF6F4E37),
  ),
  RestaurantData(
    nameAr: 'Solido Restaurant',
    nameEn: 'Solido Restaurant',
    categoryAr: 'إيطالي',
    categoryEn: 'Italian',
    cuisineKey: 'italian',
    locationAr: 'شارع الجامعة - نابلس',
    locationEn: 'University St. - Nablus',
    rating: 4.5,
    reviews: 239,
    priceRange: '25-40 ₪',
    priceTier: 'medium',
    time: '10 دقيقة',
    aboutAr: 'بيتزا وأطباق إيطالية أصلية بعجينة طرية ومكونات فريدة.',
    aboutEn:
        'Authentic Italian pizza and dishes with soft dough and unique toppings.',
    image: 'assets/images/restaurants/r33.jpg',
    placeholderIcon: Icons.local_pizza,
    placeholderColor: Color(0xFFC9A227),
  ),
  RestaurantData(
    nameAr: 'La Piazza',
    nameEn: 'La Piazza',
    categoryAr: 'إيطالي',
    categoryEn: 'Italian',
    cuisineKey: 'italian',
    locationAr: 'شارع عمان - نابلس',
    locationEn: 'Amman St. - Nablus',
    rating: 4.4,
    reviews: 103,
    priceRange: '25-40 ₪',
    priceTier: 'medium',
    time: '30 دقيقة',
    aboutAr: 'بيتزا وأطباق إيطالية أصلية بعجينة طرية ومكونات فريدة.',
    aboutEn:
        'Authentic Italian pizza and dishes with soft dough and unique toppings.',
    image: 'assets/images/restaurants/r34.jpg',
    placeholderIcon: Icons.local_pizza,
    placeholderColor: Color(0xFFB33A2E),
  ),
  RestaurantData(
    nameAr: 'Italian House',
    nameEn: 'Italian House',
    categoryAr: 'إيطالي',
    categoryEn: 'Italian',
    cuisineKey: 'italian',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.6,
    reviews: 101,
    priceRange: '25-40 ₪',
    priceTier: 'medium',
    time: '25 دقيقة',
    aboutAr: 'بيتزا وأطباق إيطالية أصلية بعجينة طرية ومكونات فريدة.',
    aboutEn:
        'Authentic Italian pizza and dishes with soft dough and unique toppings.',
    image: 'assets/images/restaurants/r35.jpg',
    placeholderIcon: Icons.local_pizza,
    placeholderColor: Color(0xFF7A4B2A),
  ),
];

// كلمة بحث إنجليزية مناسبة لصورة المطعم: أولاً نحاول اكتشاف الطبق الفعلي من
// اسم المطعم نفسه (حتى ما تظهر صورة برغر لمطعم شاورما مثلاً)، وإلا نرجع
// لتصنيف نوع المطبخ العام. مشتركة حتى تُستخدم من أي شاشة تعرض مطاعم.
String restaurantPhotoQuery(RestaurantData data) {
  final text = '${data.nameAr} ${data.nameEn}'.toLowerCase();
  if (text.contains('شاورما') || text.contains('shawarma')) {
    return 'shawarma wrap';
  }
  if (text.contains('برغر') || text.contains('burger')) {
    return 'burger and fries';
  }
  if (text.contains('بيتزا') || text.contains('pizza')) return 'pizza';
  if (text.contains('جيلاتو') || text.contains('gelato')) {
    return 'gelato ice cream';
  }
  if (text.contains('كنافة') || text.contains('kunafa')) {
    return 'kunafa dessert';
  }
  if (text.contains('حلويات') ||
      text.contains('sweets') ||
      text.contains('بكداش') ||
      text.contains('bakdash') ||
      text.contains('bakery')) {
    return 'arabic sweets baklava';
  }
  if (text.contains('كافي') ||
      text.contains('كافيه') ||
      text.contains('café') ||
      text.contains('cafe') ||
      text.contains('قهوة')) {
    return 'coffee shop interior';
  }

  switch (data.cuisineKey) {
    case 'traditional':
      return 'arabic food plate';
    case 'eastern':
      return 'middle eastern food';
    case 'cafe':
      return 'coffee shop interior';
    case 'fastfood':
      return 'fast food meal';
    case 'sweets':
      return 'kunafa dessert';
    case 'italian':
      return 'pizza';
    default:
      return 'restaurant food';
  }
}

// ==================== ودجت صورة المطعم (تعرض صورة حقيقية أو أيقونة مميزة كبديل) ====================
class _RestaurantImage extends StatelessWidget {
  final RestaurantData data;
  final double height;
  final BorderRadius? borderRadius;
  const _RestaurantImage({
    required this.data,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedImage(
      query: restaurantPhotoQuery(data),
      fallbackSeed: data.nameEn,
      height: height,
      borderRadius: borderRadius,
      fallbackIcon: data.placeholderIcon,
      fallbackColor: data.placeholderColor,
      customImageBase64: data.customImageBase64,
    );
  }
}

// ==================== الشاشة الرئيسية لصفحة المطاعم ====================
class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  int selectedIndex = 0;
  bool isGridView = true;
  int currentPage = 0;
  static const int perPage = 4;

  bool _loaded = false;
  List<RestaurantData> _liveRestaurants = [];
  List<dynamic> _keys = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = LocalDbService.instance;
    await db.seedIfEmpty(
      'restaurants',
      restaurantsSeedData.map(restaurantToMap).toList(),
    );
    final entries = db.getAll('restaurants');
    setState(() {
      _keys = entries.map((e) => e.key).toList();
      _liveRestaurants = entries.map((e) => mapToRestaurant(e.value)).toList();
      _loaded = true;
    });
  }

  void _refreshFromDb() {
    final entries = LocalDbService.instance.getAll('restaurants');
    setState(() {
      _keys = entries.map((e) => e.key).toList();
      _liveRestaurants = entries.map((e) => mapToRestaurant(e.value)).toList();
    });
  }

  // فلاتر
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Set<String> selectedCuisines = {'all'};
  double minRating = 0;
  String priceTier = 'all';
  bool sortByPriceAsc = false; // false = الأعلى تقييماً, true = الأقل سعراً

  List<RestaurantData> get _filtered {
    var list = _liveRestaurants.where((r) {
      final matchesSearch =
          searchQuery.isEmpty ||
          r.nameAr.contains(searchQuery) ||
          r.nameEn.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCuisine =
          selectedCuisines.contains('all') ||
          selectedCuisines.contains(r.cuisineKey);
      final matchesRating = r.rating >= minRating;
      final matchesPrice = priceTier == 'all' || r.priceTier == priceTier;
      return matchesSearch && matchesCuisine && matchesRating && matchesPrice;
    }).toList();

    list.sort((a, b) {
      if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
      if (sortByPriceAsc) return a.priceTier.compareTo(b.priceTier);
      return b.rating.compareTo(a.rating);
    });
    return list;
  }

  List<RestaurantData> get _pageItems {
    final list = _filtered;
    final start = currentPage * perPage;
    if (start >= list.length) return [];
    final end = (start + perPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get _pageCount {
    final len = _filtered.length;
    return len == 0 ? 1 : ((len - 1) ~/ perPage) + 1;
  }

  void _toggleCuisine(String key) {
    setState(() {
      if (key == 'all') {
        selectedCuisines = {'all'};
      } else {
        selectedCuisines.remove('all');
        if (selectedCuisines.contains(key)) {
          selectedCuisines.remove(key);
        } else {
          selectedCuisines.add(key);
        }
        if (selectedCuisines.isEmpty) selectedCuisines = {'all'};
      }
      currentPage = 0;
    });
  }

  void _openRestaurantDetail(BuildContext context, RestaurantData r) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          titleAr: r.nameAr,
          titleEn: r.nameEn,
          subtitleAr: r.categoryAr,
          subtitleEn: r.categoryEn,
          descriptionAr: r.aboutAr,
          descriptionEn: r.aboutEn,
          rating: r.rating,
          extraInfo: r.priceRange,
          locationAr: r.locationAr,
          locationEn: r.locationEn,
          customImageBase64: r.customImageBase64,
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppState.instance.t(
            '$label قيد التطوير قريبًا',
            '$label coming soon',
          ),
        ),
        duration: Duration(seconds: 2),
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
        final pageItems = _pageItems;
        final filteredList = _filtered;
        final selected = filteredList.isEmpty
            ? null
            : filteredList[selectedIndex.clamp(0, filteredList.length - 1)];
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopNav(onComingSoon: _showComingSoon),
                  _Banner(),
                  Padding(
                    padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                    child: isMobile(context)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _FiltersSidebar(
                                searchController: searchController,
                                onSearchChanged: (v) => setState(() {
                                  searchQuery = v;
                                  currentPage = 0;
                                }),
                                selectedCuisines: selectedCuisines,
                                onCuisineTap: _toggleCuisine,
                                minRating: minRating,
                                onRatingTap: (v) => setState(() {
                                  minRating = v;
                                  currentPage = 0;
                                }),
                                priceTier: priceTier,
                                onPriceTap: (v) => setState(() {
                                  priceTier = v;
                                  currentPage = 0;
                                }),
                                onApply: () => setState(() {}),
                              ),
                              SizedBox(height: 16),
                              _ResultsArea(
                                items: pageItems,
                                masterList: _liveRestaurants,
                                allFilteredCount: filteredList.length,
                                selectedData: null,
                                isGridView: isGridView,
                                onToggleView: (grid) =>
                                    setState(() => isGridView = grid),
                                onSortToggle: () => setState(
                                  () => sortByPriceAsc = !sortByPriceAsc,
                                ),
                                sortByPriceAsc: sortByPriceAsc,
                                onSelect: (data) =>
                                    _openRestaurantDetail(context, data),
                                onFavorite: (data) async {
                                  await FavoritesService.instance
                                      .toggleFavorite(data.nameEn);
                                  setState(() {});
                                },
                                currentPage: currentPage,
                                pageCount: _pageCount,
                                onPageChange: (p) =>
                                    setState(() => currentPage = p),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 240,
                                child: _FiltersSidebar(
                                  searchController: searchController,
                                  onSearchChanged: (v) => setState(() {
                                    searchQuery = v;
                                    currentPage = 0;
                                  }),
                                  selectedCuisines: selectedCuisines,
                                  onCuisineTap: _toggleCuisine,
                                  minRating: minRating,
                                  onRatingTap: (v) => setState(() {
                                    minRating = v;
                                    currentPage = 0;
                                  }),
                                  priceTier: priceTier,
                                  onPriceTap: (v) => setState(() {
                                    priceTier = v;
                                    currentPage = 0;
                                  }),
                                  onApply: () => setState(() {}),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: _ResultsArea(
                                  items: pageItems,
                                  masterList: _liveRestaurants,
                                  allFilteredCount: filteredList.length,
                                  selectedData: selected,
                                  isGridView: isGridView,
                                  onToggleView: (grid) =>
                                      setState(() => isGridView = grid),
                                  onSortToggle: () => setState(
                                    () => sortByPriceAsc = !sortByPriceAsc,
                                  ),
                                  sortByPriceAsc: sortByPriceAsc,
                                  onSelect: (data) => setState(() {
                                    selectedIndex = filteredList.indexOf(data);
                                  }),
                                  onFavorite: (data) async {
                                    await FavoritesService.instance
                                        .toggleFavorite(data.nameEn);
                                    setState(() {});
                                  },
                                  currentPage: currentPage,
                                  pageCount: _pageCount,
                                  onPageChange: (p) =>
                                      setState(() => currentPage = p),
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: 320,
                                child: selected == null
                                    ? _EmptyDetailPanel()
                                    : _DetailPanel(
                                        restaurant: selected,
                                        isFavorite: FavoritesService.instance
                                            .isFavorite(selected.nameEn),
                                        onBack: () =>
                                            Navigator.of(context).maybePop(),
                                        onFavorite: () async {
                                          await FavoritesService.instance
                                              .toggleFavorite(selected.nameEn);
                                          setState(() {});
                                        },
                                        onShowSnack: (label) =>
                                            _showComingSoon(context, label),
                                      ),
                              ),
                            ],
                          ),
                  ),
                  _FeaturesFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== الشريط العلوي ====================
class _TopNav extends StatelessWidget {
  final void Function(BuildContext, String) onComingSoon;
  const _TopNav({required this.onComingSoon});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final mobile = isMobile(context);
    final navItems = [
      _navItem(
        context,
        app.t('الرئيسية', 'Home'),
        false,
        () => Navigator.of(context).maybePop(),
      ),
      _navItem(
        context,
        app.t('الخريطة', 'Map'),
        false,
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => MapScreen())),
      ),
      _navItem(context, app.t('المطاعم', 'Restaurants'), true, null),
      _navItem(context, app.t('الفنادق', 'Hotels'), false, () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryListScreen(
              titleAr: 'فنادق',
              titleEn: 'Hotels',
              bannerSubtitleAr: 'أفضل أماكن الإقامة في نابلس',
              bannerSubtitleEn: 'The best places to stay in Nablus',
              icon: Icons.bed,
              boxName: 'hotels',
              seedData: hotelsData,
            ),
          ),
        );
      }),
      _navItem(context, app.t('الأماكن السياحية', 'Attractions'), false, () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryListScreen(
              titleAr: 'سياحة ومعالم',
              titleEn: 'Attractions',
              bannerSubtitleAr: 'اكتشف أجمل معالم نابلس التاريخية والطبيعية',
              bannerSubtitleEn:
                  'Discover the finest historic and natural landmarks of Nablus',
              icon: Icons.mosque,
              boxName: 'attractions',
              seedData: attractionsData,
            ),
          ),
        );
      }),
      _navItem(
        context,
        app.t('الأخبار', 'News'),
        false,
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => NewsScreen())),
      ),
      _navItem(
        context,
        app.t('الفعاليات', 'Events'),
        false,
        () => onComingSoon(context, app.t('الفعاليات', 'Events')),
      ),
      _navItem(
        context,
        app.t('مساعد الذكاء الاصطناعي', 'AI Assistant'),
        false,
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => AiAssistantScreen())),
      ),
    ];
    return Container(
      color: AppColors.sidebarDark,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 12 : 24, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.location_city, color: Colors.white, size: 20),
            ),
          ),
          if (!mobile) ...[
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.t('دليل نابلس الذكي', 'Nablus Smart Guide'),
                  textDirection: app.dir,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Nablus Smart City Guide',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 9),
                ),
              ],
            ),
            Spacer(),
            ...navItems,
            Spacer(),
          ] else
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: navItems),
              ),
            ),
          SizedBox(width: mobile ? 8 : 0),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => app.toggleTheme(),
            child: Icon(
              app.isDark ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.textWhite,
              size: 20,
            ),
          ),
          SizedBox(width: mobile ? 10 : 14),
          if (!mobile)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => app.toggleLanguage(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardDark2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  app.isArabic ? 'عربي  EN' : 'EN  عربي',
                  style: TextStyle(color: AppColors.textWhite, fontSize: 11),
                ),
              ),
            )
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => app.toggleLanguage(),
              child: Text(
                app.isArabic ? 'EN' : 'AR',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          SizedBox(width: mobile ? 10 : 14),
          CircleAvatar(
            radius: mobile ? 15 : 18,
            backgroundColor: AppColors.cardDark2,
            child: Icon(
              Icons.notifications_none,
              color: AppColors.textWhite,
              size: mobile ? 15 : 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    String label,
    bool active,
    VoidCallback? onTap,
  ) {
    final color = active ? AppColors.primary : AppColors.textGrey;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (active)
              Container(
                margin: EdgeInsets.only(top: 4),
                height: 2,
                width: 18,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

// ==================== بانر عنوان الصفحة ====================
class _Banner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Container(
      height: 200,
      margin: EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ThemedImage(
            query: 'Nablus restaurant',
            fallbackSeed: 'nablus-restaurants-banner',
            height: 200,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  app.t('المطاعم في نابلس', 'Restaurants in Nablus'),
                  textDirection: app.dir,
                  style: AppTypography.display(Colors.white).copyWith(fontSize: 28),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 40, height: 1, color: AppColors.gold),
                    SizedBox(width: 8),
                    Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 16),
                    SizedBox(width: 8),
                    Container(width: 40, height: 1, color: AppColors.gold),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  app.t(
                    'اكتشف أطيب المأكولات في قلب المدينة',
                    'Discover the finest food in the heart of the city',
                  ),
                  textDirection: app.dir,
                  style: AppTypography.body(Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== الشريط الجانبي للفلاتر (فعّال بالكامل) ====================
class _FiltersSidebar extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String) onSearchChanged;
  final Set<String> selectedCuisines;
  final void Function(String) onCuisineTap;
  final double minRating;
  final void Function(double) onRatingTap;
  final String priceTier;
  final void Function(String) onPriceTap;
  final VoidCallback onApply;

  const _FiltersSidebar({
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedCuisines,
    required this.onCuisineTap,
    required this.minRating,
    required this.onRatingTap,
    required this.priceTier,
    required this.onPriceTap,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return AppCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                app.t('تصفية النتائج', 'Filter Results'),
                textDirection: app.dir,
                style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            app.t('بحث', 'Search'),
            textDirection: app.dir,
            style: TextStyle(color: AppColors.textWhite, fontSize: 12),
          ),
          SizedBox(height: 6),
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
                    controller: searchController,
                    onChanged: onSearchChanged,
                    style: TextStyle(color: AppColors.textWhite, fontSize: 12),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: app.t(
                        'ابحث عن مطعم...',
                        'Search a restaurant...',
                      ),
                      hintStyle: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          Text(
            app.t('نوع الطعام', 'Cuisine Type'),
            textDirection: app.dir,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _checkRow(
            app.t('الكل', 'All'),
            selectedCuisines.contains('all'),
            () => onCuisineTap('all'),
          ),
          _checkRow(
            app.t('مأكولات شعبية', 'Traditional'),
            selectedCuisines.contains('traditional'),
            () => onCuisineTap('traditional'),
          ),
          _checkRow(
            app.t('شرقي', 'Eastern'),
            selectedCuisines.contains('eastern'),
            () => onCuisineTap('eastern'),
          ),
          _checkRow(
            app.t('كافيهات', 'Cafes'),
            selectedCuisines.contains('cafe'),
            () => onCuisineTap('cafe'),
          ),
          _checkRow(
            app.t('وجبات سريعة', 'Fast Food'),
            selectedCuisines.contains('fastfood'),
            () => onCuisineTap('fastfood'),
          ),
          _checkRow(
            app.t('حلويات', 'Sweets'),
            selectedCuisines.contains('sweets'),
            () => onCuisineTap('sweets'),
          ),
          _checkRow(
            app.t('إيطالي', 'Italian'),
            selectedCuisines.contains('italian'),
            () => onCuisineTap('italian'),
          ),
          SizedBox(height: 18),
          Text(
            app.t('التقييم', 'Rating'),
            textDirection: app.dir,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _ratingRow(
            4.5,
            minRating == 4.5,
            () => onRatingTap(minRating == 4.5 ? 0 : 4.5),
          ),
          _ratingRow(
            4.0,
            minRating == 4.0,
            () => onRatingTap(minRating == 4.0 ? 0 : 4.0),
          ),
          _ratingRow(
            3.5,
            minRating == 3.5,
            () => onRatingTap(minRating == 3.5 ? 0 : 3.5),
          ),
          _ratingRow(
            3.0,
            minRating == 3.0,
            () => onRatingTap(minRating == 3.0 ? 0 : 3.0),
          ),
          SizedBox(height: 18),
          Text(
            app.t('السعر', 'Price'),
            textDirection: app.dir,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _priceChip(
                app.t('الكل', 'All'),
                priceTier == 'all',
                () => onPriceTap('all'),
              ),
              _priceChip(
                app.t('رخيص', 'Cheap'),
                priceTier == 'cheap',
                () => onPriceTap('cheap'),
              ),
              _priceChip(
                app.t('متوسط', 'Medium'),
                priceTier == 'medium',
                () => onPriceTap('medium'),
              ),
              _priceChip(
                app.t('مرتفع', 'High'),
                priceTier == 'high',
                () => onPriceTap('high'),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(Icons.filter_alt, size: 16, color: Colors.white),
              label: Text(
                app.t('تطبيق الفلاتر', 'Apply Filters'),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRow(String label, bool checked, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              checked ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
              color: checked ? AppColors.primary : AppColors.textGrey,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: AppColors.textWhite, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratingRow(double value, bool selected, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: selected ? AppColors.primary : AppColors.textGrey,
            ),
            SizedBox(width: 8),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  Icons.star,
                  size: 12,
                  color: i < value.floor()
                      ? AppColors.gold
                      : AppColors.borderColor,
                ),
              ),
            ),
            SizedBox(width: 6),
            Text(
              '$value فأكثر',
              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardDark2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textWhite,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

// ==================== منطقة النتائج (شبكة/قائمة + ترتيب + ترقيم صفحات فعّال) ====================
class _ResultsArea extends StatelessWidget {
  final List<RestaurantData> items;
  final List<RestaurantData> masterList;
  final int allFilteredCount;
  final RestaurantData? selectedData;
  final bool isGridView;
  final void Function(bool) onToggleView;
  final VoidCallback onSortToggle;
  final bool sortByPriceAsc;
  final void Function(RestaurantData) onSelect;
  final void Function(RestaurantData) onFavorite;
  final int currentPage;
  final int pageCount;
  final void Function(int) onPageChange;

  const _ResultsArea({
    required this.items,
    required this.masterList,
    required this.allFilteredCount,
    required this.selectedData,
    required this.isGridView,
    required this.onToggleView,
    required this.onSortToggle,
    required this.sortByPriceAsc,
    required this.onSelect,
    required this.onFavorite,
    required this.currentPage,
    required this.pageCount,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSortToggle,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      sortByPriceAsc
                          ? app.t('ترتيب: الأقل سعراً', 'Sort: Lowest Price')
                          : app.t('ترتيب: الأعلى تقييماً', 'Sort: Top Rated'),
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.swap_vert, size: 16, color: AppColors.textGrey),
                  ],
                ),
              ),
            ),
            SizedBox(width: 14),
            Text(
              app.t(
                'عرض ${items.length} من أصل $allFilteredCount',
                'Showing ${items.length} of $allFilteredCount',
              ),
              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
            Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onToggleView(false),
              child: Icon(
                Icons.view_list,
                size: 20,
                color: isGridView ? AppColors.textGrey : AppColors.primary,
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onToggleView(true),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isGridView ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.grid_view,
                  size: 16,
                  color: isGridView ? Colors.white : AppColors.textGrey,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (items.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Text(
                app.t(
                  'لا توجد نتائج مطابقة للفلاتر',
                  'No results match the filters',
                ),
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
          )
        else if (isGridView)
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsiveGridColumns(
                context,
                wide: 4,
                narrow: 2,
              ),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, i) {
              final r = items[i];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(r),
                child: _RestaurantCard(
                  data: r,
                  isFavorite: FavoritesService.instance.isFavorite(r.nameEn),
                  isSelected: r == selectedData,
                  onFavorite: () => onFavorite(r),
                ),
              );
            },
          )
        else
          Column(
            children: items
                .map(
                  (r) => Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(r),
                      child: _RestaurantListTile(
                        data: r,
                        isFavorite: FavoritesService.instance.isFavorite(
                          r.nameEn,
                        ),
                        isSelected: r == selectedData,
                        onFavorite: () => onFavorite(r),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        SizedBox(height: 20),
        _Pagination(
          currentPage: currentPage,
          pageCount: pageCount,
          onPageChange: onPageChange,
        ),
      ],
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantData data;
  final bool isFavorite;
  final bool isSelected;
  final VoidCallback onFavorite;
  const _RestaurantCard({
    required this.data,
    required this.isFavorite,
    required this.isSelected,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final name = app.isArabic ? data.nameAr : data.nameEn;
    final category = app.isArabic ? data.categoryAr : data.categoryEn;
    final location = app.isArabic ? data.locationAr : data.locationEn;
    return AppCard(
      padding: EdgeInsets.zero,
      border: Border.all(
        color: isSelected ? AppColors.primary : AppColors.borderColor,
        width: isSelected ? 2 : 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              _RestaurantImage(
                data: data,
                height: 110,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
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
                        '${data.rating}',
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
              if (data.isFeatured)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.primaryGradient),
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
            ],
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
                SizedBox(height: 2),
                Text(
                  category,
                  textDirection: app.dir,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 10),
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
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.priceRange,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 11,
                          color: AppColors.textGrey,
                        ),
                        SizedBox(width: 3),
                        Text(
                          data.time,
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 10,
                          ),
                        ),
                      ],
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

// عرض قائمة (List) بديل لعرض الشبكة
class _RestaurantListTile extends StatelessWidget {
  final RestaurantData data;
  final bool isFavorite;
  final bool isSelected;
  final VoidCallback onFavorite;
  const _RestaurantListTile({
    required this.data,
    required this.isFavorite,
    required this.isSelected,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final name = app.isArabic ? data.nameAr : data.nameEn;
    final category = app.isArabic ? data.categoryAr : data.categoryEn;
    final location = app.isArabic ? data.locationAr : data.locationEn;
    return AppCard(
      padding: EdgeInsets.all(10),
      border: Border.all(
        color: isSelected ? AppColors.primary : AppColors.borderColor,
        width: isSelected ? 2 : 1,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _RestaurantImage(
            data: data,
            height: 70,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      name,
                      textDirection: app.dir,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (data.isFeatured) ...[
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFF5A623), Color(0xFFE85D5D)],
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, size: 9, color: Colors.white),
                            SizedBox(width: 2),
                            Text(
                              app.t('مميز', 'Featured'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  category,
                  textDirection: app.dir,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 10),
                ),
                SizedBox(height: 4),
                Text(
                  location,
                  textDirection: app.dir,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 9),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Icon(Icons.star, size: 12, color: AppColors.gold),
                  SizedBox(width: 3),
                  Text(
                    '${data.rating}',
                    style: TextStyle(color: AppColors.textWhite, fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 6),
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

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final void Function(int) onPageChange;
  const _Pagination({
    required this.currentPage,
    required this.pageCount,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    final pageRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: currentPage > 0 ? () => onPageChange(currentPage - 1) : null,
          child: Icon(
            Icons.chevron_right,
            color: currentPage > 0
                ? AppColors.textWhite
                : AppColors.borderColor,
          ),
        ),
        SizedBox(width: 8),
        for (int p = 0; p < pageCount; p++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onPageChange(p),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p == currentPage
                    ? AppColors.primary
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${p + 1}',
                style: TextStyle(
                  color: p == currentPage ? Colors.white : AppColors.textWhite,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        SizedBox(width: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: currentPage < pageCount - 1
              ? () => onPageChange(currentPage + 1)
              : null,
          child: Icon(
            Icons.chevron_left,
            color: currentPage < pageCount - 1
                ? AppColors.textWhite
                : AppColors.borderColor,
          ),
        ),
      ],
    );
    if (!isMobile(context)) {
      return Center(child: pageRow);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: pageRow,
    );
  }
}

// ==================== بانل تفاصيل المطعم المختار ====================
class _DetailPanel extends StatelessWidget {
  final RestaurantData restaurant;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final void Function(String) onShowSnack;
  const _DetailPanel({
    required this.restaurant,
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
    required this.onShowSnack,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final r = restaurant;
    final name = app.isArabic ? r.nameAr : r.nameEn;
    final category = app.isArabic ? r.categoryAr : r.categoryEn;
    final location = app.isArabic ? r.locationAr : r.locationEn;
    final about = app.isArabic ? r.aboutAr : r.aboutEn;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              _RestaurantImage(data: r, height: 170),
              Positioned(
                top: 10,
                left: 10,
                child: _roundIconBtn(Icons.arrow_back_rounded, onBack),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    _roundIconBtn(
                      Icons.ios_share,
                      () => onShowSnack(app.t('المشاركة', 'Share')),
                    ),
                    SizedBox(width: 8),
                    _roundIconBtn(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      onFavorite,
                      color: isFavorite ? AppColors.red : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
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
                            '${r.rating}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '(${r.reviews} ${app.t('تقييم', 'reviews')})',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  name,
                  textDirection: app.dir,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  category,
                  textDirection: app.dir,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
                SizedBox(height: 4),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 13,
                      color: AppColors.textGrey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      location,
                      textDirection: app.dir,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionIcon(
                      Icons.call,
                      app.t('اتصال', 'Call'),
                      () => onShowSnack(app.t('الاتصال', 'Call')),
                    ),
                    _actionIcon(
                      Icons.location_on,
                      app.t('الموقع', 'Location'),
                      () {
                        final point = resolveMapPoint(
                          nameAr: r.nameAr,
                          nameEn: r.nameEn,
                          locationAr: r.locationAr,
                          locationEn: r.locationEn,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              focusPoint: point,
                              focusNameAr: r.nameAr,
                              focusNameEn: r.nameEn,
                              focusCategoryAr: r.categoryAr,
                              focusCategoryEn: r.categoryEn,
                              focusRating: r.rating,
                            ),
                          ),
                        );
                      },
                    ),
                    _actionIcon(
                      Icons.share,
                      app.t('المشاركة', 'Share'),
                      () => onShowSnack(app.t('المشاركة', 'Share')),
                    ),
                    _actionIcon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      app.t('المفضلة', 'Favorite'),
                      onFavorite,
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Row(
                  children: [
                    Icon(Icons.emoji_events, size: 14, color: AppColors.gold),
                    SizedBox(width: 6),
                    Text(
                      app.t('نبذة عن المطعم', 'About the Restaurant'),
                      textDirection: app.dir,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  about,
                  textDirection: app.dir,
                  textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.primaryGradient),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: AppColors.glowShadow,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final point = resolveMapPoint(
                          nameAr: r.nameAr,
                          nameEn: r.nameEn,
                          locationAr: r.locationAr,
                          locationEn: r.locationEn,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              focusPoint: point,
                              focusNameAr: r.nameAr,
                              focusNameEn: r.nameEn,
                              focusCategoryAr: r.categoryAr,
                              focusCategoryEn: r.categoryEn,
                              focusRating: r.rating,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      icon: Icon(Icons.map_rounded, size: 16, color: Colors.white),
                      label: Text(
                        app.t('عرض على الخريطة', 'Show on Map'),
                        style: AppTypography.title(Colors.white).copyWith(fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: color ?? Colors.black87),
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardDark2,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: AppColors.textGrey, fontSize: 9)),
        ],
      ),
    );
  }
}

class _EmptyDetailPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return AppCard(
      padding: EdgeInsets.all(30),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu_rounded, color: AppColors.textGrey, size: 28),
            SizedBox(height: 10),
            Text(
              app.t(
                'اختر مطعمًا لعرض تفاصيله',
                'Select a restaurant to see details',
              ),
              textAlign: TextAlign.center,
              textDirection: app.dir,
              style: AppTypography.body(AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== شريط المزايا السفلي ====================
class _FeaturesFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final items = [
      [
        Icons.restaurant_menu_rounded,
        app.t('تجربة محلية أصيلة', 'Authentic Local Experience'),
      ],
      [Icons.explore_rounded, app.t('سهولة الوصول', 'Easy Access')],
      [Icons.reviews_rounded, app.t('تقييمات موثوقة', 'Trusted Reviews')],
      [Icons.volunteer_activism_rounded, app.t('دعم المحلي', 'Support Local')],
    ];
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      color: AppColors.sidebarDark,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        runSpacing: 20,
        children: items
            .map(
              (item) => SizedBox(
                width: 130,
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primaryGradient),
                        shape: BoxShape.circle,
                        boxShadow: AppColors.glowShadow,
                      ),
                      child: Icon(
                        item[0] as IconData,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      item[1] as String,
                      textAlign: TextAlign.center,
                      textDirection: app.dir,
                      style: AppTypography.label(AppColors.textWhite),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
