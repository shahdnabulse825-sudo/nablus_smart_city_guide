require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

const PLACE_ICON = 0xe55f; // Icons.place
const RESTAURANT_ICON = 0xe56c; // Icons.restaurant

// ==================== الفنادق ====================
const hotels = [
  { nameAr: 'فندق قصر نابلس', nameEn: 'Nablus Palace Hotel', typeAr: 'فندق 4 نجوم', typeEn: '4-Star Hotel', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.5, reviews: 180, infoLabelAr: '180-250 ₪ / ليلة', infoLabelEn: '180-250 ₪ / night', aboutAr: 'فندق راقٍ بإطلالة على المدينة، يضم غرف مريحة ومطعم داخلي وخدمة استقبال على مدار الساعة.', aboutEn: 'An elegant hotel with a city view, comfortable rooms, an in-house restaurant, and 24-hour front desk service.', photoQuery: 'hotel exterior building', colorValue: 0xff6c5ce7 },
  { nameAr: 'فندق نابلس الدولي', nameEn: 'Nablus International Hotel', typeAr: 'فندق 3 نجوم', typeEn: '3-Star Hotel', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.2, reviews: 120, infoLabelAr: '120-180 ₪ / ليلة', infoLabelEn: '120-180 ₪ / night', aboutAr: 'فندق اقتصادي بموقع مركزي قريب من الأسواق والمعالم السياحية الرئيسية.', aboutEn: 'A budget-friendly hotel in a central location near the main markets and tourist attractions.', photoQuery: 'hotel lobby', colorValue: 0xff4c6ef5 },
  { nameAr: 'شقق الرابية المفروشة', nameEn: 'Al-Rabya Furnished Apartments', typeAr: 'شقق فندقية', typeEn: 'Serviced Apartments', locationAr: 'منطقة الرابية - نابلس', locationEn: 'Al-Rabya Area - Nablus', rating: 4.4, reviews: 95, infoLabelAr: '150-220 ₪ / ليلة', infoLabelEn: '150-220 ₪ / night', aboutAr: 'شقق مفروشة بالكامل مناسبة للإقامات الطويلة والعائلات، مع مطبخ خاص وموقف سيارات.', aboutEn: 'Fully furnished apartments suitable for long stays and families, with a private kitchen and parking.', photoQuery: 'furnished apartment interior', colorValue: 0xff22c55e },
  { nameAr: 'نزل البلدة القديمة', nameEn: 'Old City Guesthouse', typeAr: 'نزل تراثي', typeEn: 'Heritage Guesthouse', locationAr: 'البلدة القديمة - نابلس', locationEn: 'Old City - Nablus', rating: 4.7, reviews: 140, infoLabelAr: '100-160 ₪ / ليلة', infoLabelEn: '100-160 ₪ / night', aboutAr: 'إقامة فريدة داخل بيت تراثي مرمم بالبلدة القديمة، تجربة أصيلة وسط أزقة نابلس التاريخية.', aboutEn: 'A unique stay inside a restored heritage house in the Old City, an authentic experience among Nablus historic alleys.', photoQuery: 'traditional guesthouse interior', colorValue: 0xffc9a227 },
];

// ==================== سياحة ومعالم ====================
const attractions = [
  { nameAr: 'البلدة القديمة', nameEn: 'Old City', typeAr: 'معلم تاريخي', typeEn: 'Historic Landmark', locationAr: 'وسط نابلس', locationEn: 'Central Nablus', rating: 4.8, reviews: 520, infoLabelAr: 'دخول مجاني', infoLabelEn: 'Free entry', aboutAr: 'قلب نابلس التاريخي، أزقة ضيقة وأسواق تراثية وعمارة عثمانية ومملوكية عريقة.', aboutEn: 'The historic heart of Nablus, with narrow alleys, heritage markets, and ancient Ottoman and Mamluk architecture.', photoQuery: 'old town stone alley', colorValue: 0xffc9a227 },
  { nameAr: 'جبل جرزيم', nameEn: 'Mount Gerizim', typeAr: 'معلم طبيعي وديني', typeEn: 'Natural & Religious Landmark', locationAr: 'جنوب نابلس', locationEn: 'South Nablus', rating: 4.7, reviews: 310, infoLabelAr: 'دخول مجاني', infoLabelEn: 'Free entry', aboutAr: 'جبل مقدس عند السامريين، يوفر إطلالة بانورامية رائعة على مدينة نابلس بالكامل.', aboutEn: 'A mountain sacred to the Samaritans, offering a stunning panoramic view over the entire city of Nablus.', photoQuery: 'mountain landscape', colorValue: 0xff4c8c4a },
  { nameAr: 'خان الوكالة', nameEn: 'Khan Al-Wakala', typeAr: 'معلم تاريخي', typeEn: 'Historic Landmark', locationAr: 'البلدة القديمة - نابلس', locationEn: 'Old City - Nablus', rating: 4.6, reviews: 210, infoLabelAr: 'دخول مجاني', infoLabelEn: 'Free entry', aboutAr: 'خان تاريخي كان محطة رئيسية للقوافل التجارية، يعكس عراقة نابلس التجارية القديمة.', aboutEn: 'A historic caravanserai that was a major stop for trade caravans, reflecting the ancient commercial legacy of Nablus.', photoQuery: 'historic market caravanserai', colorValue: 0xff9c6b30 },
  { nameAr: 'جامع الساطون', nameEn: 'Al-Satoun Mosque', typeAr: 'معلم ديني', typeEn: 'Religious Landmark', locationAr: 'البلدة القديمة - نابلس', locationEn: 'Old City - Nablus', rating: 4.7, reviews: 180, infoLabelAr: 'دخول مجاني', infoLabelEn: 'Free entry', aboutAr: 'أحد أقدم وأجمل المساجد التاريخية بنابلس، بعمارة إسلامية أصيلة.', aboutEn: 'One of the oldest and most beautiful historic mosques in Nablus, with authentic Islamic architecture.', photoQuery: 'mosque islamic architecture', colorValue: 0xffb5651d },
  { nameAr: 'حديقة التعاون', nameEn: 'Al-Taawon Park', typeAr: 'حديقة عامة', typeEn: 'Public Park', locationAr: 'شرق نابلس', locationEn: 'East Nablus', rating: 4.4, reviews: 260, infoLabelAr: 'دخول مجاني', infoLabelEn: 'Free entry', aboutAr: 'حديقة عامة واسعة مناسبة للعائلات، فيها مساحات خضراء وألعاب أطفال ومسارات مشي.', aboutEn: "A large public park suitable for families, with green spaces, children's play areas, and walking trails.", photoQuery: 'public park garden', colorValue: 0xff22c55e },
];

