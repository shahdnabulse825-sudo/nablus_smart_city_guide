const express = require('express');
const multer = require('multer');
const prisma = require('../db');
const { optionalAuth } = require('../middleware/auth');

const router = express.Router();

// حدود المستخدم المجاني اليومية — نفس الأرقام المعروضة بشاشة "الاشتراك المميز"
// (subscription.js). الضيوف (بدون تسجيل دخول، req.user غير موجود) ما إلهم حد
// محفوظ بقاعدة البيانات، فبيتعاملوا كأنهم دايمًا ضمن الحد المجاني بدون تتبع —
// تبسيط مقصود، الحد الحقيقي بيصير فعّال بس بعد تسجيل الدخول.
const FREE_DAILY_TEXT_LIMIT = 10;
const FREE_DAILY_VOICE_LIMIT = 3;

// بتتحقق من حصة المستخدم اليومية وتستهلك واحدة منها لو مسموح — وبترجع
// {allowed:false, error} برسالة عربية واضحة لو وصل الحد ومش مشترك بالاشتراك
// المناسب (premiumText لـ'text'، premiumVoice لـ'voice' — كل وحدة بتتخطى
// الفحص لحالها بس، مش باقة واحدة شاملة). بترجع كمان premiumPriority حتى
// يقدر المسار الرئيسي يختار النموذج الأقوى لمشتركي أولوية الاستجابة.
async function checkAndConsumeQuota(userId, kind) {
  if (!userId) return { allowed: true, premiumPriority: false };
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) return { allowed: true, premiumPriority: false };

  const isPremiumForKind = kind === 'voice' ? user.premiumVoice : user.premiumText;
  if (isPremiumForKind) return { allowed: true, premiumPriority: user.premiumPriority };

  const today = new Date().toISOString().slice(0, 10);
  const sameDay = user.aiUsageDate === today;
  const textCount = sameDay ? user.aiTextCount : 0;
  const voiceCount = sameDay ? user.aiVoiceCount : 0;
  const current = kind === 'voice' ? voiceCount : textCount;
  const limit = kind === 'voice' ? FREE_DAILY_VOICE_LIMIT : FREE_DAILY_TEXT_LIMIT;

  if (current >= limit) {
    return {
      allowed: false,
      premiumPriority: user.premiumPriority,
      error:
        kind === 'voice'
          ? `وصلتِ حد الاستماع الصوتي المجاني اليوم (${FREE_DAILY_VOICE_LIMIT} استماعات) — اشتركي باستماع غير محدود`
          : `وصلتِ حد أسئلة المساعد الذكي المجاني اليوم (${FREE_DAILY_TEXT_LIMIT} أسئلة) — اشتركي بأسئلة غير محدودة`,
    };
  }

  await prisma.user.update({
    where: { id: userId },
    data: {
      aiUsageDate: today,
      aiTextCount: kind === 'voice' ? textCount : textCount + 1,
      aiVoiceCount: kind === 'voice' ? voiceCount + 1 : voiceCount,
    },
  });
  return { allowed: true, premiumPriority: user.premiumPriority };
}

// تسجيل صوتي مؤقت بالذاكرة فقط (منبعته لـ Groq وبنرجع النص، ما منخزّنه على القرص)
const audioUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 15 * 1024 * 1024 }, // 15MB كحد أقصى
});

