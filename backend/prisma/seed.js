require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

// بيانات حقيقية مصدّرة مباشرة من التطبيق (lib/screens/.../*.dart) عبر
// test/_export_seed_test.dart — نفس البيانات اللي شغالة فعليًا بالتطبيق، مش بيانات
// تقديرية قديمة. لتحديثها لاحقًا: شغّلي "flutter test test/_export_seed_test.dart"
// من جذر المشروع بعد أي تعديل على بيانات التطبيق، وهيك بينحدث seed_data.json تلقائيًا.
const seedData = JSON.parse(fs.readFileSync(path.join(__dirname, 'seed_data.json'), 'utf8'));

const PLACE_ICON = 0xe55f; // Icons.place

// ==================== الأقسام العامة اللي لسا على النموذج القديم (Listing) ====================
const transport = [
  { nameAr: 'محطة الباصات المركزية', nameEn: 'Central Bus Station', typeAr: 'محطة باصات', typeEn: 'Bus Station', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.1, reviews: 150, infoLabelAr: 'يعمل 6ص - 10م', infoLabelEn: 'Operates 6AM - 10PM', aboutAr: 'المحطة الرئيسية للباصات الرابطة بين نابلس والمدن المجاورة.', aboutEn: 'The main bus station connecting Nablus with neighboring cities.', photoQuery: 'bus station', colorValue: 0xff14b8a6 },
  { nameAr: 'موقف سرفيس دوار الشهداء', nameEn: 'Martyrs Circle Service Taxi Stand', typeAr: 'سرفيس (تاكسي مشترك)', typeEn: 'Shared Taxi Stand', locationAr: 'دوار الشهداء - نابلس', locationEn: 'Martyrs Circle - Nablus', rating: 4.0, reviews: 90, infoLabelAr: 'يعمل طوال اليوم', infoLabelEn: 'Operates all day', aboutAr: 'موقف سيارات سرفيس يخدم معظم أحياء المدينة والمناطق المحيطة.', aboutEn: 'A shared taxi stand serving most neighborhoods of the city and surrounding areas.', photoQuery: 'taxi stand street', colorValue: 0xfff5a623 },
  { nameAr: 'تأجير سيارات نابلس', nameEn: 'Nablus Car Rental', typeAr: 'تأجير سيارات', typeEn: 'Car Rental', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.3, reviews: 75, infoLabelAr: 'يعمل 8ص - 8م', infoLabelEn: 'Open 8AM - 8PM', aboutAr: 'خدمة تأجير سيارات بأسعار مناسبة للزوار والسياح.', aboutEn: 'A car rental service with affordable prices for visitors and tourists.', photoQuery: 'car rental', colorValue: 0xff6c5ce7 },
];

const health = [
  { nameAr: 'مستشفى النجاح الوطني الجامعي', nameEn: 'An-Najah National University Hospital', typeAr: 'مستشفى', typeEn: 'Hospital', locationAr: 'شارع رفيديا - نابلس', locationEn: 'Rafidia St. - Nablus', rating: 4.5, reviews: 420, infoLabelAr: 'طوارئ 24 ساعة', infoLabelEn: '24-hour emergency', aboutAr: 'مستشفى جامعي كبير يقدم خدمات طبية شاملة وطوارئ على مدار الساعة.', aboutEn: 'A large university hospital providing comprehensive medical services and round-the-clock emergency care.', photoQuery: 'hospital building', colorValue: 0xffe85d5d },
  { nameAr: 'مستشفى رفيديا الحكومي', nameEn: 'Rafidia Governmental Hospital', typeAr: 'مستشفى حكومي', typeEn: 'Governmental Hospital', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.2, reviews: 310, infoLabelAr: 'طوارئ 24 ساعة', infoLabelEn: '24-hour emergency', aboutAr: 'مستشفى حكومي رئيسي يخدم سكان المدينة والمناطق المحيطة.', aboutEn: "A major governmental hospital serving the city's residents and surrounding areas.", photoQuery: 'hospital exterior', colorValue: 0xff3b82f6 },
  { nameAr: 'عيادة النور التخصصية', nameEn: 'Al-Noor Specialty Clinic', typeAr: 'عيادة تخصصية', typeEn: 'Specialty Clinic', locationAr: 'شارع فيصل - نابلس', locationEn: 'Faisal St. - Nablus', rating: 4.6, reviews: 130, infoLabelAr: 'يعمل 9ص - 6م', infoLabelEn: 'Open 9AM - 6PM', aboutAr: 'عيادة متخصصة بالكشف والاستشارات الطبية بأحدث الأجهزة.', aboutEn: 'A specialty clinic offering medical examinations and consultations with the latest equipment.', photoQuery: 'medical clinic interior', colorValue: 0xff22c55e },
];