// ==================== التسوق ====================
const shopping = [
  { nameAr: 'مركز نابلس مول', nameEn: 'Nablus Mall', typeAr: 'مركز تسوق', typeEn: 'Shopping Mall', locationAr: 'شارع رفيديا - نابلس', locationEn: 'Rafidia St. - Nablus', rating: 4.4, reviews: 340, infoLabelAr: 'يفتح 10ص - 10م', infoLabelEn: 'Open 10AM - 10PM', aboutAr: 'أكبر مركز تسوق بالمدينة يضم محلات أزياء عالمية ومحلية، مطاعم، وصالة ألعاب للأطفال.', aboutEn: "The largest shopping mall in the city, featuring international and local fashion stores, restaurants, and a kids' game arcade.", photoQuery: 'shopping mall interior', colorValue: 0xff3b82f6 },
  { nameAr: 'سوق البلدة القديمة', nameEn: 'Old City Market', typeAr: 'سوق تقليدي', typeEn: 'Traditional Market', locationAr: 'البلدة القديمة - نابلس', locationEn: 'Old City - Nablus', rating: 4.7, reviews: 410, infoLabelAr: 'يفتح 9ص - 8م', infoLabelEn: 'Open 9AM - 8PM', aboutAr: 'سوق شعبي عريق يبيع التوابل والحلويات النابلسية والمنتجات التقليدية اليدوية.', aboutEn: 'A historic traditional market selling spices, Nabulsi sweets, and traditional handmade products.', photoQuery: 'traditional market bazaar', colorValue: 0xffb5651d },
  { nameAr: 'مجمع رفيديا التجاري', nameEn: 'Rafidia Commercial Complex', typeAr: 'مجمع تجاري', typeEn: 'Commercial Complex', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.3, reviews: 190, infoLabelAr: 'يفتح 9ص - 9م', infoLabelEn: 'Open 9AM - 9PM', aboutAr: 'مجمع تجاري حديث يضم محلات إلكترونيات، ملابس، وأجهزة منزلية.', aboutEn: 'A modern commercial complex featuring electronics, clothing, and home appliance stores.', photoQuery: 'shopping center storefront', colorValue: 0xffd4a017 },
];

// ==================== المواصلات ====================
const transport = [
  { nameAr: 'محطة الباصات المركزية', nameEn: 'Central Bus Station', typeAr: 'محطة باصات', typeEn: 'Bus Station', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.1, reviews: 150, infoLabelAr: 'يعمل 6ص - 10م', infoLabelEn: 'Operates 6AM - 10PM', aboutAr: 'المحطة الرئيسية للباصات الرابطة بين نابلس والمدن المجاورة.', aboutEn: 'The main bus station connecting Nablus with neighboring cities.', photoQuery: 'bus station', colorValue: 0xff14b8a6 },
  { nameAr: 'موقف سرفيس دوار الشهداء', nameEn: 'Martyrs Circle Service Taxi Stand', typeAr: 'سرفيس (تاكسي مشترك)', typeEn: 'Shared Taxi Stand', locationAr: 'دوار الشهداء - نابلس', locationEn: 'Martyrs Circle - Nablus', rating: 4.0, reviews: 90, infoLabelAr: 'يعمل طوال اليوم', infoLabelEn: 'Operates all day', aboutAr: 'موقف سيارات سرفيس يخدم معظم أحياء المدينة والمناطق المحيطة.', aboutEn: 'A shared taxi stand serving most neighborhoods of the city and surrounding areas.', photoQuery: 'taxi stand street', colorValue: 0xfff5a623 },
  { nameAr: 'تأجير سيارات نابلس', nameEn: 'Nablus Car Rental', typeAr: 'تأجير سيارات', typeEn: 'Car Rental', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.3, reviews: 75, infoLabelAr: 'يعمل 8ص - 8م', infoLabelEn: 'Open 8AM - 8PM', aboutAr: 'خدمة تأجير سيارات بأسعار مناسبة للزوار والسياح.', aboutEn: 'A car rental service with affordable prices for visitors and tourists.', photoQuery: 'car rental', colorValue: 0xff6c5ce7 },
];

// ==================== الصحة ====================
const health = [
  { nameAr: 'مستشفى النجاح الوطني الجامعي', nameEn: 'An-Najah National University Hospital', typeAr: 'مستشفى', typeEn: 'Hospital', locationAr: 'شارع رفيديا - نابلس', locationEn: 'Rafidia St. - Nablus', rating: 4.5, reviews: 420, infoLabelAr: 'طوارئ 24 ساعة', infoLabelEn: '24-hour emergency', aboutAr: 'مستشفى جامعي كبير يقدم خدمات طبية شاملة وطوارئ على مدار الساعة.', aboutEn: 'A large university hospital providing comprehensive medical services and round-the-clock emergency care.', photoQuery: 'hospital building', colorValue: 0xffe85d5d },
  { nameAr: 'مستشفى رفيديا الحكومي', nameEn: 'Rafidia Governmental Hospital', typeAr: 'مستشفى حكومي', typeEn: 'Governmental Hospital', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.2, reviews: 310, infoLabelAr: 'طوارئ 24 ساعة', infoLabelEn: '24-hour emergency', aboutAr: 'مستشفى حكومي رئيسي يخدم سكان المدينة والمناطق المحيطة.', aboutEn: "A major governmental hospital serving the city's residents and surrounding areas.", photoQuery: 'hospital exterior', colorValue: 0xff3b82f6 },
  { nameAr: 'عيادة النور التخصصية', nameEn: 'Al-Noor Specialty Clinic', typeAr: 'عيادة تخصصية', typeEn: 'Specialty Clinic', locationAr: 'شارع فيصل - نابلس', locationEn: 'Faisal St. - Nablus', rating: 4.6, reviews: 130, infoLabelAr: 'يعمل 9ص - 6م', infoLabelEn: 'Open 9AM - 6PM', aboutAr: 'عيادة متخصصة بالكشف والاستشارات الطبية بأحدث الأجهزة.', aboutEn: 'A specialty clinic offering medical examinations and consultations with the latest equipment.', photoQuery: 'medical clinic interior', colorValue: 0xff22c55e },
];