// تحويل رسالة صوتية لنص عبر Whisper (Groq) — تُستخدم قبل إرسال الرسالة كنص عادي
// لمسار /api/ai-chat العادي، حتى تجربة "اضغطي وسجّلي" تشتغل بأي لغة تحكيها.
router.post('/transcribe', audioUpload.single('audio'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'ملف صوتي مطلوب' });
  const apiKey = process.env.GROQ_API_KEY;
  if (!apiKey) {
    return res.status(503).json({ error: 'المساعد الذكي غير مُفعّل بعد (لا يوجد مفتاح Groq)' });
  }
  const lang = req.body?.lang === 'en' ? 'en' : 'ar';

  const form = new FormData();
  form.append(
    'file',
    new Blob([req.file.buffer], { type: req.file.mimetype || 'audio/m4a' }),
    req.file.originalname || 'audio.m4a',
  );
  // whisper-large-v3 (مش نسخة turbo) — turbo أسرع بس دقّته أقل خصوصًا بالعربي/
  // الأسماء المحلية، وهاد تطبيق أساسه عربي فالدقة أهم من سرعة الرد بجزء ثانية.
  form.append('model', 'whisper-large-v3');
  form.append('language', lang);
  form.append('response_format', 'json');
  // تلميح مفردات — بيساعد Whisper يتعرف صح على أسماء أماكن نابلس المحلية
  // (بدل ما يخمّن كلمة عربية عامة تشبهها صوتيًا).
  form.append(
    'prompt',
    lang === 'ar'
      ? 'نابلس، البلدة القديمة، رفيديا، الكنافة النابلسية، جبل جرزيم، مطاعم، فنادق، صيدليات، معالم سياحية، تسوق'
      : 'Nablus, Old City, Rafidia, Kunafa, Mount Gerizim, restaurants, hotels, pharmacies, attractions, shopping',
  );

  const groqRes = await fetch('https://api.groq.com/openai/v1/audio/transcriptions', {
    method: 'POST',
    headers: { Authorization: `Bearer ${apiKey}` },
    body: form,
  });

  if (!groqRes.ok) {
    const errBody = await groqRes.text().catch(() => '');
    console.error('Groq transcription error:', groqRes.status, errBody);
    return res.status(502).json({ error: 'تعذّر تحويل الصوت لنص — حاولي بعد شوي' });
  }

  const data = await groqRes.json();
  res.json({ text: (data?.text || '').trim() });
});

// تحويل نص (زي قصة راوي الجولات) لصوت حقيقي — نموذج Orpheus العربي عبر Groq،
// بصوت "sultan" (اخترناه بعد ما جرّبنا كل الأصوات المتاحة مع المستخدمة).
// لازم موافقة على شروط النموذج من console.groq.com قبل ما يشتغل.
router.post('/speak', optionalAuth, async (req, res) => {
  const text = (req.body?.text || '').toString().trim().slice(0, 2000);
  if (!text) return res.status(400).json({ error: 'text مطلوب' });
  const apiKey = process.env.GROQ_API_KEY;
  if (!apiKey) {
    return res.status(503).json({ error: 'المساعد الذكي غير مُفعّل بعد (لا يوجد مفتاح Groq)' });
  }

  const quota = await checkAndConsumeQuota(req.user?.id, 'voice');
  if (!quota.allowed) return res.status(429).json({ error: quota.error });

  const groqRes = await fetch('https://api.groq.com/openai/v1/audio/speech', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: process.env.GROQ_TTS_MODEL || 'canopylabs/orpheus-arabic-saudi',
      input: text,
      voice: process.env.GROQ_TTS_VOICE || 'sultan',
      response_format: 'wav',
    }),
  });

  if (!groqRes.ok) {
    const errBody = await groqRes.text().catch(() => '');
    console.error('Groq TTS error:', groqRes.status, errBody);
    // الحد اليومي المجاني لتحويل النص لصوت — بيتجدد تلقائيًا، مش خطأ دائم،
    // فبنوضحله للمستخدم صراحة بدل رسالة عامة مضلّلة.
    if (groqRes.status === 429) {
      return res.status(429).json({
        error: 'وصلنا الحد اليومي المجاني لتحويل النص لصوت — بيتجدد تلقائيًا بعد كم ساعة، جربي وقتها',
      });
    }
    return res.status(502).json({ error: 'تعذّر توليد الصوت — حاولي بعد شوي' });
  }

  const audioBuffer = Buffer.from(await groqRes.arrayBuffer());
  res.set('Content-Type', 'audio/wav');
  res.send(audioBuffer);
});

// كلمات وظيفية عربية/إنجليزية شائعة نتجاهلها عند استخراج كلمات البحث من رسالة
// المستخدم — حتى ما نطلع نتائج عشوائية بسبب كلمات زي "في"/"the"/"مطعم كويس".
const STOPWORDS = new Set([
  'في', 'من', 'على', 'إلى', 'عن', 'مع', 'هل', 'ما', 'وين', 'أي', 'كل', 'هذا', 'هذه',
  'the', 'a', 'an', 'in', 'on', 'at', 'to', 'of', 'is', 'are', 'me', 'my', 'best',
]);

