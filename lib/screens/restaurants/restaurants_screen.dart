import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../services/favorites_service.dart';
import '../../services/api_service.dart';
import '../map/map_screen.dart';
import '../news/news_screen.dart';
import '../ai_assistant/ai_assistant_screen.dart';
import '../hotels/hotels_screen.dart';
import '../attractions/attractions_screen.dart';
import '../../widgets/responsive.dart';
import '../common/detail_screen.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_toggle_bar.dart';
import '../../widgets/keyboard_scrollable.dart';

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
  final String phone; // رقم الهاتف للاتصال المباشر من شاشة التفاصيل
  final double?
  lat; // إحداثيات دقيقة حدّدها الأدمن بالضغط على الخريطة (لو موجودة)
  final double? lng;
  final String?
  serverImageUrl; // صورة رفعها الأدمن ومخزّنة على السيرفر (/uploads/...)

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
    this.phone = '',
    this.lat,
    this.lng,
    this.serverImageUrl,
  });
}

final List<RestaurantData> restaurantsSeedData = [
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
    aboutAr: 'يشتهر بالمشاوي والأطباق الشعبية المشوية على الفحم بنكهة مميزة.',
    aboutEn:
        'Known for grilled traditional dishes and charcoal-grilled meats with a distinctive flavor.',
    image: 'assets/images/restaurants/tanoreen.jpg',
    placeholderIcon: Icons.dinner_dining,
    placeholderColor: Color(0xFFB5651D),
  ),
  RestaurantData(
    nameAr: 'W Restaurant',
    nameEn: 'W Restaurant',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr: 'شارع تونس - نابلس',
    locationEn: 'Tunis St. - Nablus',
    rating: 3.9,
    reviews: 115,
    priceRange: '30-45 ₪',
    priceTier: 'medium',
    time: '15 دقيقة',
    aboutAr: 'يقدم مأكولات شرقية بلمسة عصرية وديكور أنيق يناسب السهرات.',
    aboutEn:
        'Serves Eastern cuisine with a modern twist in a stylish setting ideal for evenings out.',
    image: 'assets/images/restaurants/w_restaurant.jpg',
    placeholderIcon: Icons.restaurant,
    placeholderColor: Color(0xFFC9A227),
    phone: '+970 59 736 7788',
  ),
  RestaurantData(
    nameAr: '1948 Restaurant',
    nameEn: '1948 Restaurant',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.4,
    reviews: 66,
    priceRange: '30-45 ₪',
    priceTier: 'medium',
    time: '30 دقيقة',
    aboutAr: 'يجمع بين نكهات المطبخ الفلسطيني التقليدي وتقديم عصري مميز.',
    aboutEn:
        'Blends traditional Palestinian flavors with a distinctive modern presentation.',
    image: 'assets/images/restaurants/1948_restaurant.jpg',
    placeholderIcon: Icons.restaurant,
    placeholderColor: Color(0xFFB33A2E),
  ),
  RestaurantData(
    nameAr: 'Ward Restaurant & Café',
    nameEn: 'Ward Restaurant & Café',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr: 'شارع عمان - نابلس',
    locationEn: 'Amman St. - Nablus',
    rating: 4.3,
    reviews: 174,
    priceRange: '30-45 ₪',
    priceTier: 'medium',
    time: '30 دقيقة',
    aboutAr:
        'مطعم وكافيه بأجواء هادئة يجمع بين الأطباق الشرقية والمشروبات المختصة.',
    aboutEn:
        'A restaurant and café combining Eastern dishes with specialty drinks in a relaxed setting.',
    image: 'assets/images/restaurants/ward_restaurant_cafe.jpg',
    placeholderIcon: Icons.restaurant,
    placeholderColor: Color(0xFFE8A33D),
    phone: '+970 9 234 8573',
  ),
  RestaurantData(
    nameAr: 'Rexos Café & Restaurant',
    nameEn: 'Rexos Café & Restaurant',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr: 'شارع فيصل - نابلس',
    locationEn: 'Faisal St. - Nablus',
    rating: 4.2,
    reviews: 282,
    priceRange: '30-45 ₪',
    priceTier: 'medium',
    time: '10 دقيقة',
    aboutAr: 'يقدم قائمة متنوعة من الأطباق الشرقية والمشروبات في أجواء عصرية.',
    aboutEn:
        'Offers a diverse menu of Eastern dishes and drinks in a contemporary atmosphere.',
    image: 'assets/images/restaurants/food_spread_platters.jpg',
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
    aboutAr: 'كافيه عصري بديكور أنيق ومساحة مناسبة للعمل والاجتماعات.',
    aboutEn:
        'A modern café with stylish décor and a comfortable space for work and meetings.',
    image: 'assets/images/restaurants/pardo_cafe.jpg',
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
    aboutAr: 'تراس مفتوح وأجواء مريحة مع قائمة قهوة مختصة.',
    aboutEn:
        'An open-air terrace with a relaxed vibe and a specialty coffee menu.',
    image: 'assets/images/restaurants/veranda_lounge.jpg',
    placeholderIcon: Icons.coffee,
    placeholderColor: Color(0xFFB5651D),
    phone: '+970 9 235 5778',
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
    aboutAr: 'معروف بمشروباته المنعشة القائمة على الليمون والنعناع.',
    aboutEn: 'Known for its refreshing lemon-and-mint based drinks.',
    image: 'assets/images/restaurants/lemon_w_nana.jpg',
    placeholderIcon: Icons.coffee,
    placeholderColor: Color(0xFF8E5B3F),
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
    aboutAr: 'يقدم جيلاتو إيطالي طازج إلى جانب قائمة قهوة متنوعة.',
    aboutEn: 'Serves fresh Italian gelato alongside a varied coffee menu.',
    image: 'assets/images/restaurants/cedarz_gelato.jpg',
    placeholderIcon: Icons.coffee,
    placeholderColor: Color(0xFF6F4E37),
    phone: '+970 594 802 121',
  ),
  RestaurantData(
    nameAr: 'غلوريا جينز',
    nameEn: "Gloria Jean's Coffees",
    categoryAr: 'كافيه',
    categoryEn: 'Cafe',
    cuisineKey: 'cafe',
    locationAr: 'شارع جامعة النجاح - نابلس',
    locationEn: 'An-Najah University St. - Nablus',
    rating: 4.5,
    reviews: 160,
    priceRange: '20-35 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr: 'سلسلة عالمية للقهوة المختصة والعصائر الطازجة والمشروبات المثلجة.',
    aboutEn:
        'A global chain for specialty coffee, fresh juices, and iced drinks.',
    image: 'assets/images/restaurants/gloria_jeans.jpg',
    placeholderIcon: Icons.coffee,
    placeholderColor: Color(0xFFC9A227),
    phone: '+970 593 555 111',
  ),
  RestaurantData(
    nameAr: 'تري هاوس كافيه',
    nameEn: 'Tree House Cafe',
    categoryAr: 'كافيه',
    categoryEn: 'Cafe',
    cuisineKey: 'cafe',
    locationAr: 'شارع النصر - حارة الغرب - نابلس',
    locationEn: 'Al-Nasr St. - Harat Al-Gharb - Nablus',
    rating: 4.6,
    reviews: 120,
    priceRange: '15-25 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr: 'كافيه هادئ بديكور طبيعي دافئ يناسب الجلسات الطويلة.',
    aboutEn: 'A calm café with warm, natural décor perfect for long hangouts.',
    image: 'assets/images/restaurants/al_shajara.jpg',
    placeholderIcon: Icons.coffee,
    placeholderColor: Color(0xFF7A4B2A),
    phone: '+970 597 831 061',
  ),
  RestaurantData(
    nameAr: 'ع الطريق - فرع الدوار',
    nameEn: 'Aa Al-Tareeq - Dawar Branch',
    categoryAr: 'كافيه',
    categoryEn: 'Cafe',
    cuisineKey: 'cafe',
    locationAr: 'المجمع التجاري - الدوار - نابلس',
    locationEn: 'Commercial Complex - Al-Dawar - Nablus',
    rating: 4.4,
    reviews: 90,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr: 'كافيه شعبي بسيط قريب من الدوار يقدم القهوة والمشروبات اليومية.',
    aboutEn:
        'A simple neighborhood café near Al-Dawar serving coffee and daily drinks.',
    image: 'assets/images/restaurants/3altareeq_coffee.jpg',
    placeholderIcon: Icons.coffee,
    placeholderColor: Color(0xFF9C6644),
  ),
  RestaurantData(
    nameAr: 'الدجاج الملكي فرايزر - شارع فيصل',
    nameEn: 'Malaky Broast Chicken - Faisal St.',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'شارع فيصل - نابلس',
    locationEn: 'Faisal St. - Nablus',
    rating: 4.4,
    reviews: 110,
    priceRange: '15-30 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr: 'دجاج بروست مقرمش بوصفة خاصة وأطباق دجاج متنوعة.',
    aboutEn:
        'Crispy broast chicken with a signature recipe and varied chicken plates.',
    image: 'assets/images/restaurants/malaky_broast.jpg',
    placeholderIcon: Icons.fastfood,
    placeholderColor: Color(0xFFB5651D),
    phone: '+970 1700 250 250',
  ),
  RestaurantData(
    nameAr: 'الدجاج الملكي فرايزر - شارع سفيان',
    nameEn: 'Malaky Broast Chicken - Sufyan St.',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'شارع سفيان - نابلس',
    locationEn: 'Sufyan St. - Nablus',
    rating: 4.3,
    reviews: 95,
    priceRange: '15-30 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr: 'دجاج بروست مقرمش بوصفة خاصة وأطباق دجاج متنوعة.',
    aboutEn:
        'Crispy broast chicken with a signature recipe and varied chicken plates.',
    image: 'assets/images/restaurants/malaky_broast.jpg',
    placeholderIcon: Icons.fastfood,
    placeholderColor: Color(0xFF8E5B3F),
    phone: '+970 1700 250 250',
  ),
  RestaurantData(
    nameAr: 'شاورما الشاطر حسن',
    nameEn: 'Al-Shater Hasan Shawarma',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'شارع عسكر الرئيسي - نابلس',
    locationEn: 'Askar Main St. - Nablus',
    rating: 4.4,
    reviews: 100,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr: 'شاورما فلسطينية شعبية معروفة بنكهتها الأصيلة وزحمتها الدائمة.',
    aboutEn:
        'A popular Palestinian shawarma spot known for its authentic taste.',
    image: 'assets/images/restaurants/al_shater_hasan.jpg',
    placeholderIcon: Icons.kebab_dining,
    placeholderColor: Color(0xFFD4A017),
    phone: '+970 9 231 5222',
  ),
  RestaurantData(
    nameAr: 'بوبايز فلسطين - سيتي مول نابلس',
    nameEn: 'Popeyes Palestine - City Mall Nablus',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'سيتي مول - نابلس',
    locationEn: 'City Mall - Nablus',
    rating: 4.4,
    reviews: 105,
    priceRange: '20-35 ₪',
    priceTier: 'medium',
    time: '25 دقيقة',
    aboutAr: 'دجاج مقرمش بطريقة لويزيانا الأمريكية بنكهة حارة مميزة.',
    aboutEn:
        'Crispy Louisiana-style fried chicken with a spicy signature kick.',
    image: 'assets/images/restaurants/popeyes.jpg',
    placeholderIcon: Icons.fastfood,
    placeholderColor: Color(0xFFE8A33D),
    phone: '+970 1700 808 080',
  ),
  RestaurantData(
    nameAr: 'تريو شاورما',
    nameEn: 'Trio Shawerma',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'وسط نابلس',
    locationEn: 'Downtown Nablus',
    rating: 4.4,
    reviews: 165,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr: 'شاورما دجاج ولحمة بأطباق متنوعة وسندويشات مميزة.',
    aboutEn:
        'Chicken and beef shawarma with a variety of plates and sandwiches.',
    image: 'assets/images/restaurants/trio_shawarma.jpg',
    placeholderIcon: Icons.kebab_dining,
    placeholderColor: Color(0xFF8E5B3F),
    phone: '+970 9 236 7614',
  ),
  RestaurantData(
    nameAr: 'أورجادا برجرز',
    nameEn: 'Orgada Burgers',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'شارع عبد الرحيم محمود - نابلس',
    locationEn: 'Abdul Rahim Mahmoud St. - Nablus',
    rating: 4.5,
    reviews: 130,
    priceRange: '20-35 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr: 'برجر مشوي طازج بلحمة عالية الجودة وخبز منزلي.',
    aboutEn: 'Freshly grilled burgers with premium beef and homemade buns.',
    image: 'assets/images/restaurants/orgada_burgers.jpg',
    placeholderIcon: Icons.lunch_dining,
    placeholderColor: Color(0xFFC9A227),
    phone: '+972 9 235 7166',
  ),
  RestaurantData(
    nameAr: '90s Burger',
    nameEn: '90s Burger',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'رفيديا - طلعة بليبلة - نابلس',
    locationEn: 'Rafidia - Balibla Slope - Nablus',
    rating: 4.6,
    reviews: 145,
    priceRange: '20-35 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr: 'برجرات بطابع رجعي وأجواء شبابية مع صوصات مبتكرة.',
    aboutEn: 'Retro-themed burgers in a youthful vibe with creative sauces.',
    image: 'assets/images/restaurants/90s_burger_logo.jpg',
    placeholderIcon: Icons.lunch_dining,
    placeholderColor: Color(0xFFD4A017),
    phone: '+970 9 235 9090',
  ),
  RestaurantData(
    nameAr: 'هارت أتاك - جلطة',
    nameEn: 'Heart Attack - جلطة',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'رفيديا - بجانب المستشفى العربي التخصصي - نابلس',
    locationEn: 'Rafidia - next to Arab Specialized Hospital - Nablus',
    rating: 4.5,
    reviews: 175,
    priceRange: '20-40 ₪',
    priceTier: 'medium',
    time: '25 دقيقة',
    aboutAr: 'برجرات ضخمة محشوة بطبقات جبنة ولحمة لعشاق الوجبات الدسمة.',
    aboutEn:
        'Massive loaded burgers stacked with cheese and beef for hearty appetites.',
    image: 'assets/images/restaurants/jaltah_burger.jpg',
    placeholderIcon: Icons.lunch_dining,
    placeholderColor: Color(0xFF7A4B2A),
    phone: '+970 59 566 5960',
  ),
  RestaurantData(
    nameAr: 'بيتزا تايم',
    nameEn: 'Pizza TIME Restaurant',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'وسط مدينة نابلس',
    locationEn: 'Downtown Nablus',
    rating: 4.2,
    reviews: 88,
    priceRange: '20-35 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr: 'بيتزا وسندويشات سريعة بأسعار مناسبة للجميع.',
    aboutEn: 'Quick pizza and sandwiches at prices that suit everyone.',
    image: 'assets/images/restaurants/pizza_time.jpg',
    placeholderIcon: Icons.local_pizza,
    placeholderColor: Color(0xFFA85E2C),
    phone: '+970 9 234 3440',
  ),
  RestaurantData(
    nameAr: 'فريزدي',
    nameEn: 'Friesday',
    categoryAr: 'وجبات سريعة',
    categoryEn: 'Fast Food',
    cuisineKey: 'fastfood',
    locationAr: 'وسط نابلس',
    locationEn: 'Downtown Nablus',
    rating: 4.3,
    reviews: 96,
    priceRange: '15-25 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr: 'متخصص بالبطاطا المقرمشة بنكهات متعددة والوجبات الخفيفة.',
    aboutEn:
        'Specializes in crispy fries with multiple flavors and light bites.',
    image: 'assets/images/restaurants/friesday.jpg',
    placeholderIcon: Icons.fastfood,
    placeholderColor: Color(0xFFE8A33D),
    phone: '+970 595 687 077',
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
    aboutAr:
        'في قلب البلدة القديمة، يقدم الكنافة النابلسية الساخنة طازجة أولًا بأول.',
    aboutEn:
        'Located in the heart of the Old City, serving hot Nabulsi kunafa fresh off the tray.',
    image: 'assets/images/restaurants/sweets_kunafa.jpg',
    placeholderIcon: Icons.cake,
    placeholderColor: Color(0xFFA85E2C),
    phone: '+970 9 237 6412',
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
    aboutAr: 'من أقدم محلات الحلويات في نابلس، يشتهر بالكنافة والمفروكة.',
    aboutEn:
        "One of Nablus's oldest sweet shops, known for kunafa and mafrouka.",
    image: 'assets/images/restaurants/abu_seir_sweets.jpg',
    placeholderIcon: Icons.cake,
    placeholderColor: Color(0xFF8E5B3F),
  ),
  RestaurantData(
    nameAr: 'حلويات بوابة البيك - رفيديا',
    nameEn: 'Bawabat Al-Baik Sweets - Rafidia',
    categoryAr: 'حلويات',
    categoryEn: 'Sweets',
    cuisineKey: 'sweets',
    locationAr: 'رفيديا - بناية مرعي - نابلس',
    locationEn: 'Rafidia - Mar\'i Building - Nablus',
    rating: 4.5,
    reviews: 108,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr: 'يشتهر بالهريسة والحلويات الشرقية الطازجة المحضّرة يوميًا.',
    aboutEn:
        'Known for fresh harissa and traditional Eastern sweets made daily.',
    image: 'assets/images/restaurants/albaik_sweets.jpg',
    placeholderIcon: Icons.cake,
    placeholderColor: Color(0xFFC9A227),
    phone: '+970 9 238 4644',
  ),
  RestaurantData(
    nameAr: 'حلويات السرايا',
    nameEn: 'Al-Saraya Sweets',
    categoryAr: 'حلويات',
    categoryEn: 'Sweets',
    cuisineKey: 'sweets',
    locationAr: 'شارع رفيديا - نابلس',
    locationEn: 'Rafidia St. - Nablus',
    rating: 4.6,
    reviews: 132,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr: 'يشتهر بالقراقيش والحلويات الشرقية الفاخرة.',
    aboutEn: 'Known for karakesh and premium Eastern sweets.',
    image: 'assets/images/restaurants/karakesh_alsaraya.jpg',
    placeholderIcon: Icons.cake,
    placeholderColor: Color(0xFFB5651D),
    phone: '+970 9 259 1414',
  ),
  RestaurantData(
    nameAr: 'حلويات أبو صالحة',
    nameEn: 'Abu Saleh Sweets',
    categoryAr: 'حلويات',
    categoryEn: 'Sweets',
    cuisineKey: 'sweets',
    locationAr: 'رفيديا - نابلس',
    locationEn: 'Rafidia - Nablus',
    rating: 4.4,
    reviews: 85,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr: 'محل حلويات شعبي يقدم تشكيلة يومية من الحلويات الشرقية الطازجة.',
    aboutEn:
        'A neighborhood sweet shop offering a daily selection of fresh Eastern sweets.',
    image: 'assets/images/restaurants/abu_salha_sweets.jpg',
    placeholderIcon: Icons.cake,
    placeholderColor: Color(0xFF7A4B2A),
    phone: '+970 9 234 1561',
  ),
  RestaurantData(
    nameAr: 'حلويات أبو صالحة - فرع الدوار',
    nameEn: 'Abu Saleh Sweets - Al-Dawar Branch',
    categoryAr: 'حلويات',
    categoryEn: 'Sweets',
    cuisineKey: 'sweets',
    locationAr: 'دوار الحسين - مجمع نابلس التجاري - وسط البلد - نابلس',
    locationEn:
        'Al-Hussein Circle - Nablus Commercial Complex - Downtown - Nablus',
    rating: 4.3,
    reviews: 70,
    priceRange: '10-20 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr:
        'فرع الدوار لمحل أبو صالحة، يقدم نفس التشكيلة الشعبية من الحلويات.',
    aboutEn:
        'The Al-Dawar branch of Abu Saleh, offering the same popular sweets selection.',
    image: 'assets/images/restaurants/abu_salha_sweets.jpg',
    placeholderIcon: Icons.cake,
    placeholderColor: Color(0xFF9C6644),
    phone: '+970 9 238 2325',
  ),
  RestaurantData(
    nameAr: 'بيتزا إن فلسطين',
    nameEn: 'Pizza Inn Palestine',
    categoryAr: 'إيطالي',
    categoryEn: 'Italian',
    cuisineKey: 'italian',
    locationAr: 'رفيديا - مقابل جامعة النجاح الوطنية - نابلس',
    locationEn: 'Rafidia - opposite An-Najah National University - Nablus',
    rating: 4.4,
    reviews: 190,
    priceRange: '25-40 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr: 'يقدم بيتزا وباستا وأطباق إيطالية متنوعة.',
    aboutEn: 'Serves pizza, pasta, and a variety of Italian dishes.',
    image: 'assets/images/restaurants/pizza_inn.jpg',
    placeholderIcon: Icons.local_pizza,
    placeholderColor: Color(0xFFD4A017),
    phone: '+970 9 235 6936',
  ),
  RestaurantData(
    nameAr: 'Mono Pizza',
    nameEn: 'Mono Pizza',
    categoryAr: 'إيطالي',
    categoryEn: 'Italian',
    cuisineKey: 'italian',
    locationAr: 'وسط مدينة نابلس',
    locationEn: 'Downtown Nablus',
    rating: 4.3,
    reviews: 150,
    priceRange: '25-40 ₪',
    priceTier: 'medium',
    time: '15 دقيقة',
    aboutAr: 'متخصص بالبيتزا الإيطالية مع تشكيلة من المقبلات.',
    aboutEn: 'Specializes in Italian pizza with a selection of appetizers.',
    image: 'assets/images/restaurants/mono_pizza.jpg',
    placeholderIcon: Icons.local_pizza,
    placeholderColor: Color(0xFF6F4E37),
    phone: '+970 9 235 5655',
  ),
  RestaurantData(
    nameAr: 'بيتزا هاوس',
    nameEn: 'Pizza House',
    categoryAr: 'إيطالي',
    categoryEn: 'Italian',
    cuisineKey: 'italian',
    locationAr:
        'رفيديا - شارع الجامعة القديم - بالقرب من فندق القصر، بجانب مخابز أيام زمان - نابلس',
    locationEn:
        'Rafidia - Old University St. - near Al-Qasr Hotel, next to Ayyam Zaman Bakery - Nablus',
    rating: 4.5,
    reviews: 120,
    priceRange: '20-35 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr: 'بيتزا طازجة بعجينة بيتية وتشكيلة نكهات متنوعة.',
    aboutEn: 'Fresh pizza with homemade dough and a variety of flavors.',
    image: 'assets/images/restaurants/pizza_house.jpg',
    placeholderIcon: Icons.local_pizza,
    placeholderColor: Color(0xFFC9A227),
    phone: '+970 9 235 2121',
  ),
  RestaurantData(
    nameAr: 'بيتزا تايم',
    nameEn: 'Pizza TIME',
    categoryAr: 'إيطالي',
    categoryEn: 'Italian',
    cuisineKey: 'italian',
    locationAr: 'رفيديا - شارع عبد الرحيم محمود - قرب جامعة النجاح - نابلس',
    locationEn:
        'Rafidia - Abdul Rahim Mahmoud St. - near An-Najah University - Nablus',
    rating: 4.3,
    reviews: 95,
    priceRange: '20-35 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr: 'بيتزا وأطباق إيطالية بأسعار مناسبة للجميع.',
    aboutEn: 'Pizza and Italian dishes at prices that suit everyone.',
    image: 'assets/images/restaurants/pizza_time.jpg',
    placeholderIcon: Icons.local_pizza,
    placeholderColor: Color(0xFFB33A2E),
    phone: '+970 1700 202 020',
  ),
  RestaurantData(
    nameAr: 'مطبخ العمدة',
    nameEn: 'Matbakh Al-Omda Restaurant',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr: 'منطقة المخفية - بعد عيادة الصحة بـ 100 متر - نابلس',
    locationEn: 'Al-Makhfiya Area - 100m past the health clinic - Nablus',
    rating: 4.6,
    reviews: 90,
    priceRange: '30-50 ₪',
    priceTier: 'medium',
    time: '25 دقيقة',
    aboutAr:
        'يشتهر بتقديم الأكلات الشعبية الفلسطينية والمناسف الأصيلة بنكهة بيتية مميزة.',
    aboutEn:
        'Known for serving authentic Palestinian traditional dishes and Mansaf with a distinctive homemade flavor.',
    image: 'assets/images/restaurants/al_omda_kitchen.jpg',
    placeholderIcon: Icons.dinner_dining,
    placeholderColor: Color(0xFFA0522D),
  ),
  RestaurantData(
    nameAr: 'مطعم وفرن الخليلي',
    nameEn: 'Al-Khalili Restaurant & Bakery',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr:
        'البلدة القديمة - بجانب الجامع الصلاحي الكبير، مقابل جاتوه فرح - نابلس',
    locationEn:
        'Old City - next to Al-Salahi Grand Mosque, opposite Gateau Farah - Nablus',
    rating: 4.7,
    reviews: 134,
    priceRange: '20-40 ₪',
    priceTier: 'medium',
    time: '20 دقيقة',
    aboutAr:
        'يقدم أشهى الأكلات الشعبية البلدية والمشاوي وفطور الصباح الطازج يوميًا.',
    aboutEn:
        'Serves delicious traditional local dishes, grills, and fresh daily breakfast.',
    image: 'assets/images/restaurants/al_khalili_pizza.jpg',
    placeholderIcon: Icons.outdoor_grill,
    placeholderColor: Color(0xFF8B5E3C),
  ),
  RestaurantData(
    nameAr: 'مطعم فتة وعجة',
    nameEn: 'Fatteh & Ijjeh Restaurant',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr:
        'شارع فيصل - مقابل مستوصف الرحمة، بجانب مخبز أبو صالحية - نابلس',
    locationEn:
        'Faisal St. - opposite Al-Rahma Clinic, next to Abu Salahiya Bakery - Nablus',
    rating: 4.5,
    reviews: 112,
    priceRange: '10-25 ₪',
    priceTier: 'cheap',
    time: '15 دقيقة',
    aboutAr:
        'متخصص في الفطور الشعبي كالحمص والفول والفلافل وأنواع الفتة الشهية.',
    aboutEn:
        'Specializes in traditional breakfast dishes like hummus, fava beans, falafel, and various fatteh.',
    image: 'assets/images/restaurants/vegetable_kebba_platter.jpg',
    placeholderIcon: Icons.free_breakfast,
    placeholderColor: Color(0xFF6B4226),
  ),
  RestaurantData(
    nameAr: 'مطعم كان ياما كان',
    nameEn: 'Kan Yama Kan Restaurant',
    categoryAr: 'مأكولات شعبية',
    categoryEn: 'Traditional Food',
    cuisineKey: 'traditional',
    locationAr: 'شارع رفيديا - نابلس',
    locationEn: 'Rafidia St. - Nablus',
    rating: 4.5,
    reviews: 98,
    priceRange: '25-45 ₪',
    priceTier: 'medium',
    time: '25 دقيقة',
    aboutAr: 'يقدم أطباقًا شهية من المأكولات الشعبية والشرقية بلمسة تقليدية.',
    aboutEn:
        'Offers delicious traditional and Eastern dishes with an authentic touch.',
    image: 'assets/images/restaurants/kan_ya_ma_kan.jpg',
    placeholderIcon: Icons.restaurant_menu,
    placeholderColor: Color(0xFFB5651D),
  ),
];

