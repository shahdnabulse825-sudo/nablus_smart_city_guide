# باك اند دليل نابلس الذكي

سيرفر حقيقي (Node.js + Express + PostgreSQL عبر Prisma) لتطبيق دليل نابلس الذكي.
يوفر: تسجيل حسابات حقيقي، تسجيل دخول أدمن، وقاعدة بيانات حقيقية للمطاعم والفنادق
والمعالم وكل الأقسام والأخبار، مع رفع صور حقيقية وتخزينها على السيرفر.

## 1. أنشئي قاعدة بيانات مجانية على Neon

1. روحي على [neon.tech](https://neon.tech) وسجّلي حساب مجاني (بدون بطاقة ائتمان).
2. أنشئي مشروع جديد (Project).
3. من لوحة التحكم، انسخي **Connection string** (رابط يبدأ بـ `postgresql://...`).

## 2. جهّزي السيرفر

```bash
cd backend
npm install
cp .env.example .env
```

افتحي ملف `.env` وحطي:
- `DATABASE_URL` = رابط الاتصال اللي نسختيه من Neon
- `JWT_SECRET` = أي نص عشوائي طويل (لتوقيع رموز الدخول)
- `ADMIN_USERNAME` / `ADMIN_PASSWORD` = بيانات حساب الأدمن اللي بدك ياها (افتراضيًا `admin` / `admin123`)

## 3. أنشئي الجداول وعبّي البيانات الابتدائية

```bash
npx prisma migrate dev --name init
npm run seed
```

هاي الخطوة بتنشئ كل الجداول على قاعدة بيانات Neon، وبتعبّيها بنفس البيانات اللي
كانت موجودة بالتطبيق (35 مطعم، فنادق، معالم سياحية، تسوق، مواصلات، صحة، صيدليات،
تعليم، بنوك، ترفيه، خدمات حكومية، وأخبار)، بالإضافة لحساب الأدمن.

## 4. شغّلي السيرفر

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
فنادق، سياحة ومعالم، تسوق، مواصلات، صحة، صيدليات، تعليم، بنوك، ترفيه، خدمات حكومية
— كلها بجدول واحد مع حقل `category`.

| Method | Path | صلاحية | الوصف |
|---|---|---|---|
| GET | `/?category=hotels` | عام | كل العناصر (فلترة اختيارية حسب القسم) |
| GET | `/:id` | عام | عنصر واحد |
| POST | `/` | أدمن | إضافة (multipart/form-data، حقل `image` اختياري) |
| PUT | `/:id` | أدمن | تعديل (multipart/form-data) |
| DELETE | `/:id` | أدمن | حذف |

القيم الممكنة لـ `category`: `hotels`, `attractions`, `shopping`, `transport`,
`health`, `pharmacies`, `education`, `banks`, `entertainment`, `government`.

### المطاعم (`/api/restaurants`)
نفس نمط `/api/listings` (GET عام، POST/PUT/DELETE أدمن فقط).

### الأخبار (`/api/news`)
نفس النمط أيضًا.

### الصور
أي صورة تترفع بترد بمسار زي `/uploads/xxxxx.jpg`، وبتنعرض مباشرة من
`http://localhost:4000/uploads/xxxxx.jpg`.

## أدوات مفيدة

```bash
npx prisma studio   # واجهة رسومية لتصفح وتعديل قاعدة البيانات مباشرة بالمتصفح
```