function extractKeywords(message) {
  return message
    .split(/[\s,.،؟?!]+/)
    .map((w) => w.trim())
    .filter((w) => w.length >= 3 && !STOPWORDS.has(w.toLowerCase()));
}

// ==================== تحمّل الأخطاء الإملائية (عربي/إنجليزي) ====================
// توحيد الحروف العربية المتشابهة إملائيًا/الحركات حتى المقارنة تتجاهل فروق
// شائعة (أ/إ/آ ← ا، ى ← ي، ة ← ه) وتشطب التشكيل والتطويل — بدون هيك أي فرق
// بسيط بالكتابة بيكسر أي تطابق حرفي.
function normalizeArabic(s) {
  return s
    .normalize('NFKD')
    .replace(/[ً-ٰٟ]/g, '')
    .replace(/ـ/g, '')
    .replace(/[أإآ]/g, 'ا')
    .replace(/ى/g, 'ي')
    .replace(/ة/g, 'ه')
    .toLowerCase()
    .trim();
}

function levenshtein(a, b) {
  const m = a.length;
  const n = b.length;
  if (m === 0) return n;
  if (n === 0) return m;
  const dp = Array.from({ length: m + 1 }, () => new Array(n + 1).fill(0));
  for (let i = 0; i <= m; i++) dp[i][0] = i;
  for (let j = 0; j <= n; j++) dp[0][j] = j;
  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      dp[i][j] = a[i - 1] === b[j - 1]
        ? dp[i - 1][j - 1]
        : 1 + Math.min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]);
    }
  }
  return dp[m][n];
}

// بترجع true لو الكلمتين قريبين لبعض بحدود "مسافة تحرير" متناسبة مع طولهم —
// كلمة قصيرة بتسمح بفرق حرف واحد بس، كلمة أطول بتسمح بفرقين، حتى ما نطلع
// تطابقات عشوائية بين كلمات قصيرة مختلفة تمامًا زي "شي"/"في".
function isFuzzyMatch(a, b) {
  const na = normalizeArabic(a);
  const nb = normalizeArabic(b);
  if (!na || !nb) return false;
  if (na.includes(nb) || nb.includes(na)) return true;
  const maxLen = Math.max(na.length, nb.length);
  const tolerance = maxLen <= 4 ? 1 : maxLen <= 8 ? 2 : 3;
  return levenshtein(na, nb) <= tolerance;
}

// مرادفات كل قسم (عربي/إنجليزي، مفرد/جمع) — تُطابق بمرونة إملائية (isFuzzyMatch)
// مش بالحرف، حتى غلطة بسيطة زي "البطاعم" بدل "المطاعم" تنفهم صح كـ"مطاعم".
const CATEGORY_KEYWORDS = {
  restaurant: ['مطعم', 'مطاعم', 'المطعم', 'المطاعم', 'اكل', 'أكل', 'restaurant', 'restaurants', 'food'],
  hotel: ['فندق', 'فنادق', 'الفندق', 'الفنادق', 'hotel', 'hotels'],
  pharmacy: ['صيدلية', 'صيدليات', 'الصيدلية', 'الصيدليات', 'دواء', 'pharmacy', 'pharmacies'],
  attraction: ['معلم', 'معالم', 'المعالم', 'سياحة', 'سياحي', 'attraction', 'attractions', 'landmark'],
  shopping: ['تسوق', 'محل', 'محلات', 'التسوق', 'shopping', 'shop', 'shops', 'mall'],
};

// بتدوّر بكلمات الرسالة عن أي تصنيف مطابق (بمرونة إملائية) — بترجع أول
// تصنيف تلاقيه، أو null لو ما في.
function matchCategory(keywords) {
  for (const [category, variants] of Object.entries(CATEGORY_KEYWORDS)) {
    if (keywords.some((k) => variants.some((v) => isFuzzyMatch(k, v)))) {
      return category;
    }
  }
  return null;
}

