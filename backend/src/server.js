require('dotenv').config();
const express = require('express');
require('express-async-errors'); // يلتقط أي خطأ من دوال راوترات async ويمرره للمعالج العام (بدل تعطيل السيرفر بالكامل)
const cors = require('cors');
const path = require('path');

const authRoutes = require('./routes/auth');
const listingsRoutes = require('./routes/listings');
const restaurantsRoutes = require('./routes/restaurants');
const newsRoutes = require('./routes/news');

const app = express();

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'nablus-smart-guide-backend' });
});

app.use('/api/auth', authRoutes);
app.use('/api/listings', listingsRoutes);
app.use('/api/restaurants', restaurantsRoutes);
app.use('/api/news', newsRoutes);

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