const education = [
  { nameAr: 'جامعة النجاح الوطنية', nameEn: 'An-Najah National University', typeAr: 'جامعة', typeEn: 'University', locationAr: 'الرابية - نابلس', locationEn: 'Al-Rabya - Nablus', rating: 4.7, reviews: 610, infoLabelAr: 'الدوام 8ص - 4م', infoLabelEn: 'Hours 8AM - 4PM', aboutAr: 'أكبر جامعة فلسطينية، تضم كليات متعددة وحرمًا جامعيًا حديثًا في الرابية.', aboutEn: 'The largest Palestinian university, with multiple faculties and a modern campus in Al-Rabya.', photoQuery: 'university campus', colorValue: 0xff6c5ce7 },
  { nameAr: 'جامعة النجاح القديمة', nameEn: 'An-Najah Old Campus', typeAr: 'حرم جامعي', typeEn: 'University Campus', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.5, reviews: 240, infoLabelAr: 'الدوام 8ص - 4م', infoLabelEn: 'Hours 8AM - 4PM', aboutAr: 'الحرم التاريخي للجامعة بموقع مركزي وسط المدينة.', aboutEn: "The university's historic campus, centrally located in the city.", photoQuery: 'university building', colorValue: 0xff4c6ef5 },
  { nameAr: 'مدارس نابلس الثانوية', nameEn: 'Nablus Secondary Schools', typeAr: 'مدرسة', typeEn: 'School', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.2, reviews: 95, infoLabelAr: 'الدوام 7:30ص - 1:30م', infoLabelEn: 'Hours 7:30AM - 1:30PM', aboutAr: 'مجمع مدارس حكومية وخاصة يخدم أحياء المدينة المختلفة.', aboutEn: "A cluster of public and private schools serving the city's different neighborhoods.", photoQuery: 'school building', colorValue: 0xff22c55e },
];

const banks = [
  { nameAr: 'بنك فلسطين - الفرع الرئيسي', nameEn: 'Bank of Palestine - Main Branch', typeAr: 'بنك', typeEn: 'Bank', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.3, reviews: 210, infoLabelAr: 'يفتح 8:30ص - 3م', infoLabelEn: 'Open 8:30AM - 3PM', aboutAr: 'الفرع الرئيسي لأكبر بنك فلسطيني، يقدم كافة الخدمات المصرفية وصرافة العملات.', aboutEn: 'The main branch of the largest Palestinian bank, offering full banking and currency exchange services.', photoQuery: 'bank building', colorValue: 0xff14b8a6 },
  { nameAr: 'البنك العربي', nameEn: 'Arab Bank', typeAr: 'بنك', typeEn: 'Bank', locationAr: 'دوار الشهداء - نابلس', locationEn: 'Martyrs Circle - Nablus', rating: 4.1, reviews: 140, infoLabelAr: 'يفتح 8:30ص - 3م', infoLabelEn: 'Open 8:30AM - 3PM', aboutAr: 'فرع بنكي يقدم حسابات جارية وتوفير وخدمات تحويل الأموال.', aboutEn: 'A bank branch offering current and savings accounts and money transfer services.', photoQuery: 'bank exterior', colorValue: 0xff3b82f6 },
  { nameAr: 'صرافة الاتحاد', nameEn: 'Al-Ittihad Exchange', typeAr: 'محل صرافة', typeEn: 'Currency Exchange', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.4, reviews: 88, infoLabelAr: 'يفتح 9ص - 7م', infoLabelEn: 'Open 9AM - 7PM', aboutAr: 'محل صرافة موثوق لتبديل العملات الأجنبية بأسعار يومية محدثة.', aboutEn: 'A trusted currency exchange shop with daily updated rates.', photoQuery: 'currency exchange shop', colorValue: 0xffc9a227 },
];