// كلمات بتدل إنه المستخدم بده يخطط يوم/رحلة كاملة، مش يسأل عن مكان محدد —
// هاي الحالة محتاجة استرجاع بيانات مختلف (تشكيلة متنوعة من أفضل الأماكن بكل
// تصنيف)، مش بحث بكلمات مفتاحية عادي (اللي رح يرجّع نتائج فاضية أو عشوائية).
const TRIP_PLANNING_PATTERNS = [
  'خطط', 'خطة', 'برنامج', 'رحلة', 'جولة', 'يوم كامل', 'برنامج يوم',
  'plan', 'itinerary', 'schedule', 'day trip', 'trip',
];

function isTripPlanningRequest(message) {
  const text = message.toLowerCase();
  return TRIP_PLANNING_PATTERNS.some((p) => text.includes(p));
}

// كلمات بتدل إنه المستخدم بده قصة/رواية سردية عن مكان، مش وصف جاف بالنقاط —
// منفصلة عن كلمات تخطيط الرحلة حتى ما تتعارض معها.
const TOUR_NARRATION_PATTERNS = [
  'قصة', 'قصه', 'احكيلي', 'احكي لي', 'حدثني عن', 'روي لي', 'راوي',
  'tell me the story', 'narrate', 'walking tour', 'story of',
];

function isTourNarrationRequest(message) {
  const text = message.toLowerCase();
  return TOUR_NARRATION_PATTERNS.some((p) => text.includes(p));
}

// بتدور عن رقم ميزانية بالرسالة (بالعربي أو الإنجليزي) بصيغ شائعة مختلفة —
// بترجع null لو ما لقت شي، حتى ما نفترض ميزانية المستخدم ما ذكرها أصلاً.
function extractBudget(message) {
  const patterns = [
    /(\d+(?:\.\d+)?)\s*(?:شيكل|شيقل|₪|nis|ils)/i,
    /(?:شيكل|شيقل|₪|nis|ils)\s*(\d+(?:\.\d+)?)/i,
    /ميزاني[ةه]\s*(?:ب|بـ)?\s*(\d+(?:\.\d+)?)/,
    /budget\s*(?:of|:)?\s*(\d+(?:\.\d+)?)/i,
  ];
  for (const re of patterns) {
    const m = message.match(re);
    if (m) {
      const n = Number(m[1]);
      if (Number.isFinite(n) && n > 0) return n;
    }
  }
  return null;
}

const _normalizePlaces = (rows, categoryAr, categoryEn) =>
  rows.map((r) => ({
    nameAr: r.nameAr,
    nameEn: r.nameEn,
    categoryAr: r.categoryAr || r.typeAr || categoryAr,
    categoryEn: r.categoryEn || r.typeEn || categoryEn,
    locationAr: r.locationAr,
    rating: r.rating,
    aboutAr: r.aboutAr,
  }));

// جدول كل قسم تجاري (بدون "الخدمات" العامة listings — ما إلها اسم تصنيف
// مفرد واحد واضح نطابقه بمرونة) — يُستخدم لما الرسالة تذكر اسم قسم كامل
// (زي "مطاعم" أو حتى "البطاعم" بغلطة إملائية) بدل اسم مكان محدد.
const CATEGORY_TABLE = {
  restaurant: { model: () => prisma.restaurant, categoryAr: 'مطعم', categoryEn: 'Restaurant' },
  hotel: { model: () => prisma.hotel, categoryAr: 'فندق', categoryEn: 'Hotel' },
  pharmacy: { model: () => prisma.pharmacy, categoryAr: 'صيدلية', categoryEn: 'Pharmacy' },
  attraction: { model: () => prisma.attraction, categoryAr: 'معلم سياحي', categoryEn: 'Attraction' },
  shopping: { model: () => prisma.shoppingVenue, categoryAr: 'تسوق', categoryEn: 'Shopping' },
};