// ترتيب الأقسام الافتراضي لتجميع المطاعم في القائمة (نفس ترتيب فلتر نوع الطعام بالشريط الجانبي)
const List<String> cuisineOrder = [
  'traditional',
  'cafe',
  'fastfood',
  'sweets',
  'italian',
];

const Map<String, (String, String)> cuisineCategoryLabels = {
  'traditional': ('مأكولات شعبية', 'Traditional Food'),
  'cafe': ('كافيهات', 'Cafes'),
  'fastfood': ('وجبات سريعة', 'Fast Food'),
  'sweets': ('حلويات', 'Sweets'),
  'italian': ('إيطالي', 'Italian'),
};

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
      serverImageUrl: data.serverImageUrl,
      localAsset: data.image,
    );
  }
}

// ==================== الشاشة الرئيسية لصفحة المطاعم ====================
class RestaurantsScreen extends StatefulWidget {
  // قسم مبدئي (نوع طعام) نجي إله من كرت القسم بشاشة RestaurantCategoriesScreen
  // إذا كانت null بتظهر كل المطاعم مجمّعة زي المعتاد.
  final String? initialCuisine;
  const RestaurantsScreen({super.key, this.initialCuisine});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  int selectedIndex = 0;
  bool isGridView = true;
  int currentPage = 0;
  // أكبر من عدد المطاعم الكلي حتى تظهر كل الأقسام مجمّعة بصفحة واحدة بدل تقطيعها بالترقيم
  static const int perPage = 100;

