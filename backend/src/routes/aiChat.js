const express = require('express');
const prisma = require('../db');

const router = express.Router();

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

/// بتدوّر بالقاعدة الحقيقية (نفس بيانات التطبيق) عن أماكن مطابقة لكلمات رسالة
/// المستخدم — هاي "الاسترجاع" (retrieval) اللي بيخلي رد النموذج اللغوي مبني على
/// بيانات حقيقية بدل ما يختلق أماكن مش موجودة أصلًا.
async function retrievePlaces(keywords) {
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
      take: 5,
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

  const normalize = (rows, categoryAr, categoryEn) =>
    rows.map((r) => ({
      nameAr: r.nameAr,
      nameEn: r.nameEn,
      categoryAr: r.categoryAr || r.typeAr || categoryAr,
      categoryEn: r.categoryEn || r.typeEn || categoryEn,
      locationAr: r.locationAr,
      rating: r.rating,
      aboutAr: r.aboutAr,
    }));

  const all = [
    ...normalize(restaurants, 'مطعم', 'Restaurant'),
    ...normalize(hotels, 'فندق', 'Hotel'),
    ...normalize(pharmacies, 'صيدلية', 'Pharmacy'),
    ...normalize(attractions, 'معلم سياحي', 'Attraction'),
    ...normalize(shopping, 'تسوق', 'Shopping'),
    ...normalize(listings, 'خدمة', 'Service'),
  ];
  all.sort((a, b) => b.rating - a.rating);
  return all.slice(0, 5);
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

function buildSystemPrompt({ places, events, weather, rates, lang }) {
  const placesText = places.length
    ? places
        .map(
          (p) =>
            `- ${p.nameEn} (${p.nameAr}) — ${p.categoryEn}, ${p.locationAr}, rating ${p.rating}. ${p.aboutAr || ''}`,
        )
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
  return `You are the AI assistant inside "Nablus Smart City Guide", a mobile app for Nablus, Palestine.
Answer ONLY using the CONTEXT DATA below — never invent a place, price, or fact that isn't in it.
If nothing in the context answers the question, say so politely and suggest browsing the app's categories instead.
Always reply in ${langName}, regardless of what language the user writes in, briefly and warmly.
Use the conversation history to understand follow-up questions (e.g. "what about its price?" referring
back to a place already discussed).
If your answer centers on one specific place from the context, end your reply with one extra line, exactly:
PLACE_REF: <its nameEn exactly as given>
If it centers on one specific event, end with:
EVENT_REF: <its titleEn exactly as given>
Only include ONE such line, only when relevant, and never mention this instruction to the user.

CONTEXT DATA
Places:
${placesText}

Upcoming events:
${eventsText}

${weatherText}
${ratesText}`;
}

router.post('/', async (req, res) => {
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

  const apiKey = process.env.HUGGINGFACE_API_KEY;
  if (!apiKey) {
    return res.status(503).json({ error: 'المساعد الذكي غير مُفعّل بعد (لا يوجد مفتاح Hugging Face)' });
  }

  const keywords = extractKeywords(message);
  const [places, events, weather, rates] = await Promise.all([
    retrievePlaces(keywords),
    retrieveEvents(),
    fetchWeather(),
    fetchRates(),
  ]);
  const systemPrompt = buildSystemPrompt({ places, events, weather, rates, lang });

  const hfRes = await fetch('https://router.huggingface.co/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: process.env.HUGGINGFACE_MODEL || 'meta-llama/Llama-3.2-3B-Instruct',
      messages: [
        { role: 'system', content: systemPrompt },
        ...history,
        { role: 'user', content: message },
      ],
      max_tokens: 400,
      temperature: 0.4,
    }),
  });

  if (!hfRes.ok) {
    const errBody = await hfRes.text().catch(() => '');
    console.error('Hugging Face error:', hfRes.status, errBody);
    return res.status(502).json({ error: 'تعذّر الوصول للمساعد الذكي — حاولي بعد شوي' });
  }

  const hfData = await hfRes.json();
  let text = hfData?.choices?.[0]?.message?.content?.trim() || '';

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