/// بتدوّر بالقاعدة الحقيقية (نفس بيانات التطبيق) عن أماكن مطابقة لكلمات رسالة
/// المستخدم — هاي "الاسترجاع" (retrieval) اللي بيخلي رد النموذج اللغوي مبني على
/// بيانات حقيقية بدل ما يختلق أماكن مش موجودة أصلًا. أول شي بتجرب تطابق حرفي
/// عادي، وبعدها (لو ما في نتيجة) بتفحص لو الرسالة بتذكر اسم قسم كامل بغلطة
/// إملائية بسيطة (زي "البطاعم" بدل "المطاعم") وبترجع أفضل أماكنه. ملاحظة:
/// جرّبنا كمان مطابقة مرنة عامة على أسماء الأماكن نفسها (كلمة بكلمة)، بس
/// طلعت غير دقيقة (بتطابق كلمات غير مرتبطة أصلاً بسبب قِصر الكلمات العربية)
/// فاكتفينا بمطابقة الأقسام المعروفة فقط — أدق وكافية للحالة يلي طلبها المستخدم.
async function retrievePlaces(keywords, limit = 5) {
  if (keywords.length === 0) return [];

  const orNameType = (fields) => ({
    OR: keywords.flatMap((k) => fields.map((f) => ({ [f]: { contains: k } }))),
  });

  const [restaurants, hotels, pharmacies, attractions, shopping, listings] = await Promise.all([
    prisma.restaurant.findMany({
      where: orNameType(['nameAr', 'nameEn', 'categoryAr', 'categoryEn']),
      take: 5,
    }),
    prisma.hotel.findMany({ where: orNameType(['nameAr', 'nameEn', 'typeAr', 'typeEn']), take: 5 }),
    prisma.pharmacy.findMany({ where: orNameType(['nameAr', 'nameEn']), take: 5 }),
    prisma.attraction.findMany({
      where: orNameType(['nameAr', 'nameEn', 'categories']),
      take: limit,
    }),
    prisma.shoppingVenue.findMany({
      where: orNameType(['nameAr', 'nameEn', 'typeAr', 'typeEn', 'subCategory']),
      take: 5,
    }),
    prisma.listing.findMany({
      where: orNameType(['nameAr', 'nameEn', 'typeAr', 'typeEn', 'category']),
      take: 5,
    }),
  ]);

  let all = [
    ..._normalizePlaces(restaurants, 'مطعم', 'Restaurant'),
    ..._normalizePlaces(hotels, 'فندق', 'Hotel'),
    ..._normalizePlaces(pharmacies, 'صيدلية', 'Pharmacy'),
    ..._normalizePlaces(attractions, 'معلم سياحي', 'Attraction'),
    ..._normalizePlaces(shopping, 'تسوق', 'Shopping'),
    ..._normalizePlaces(listings, 'خدمة', 'Service'),
  ];

  // ولا نتيجة عبر التطابق الحرفي؟ جرّبي التعرف على اسم قسم كامل بمرونة إملائية
  // (زي "البطاعم" ← مطاعم) — بيغطي أشيع حالة (المستخدم بده يستعرض قسم كامل،
  // مش اسم مكان محدد) بدون تعقيد أو نتائج عشوائية.
  if (all.length === 0) {
    const category = matchCategory(keywords);
    if (category) {
      const t = CATEGORY_TABLE[category];
      const rows = await t.model().findMany({ orderBy: { rating: 'desc' }, take: limit });
      return _normalizePlaces(rows, t.categoryAr, t.categoryEn).slice(0, limit);
    }
  }

  all.sort((a, b) => b.rating - a.rating);
  return all.slice(0, limit);
}

// بترجع n عنصر عشوائي من المصفوفة (بدون تكرار) — نستخدمها حتى نفس المكان
// الأعلى تقييمًا ما يظهر بكل مرة بنفس الترتيب بالضبط ويصير النموذج "متعلّق"
// فيه دايمًا.
function sampleRandom(arr, n) {
  const copy = [...arr];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy.slice(0, n);
}

