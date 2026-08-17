require('dotenv').config();
const express = require('express');
require('express-async-errors'); // يلتقط أي خطأ من دوال راوترات async ويمرره للمعالج العام (بدل تعطيل السيرفر بالكامل)
const cors = require('cors');
const path = require('path');

const authRoutes = require('./routes/auth');
const listingsRoutes = require('./routes/listings');
const restaurantsRoutes = require('./routes/restaurants');
const hotelsRoutes = require('./routes/hotels');
const pharmaciesRoutes = require('./routes/pharmacies');
const attractionsRoutes = require('./routes/attractions');
const shoppingRoutes = require('./routes/shopping');
const newsRoutes = require('./routes/news');
const eventsRoutes = require('./routes/events');
const visitsRoutes = require('./routes/visits');
const categoryImagesRoutes = require('./routes/categoryImages');
const favoritesRoutes = require('./routes/favorites');
const placeViewsRoutes = require('./routes/placeViews');
const aiChatRoutes = require('./routes/aiChat');
const reviewsRoutes = require('./routes/reviews');
const feedbackRoutes = require('./routes/feedback');
const checkpointsRoutes = require('./routes/checkpoints');
const trafficAlertsRoutes = require('./routes/trafficAlerts');
const promotionsRoutes = require('./routes/promotions');
const subscriptionRoutes = require('./routes/subscription');
const ownershipRequestsRoutes = require('./routes/ownershipRequests');

const app = express();

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));
// نسخة APK حقيقية قابلة للتحميل المباشر (بدون نشر على Google Play) — يفتحها
// المستخدم عبر رمز QR أو زر "حمل التطبيق" بالصفحة الرئيسية، بشرط يكون جهازه
// على نفس شبكة الواي فاي متل جهاز السيرفر (ما في استضافة عامة لهاد المشروع).
app.use('/downloads', express.static(path.join(__dirname, '..', 'downloads')));

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'nablus-smart-guide-backend' });
});

app.use('/api/auth', authRoutes);
app.use('/api/listings', listingsRoutes);
app.use('/api/restaurants', restaurantsRoutes);
app.use('/api/hotels', hotelsRoutes);
app.use('/api/pharmacies', pharmaciesRoutes);
app.use('/api/attractions', attractionsRoutes);
app.use('/api/shopping', shoppingRoutes);
app.use('/api/news', newsRoutes);
app.use('/api/events', eventsRoutes);
app.use('/api/visits', visitsRoutes);
app.use('/api/category-images', categoryImagesRoutes);
app.use('/api/favorites', favoritesRoutes);
app.use('/api/place-views', placeViewsRoutes);
app.use('/api/ai-chat', aiChatRoutes);
app.use('/api/reviews', reviewsRoutes);
app.use('/api/feedback', feedbackRoutes);
app.use('/api/checkpoints', checkpointsRoutes);
app.use('/api/traffic-alerts', trafficAlertsRoutes);
app.use('/api/promotions', promotionsRoutes);
app.use('/api/subscription', subscriptionRoutes);
app.use('/api/ownership-requests', ownershipRequestsRoutes);

// معالج أخطاء عام (يلتقط أخطاء multer، وفشل الاتصال بقاعدة البيانات، وأي استثناء غير متوقع بالراوترات)
app.use((err, req, res, next) => {
  console.error(err);
  if (err.name === 'PrismaClientInitializationError' || err.code === 'P1001') {
    return res.status(503).json({ error: 'تعذر الاتصال بقاعدة البيانات. تأكدي من صحة DATABASE_URL بملف .env' });
  }
  if (err.code === 'P2025') {
    return res.status(404).json({ error: 'العنصر غير موجود' });
  }
  res.status(err.status || 500).json({ error: err.message || 'خطأ غير متوقع بالسيرفر' });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`✅ السيرفر يعمل على http://localhost:${PORT}`);
});