// ==================== التعليم ====================
const education = [
  { nameAr: 'جامعة النجاح الوطنية', nameEn: 'An-Najah National University', typeAr: 'جامعة', typeEn: 'University', locationAr: 'الرابية - نابلس', locationEn: 'Al-Rabya - Nablus', rating: 4.7, reviews: 610, infoLabelAr: 'الدوام 8ص - 4م', infoLabelEn: 'Hours 8AM - 4PM', aboutAr: 'أكبر جامعة فلسطينية، تضم كليات متعددة وحرمًا جامعيًا حديثًا في الرابية.', aboutEn: 'The largest Palestinian university, with multiple faculties and a modern campus in Al-Rabya.', photoQuery: 'university campus', colorValue: 0xff6c5ce7 },
  { nameAr: 'جامعة النجاح القديمة', nameEn: 'An-Najah Old Campus', typeAr: 'حرم جامعي', typeEn: 'University Campus', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.5, reviews: 240, infoLabelAr: 'الدوام 8ص - 4م', infoLabelEn: 'Hours 8AM - 4PM', aboutAr: 'الحرم التاريخي للجامعة بموقع مركزي وسط المدينة.', aboutEn: "The university's historic campus, centrally located in the city.", photoQuery: 'university building', colorValue: 0xff4c6ef5 },
  { nameAr: 'مدارس نابلس الثانوية', nameEn: 'Nablus Secondary Schools', typeAr: 'مدرسة', typeEn: 'School', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.2, reviews: 95, infoLabelAr: 'الدوام 7:30ص - 1:30م', infoLabelEn: 'Hours 7:30AM - 1:30PM', aboutAr: 'مجمع مدارس حكومية وخاصة يخدم أحياء المدينة المختلفة.', aboutEn: "A cluster of public and private schools serving the city's different neighborhoods.", photoQuery: 'school building', colorValue: 0xff22c55e },
];

// ==================== البنوك والصرافة ====================
const banks = [
  { nameAr: 'بنك فلسطين - الفرع الرئيسي', nameEn: 'Bank of Palestine - Main Branch', typeAr: 'بنك', typeEn: 'Bank', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.3, reviews: 210, infoLabelAr: 'يفتح 8:30ص - 3م', infoLabelEn: 'Open 8:30AM - 3PM', aboutAr: 'الفرع الرئيسي لأكبر بنك فلسطيني، يقدم كافة الخدمات المصرفية وصرافة العملات.', aboutEn: 'The main branch of the largest Palestinian bank, offering full banking and currency exchange services.', photoQuery: 'bank building', colorValue: 0xff14b8a6 },
  { nameAr: 'البنك العربي', nameEn: 'Arab Bank', typeAr: 'بنك', typeEn: 'Bank', locationAr: 'دوار الشهداء - نابلس', locationEn: 'Martyrs Circle - Nablus', rating: 4.1, reviews: 140, infoLabelAr: 'يفتح 8:30ص - 3م', infoLabelEn: 'Open 8:30AM - 3PM', aboutAr: 'فرع بنكي يقدم حسابات جارية وتوفير وخدمات تحويل الأموال.', aboutEn: 'A bank branch offering current and savings accounts and money transfer services.', photoQuery: 'bank exterior', colorValue: 0xff3b82f6 },
  { nameAr: 'صرافة الاتحاد', nameEn: 'Al-Ittihad Exchange', typeAr: 'محل صرافة', typeEn: 'Currency Exchange', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.4, reviews: 88, infoLabelAr: 'يفتح 9ص - 7م', infoLabelEn: 'Open 9AM - 7PM', aboutAr: 'محل صرافة موثوق لتبديل العملات الأجنبية بأسعار يومية محدثة.', aboutEn: 'A trusted currency exchange shop with daily updated rates.', photoQuery: 'currency exchange shop', colorValue: 0xffc9a227 },
];

// ==================== الترفيه ====================
const entertainment = [
  { nameAr: 'مدينة الملاهي نابلس', nameEn: 'Nablus Amusement Park', typeAr: 'مدينة ملاهي', typeEn: 'Amusement Park', locationAr: 'شرق نابلس', locationEn: 'East Nablus', rating: 4.3, reviews: 175, infoLabelAr: 'يفتح 3م - 11م', infoLabelEn: 'Open 3PM - 11PM', aboutAr: 'ألعاب متنوعة للأطفال والعائلات مع مساحات جلوس ومطاعم خفيفة.', aboutEn: 'A variety of rides for children and families, with seating areas and light dining.', photoQuery: 'amusement park rides', colorValue: 0xffe85d5d },
  { nameAr: 'سينما نابلس', nameEn: 'Nablus Cinema', typeAr: 'سينما', typeEn: 'Cinema', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.5, reviews: 230, infoLabelAr: 'يفتح 12م - 12ص', infoLabelEn: 'Open 12PM - 12AM', aboutAr: 'صالة عرض سينمائي بتقنية صوت وصورة حديثة وأحدث الأفلام.', aboutEn: 'A modern cinema hall with up-to-date sound and picture technology, showing the latest films.', photoQuery: 'cinema movie theater', colorValue: 0xff6c5ce7 },
  { nameAr: 'صالة بولينج نابلس', nameEn: 'Nablus Bowling Hall', typeAr: 'صالة ألعاب', typeEn: 'Bowling & Games Hall', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.2, reviews: 98, infoLabelAr: 'يفتح 2م - 12ص', infoLabelEn: 'Open 2PM - 12AM', aboutAr: 'مسارات بولينج وألعاب فيديو مناسبة للشباب والعائلات.', aboutEn: 'Bowling lanes and video games suitable for youth and families.', photoQuery: 'bowling alley', colorValue: 0xff22c55e },
];

// ==================== خدمات حكومية ====================
const government = [
  { nameAr: 'بلدية نابلس', nameEn: 'Nablus Municipality', typeAr: 'دائرة حكومية', typeEn: 'Government Office', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.0, reviews: 160, infoLabelAr: 'الدوام 8ص - 3م', infoLabelEn: 'Hours 8AM - 3PM', aboutAr: 'المقر الرئيسي لبلدية نابلس، يقدم خدمات الترخيص والمعاملات البلدية.', aboutEn: 'The main office of Nablus Municipality, providing licensing and municipal services.', photoQuery: 'municipality government building', colorValue: 0xff3b82f6 },
  { nameAr: 'دائرة الأحوال المدنية', nameEn: 'Civil Affairs Department', typeAr: 'دائرة حكومية', typeEn: 'Government Office', locationAr: 'شارع فيصل - نابلس', locationEn: 'Faisal St. - Nablus', rating: 3.9, reviews: 120, infoLabelAr: 'الدوام 8ص - 2:30م', infoLabelEn: 'Hours 8AM - 2:30PM', aboutAr: 'إصدار وتجديد الهويات ووثائق الأحوال المدنية.', aboutEn: 'Issuing and renewing IDs and civil status documents.', photoQuery: 'government office', colorValue: 0xff9c6b30 },
  { nameAr: 'مكتب البريد المركزي', nameEn: 'Central Post Office', typeAr: 'بريد', typeEn: 'Post Office', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.0, reviews: 70, infoLabelAr: 'الدوام 8ص - 3م', infoLabelEn: 'Hours 8AM - 3PM', aboutAr: 'خدمات البريد والطرود والتحويلات المالية.', aboutEn: 'Postal, parcel, and money transfer services.', photoQuery: 'post office', colorValue: 0xffc9a227 },
];