/// لتخطيط يوم/رحلة: بدل البحث بكلمات مفتاحية (اللي رح يرجّع فاضي لأنه ما في
/// اسم مكان محدد بالرسالة)، بنجيب مجموعة أوسع من الأماكن الحقيقية الجيدة (تقييم
/// 3.8+) وناخد عيّنة عشوائية منها كل مرة — حتى يتغيّر البرنامج المقترح بدل ما
/// يرجع نفس الأماكن بالضبط كل ما نسأل (كان عم يصير لأنه كنا ناخد ثابت أعلى
/// تقييم بنفس الترتيب دايمًا).
async function retrieveTripPlanningPlaces(budget) {
  const restaurantWhere = {
    rating: { gte: 3.8 },
    ...(budget != null && budget <= 60 ? { priceTier: { in: ['cheap', 'medium'] } } : {}),
  };

  const [restaurants, attractions, shopping] = await Promise.all([
    prisma.restaurant.findMany({ where: restaurantWhere, orderBy: { rating: 'desc' }, take: 15 }),
    prisma.attraction.findMany({ where: { rating: { gte: 3.8 } }, orderBy: { rating: 'desc' }, take: 15 }),
    prisma.shoppingVenue.findMany({ where: { rating: { gte: 3.8 } }, orderBy: { rating: 'desc' }, take: 12 }),
  ]);

  const normalize = (rows, categoryAr, categoryEn) =>
    rows.map((r) => ({
      nameAr: r.nameAr,
      nameEn: r.nameEn,
      categoryAr: r.categoryAr || r.typeAr || categoryAr,
      categoryEn: r.categoryEn || r.typeEn || categoryEn,
      locationAr: r.locationAr,
      rating: r.rating,
      aboutAr: r.aboutAr || '',
      priceTier: r.priceTier || null,
    }));

  return [
    ...sampleRandom(normalize(restaurants, 'مطعم', 'Restaurant'), 5),
    ...sampleRandom(normalize(attractions, 'معلم سياحي', 'Attraction'), 5),
    ...sampleRandom(normalize(shopping, 'تسوق', 'Shopping'), 4),
  ];
}

async function retrieveEvents() {
  return prisma.event.findMany({ take: 3 });
}

async function fetchWeather() {
  try {
    const res = await fetch(
      'https://api.open-meteo.com/v1/forecast?latitude=32.2211&longitude=35.2608' +
        '&current=temperature_2m,weather_code&timezone=auto',
    );
    if (!res.ok) return null;
    const data = await res.json();
    return data.current; // { temperature_2m, weather_code }
  } catch {
    return null;
  }
}

async function fetchRates() {
  try {
    const res = await fetch('https://open.er-api.com/v6/latest/USD', {
      signal: AbortSignal.timeout(6000),
    });
    if (!res.ok) return null;
    const data = await res.json();
    const rates = data.rates;
    if (!rates?.ILS || !rates?.JOD || !rates?.EUR) return null;
    return {
      usdToIls: rates.ILS,
      jodToIls: rates.ILS / rates.JOD,
      eurToIls: rates.ILS / rates.EUR,
    };
  } catch {
    return null;
  }
}