  bool _loaded = false;
  List<RestaurantData> _liveRestaurants = [];
  List<dynamic> _keys = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCuisine != null) {
      selectedCuisines = {widget.initialCuisine!};
    }
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
      'restaurants',
      restaurantsSeedData.map(restaurantToMap).toList(),
    );
    await ApiService.syncRestaurants();
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
      final categoryCompare = cuisineOrder
          .indexOf(a.cuisineKey)
          .compareTo(cuisineOrder.indexOf(b.cuisineKey));
      if (categoryCompare != 0) return categoryCompare;
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
          serverImageUrl: r.serverImageUrl,
          localAsset: r.image,
          phone: r.phone,
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
            body: KeyboardScrollable(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
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
                                      selectedIndex = filteredList.indexOf(
                                        data,
                                      );
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
                                                .toggleFavorite(
                                                  selected.nameEn,
                                                );
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
          ),
        );
      },
    );
  }
}

// ==================== شاشة اختيار قسم المطاعم (كروت الأقسام) ====================
// أول شاشة تظهر لما تفتح "المطاعم": كرت لكل نوع طعام، وبالضغط عليه بتفتح
// قائمة مطاعم ذلك القسم فقط (RestaurantsScreen مع initialCuisine محدد).
class RestaurantCategoriesScreen extends StatefulWidget {
  const RestaurantCategoriesScreen({super.key});

