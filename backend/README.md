# باك اند دليل نابلس الذكي

سيرفر حقيقي (Node.js + Express + SQLite عبر Prisma) لتطبيق دليل نابلس الذكي.
قاعدة البيانات ملف واحد محفوظ جوا مجلد `backend` نفسه (`prisma/dev.db`) — **بدون
تسجيل أي حساب، بدون أي رابط اتصال، بدون إنترنت.** يوفر: تسجيل حسابات حقيقي، تسجيل
دخول أدمن، وقاعدة بيانات حقيقية للمطاعم والفنادق والصيدليات والمعالم والتسوق وكل
الأقسام والأخبار، مع رفع صور حقيقية وتخزينها على السيرفر.

## 0. ثبّتي Node.js أولًا (لو مش مثبّت عندك)

هاد السيرفر يحتاج Node.js حتى يشتغل. لو ما جربتيه قبل هيك على هاد الجهاز:
1. روحي على [nodejs.org](https://nodejs.org) ونزّلي النسخة "LTS" (الموصى فيها).
2. ثبّتيها بالإعدادات الافتراضية (Next, Next, Install).
3. أعيدي فتح الطرفية (Terminal) بعد التثبيت.

هاي الخطوة الوحيدة اللي بتحتاجي تعمليها إنتي. الباقي كله أوامر تنسخيها وتشغّليها.

## 1. جهّزي السيرفر

```bash
cd backend
npm install
cp .env.example .env
```

ملف `.env` جاهز بإعدادات افتراضية شغّالة فورًا (قاعدة بيانات محلية + حساب أدمن
`admin` / `admin123`) — ما في شي لازم تغيّريه فيه إلا إذا حبيتي.

## 2. أنشئي الجداول وعبّي البيانات الابتدائية

```bash
npx prisma migrate dev --name init
npm run seed
```

هاي الخطوة بتنشئ ملف قاعدة البيانات (`prisma/dev.db`) وكل الجداول، وبتعبّيها بنفس
البيانات الحقيقية الشغالة فعليًا بالتطبيق هلق (36 مطعم، 11 فندق، 10 صيدليات، 16 معلم
سياحي، مركزين تجاريين، مواصلات، صحة، تعليم، بنوك، ترفيه، خدمات حكومية، وأخبار)،
بالإضافة لحساب الأدمن. البيانات مصدّرة من `test/_export_seed_test.dart` لملف
`prisma/seed_data.json` — لو عدّلتي بيانات التطبيق لاحقًا وبدك تحدّثي قاعدة البيانات،
شغّلي:
```bash
flutter test test/_export_seed_test.dart
```
من جذر المشروع، وانسخي `seed_export.json` الناتج فوق `backend/prisma/seed_data.json`.

## 3. شغّلي السيرفر

```bash
npm run dev
```

السيرفر رح يشتغل على `http://localhost:4000`. جربي:

```bash
curl http://localhost:4000/api/health
```

## نقاط الوصول (API Endpoints)

### المصادقة (`/api/auth`)
| Method | Path | الوصف |
|---|---|---|
| POST | `/register` | `{name, email, password}` → إنشاء حساب جديد |
| POST | `/login` | `{email, password}` → تسجيل دخول مستخدم |
| POST | `/admin-login` | `{username, password}` → تسجيل دخول أدمن |
| GET | `/check-email/:email` | التحقق من وجود حساب (لخطوة نسيت كلمة السر) |
| POST | `/reset-password` | `{email, newPassword}` → تعيين كلمة مرور جديدة |

كل من `/login` و `/register` و `/admin-login` بيرجعوا `{token, user}`. حطي الـ token
بكل طلب لاحق كـ header: `Authorization: Bearer <token>`.

### الأماكن العامة (`/api/listings`)
مواصلات، صحة، تعليم، بنوك، ترفيه، خدمات حكومية — كلها بجدول واحد مع حقل `category`.

| Method | Path | صلاحية | الوصف |
|---|---|---|---|
| GET | `/?category=transport` | عام | كل العناصر (فلترة اختيارية حسب القسم) |
| GET | `/:id` | عام | عنصر واحد |
| POST | `/` | أدمن | إضافة (multipart/form-data، حقل `image` اختياري) |
| PUT | `/:id` | أدمن | تعديل (multipart/form-data) |
| DELETE | `/:id` | أدمن | حذف |

القيم الممكنة لـ `category`: `transport`, `health`, `education`, `banks`,
`entertainment`, `government`.

### المطاعم، الفنادق، الصيدليات، المعالم، التسوق
كل قسم من هدول إله جدول ونقاط وصول خاصة فيه (نفس نمط `/api/listings` بالضبط —
GET عام، POST/PUT/DELETE أدمن فقط، صورة عبر `multipart/form-data`):

| القسم | المسار |
|---|---|
| المطاعم | `/api/restaurants` |
| الفنادق | `/api/hotels` |
| الصيدليات | `/api/pharmacies` |
| المعالم السياحية | `/api/attractions` |
| المراكز التجارية (تسوق) | `/api/shopping` |

حقول إضافية خاصة بكل قسم — القوائم (زي `tags`) بترجع وبتترسل كنص واحد مفصول بفواصل
(مثلاً `"wifi,parking"`) مش كمصفوفة JSON، لأنه SQLite ما بيدعم مصفوفات:
- **الفنادق**: `gallery` و`amenities` و`tags`.
- **الصيدليات**: `is24Hours` و`hasDelivery` (`true`/`false`)، و`tags`.
- **المعالم**: `categories` (مثلاً `"historical,oldCity"`)، و`visitHoursAr/En`، و`entryFeeAr/En`.

### الأخبار (`/api/news`)
نفس النمط أيضًا.

### الصور
أي صورة تترفع بترد بمسار زي `/uploads/xxxxx.jpg`، وبتنعرض مباشرة من
`http://localhost:4000/uploads/xxxxx.jpg`.

## أدوات مفيدة

```bash
npx prisma studio   # واجهة رسومية لتصفح وتعديل قاعدة البيانات مباشرة بالمتصفح
```