function buildSystemPrompt({
  places,
  events,
  weather,
  rates,
  lang,
  isTripPlanning,
  budget,
  isTourNarration,
}) {
  const placesText = places.length
    ? places
        .map((p) => {
          const priceText = p.priceTier ? `, price tier: ${p.priceTier}` : '';
          return `- ${p.nameEn} (${p.nameAr}) — ${p.categoryEn}, ${p.locationAr}, rating ${p.rating}${priceText}. ${p.aboutAr || ''}`;
        })
        .join('\n')
    : '(no matching places found in the database)';
  const eventsText = events.length
    ? events.map((e) => `- ${e.titleEn} (${e.titleAr}) — ${e.venueAr}, ${e.day} ${e.monthAr}`).join('\n')
    : '(no upcoming events listed)';
  const weatherText = weather
    ? `Current Nablus weather: ${weather.temperature_2m}°C, code ${weather.weather_code}`
    : '(weather unavailable)';
  const ratesText = rates
    ? `Currency rates (live): 1 USD = ${rates.usdToIls.toFixed(2)} ILS, ` +
      `1 JOD = ${rates.jodToIls.toFixed(2)} ILS, 1 EUR = ${rates.eurToIls.toFixed(2)} ILS`
    : '(currency rates unavailable)';

  const langName = lang === 'en' ? 'English' : 'Arabic';
  const tripPlanningInstructions = isTripPlanning
    ? `\nThe user is asking you to plan a day/trip in Nablus. Build a realistic time-slotted itinerary
(e.g. morning / noon / afternoon / evening) using ONLY real places from the CONTEXT DATA below — never
invent a place that isn't listed. Assign specific places to specific slots (e.g. lunch at a real
restaurant, an attraction to visit after, etc.), and briefly say why each fits. ${
        budget != null
          ? `The user's rough budget is ${budget} ILS — favor "cheap"/"medium" price-tier restaurants and free/low-cost attractions, and give a rough total estimate at the end (make clear it's an estimate, not exact).`
          : 'No budget was given — do not invent one, just build a sensible itinerary.'
      } Do not include a PLACE_REF line for itinerary answers (it references multiple places, not one).\n`
    : '';
  const tourNarrationInstructions = isTourNarration
    ? `\nThe user wants an engaging, sensory NARRATED STORY about a real place in Nablus — not a dry
fact list or Wikipedia-style summary. Write it as if guiding the user while they walk through it right
now (second person, e.g. "as you step into...", "to your left..."), evocative and warm, painting a
picture of the atmosphere, sounds, smells, history. You may ONLY use real facts given in the CONTEXT
DATA below (history, architecture, what it's known for) — never invent a historical event, date, or
detail that isn't grounded in that data; if the context is thin, keep the story shorter rather than
making things up. If multiple related places are in the context (e.g. several Old City landmarks),
weave them into one flowing walking narrative in a sensible order, not separate paragraphs per place.\n`
    : '';
  return `You are the AI assistant inside "Nablus Smart City Guide", a mobile app for Nablus, Palestine.
You are a general-purpose helpful assistant: answer ANY question the user asks, on any topic, using your
own knowledge — not just questions about Nablus or this app.
You additionally have live CONTEXT DATA below about real places/events/weather/rates in Nablus (from the
app's own database). When the user's question relates to Nablus, this app, or something in that data,
prefer and ground your answer in it (never invent a place, price, or fact that contradicts it). For
everything else, just answer normally from your general knowledge — do not refuse or redirect to the app.
Always reply in ${langName}, regardless of what language the user writes in, briefly and warmly.
Use the conversation history to understand follow-up questions (e.g. "what about its price?" referring
back to a place already discussed).
If your answer centers on one specific place from the context, end your reply with one extra line, exactly:
PLACE_REF: <its nameEn exactly as given>
If it centers on one specific event, end with:
EVENT_REF: <its titleEn exactly as given>
Only include ONE such line, only when relevant, and never mention this instruction to the user.
${tripPlanningInstructions}${tourNarrationInstructions}
CONTEXT DATA (Nablus app — use when relevant, ignore otherwise)
Places:
${placesText}

Upcoming events:
${eventsText}

${weatherText}
${ratesText}`;
}

