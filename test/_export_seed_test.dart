import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:nablus_smart_city_guide/screens/restaurants/restaurants_screen.dart';
import 'package:nablus_smart_city_guide/screens/hotels/hotels_screen.dart';
import 'package:nablus_smart_city_guide/screens/pharmacies/pharmacies_screen.dart';
import 'package:nablus_smart_city_guide/screens/attractions/attractions_screen.dart';
import 'package:nablus_smart_city_guide/screens/shopping/shopping_screen.dart';
import 'package:nablus_smart_city_guide/services/data_converters.dart';

/// أداة تصدير بيانات التطبيق الحقيقية (مطاعم/فنادق/صيدليات/معالم/تسوق) لملف JSON
/// يستخدمه سيرفر الباك اند (backend/prisma/seed.js) لتعبئة قاعدة البيانات الحقيقية
/// بنفس البيانات الشغالة فعليًا بالتطبيق. شغّليها بعد أي تعديل على بيانات التطبيق:
///   flutter test test/_export_seed_test.dart
/// وبعدين انسخي الملف الناتج seed_export.json إلى backend/prisma/seed_data.json
void main() {
  test('export seed data to json', () {
    final out = {
      'restaurants': restaurantsSeedData.map(restaurantToMap).toList(),
      'hotels': hotelsSeedData.map(hotelToMap).toList(),
      'pharmacies': pharmaciesSeedData.map(pharmacyToMap).toList(),
      'attractions': attractionsSeedData.map(attractionToMap).toList(),
      'shoppingVenues': shoppingVenuesSeedData.map(shoppingVenueToMap).toList(),
    };
    File('seed_export.json').writeAsStringSync(JsonEncoder.withIndent('  ').convert(out));
  });
}
