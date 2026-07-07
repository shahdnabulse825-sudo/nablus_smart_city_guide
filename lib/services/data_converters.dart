import 'package:flutter/material.dart';
import '../screens/restaurants/restaurants_screen.dart' show RestaurantData;
import '../screens/category/category_data.dart' show ListingItem;
import '../screens/news/news_screen.dart' show NewsArticle;

// ==================== المطاعم ====================
Map<String, dynamic> restaurantToMap(RestaurantData r) => {
      'nameAr': r.nameAr,
      'nameEn': r.nameEn,
      'categoryAr': r.categoryAr,
      'categoryEn': r.categoryEn,
      'cuisineKey': r.cuisineKey,
      'locationAr': r.locationAr,
      'locationEn': r.locationEn,
      'rating': r.rating,
      'reviews': r.reviews,
      'priceRange': r.priceRange,
      'priceTier': r.priceTier,
      'time': r.time,
      'aboutAr': r.aboutAr,
      'aboutEn': r.aboutEn,
      'image': r.image,
      'iconCodePoint': r.placeholderIcon.codePoint,
      'colorValue': r.placeholderColor.value,
    };

RestaurantData mapToRestaurant(Map<String, dynamic> m) => RestaurantData(
      nameAr: m['nameAr'] ?? '',
      nameEn: m['nameEn'] ?? '',
      categoryAr: m['categoryAr'] ?? '',
      categoryEn: m['categoryEn'] ?? '',
      cuisineKey: m['cuisineKey'] ?? 'traditional',
      locationAr: m['locationAr'] ?? '',
      locationEn: m['locationEn'] ?? '',
      rating: (m['rating'] as num?)?.toDouble() ?? 4.0,
      reviews: (m['reviews'] as num?)?.toInt() ?? 0,
      priceRange: m['priceRange'] ?? '',
      priceTier: m['priceTier'] ?? 'medium',
      time: m['time'] ?? '',
      aboutAr: m['aboutAr'] ?? '',
      aboutEn: m['aboutEn'] ?? '',
      image: m['image'] ?? 'assets/images/restaurants/custom.jpg',
      placeholderIcon: IconData(m['iconCodePoint'] ?? Icons.restaurant.codePoint,
          fontFamily: 'MaterialIcons'),
      placeholderColor: Color(m['colorValue'] ?? 0xFF6C5CE7),
    );

// ==================== العناصر العامة (فنادق/سياحة/تسوق/مواصلات/صحة/صيدليات) ====================
Map<String, dynamic> listingToMap(ListingItem it) => {
      'nameAr': it.nameAr,
      'nameEn': it.nameEn,
      'typeAr': it.typeAr,
      'typeEn': it.typeEn,
      'locationAr': it.locationAr,
      'locationEn': it.locationEn,
      'rating': it.rating,
      'reviews': it.reviews,
      'infoLabelAr': it.infoLabelAr,
      'infoLabelEn': it.infoLabelEn,
      'aboutAr': it.aboutAr,
      'aboutEn': it.aboutEn,
      'phone': it.phone,
      'photoQuery': it.photoQuery,
      'iconCodePoint': it.placeholderIcon.codePoint,
      'colorValue': it.placeholderColor.value,
    };

ListingItem mapToListing(Map<String, dynamic> m) => ListingItem(
      nameAr: m['nameAr'] ?? '',
      nameEn: m['nameEn'] ?? '',
      typeAr: m['typeAr'] ?? '',
      typeEn: m['typeEn'] ?? '',
      locationAr: m['locationAr'] ?? '',
      locationEn: m['locationEn'] ?? '',
      rating: (m['rating'] as num?)?.toDouble() ?? 4.0,
      reviews: (m['reviews'] as num?)?.toInt() ?? 0,
      infoLabelAr: m['infoLabelAr'] ?? '',
      infoLabelEn: m['infoLabelEn'] ?? '',
      aboutAr: m['aboutAr'] ?? '',
      aboutEn: m['aboutEn'] ?? '',
      phone: m['phone'] ?? '+970 59 000 0000',
      photoQuery: m['photoQuery'] ?? 'nablus palestine city',
      placeholderIcon: IconData(m['iconCodePoint'] ?? Icons.place.codePoint,
          fontFamily: 'MaterialIcons'),
      placeholderColor: Color(m['colorValue'] ?? 0xFF3B82F6),
    );

// ==================== الأخبار ====================
Map<String, dynamic> newsToMap(NewsArticle a) => {
      'titleAr': a.titleAr,
      'titleEn': a.titleEn,
      'dateAr': a.dateAr,
      'dateEn': a.dateEn,
      'categoryAr': a.categoryAr,
      'categoryEn': a.categoryEn,
      'categoryKey': a.categoryKey,
      'summaryAr': a.summaryAr,
      'summaryEn': a.summaryEn,
      'bodyAr': a.bodyAr,
      'bodyEn': a.bodyEn,
      'image': a.image,
    };

NewsArticle mapToNews(Map<String, dynamic> m) => NewsArticle(
      titleAr: m['titleAr'] ?? '',
      titleEn: m['titleEn'] ?? '',
      dateAr: m['dateAr'] ?? '',
      dateEn: m['dateEn'] ?? '',
      categoryAr: m['categoryAr'] ?? '',
      categoryEn: m['categoryEn'] ?? '',
      categoryKey: m['categoryKey'] ?? 'events',
      summaryAr: m['summaryAr'] ?? '',
      summaryEn: m['summaryEn'] ?? '',
      bodyAr: m['bodyAr'] ?? '',
      bodyEn: m['bodyEn'] ?? '',
      image: m['image'] ?? '',
    );