const entertainment = [
  { nameAr: 'مدينة الملاهي نابلس', nameEn: 'Nablus Amusement Park', typeAr: 'مدينة ملاهي', typeEn: 'Amusement Park', locationAr: 'شرق نابلس', locationEn: 'East Nablus', rating: 4.3, reviews: 175, infoLabelAr: 'يفتح 3م - 11م', infoLabelEn: 'Open 3PM - 11PM', aboutAr: 'ألعاب متنوعة للأطفال والعائلات مع مساحات جلوس ومطاعم خفيفة.', aboutEn: 'A variety of rides for children and families, with seating areas and light dining.', photoQuery: 'amusement park rides', colorValue: 0xffe85d5d },
  { nameAr: 'سينما نابلس', nameEn: 'Nablus Cinema', typeAr: 'سينما', typeEn: 'Cinema', locationAr: 'رفيديا - نابلس', locationEn: 'Rafidia - Nablus', rating: 4.5, reviews: 230, infoLabelAr: 'يفتح 12م - 12ص', infoLabelEn: 'Open 12PM - 12AM', aboutAr: 'صالة عرض سينمائي بتقنية صوت وصورة حديثة وأحدث الأفلام.', aboutEn: 'A modern cinema hall with up-to-date sound and picture technology, showing the latest films.', photoQuery: 'cinema movie theater', colorValue: 0xff6c5ce7 },
  { nameAr: 'صالة بولينج نابلس', nameEn: 'Nablus Bowling Hall', typeAr: 'صالة ألعاب', typeEn: 'Bowling & Games Hall', locationAr: 'شارع الجامعة - نابلس', locationEn: 'University St. - Nablus', rating: 4.2, reviews: 98, infoLabelAr: 'يفتح 2م - 12ص', infoLabelEn: 'Open 2PM - 12AM', aboutAr: 'مسارات بولينج وألعاب فيديو مناسبة للشباب والعائلات.', aboutEn: 'Bowling lanes and video games suitable for youth and families.', photoQuery: 'bowling alley', colorValue: 0xff22c55e },
];

const government = [
  { nameAr: 'بلدية نابلس', nameEn: 'Nablus Municipality', typeAr: 'دائرة حكومية', typeEn: 'Government Office', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.0, reviews: 160, infoLabelAr: 'الدوام 8ص - 3م', infoLabelEn: 'Hours 8AM - 3PM', aboutAr: 'المقر الرئيسي لبلدية نابلس، يقدم خدمات الترخيص والمعاملات البلدية.', aboutEn: 'The main office of Nablus Municipality, providing licensing and municipal services.', photoQuery: 'municipality government building', colorValue: 0xff3b82f6 },
  { nameAr: 'دائرة الأحوال المدنية', nameEn: 'Civil Affairs Department', typeAr: 'دائرة حكومية', typeEn: 'Government Office', locationAr: 'شارع فيصل - نابلس', locationEn: 'Faisal St. - Nablus', rating: 3.9, reviews: 120, infoLabelAr: 'الدوام 8ص - 2:30م', infoLabelEn: 'Hours 8AM - 2:30PM', aboutAr: 'إصدار وتجديد الهويات ووثائق الأحوال المدنية.', aboutEn: 'Issuing and renewing IDs and civil status documents.', photoQuery: 'government office', colorValue: 0xff9c6b30 },
  { nameAr: 'مكتب البريد المركزي', nameEn: 'Central Post Office', typeAr: 'بريد', typeEn: 'Post Office', locationAr: 'وسط البلد - نابلس', locationEn: 'Downtown - Nablus', rating: 4.0, reviews: 70, infoLabelAr: 'الدوام 8ص - 3م', infoLabelEn: 'Hours 8AM - 3PM', aboutAr: 'خدمات البريد والطرود والتحويلات المالية.', aboutEn: 'Postal, parcel, and money transfer services.', photoQuery: 'post office', colorValue: 0xffc9a227 },
];