  @override
  State<RestaurantCategoriesScreen> createState() =>
      _RestaurantCategoriesScreenState();
}

class _RestaurantCategoriesScreenState
    extends State<RestaurantCategoriesScreen> {
  bool _loaded = false;
  List<RestaurantData> _liveRestaurants = [];
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
      'restaurants',
      restaurantsSeedData.map(restaurantToMap).toList(),
    );
    await ApiService.syncRestaurants();
    final entries = db.getAll('restaurants');
    setState(() {
      _liveRestaurants = entries.map((e) => mapToRestaurant(e.value)).toList();
      _loaded = true;
    });
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
                    _TopNav(onComingSoon: _showComingSoon),
                    _Banner(),
                    Padding(
                      padding: EdgeInsets.all(isMobile(context) ? 16 : 24),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: cuisineOrder.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: responsiveGridColumns(
                            context,
                            wide: 3,
                            narrow: 2,
                          ),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.15,
                        ),
                        itemBuilder: (context, i) {
                          final key = cuisineOrder[i];
                          final count = _liveRestaurants
                              .where((r) => r.cuisineKey == key)
                              .length;
                          return _CuisineCategoryCard(
                            cuisineKey: key,
                            count: count,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    RestaurantsScreen(initialCuisine: key),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _FeaturesFooter(),
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

const Map<String, IconData> _cuisineCategoryIcons = {
  'traditional': Icons.dinner_dining,
  'cafe': Icons.coffee,
  'fastfood': Icons.fastfood,
  'sweets': Icons.cake,
  'italian': Icons.local_pizza,
};

const Map<String, Color> _cuisineCategoryColors = {
  'traditional': Color(0xFFB5651D),
  'cafe': Color(0xFF6F4E37),
  'fastfood': Color(0xFFD4A017),
  'sweets': Color(0xFFC9A227),
  'italian': Color(0xFFB33A2E),
};

// صور حقيقية لكروت الأقسام (اختيارية) - إذا ما في صورة لقسم معيّن بيرجع لتصميم
// الأيقونة الافتراضي.
const Map<String, String> _cuisineCategoryImages = {
  'traditional': 'assets/images/restaurants/traditional_food.jpg',
  'italian': 'assets/images/restaurants/italian_food.jpg',
  'cafe': 'assets/images/restaurants/cafe_interior.jpg',
  'sweets': 'assets/images/restaurants/sweets_kunafa.jpg',
  'fastfood': 'assets/images/restaurants/fastfood_shawarma.jpg',
};

class _CuisineCategoryCard extends StatelessWidget {
  final String cuisineKey;
  final int count;
  final VoidCallback onTap;
  const _CuisineCategoryCard({
    required this.cuisineKey,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final label = cuisineCategoryLabels[cuisineKey];
    final title = label == null ? '' : app.t(label.$1, label.$2);
    final image = _cuisineCategoryImages[cuisineKey];

    if (image != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppColors.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(image, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.start,
                      textDirection: app.dir,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      app.t('$count مطعم', '$count places'),
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final icon = _cuisineCategoryIcons[cuisineKey] ?? Icons.restaurant;
    final color = _cuisineCategoryColors[cuisineKey] ?? AppColors.primary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.sidebarDark,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderColor),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              textDirection: app.dir,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              app.t('$count مطعم', '$count places'),
              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
          ],
        ),
      ),
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
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => HotelsScreen()));
      }),
      _navItem(context, app.t('الأماكن السياحية', 'Attractions'), false, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AttractionCategoriesScreen()),
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
          AppToggleBar(),
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
          GestureDetector(
            onTap: () => showImageZoom(
              context,
              query: 'restaurant food table Nablus',
              fallbackSeed: 'nablus-restaurants-banner',
              fallbackIcon: Icons.restaurant,
            ),
            child: ThemedImage(
              query: 'restaurant food table Nablus',
              fallbackSeed: 'nablus-restaurants-banner',
              height: 200,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  app.t('المطاعم في نابلس', 'Restaurants in Nablus'),
                  textDirection: app.dir,
                  style: AppTypography.display(
                    Colors.white,
                  ).copyWith(fontSize: 28),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 40, height: 1, color: AppColors.gold),
                    SizedBox(width: 8),
                    Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.gold,
                      size: 16,
                    ),
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
                style: AppTypography.title(
                  AppColors.textWhite,
                ).copyWith(fontSize: 14),
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
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _groupByCuisine(items)
                .map(
                  (group) => Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CategorySectionHeader(cuisineKey: group.key),
                        SizedBox(height: 12),
                        if (isGridView)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: group.value.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                              final r = group.value[i];
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => onSelect(r),
                                child: _RestaurantCard(
                                  data: r,
                                  isFavorite: FavoritesService.instance
                                      .isFavorite(r.nameEn),
                                  isSelected: r == selectedData,
                                  onFavorite: () => onFavorite(r),
                                ),
                              );
                            },
                          )
                        else
                          Column(
                            children: group.value
                                .map(
                                  (r) => Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => onSelect(r),
                                      child: _RestaurantListTile(
                                        data: r,
                                        isFavorite: FavoritesService.instance
                                            .isFavorite(r.nameEn),
                                        isSelected: r == selectedData,
                                        onFavorite: () => onFavorite(r),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        if (pageCount > 1) ...[
          SizedBox(height: 20),
          _Pagination(
            currentPage: currentPage,
            pageCount: pageCount,
            onPageChange: onPageChange,
          ),
        ],
      ],
    );
  }
}