// ==================== الصيدليات ====================
const pharmacies = [
  { nameAr: 'صيدلية النجاح', nameEn: 'Al-Najah Pharmacy', typeAr: 'صيدلية 24 ساعة', typeEn: '24-Hour Pharmacy', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.5, reviews: 160, infoLabelAr: 'تعمل 24 ساعة', infoLabelEn: 'Open 24 hours', aboutAr: 'صيدلية تعمل على مدار الساعة، توفر جميع الأدوية والمستلزمات الطبية.', aboutEn: 'A pharmacy open around the clock, providing all medications and medical supplies.', photoQuery: 'pharmacy interior', colorValue: 0xff3b82f6 },
  { nameAr: 'صيدلية الشفاء', nameEn: 'Al-Shifa Pharmacy', typeAr: 'صيدلية', typeEn: 'Pharmacy', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.3, reviews: 110, infoLabelAr: 'تعمل 8ص - 11م', infoLabelEn: 'Open 8AM - 11PM', aboutAr: 'صيدلية بموقع مركزي تقدم استشارات دوائية مجانية.', aboutEn: 'A centrally located pharmacy offering free medication consultations.', photoQuery: 'pharmacy shelves medicine', colorValue: 0xff22c55e },
  { nameAr: 'صيدلية الرحمة', nameEn: 'Al-Rahma Pharmacy', typeAr: 'صيدلية 24 ساعة', typeEn: '24-Hour Pharmacy', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.4, reviews: 140, infoLabelAr: 'تعمل 24 ساعة', infoLabelEn: 'Open 24 hours', aboutAr: 'صيدلية تعمل على مدار الساعة مع خدمة توصيل للمنازل.', aboutEn: 'A 24-hour pharmacy offering home delivery service.', photoQuery: 'pharmacy store', colorValue: 0xffe85d5d },
  { nameAr: 'صيدلية الأمل', nameEn: 'Al-Amal Pharmacy', typeAr: 'صيدلية', typeEn: 'Pharmacy', locationAr: 'شارع فيصل - نابلس', locationEn: 'Faisal St. - Nablus', rating: 4.2, reviews: 85, infoLabelAr: 'تعمل 8ص - 10م', infoLabelEn: 'Open 8AM - 10PM', aboutAr: 'صيدلية عائلية تقدم خدمة شخصية ومتابعة دقيقة للزبائن.', aboutEn: 'A family pharmacy offering personalized service and careful follow-up for customers.', photoQuery: 'pharmacy counter', colorValue: 0xffc9a227 },
];

const LISTING_CATEGORIES = {
  hotels,
  attractions,
  shopping,
  transport,
  health,
  education,
  banks,
  entertainment,
  government,
  pharmacies,
};