const LISTING_CATEGORIES = { transport, health, education, banks, entertainment, government };

// ==================== الأخبار ====================
const news = [
  { titleAr: 'افتتاح مشروع تطوير البلدة القديمة', titleEn: 'Old City Development Project Launched', dateAr: '10 مايو 2025', dateEn: 'May 10, 2025', categoryAr: 'تطوير', categoryEn: 'Development', categoryKey: 'development', summaryAr: 'مشروع جديد لترميم وتطوير أزقة البلدة القديمة والحفاظ على طابعها التراثي.', summaryEn: 'A new project to restore and develop the Old City alleys while preserving its heritage character.', bodyAr: 'أعلنت بلدية نابلس عن انطلاق مشروع شامل لتطوير البلدة القديمة يهدف إلى ترميم الأبنية التاريخية وتحسين البنية التحتية مع الحفاظ على الطابع المعماري الأصيل.', bodyEn: 'Nablus Municipality announced the launch of a comprehensive project to develop the Old City, aiming to restore historic buildings and improve infrastructure while preserving the original architectural character.' },
  { titleAr: 'نابلس تستضيف المؤتمر السياحي الدولي', titleEn: 'Nablus Hosts International Tourism Conference', dateAr: '8 مايو 2025', dateEn: 'May 8, 2025', categoryAr: 'سياحة', categoryEn: 'Tourism', categoryKey: 'tourism', summaryAr: 'استضافت المدينة مؤتمرًا دوليًا لبحث سبل تعزيز السياحة الداخلية والخارجية.', summaryEn: 'The city hosted an international conference to discuss ways to promote domestic and international tourism.', bodyAr: 'شهدت نابلس هذا الأسبوع فعاليات المؤتمر السياحي الدولي بمشاركة خبراء ومختصين من عدة دول.', bodyEn: 'Nablus witnessed this week the International Tourism Conference with the participation of experts from several countries.' },
  { titleAr: 'تحسن حركة السياحة في نابلس', titleEn: 'Tourism Activity Improves in Nablus', dateAr: '5 مايو 2025', dateEn: 'May 5, 2025', categoryAr: 'سياحة', categoryEn: 'Tourism', categoryKey: 'tourism', summaryAr: 'ارتفاع ملحوظ بعدد الزوار خلال الأشهر الأخيرة مقارنة بالعام الماضي.', summaryEn: 'A noticeable increase in visitor numbers over recent months compared to last year.', bodyAr: 'أظهرت إحصائيات حديثة ارتفاعًا ملحوظًا في أعداد الزوار القادمين إلى نابلس خلال الأشهر الأخيرة.', bodyEn: 'Recent statistics showed a noticeable increase in the number of visitors coming to Nablus in recent months.' },
  { titleAr: 'فعاليات ثقافية جديدة في المدينة', titleEn: 'New Cultural Events in the City', dateAr: '2 مايو 2025', dateEn: 'May 2, 2025', categoryAr: 'ثقافة', categoryEn: 'Culture', categoryKey: 'culture', summaryAr: 'سلسلة فعاليات ثقافية وفنية تنطلق هذا الشهر في عدة مواقع بالمدينة.', summaryEn: 'A series of cultural and artistic events kicks off this month at several locations in the city.', bodyAr: 'تنطلق هذا الشهر سلسلة من الفعاليات الثقافية والفنية في نابلس، تشمل معارض فنية وأمسيات شعرية.', bodyEn: 'A series of cultural and artistic events kicks off this month in Nablus, including art exhibitions and poetry evenings.' },
  { titleAr: 'مهرجان نابلس للتسوق ينطلق الشهر القادم', titleEn: 'Nablus Shopping Festival Launches Next Month', dateAr: '28 أبريل 2025', dateEn: 'April 28, 2025', categoryAr: 'فعاليات', categoryEn: 'Events', categoryKey: 'events', summaryAr: 'استعدادات مكثفة لانطلاق مهرجان التسوق السنوي بمشاركة عشرات المحال التجارية.', summaryEn: 'Intensive preparations underway for the annual shopping festival with dozens of participating stores.', bodyAr: 'تجري الاستعدادات على قدم وساق لانطلاق مهرجان نابلس للتسوق السنوي.', bodyEn: 'Preparations are in full swing for the launch of the annual Nablus Shopping Festival.' },
  { titleAr: 'توسعة شبكة المواصلات العامة داخل المدينة', titleEn: 'Expansion of Public Transportation Network in the City', dateAr: '20 أبريل 2025', dateEn: 'April 20, 2025', categoryAr: 'تطوير', categoryEn: 'Development', categoryKey: 'development', summaryAr: 'خطوط جديدة للمواصلات العامة لتسهيل الوصول لمختلف أحياء المدينة.', summaryEn: 'New public transportation lines to facilitate access to different neighborhoods of the city.', bodyAr: 'أعلنت الجهات المختصة عن توسعة شبكة المواصلات العامة داخل نابلس بإضافة خطوط جديدة.', bodyEn: 'Authorities announced the expansion of the public transportation network within Nablus by adding new lines.' },
];

