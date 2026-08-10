const express = require('express');
const prisma = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// حدود المستخدم المجاني اليومية للمساعد الذكي — نفس الأرقام المستخدمة بفحص
// الحصة داخل aiChat.js (FREE_DAILY_TEXT_LIMIT / FREE_DAILY_VOICE_LIMIT).
const FREE_DAILY_TEXT_LIMIT = 10;
const FREE_DAILY_VOICE_LIMIT = 3;

// ثلاث اشتراكات منفصلة (à la carte) — كل وحدة تُشترى لحالها بسعرها، بدل باقة
// واحدة شاملة. "text" بيفتح كمان مخطط الرحلة وراوي الجولات لأنهم بيستخدموا
// نفس حصة الأسئلة النصية تحت الغطاء.
const PRICES = { text: 20, voice: 30, priority: 25 };
const FEATURE_FIELD = {
  text: 'premiumText',
  voice: 'premiumVoice',
  priority: 'premiumPriority',
};

function publicStatus(user) {
  const today = new Date().toISOString().slice(0, 10);
  const sameDay = user.aiUsageDate === today;
  return {
    premiumText: user.premiumText,
    premiumVoice: user.premiumVoice,
    premiumPriority: user.premiumPriority,
    textUsedToday: sameDay ? user.aiTextCount : 0,
    voiceUsedToday: sameDay ? user.aiVoiceCount : 0,
    textLimit: FREE_DAILY_TEXT_LIMIT,
    voiceLimit: FREE_DAILY_VOICE_LIMIT,
    prices: PRICES,
  };
}

// حالة الاشتراكات الثلاثة + استخدام اليوم — تُستخدم بشاشة "الاشتراك المميز".
router.get('/status', requireAuth, async (req, res) => {
  const user = await prisma.user.findUnique({ where: { id: req.user.id } });
  if (!user) return res.status(404).json({ error: 'الحساب غير موجود' });
  res.json(publicStatus(user));
});

// اشتراك بميزة واحدة محددة (text | voice | priority) — لا توجد بوابة دفع
// حقيقية بهذا المشروع الأكاديمي (Stripe/PayPal خارج نطاقه)، فهاي "دفع وهمي"
// بالكامل: شاشة الدفع بالتطبيق بتقبل أي بيانات بطاقة شكليًا ثم تستدعي هذا
// المسار مباشرة لتفعيل الميزة المطلوبة، لغرض العرض التوضيحي فقط.
router.post('/upgrade', requireAuth, async (req, res) => {
  const feature = req.body?.feature;
  const field = FEATURE_FIELD[feature];
  if (!field) return res.status(400).json({ error: 'ميزة اشتراك غير معروفة' });

  const user = await prisma.user.update({
    where: { id: req.user.id },
    data: { [field]: true },
  });
  res.json(publicStatus(user));
});

// إلغاء اشتراك ميزة واحدة (بدون تأكيد دفع لأنه ما في فوترة حقيقية متكررة —
// فقط لتقدروا تجربوا الحالتين المجانية والمميزة أثناء العرض).
router.post('/cancel', requireAuth, async (req, res) => {
  const feature = req.body?.feature;
  const field = FEATURE_FIELD[feature];
  if (!field) return res.status(400).json({ error: 'ميزة اشتراك غير معروفة' });

  const user = await prisma.user.update({
    where: { id: req.user.id },
    data: { [field]: false },
  });
  res.json(publicStatus(user));
});

module.exports = router;