// ==================== المطاعم (35) ====================
const restaurants = [
  { nameAr: 'مطعم البيت النابلسي', nameEn: 'Al-Bait Al-Nabulsi Restaurant', categoryAr: 'مأكولات شعبية', categoryEn: 'Traditional Food', cuisineKey: 'traditional', locationAr: 'شارع سفيان - نابلس', locationEn: 'Sufyan St. - Nablus', rating: 4.8, reviews: 256, priceRange: '25-35 ₪', priceTier: 'medium', time: '20 دقيقة', aboutAr: 'مطعم تراثي نابلسي يقدم أشهى الأطباق الشعبية بنكهات أصيلة ومكونات طازجة من قلب نابلس.', aboutEn: 'A traditional Nablus restaurant serving the finest local dishes with authentic flavors and fresh ingredients from the heart of Nablus.', colorValue: 0xffb5651d },
  { nameAr: 'مطعم الأندلس', nameEn: 'Al-Andalus Restaurant', categoryAr: 'مأكولات شرقية', categoryEn: 'Eastern Food', cuisineKey: 'eastern', locationAr: 'شارع فيصل - نابلس', locationEn: 'Faisal St. - Nablus', rating: 4.6, reviews: 205, priceRange: '30-45 ₪', priceTier: 'medium', time: '25 دقيقة', aboutAr: 'أطباق شرقية متنوعة بأسلوب تقديم راقٍ ونكهات غنية.', aboutEn: 'A variety of eastern dishes with elegant presentation and rich flavors.', colorValue: 0xff8e5b3f },
  { nameAr: 'Burger Lounge', nameEn: 'Burger Lounge', categoryAr: 'وجبات سريعة', categoryEn: 'Fast Food', cuisineKey: 'fastfood', locationAr: 'دوار الشهداء - نابلس', locationEn: 'Martyrs Circle - Nablus', rating: 4.6, reviews: 180, priceRange: '20-35 ₪', priceTier: 'medium', time: '25 دقيقة', aboutAr: 'أشهى البرغر الطازج مع بطاطا مقرمشة وصوصات مميزة.', aboutEn: 'The tastiest fresh burgers with crispy fries and signature sauces.', colorValue: 0xffd4a017 },
  { nameAr: 'كافية الريفة', nameEn: 'Al-Reefa Cafe', categoryAr: 'كافيهات', categoryEn: 'Cafes', cuisineKey: 'cafe', locationAr: 'منطقة الرابية - نابلس', locationEn: 'Al-Rabya Area - Nablus', rating: 4.4, reviews: 140, priceRange: '15-25 ₪', priceTier: 'cheap', time: '20 دقيقة', aboutAr: 'أجواء هادئة ومشروبات مختصة بمكونات مميزة.', aboutEn: 'A calm atmosphere with specialty drinks and premium ingredients.', colorValue: 0xff6f4e37 },
  { nameAr: 'حلويات السلطان', nameEn: 'Al-Sultan Sweets', categoryAr: 'حلويات', categoryEn: 'Sweets', cuisineKey: 'sweets', locationAr: 'شارع رفيديا - نابلس', locationEn: 'Rafidia St. - Nablus', rating: 4.5, reviews: 210, priceRange: '10-20 ₪', priceTier: 'cheap', time: '20 دقيقة', aboutAr: 'أشهى الحلويات الشرقية الطازجة يوميًا.', aboutEn: 'The finest traditional sweets made fresh daily.', colorValue: 0xffc9a227 },
  { nameAr: 'بيتزا نابلس', nameEn: 'Nablus Pizza', categoryAr: 'إيطالي', categoryEn: 'Italian', cuisineKey: 'italian', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.3, reviews: 260, priceRange: '20-30 ₪', priceTier: 'medium', time: '20 دقيقة', aboutAr: 'بيتزا إيطالية أصلية بعجينة طرية ومكونات فريدة.', aboutEn: 'Authentic Italian pizza with soft dough and unique toppings.', colorValue: 0xffb33a2e },
  { nameAr: 'شاورما نابلس', nameEn: 'Nablus Shawarma', categoryAr: 'وجبات سريعة', categoryEn: 'Fast Food', cuisineKey: 'fastfood', locationAr: 'شارع عمان - نابلس', locationEn: 'Amman St. - Nablus', rating: 4.2, reviews: 275, priceRange: '10-15 ₪', priceTier: 'cheap', time: '15 دقيقة', aboutAr: 'شاورما طازجة يوميًا بنكهة لا تُنسى.', aboutEn: 'Fresh shawarma made daily with an unforgettable taste.', colorValue: 0xff7a4b2a },
  { nameAr: 'كنافة نابلس', nameEn: 'Nablus Kunafa', categoryAr: 'حلويات', categoryEn: 'Sweets', cuisineKey: 'sweets', locationAr: 'المساكن الشعبية - نابلس', locationEn: 'Popular Housing - Nablus', rating: 4.2, reviews: 190, priceRange: '12-20 ₪', priceTier: 'cheap', time: '10 دقيقة', aboutAr: 'الكنافة النابلسية الأصلية بالجبن الطازج.', aboutEn: 'Authentic Nabulsi kunafa made with fresh cheese.', colorValue: 0xffe8a33d },
  { nameAr: 'مطعم تنورين', nameEn: 'Tannourine Restaurant', categoryAr: 'مأكولات شعبية', categoryEn: 'Traditional Food', cuisineKey: 'traditional', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.5, reviews: 66, priceRange: '25-35 ₪', priceTier: 'medium', time: '20 دقيقة', aboutAr: 'مطعم يقدم أشهى الأطباق الشعبية بنكهات أصيلة ومكونات طازجة من قلب نابلس.', aboutEn: 'A restaurant serving the finest local dishes with authentic flavors and fresh ingredients from the heart of Nablus.', colorValue: 0xffb5651d },
  { nameAr: 'مطعم المدينة', nameEn: 'Al-Madina Restaurant', categoryAr: 'مأكولات شعبية', categoryEn: 'Traditional Food', cuisineKey: 'traditional', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.1, reviews: 95, priceRange: '25-35 ₪', priceTier: 'medium', time: '10 دقيقة', aboutAr: 'مطعم يقدم أشهى الأطباق الشعبية بنكهات أصيلة ومكونات طازجة من قلب نابلس.', aboutEn: 'A restaurant serving the finest local dishes with authentic flavors and fresh ingredients from the heart of Nablus.', colorValue: 0xff8e5b3f },
  { nameAr: 'مطعم ليفانت (Levant)', nameEn: 'Levant Restaurant', categoryAr: 'مأكولات شعبية', categoryEn: 'Traditional Food', cuisineKey: 'traditional', locationAr: 'شارع فيصل - نابلس', locationEn: 'Faisal St. - Nablus', rating: 4.5, reviews: 288, priceRange: '25-35 ₪', priceTier: 'medium', time: '30 دقيقة', aboutAr: 'مطعم يقدم أشهى الأطباق الشعبية بنكهات أصيلة ومكونات طازجة من قلب نابلس.', aboutEn: 'A restaurant serving the finest local dishes with authentic flavors and fresh ingredients from the heart of Nablus.', colorValue: 0xffd4a017 },
  { nameAr: 'مطعم الف ليلة وليلة', nameEn: 'Alf Layla wa Layla Restaurant', categoryAr: 'مأكولات شعبية', categoryEn: 'Traditional Food', cuisineKey: 'traditional', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.0, reviews: 168, priceRange: '25-35 ₪', priceTier: 'medium', time: '10 دقيقة', aboutAr: 'مطعم يقدم أشهى الأطباق الشعبية بنكهات أصيلة ومكونات طازجة من قلب نابلس.', aboutEn: 'A restaurant serving the finest local dishes with authentic flavors and fresh ingredients from the heart of Nablus.', colorValue: 0xff6f4e37 },
  { nameAr: 'W Restaurant', nameEn: 'W Restaurant', categoryAr: 'مأكولات شرقية', categoryEn: 'Eastern Food', cuisineKey: 'eastern', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 3.9, reviews: 115, priceRange: '30-45 ₪', priceTier: 'medium', time: '15 دقيقة', aboutAr: 'أطباق شرقية متنوعة بأسلوب تقديم راقٍ ونكهات غنية.', aboutEn: 'A variety of eastern dishes with elegant presentation and rich flavors.', colorValue: 0xffc9a227 },
  { nameAr: '1948 Restaurant', nameEn: '1948 Restaurant', categoryAr: 'مأكولات شرقية', categoryEn: 'Eastern Food', cuisineKey: 'eastern', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.4, reviews: 66, priceRange: '30-45 ₪', priceTier: 'medium', time: '30 دقيقة', aboutAr: 'أطباق شرقية متنوعة بأسلوب تقديم راقٍ ونكهات غنية.', aboutEn: 'A variety of eastern dishes with elegant presentation and rich flavors.', colorValue: 0xffb33a2e },
  { nameAr: 'Solido Restaurant', nameEn: 'Solido Restaurant', categoryAr: 'مأكولات شرقية', categoryEn: 'Eastern Food', cuisineKey: 'eastern', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.1, reviews: 226, priceRange: '30-45 ₪', priceTier: 'medium', time: '30 دقيقة', aboutAr: 'أطباق شرقية متنوعة بأسلوب تقديم راقٍ ونكهات غنية.', aboutEn: 'A variety of eastern dishes with elegant presentation and rich flavors.', colorValue: 0xff7a4b2a },
  { nameAr: 'Ward Restaurant & Café', nameEn: 'Ward Restaurant & Café', categoryAr: 'مأكولات شرقية', categoryEn: 'Eastern Food', cuisineKey: 'eastern', locationAr: 'شارع عمان - نابلس', locationEn: 'Amman St. - Nablus', rating: 4.3, reviews: 174, priceRange: '30-45 ₪', priceTier: 'medium', time: '30 دقيقة', aboutAr: 'أطباق شرقية متنوعة بأسلوب تقديم راقٍ ونكهات غنية.', aboutEn: 'A variety of eastern dishes with elegant presentation and rich flavors.', colorValue: 0xffe8a33d },
  { nameAr: 'Rexos Café & Restaurant', nameEn: 'Rexos Café & Restaurant', categoryAr: 'مأكولات شرقية', categoryEn: 'Eastern Food', cuisineKey: 'eastern', locationAr: 'شارع فيصل - نابلس', locationEn: 'Faisal St. - Nablus', rating: 4.2, reviews: 282, priceRange: '30-45 ₪', priceTier: 'medium', time: '10 دقيقة', aboutAr: 'أطباق شرقية متنوعة بأسلوب تقديم راقٍ ونكهات غنية.', aboutEn: 'A variety of eastern dishes with elegant presentation and rich flavors.', colorValue: 0xff9c6b30 },
  { nameAr: 'Pardo Café', nameEn: 'Pardo Café', categoryAr: 'كافيه', categoryEn: 'Cafe', cuisineKey: 'cafe', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.6, reviews: 100, priceRange: '15-25 ₪', priceTier: 'cheap', time: '25 دقيقة', aboutAr: 'أجواء هادئة ومشروبات مختصة بمكونات مميزة.', aboutEn: 'A calm atmosphere with specialty drinks and premium ingredients.', colorValue: 0xffa85e2c },
  { nameAr: 'Veranda Café', nameEn: 'Veranda Café', categoryAr: 'كافيه', categoryEn: 'Cafe', cuisineKey: 'cafe', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.2, reviews: 99, priceRange: '15-25 ₪', priceTier: 'cheap', time: '15 دقيقة', aboutAr: 'أجواء هادئة ومشروبات مختصة بمكونات مميزة.', aboutEn: 'A calm atmosphere with specialty drinks and premium ingredients.', colorValue: 0xffb5651d },
  { nameAr: 'Lemon W Nana', nameEn: 'Lemon W Nana', categoryAr: 'كافيه', categoryEn: 'Cafe', cuisineKey: 'cafe', locationAr: 'شارع عمان - نابلس', locationEn: 'Amman St. - Nablus', rating: 4.8, reviews: 146, priceRange: '15-25 ₪', priceTier: 'cheap', time: '10 دقيقة', aboutAr: 'أجواء هادئة ومشروبات مختصة بمكونات مميزة.', aboutEn: 'A calm atmosphere with specialty drinks and premium ingredients.', colorValue: 0xff8e5b3f },
  { nameAr: 'Nosha Café', nameEn: 'Nosha Café', categoryAr: 'كافيه', categoryEn: 'Cafe', cuisineKey: 'cafe', locationAr: 'شارع فيصل - نابلس', locationEn: 'Faisal St. - Nablus', rating: 4.0, reviews: 84, priceRange: '15-25 ₪', priceTier: 'cheap', time: '20 دقيقة', aboutAr: 'أجواء هادئة ومشروبات مختصة بمكونات مميزة.', aboutEn: 'A calm atmosphere with specialty drinks and premium ingredients.', colorValue: 0xffd4a017 },
  { nameAr: 'Cedarz Gelato & Coffee House', nameEn: 'Cedarz Gelato & Coffee House', categoryAr: 'كافيه', categoryEn: 'Cafe', cuisineKey: 'cafe', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.7, reviews: 214, priceRange: '15-25 ₪', priceTier: 'cheap', time: '20 دقيقة', aboutAr: 'أجواء هادئة ومشروبات مختصة بمكونات مميزة.', aboutEn: 'A calm atmosphere with specialty drinks and premium ingredients.', colorValue: 0xff6f4e37 },
  { nameAr: 'Pizza Inn', nameEn: 'Pizza Inn', categoryAr: 'وجبات سريعة', categoryEn: 'Fast Food', cuisineKey: 'fastfood', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.6, reviews: 246, priceRange: '10-20 ₪', priceTier: 'cheap', time: '25 دقيقة', aboutAr: 'وجبات سريعة طازجة بنكهة لا تُنسى وخدمة سريعة.', aboutEn: 'Fresh fast food with an unforgettable taste and quick service.', colorValue: 0xffc9a227 },
  { nameAr: 'Mono Pizza', nameEn: 'Mono Pizza', categoryAr: 'وجبات سريعة', categoryEn: 'Fast Food', cuisineKey: 'fastfood', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.4, reviews: 296, priceRange: '10-20 ₪', priceTier: 'cheap', time: '25 دقيقة', aboutAr: 'وجبات سريعة طازجة بنكهة لا تُنسى وخدمة سريعة.', aboutEn: 'Fresh fast food with an unforgettable taste and quick service.', colorValue: 0xffb33a2e },
  { nameAr: 'Sawa Rbena', nameEn: 'Sawa Rbena', categoryAr: 'وجبات سريعة', categoryEn: 'Fast Food', cuisineKey: 'fastfood', locationAr: 'شارع عمان - نابلس', locationEn: 'Amman St. - Nablus', rating: 4.0, reviews: 135, priceRange: '10-20 ₪', priceTier: 'cheap', time: '30 دقيقة', aboutAr: 'وجبات سريعة طازجة بنكهة لا تُنسى وخدمة سريعة.', aboutEn: 'Fresh fast food with an unforgettable taste and quick service.', colorValue: 0xff7a4b2a },
  { nameAr: 'Shawarma House', nameEn: 'Shawarma House', categoryAr: 'وجبات سريعة', categoryEn: 'Fast Food', cuisineKey: 'fastfood', locationAr: 'شارع سفيان - نابلس', locationEn: 'Sufyan St. - Nablus', rating: 4.7, reviews: 152, priceRange: '10-20 ₪', priceTier: 'cheap', time: '30 دقيقة', aboutAr: 'وجبات سريعة طازجة بنكهة لا تُنسى وخدمة سريعة.', aboutEn: 'Fresh fast food with an unforgettable taste and quick service.', colorValue: 0xffe8a33d },
  { nameAr: 'بكداش للحلويات', nameEn: 'Bakdash Sweets', categoryAr: 'حلويات', categoryEn: 'Sweets', cuisineKey: 'sweets', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.1, reviews: 77, priceRange: '10-20 ₪', priceTier: 'cheap', time: '10 دقيقة', aboutAr: 'أشهى الحلويات الشرقية الطازجة يوميًا.', aboutEn: 'The finest traditional sweets made fresh daily.', colorValue: 0xff9c6b30 },
  { nameAr: 'كنافة الأقصى', nameEn: 'Al-Aqsa Kunafa', categoryAr: 'حلويات', categoryEn: 'Sweets', cuisineKey: 'sweets', locationAr: 'البلدة القديمة - نابلس', locationEn: 'Old City - Nablus', rating: 4.5, reviews: 257, priceRange: '10-20 ₪', priceTier: 'cheap', time: '20 دقيقة', aboutAr: 'أشهى الحلويات الشرقية الطازجة يوميًا.', aboutEn: 'The finest traditional sweets made fresh daily.', colorValue: 0xffa85e2c },
  { nameAr: 'Becasse Bakery', nameEn: 'Becasse Bakery', categoryAr: 'حلويات', categoryEn: 'Sweets', cuisineKey: 'sweets', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.8, reviews: 278, priceRange: '10-20 ₪', priceTier: 'cheap', time: '15 دقيقة', aboutAr: 'أشهى الحلويات الشرقية الطازجة يوميًا.', aboutEn: 'The finest traditional sweets made fresh daily.', colorValue: 0xffb5651d },
  { nameAr: 'أبو سير للحلويات', nameEn: 'Abu Seir Sweets', categoryAr: 'حلويات', categoryEn: 'Sweets', cuisineKey: 'sweets', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.7, reviews: 157, priceRange: '10-20 ₪', priceTier: 'cheap', time: '20 دقيقة', aboutAr: 'أشهى الحلويات الشرقية الطازجة يوميًا.', aboutEn: 'The finest traditional sweets made fresh daily.', colorValue: 0xff8e5b3f },
  { nameAr: 'Pizza Inn', nameEn: 'Pizza Inn', categoryAr: 'إيطالي', categoryEn: 'Italian', cuisineKey: 'italian', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.3, reviews: 273, priceRange: '25-40 ₪', priceTier: 'medium', time: '20 دقيقة', aboutAr: 'بيتزا وأطباق إيطالية أصلية بعجينة طرية ومكونات فريدة.', aboutEn: 'Authentic Italian pizza and dishes with soft dough and unique toppings.', colorValue: 0xffd4a017 },
  { nameAr: 'Mono Pizza', nameEn: 'Mono Pizza', categoryAr: 'إيطالي', categoryEn: 'Italian', cuisineKey: 'italian', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.0, reviews: 150, priceRange: '25-40 ₪', priceTier: 'medium', time: '15 دقيقة', aboutAr: 'بيتزا وأطباق إيطالية أصلية بعجينة طرية ومكونات فريدة.', aboutEn: 'Authentic Italian pizza and dishes with soft dough and unique toppings.', colorValue: 0xff6f4e37 },
  { nameAr: 'Solido Restaurant', nameEn: 'Solido Restaurant', categoryAr: 'إيطالي', categoryEn: 'Italian', cuisineKey: 'italian', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.5, reviews: 239, priceRange: '25-40 ₪', priceTier: 'medium', time: '10 دقيقة', aboutAr: 'بيتزا وأطباق إيطالية أصلية بعجينة طرية ومكونات فريدة.', aboutEn: 'Authentic Italian pizza and dishes with soft dough and unique toppings.', colorValue: 0xffc9a227 },
  { nameAr: 'La Piazza', nameEn: 'La Piazza', categoryAr: 'إيطالي', categoryEn: 'Italian', cuisineKey: 'italian', locationAr: 'شارع عمان - نابلس', locationEn: 'Amman St. - Nablus', rating: 4.4, reviews: 103, priceRange: '25-40 ₪', priceTier: 'medium', time: '30 دقيقة', aboutAr: 'بيتزا وأطباق إيطالية أصلية بعجينة طرية ومكونات فريدة.', aboutEn: 'Authentic Italian pizza and dishes with soft dough and unique toppings.', colorValue: 0xffb33a2e },
  { nameAr: 'Italian House', nameEn: 'Italian House', categoryAr: 'إيطالي', categoryEn: 'Italian', cuisineKey: 'italian', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.6, reviews: 101, priceRange: '25-40 ₪', priceTier: 'medium', time: '25 دقيقة', aboutAr: 'بيتزا وأطباق إيطالية أصلية بعجينة طرية ومكونات فريدة.', aboutEn: 'Authentic Italian pizza and dishes with soft dough and unique toppings.', colorValue: 0xff7a4b2a },
];