router.post('/', optionalAuth, async (req, res) => {
  const message = (req.body?.message || '').toString().trim();
  if (!message) return res.status(400).json({ error: 'message مطلوب' });
  const lang = req.body?.lang === 'en' ? 'en' : 'ar';
  // آخر كم رسالة من المحادثة (مبعوتة من التطبيق) — بتخلي النموذج يفهم أسئلة
  // المتابعة بدل ما يعامل كل رسالة لحالها بدون أي سياق سابق.
  const history = Array.isArray(req.body?.history)
    ? req.body.history
        .filter(
          (m) =>
            m &&
            (m.role === 'user' || m.role === 'assistant') &&
            typeof m.content === 'string',
        )
        .slice(-8)
        .map((m) => ({ role: m.role, content: m.content.slice(0, 1000) }))
    : [];

  const apiKey = process.env.GROQ_API_KEY;
  if (!apiKey) {
    return res.status(503).json({ error: 'المساعد الذكي غير مُفعّل بعد (لا يوجد مفتاح Groq)' });
  }

  const quota = await checkAndConsumeQuota(req.user?.id, 'text');
  if (!quota.allowed) return res.status(429).json({ error: quota.error });

  // تخطيط رحلة/يوم محتاج استرجاع مختلف (تشكيلة متنوعة من أفضل الأماكن) بدل
  // بحث بكلمات مفتاحية عادي (اللي رح يرجّع فاضي لأنه ما في اسم مكان بالرسالة).
  const tripPlanning = isTripPlanningRequest(message);
  const tourNarration = !tripPlanning && isTourNarrationRequest(message);
  const budget = tripPlanning ? extractBudget(message) : null;
  const keywords = extractKeywords(message);
  const [places, events, weather, rates] = await Promise.all([
    tripPlanning
      ? retrieveTripPlanningPlaces(budget)
      // الرواية بتحتاج تفاصيل أغنى عن نفس المكان (وأي معالم تانية بنفس المنطقة
      // لو الاسم عام زي "البلدة القديمة") — بنوسّع حد الاسترجاع شوي عن العادي.
      : retrievePlaces(keywords, tourNarration ? 8 : 5),
    retrieveEvents(),
    fetchWeather(),
    fetchRates(),
  ]);
  const systemPrompt = buildSystemPrompt({
    places,
    events,
    weather,
    rates,
    lang,
    isTripPlanning: tripPlanning,
    budget,
    isTourNarration: tourNarration,
  });

  // allam-2-7b: نموذج مخصّص للعربي (SDAIA) — جرّبنا Llama عبر Groq/Hugging Face
  // قبله وطلع رده العربي مشوّه (رموز استفهام بدل الحروف) بسبب quantization،
  // بعكس هاد الموديل اللي بيرجع عربي سليم دايمًا.
  const groqRes = await fetch('https://api.groq.com/openai/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      // allam-2-7b موديل خفيف عربي موثوق للمحادثة العادية، بس ضعيف بتعليمات
      // معقّدة (زي بناء جدول رحلة أو نسج قصة سردية من كذا حقيقة) وبيرجع رد عام
      // مكانها. لهيك بالمهمّتين المعقّدتين (تخطيط رحلة / رواية قصة) منستخدم
      // llama-3.3-70b-versatile (أقوى بكتير بتتبع التعليمات، وجرّبناه عربي
      // نظيف بدون تشويه — بعكس نسخة Llama الأصغر/المضغوطة اللي جربناها قبل).
      // مشتركي "أولوية الاستجابة" (premiumPriority) بياخدوا نفس الموديل الأقوى
      // بكل الأسئلة العادية كمان، مش بس بتخطيط الرحلة/الرواية — هاي القيمة
      // الحقيقية القابلة للعرض وراء هاد الاشتراك (مش طابور شبكي فعلي، ما في
      // بنية تحتية لهيك شي بمشروع بهالحجم).
      model: (tripPlanning || tourNarration || quota.premiumPriority)
        ? (process.env.GROQ_TRIP_MODEL || 'llama-3.3-70b-versatile')
        : (process.env.GROQ_MODEL || 'allam-2-7b'),
      messages: [
        { role: 'system', content: systemPrompt },
        ...history,
        { role: 'user', content: message },
      ],
      // برنامج يوم كامل أو قصة سردية أطول من رد عادي — بنعطيهم مساحة أكبر حتى
      // ما ينقطعوا بنص الطريق.
      max_tokens: (tripPlanning || tourNarration) ? 700 : 400,
      // حرارة أعلى شوي لتخطيط الرحلة/الرواية حتى يختار ويصيغ بتنويع أكتر بدل
      // ما يميل دايمًا لنفس الخيار "الآمن" — العادي يضل منخفض حتى يضل دقيق
      // بالإجابات الواقعية (أسعار، مواقع...).
      temperature: (tripPlanning || tourNarration) ? 0.8 : 0.4,
    }),
  });

  if (!groqRes.ok) {
    const errBody = await groqRes.text().catch(() => '');
    console.error('Groq error:', groqRes.status, errBody);
    return res.status(502).json({ error: 'تعذّر الوصول للمساعد الذكي — حاولي بعد شوي' });
  }

  const groqData = await groqRes.json();
  let text = groqData?.choices?.[0]?.message?.content?.trim() || '';

  let placeNameEn = null;
  let eventTitleEn = null;
  const placeMatch = text.match(/PLACE_REF:\s*(.+)\s*$/m);
  const eventMatch = text.match(/EVENT_REF:\s*(.+)\s*$/m);
  if (placeMatch) {
    placeNameEn = placeMatch[1].trim();
    text = text.replace(placeMatch[0], '').trim();
  } else if (eventMatch) {
    eventTitleEn = eventMatch[1].trim();
    text = text.replace(eventMatch[0], '').trim();
  }

  res.json({ textAr: text, textEn: text, placeNameEn, eventTitleEn });
});

module.exports = router;