function rgb(colorValue) {
  return colorValue & 0xffffff;
}

// SQLite ما بيدعم مصفوفات، فنخزّن القوائم (tags/amenities/gallery/categories) كنص مفصول بفواصل
function csv(list) {
  return Array.isArray(list) ? list.join(',') : '';
}

async function main() {
  console.log('🌱 بدء تعبئة قاعدة البيانات بالبيانات الحقيقية الحالية...');

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

  // الأقسام العامة اللي لسا على النموذج القديم
  for (const [category, items] of Object.entries(LISTING_CATEGORIES)) {
    const count = await prisma.listing.count({ where: { category } });
    if (count > 0) continue;
    for (const item of items) {
      await prisma.listing.create({
        data: { ...item, category, phone: '', iconCodePoint: PLACE_ICON, colorValue: rgb(item.colorValue) },
      });
    }
    console.log(`✅ تمت تعبئة تصنيف "${category}" بـ ${items.length} عنصر`);
  }

  // الأخبار
  const newsCount = await prisma.newsArticle.count();
  if (newsCount === 0) {
    for (const n of news) {
      await prisma.newsArticle.create({ data: n });
    }
    console.log(`✅ تمت تعبئة الأخبار بـ ${news.length} خبر`);
  }

  // المطاعم (البيانات الحقيقية المصدّرة من التطبيق)
  const restaurantCount = await prisma.restaurant.count();
  if (restaurantCount === 0) {
    for (const r of seedData.restaurants) {
      await prisma.restaurant.create({
        data: {
          nameAr: r.nameAr, nameEn: r.nameEn, categoryAr: r.categoryAr, categoryEn: r.categoryEn,
          cuisineKey: r.cuisineKey, locationAr: r.locationAr, locationEn: r.locationEn,
          rating: r.rating, reviews: r.reviews, priceRange: r.priceRange, priceTier: r.priceTier,
          time: r.time, aboutAr: r.aboutAr, aboutEn: r.aboutEn, phone: r.phone || '',
          iconCodePoint: r.iconCodePoint, colorValue: rgb(r.colorValue),
        },
      });
    }
    console.log(`✅ تمت تعبئة المطاعم بـ ${seedData.restaurants.length} مطعم`);
  }

  // الفنادق
  const hotelCount = await prisma.hotel.count();
  if (hotelCount === 0) {
    for (const h of seedData.hotels) {
      await prisma.hotel.create({
        data: {
          nameAr: h.nameAr, nameEn: h.nameEn, typeAr: h.typeAr, typeEn: h.typeEn,
          locationAr: h.locationAr, locationEn: h.locationEn, rating: h.rating, reviews: h.reviews,
          priceInfoAr: h.priceInfoAr, priceInfoEn: h.priceInfoEn, priceTier: h.priceTier,
          hoursAr: h.hoursAr, hoursEn: h.hoursEn, aboutAr: h.aboutAr, aboutEn: h.aboutEn,
          phone: h.phone || '', gallery: csv(h.gallery), amenities: csv(h.amenities), tags: csv(h.tags),
          iconCodePoint: h.iconCodePoint, colorValue: rgb(h.colorValue), isFeatured: !!h.isFeatured,
        },
      });
    }
    console.log(`✅ تمت تعبئة الفنادق بـ ${seedData.hotels.length} فندق`);
  }

  // الصيدليات
  const pharmacyCount = await prisma.pharmacy.count();
  if (pharmacyCount === 0) {
    for (const p of seedData.pharmacies) {
      await prisma.pharmacy.create({
        data: {
          nameAr: p.nameAr, nameEn: p.nameEn, locationAr: p.locationAr, locationEn: p.locationEn,
          rating: p.rating, reviews: p.reviews, hoursAr: p.hoursAr, hoursEn: p.hoursEn,
          is24Hours: !!p.is24Hours, hasDelivery: !!p.hasDelivery, aboutAr: p.aboutAr, aboutEn: p.aboutEn,
          phone: p.phone || '', tags: csv(p.tags), iconCodePoint: p.iconCodePoint,
          colorValue: rgb(p.colorValue), isFeatured: !!p.isFeatured,
        },
      });
    }
    console.log(`✅ تمت تعبئة الصيدليات بـ ${seedData.pharmacies.length} صيدلية`);
  }

  // المعالم السياحية
  const attractionCount = await prisma.attraction.count();
  if (attractionCount === 0) {
    for (const a of seedData.attractions) {
      await prisma.attraction.create({
        data: {
          nameAr: a.nameAr, nameEn: a.nameEn, categories: csv(a.categories),
          locationAr: a.locationAr, locationEn: a.locationEn, rating: a.rating, reviews: a.reviews,
          aboutAr: a.aboutAr, aboutEn: a.aboutEn, visitHoursAr: a.visitHoursAr, visitHoursEn: a.visitHoursEn,
          entryFeeAr: a.entryFeeAr, entryFeeEn: a.entryFeeEn, iconCodePoint: a.iconCodePoint,
          colorValue: rgb(a.colorValue), isFeatured: !!a.isFeatured,
        },
      });
    }
    console.log(`✅ تمت تعبئة المعالم بـ ${seedData.attractions.length} معلم`);
  }

  // المراكز التجارية (تسوق)
  const shoppingCount = await prisma.shoppingVenue.count();
  if (shoppingCount === 0) {
    for (const s of seedData.shoppingVenues) {
      await prisma.shoppingVenue.create({
        data: {
          nameAr: s.nameAr, nameEn: s.nameEn, typeAr: s.typeAr, typeEn: s.typeEn,
          locationAr: s.locationAr, locationEn: s.locationEn, rating: s.rating, reviews: s.reviews,
          hoursAr: s.hoursAr, hoursEn: s.hoursEn, aboutAr: s.aboutAr, aboutEn: s.aboutEn,
          phone: s.phone || '', iconCodePoint: s.iconCodePoint, colorValue: rgb(s.colorValue),
          isFeatured: !!s.isFeatured,
        },
      });
    }
    console.log(`✅ تمت تعبئة المراكز التجارية بـ ${seedData.shoppingVenues.length} مركز`);
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