// ==================== الأخبار ====================
const news = [
  { titleAr: 'افتتاح مشروع تطوير البلدة القديمة', titleEn: 'Old City Development Project Launched', dateAr: '10 مايو 2025', dateEn: 'May 10, 2025', categoryAr: 'تطوير', categoryEn: 'Development', categoryKey: 'development', summaryAr: 'مشروع جديد لترميم وتطوير أزقة البلدة القديمة والحفاظ على طابعها التراثي.', summaryEn: 'A new project to restore and develop the Old City alleys while preserving its heritage character.', bodyAr: 'أعلنت بلدية نابلس عن انطلاق مشروع شامل لتطوير البلدة القديمة يهدف إلى ترميم الأبنية التاريخية وتحسين البنية التحتية مع الحفاظ على الطابع المعماري الأصيل. يتضمن المشروع تحسين الإنارة، رصف الأزقة بالحجر الطبيعي، وإعادة تأهيل الأسواق القديمة لجذب مزيد من الزوار والسياح.', bodyEn: 'Nablus Municipality announced the launch of a comprehensive project to develop the Old City, aiming to restore historic buildings and improve infrastructure while preserving the original architectural character. The project includes improved lighting, natural stone paving for the alleys, and rehabilitation of the old markets to attract more visitors and tourists.' },
  { titleAr: 'نابلس تستضيف المؤتمر السياحي الدولي', titleEn: 'Nablus Hosts International Tourism Conference', dateAr: '8 مايو 2025', dateEn: 'May 8, 2025', categoryAr: 'سياحة', categoryEn: 'Tourism', categoryKey: 'tourism', summaryAr: 'استضافت المدينة مؤتمرًا دوليًا لبحث سبل تعزيز السياحة الداخلية والخارجية.', summaryEn: 'The city hosted an international conference to discuss ways to promote domestic and international tourism.', bodyAr: 'شهدت نابلس هذا الأسبوع فعاليات المؤتمر السياحي الدولي بمشاركة خبراء ومختصين من عدة دول، حيث تم بحث استراتيجيات تطوير القطاع السياحي وجذب المزيد من الزوار عبر تحسين الخدمات والبنية التحتية السياحية بالمدينة.', bodyEn: 'Nablus witnessed this week the International Tourism Conference with the participation of experts from several countries, discussing strategies to develop the tourism sector and attract more visitors by improving tourism services and infrastructure in the city.' },
  { titleAr: 'تحسن حركة السياحة في نابلس', titleEn: 'Tourism Activity Improves in Nablus', dateAr: '5 مايو 2025', dateEn: 'May 5, 2025', categoryAr: 'سياحة', categoryEn: 'Tourism', categoryKey: 'tourism', summaryAr: 'ارتفاع ملحوظ بعدد الزوار خلال الأشهر الأخيرة مقارنة بالعام الماضي.', summaryEn: 'A noticeable increase in visitor numbers over recent months compared to last year.', bodyAr: 'أظهرت إحصائيات حديثة ارتفاعًا ملحوظًا في أعداد الزوار القادمين إلى نابلس خلال الأشهر الأخيرة، ويعزو المختصون هذا التحسن إلى الحملات الترويجية الأخيرة وتحسين الخدمات السياحية في المدينة.', bodyEn: 'Recent statistics showed a noticeable increase in the number of visitors coming to Nablus in recent months. Experts attribute this improvement to recent promotional campaigns and improved tourism services in the city.' },
  { titleAr: 'فعاليات ثقافية جديدة في المدينة', titleEn: 'New Cultural Events in the City', dateAr: '2 مايو 2025', dateEn: 'May 2, 2025', categoryAr: 'ثقافة', categoryEn: 'Culture', categoryKey: 'culture', summaryAr: 'سلسلة فعاليات ثقافية وفنية تنطلق هذا الشهر في عدة مواقع بالمدينة.', summaryEn: 'A series of cultural and artistic events kicks off this month at several locations in the city.', bodyAr: 'تنطلق هذا الشهر سلسلة من الفعاليات الثقافية والفنية في نابلس، تشمل معارض فنية وأمسيات شعرية وعروض موسيقية تراثية، بهدف إحياء التراث الثقافي المحلي وتشجيع السياحة الثقافية بالمدينة.', bodyEn: 'A series of cultural and artistic events kicks off this month in Nablus, including art exhibitions, poetry evenings, and traditional music performances, aiming to revive local cultural heritage and encourage cultural tourism in the city.' },
  { titleAr: 'مهرجان نابلس للتسوق ينطلق الشهر القادم', titleEn: 'Nablus Shopping Festival Launches Next Month', dateAr: '28 أبريل 2025', dateEn: 'April 28, 2025', categoryAr: 'فعاليات', categoryEn: 'Events', categoryKey: 'events', summaryAr: 'استعدادات مكثفة لانطلاق مهرجان التسوق السنوي بمشاركة عشرات المحال التجارية.', summaryEn: 'Intensive preparations underway for the annual shopping festival with dozens of participating stores.', bodyAr: 'تجري الاستعدادات على قدم وساق لانطلاق مهرجان نابلس للتسوق السنوي الذي يشارك فيه عشرات المحال التجارية بعروض وتخفيضات خاصة، إلى جانب فعاليات ترفيهية للعائلات طوال أيام المهرجان.', bodyEn: 'Preparations are in full swing for the launch of the annual Nablus Shopping Festival, with dozens of stores participating with special offers and discounts, alongside family entertainment activities throughout the festival days.' },
  { titleAr: 'توسعة شبكة المواصلات العامة داخل المدينة', titleEn: 'Expansion of Public Transportation Network in the City', dateAr: '20 أبريل 2025', dateEn: 'April 20, 2025', categoryAr: 'تطوير', categoryEn: 'Development', categoryKey: 'development', summaryAr: 'خطوط جديدة للمواصلات العامة لتسهيل الوصول لمختلف أحياء المدينة.', summaryEn: 'New public transportation lines to facilitate access to different neighborhoods of the city.', bodyAr: 'أعلنت الجهات المختصة عن توسعة شبكة المواصلات العامة داخل نابلس بإضافة خطوط جديدة تربط الأحياء السكنية بمركز المدينة والمعالم السياحية الرئيسية، بهدف تسهيل التنقل للسكان والزوار على حد سواء.', bodyEn: 'Authorities announced the expansion of the public transportation network within Nablus by adding new lines connecting residential neighborhoods to the city center and major tourist landmarks, aiming to facilitate movement for both residents and visitors.' },
];