// تجميع المطاعم حسب القسم (نوع الطعام) مع الحفاظ على الترتيب الوارد
// (القائمة مرتّبة مسبقًا حسب القسم في _RestaurantsScreenState._filtered لذا
// المطاعم من نفس القسم متتالية دائمًا).
List<MapEntry<String, List<RestaurantData>>> _groupByCuisine(
  List<RestaurantData> items,
) {
  final groups = <MapEntry<String, List<RestaurantData>>>[];
  for (final r in items) {
    if (groups.isNotEmpty && groups.last.key == r.cuisineKey) {
      groups.last.value.add(r);
    } else {
      groups.add(MapEntry(r.cuisineKey, [r]));
    }
  }
  return groups;
}

class _CategorySectionHeader extends StatelessWidget {
  final String cuisineKey;
  const _CategorySectionHeader({required this.cuisineKey});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final label = cuisineCategoryLabels[cuisineKey];
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label == null ? '' : app.t(label.$1, label.$2),
          textDirection: app.dir,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
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
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _RestaurantImage(
                  data: data,
                  height: double.infinity,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
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
          SizedBox(
            width: 70,
            height: 70,
            child: _RestaurantImage(
              data: data,
              height: 70,
              borderRadius: BorderRadius.circular(AppRadius.sm),
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
              GestureDetector(
                onTap: () => showImageZoom(
                  context,
                  query: restaurantPhotoQuery(r),
                  fallbackSeed: r.nameEn,
                  fallbackIcon: r.placeholderIcon,
                  fallbackColor: r.placeholderColor,
                  customImageBase64: r.customImageBase64,
                  serverImageUrl: r.serverImageUrl,
                  localAsset: r.image,
                ),
                child: _RestaurantImage(data: r, height: 170),
              ),
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
                      () => r.phone.isEmpty
                          ? onShowSnack(app.t('الاتصال', 'Call'))
                          : launchUrl(Uri.parse('tel:${r.phone}')),
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
                          lat: r.lat,
                          lng: r.lng,
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
                      () => Share.share(
                        '${app.isArabic ? r.nameAr : r.nameEn} '
                        '(${r.rating}⭐) — ${app.isArabic ? r.locationAr : r.locationEn}',
                      ),
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
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
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
                          lat: r.lat,
                          lng: r.lng,
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
                      icon: Icon(
                        Icons.map_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        app.t('عرض على الخريطة', 'Show on Map'),
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
            Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.textGrey,
              size: 28,
            ),
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
                        gradient: LinearGradient(
                          colors: AppColors.primaryGradient,
                        ),
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