async function main() {
  console.log('🌱 بدء تعبئة قاعدة البيانات بالبيانات الابتدائية...');

  // حساب الأدمن (مرة واحدة فقط لو ما كان موجود)
  const adminUsername = (process.env.ADMIN_USERNAME || 'admin').toLowerCase();
  const adminPassword = process.env.ADMIN_PASSWORD || 'admin123';
  const existingAdmin = await prisma.user.findUnique({ where: { email: adminUsername } });
  if (!existingAdmin) {
    await prisma.user.create({
      data: {
        name: 'Admin',
        email: adminUsername,
        passwordHash: await bcrypt.hash(adminPassword, 10),
        role: 'admin',
      },
    });
    console.log(`✅ تم إنشاء حساب الأدمن (${adminUsername})`);
  }

  for (const [category, items] of Object.entries(LISTING_CATEGORIES)) {
    const count = await prisma.listing.count({ where: { category } });
    if (count > 0) continue;
    for (const item of items) {
      await prisma.listing.create({
        data: {
          ...item,
          category,
          phone: '+970 59 000 0000',
          iconCodePoint: PLACE_ICON,
          colorValue: item.colorValue & 0xffffff,
        },
      });
    }
    console.log(`✅ تمت تعبئة تصنيف "${category}" بـ ${items.length} عنصر`);
  }

  const restaurantCount = await prisma.restaurant.count();
  if (restaurantCount === 0) {
    for (const r of restaurants) {
      await prisma.restaurant.create({
        data: { ...r, iconCodePoint: RESTAURANT_ICON, colorValue: r.colorValue & 0xffffff },
      });
    }
    console.log(`✅ تمت تعبئة المطاعم بـ ${restaurants.length} مطعم`);
  }

  const newsCount = await prisma.newsArticle.count();
  if (newsCount === 0) {
    for (const n of news) {
      await prisma.newsArticle.create({ data: n });
    }
    console.log(`✅ تمت تعبئة الأخبار بـ ${news.length} خبر`);
  }

  console.log('🎉 انتهت تعبئة قاعدة البيانات بنجاح');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
