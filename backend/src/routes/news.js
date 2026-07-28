const express = require('express');
const fs = require('fs');
const path = require('path');
const prisma = require('../db');
const upload = require('../middleware/upload');
const { requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();

router.get('/', async (req, res) => {
  const items = await prisma.newsArticle.findMany({ orderBy: { createdAt: 'desc' } });
  res.json(items);
});

// ==================== أخبار حقيقية مباشرة عن الضفة الغربية/فلسطين ====================
// مصدر خارجي حقيقي (Al Jazeera RSS العام، بدون مفتاح API) مفلتر بكلمات مفتاحية
// للضفة الغربية/فلسطين، مع جلب صورة كل خبر من صفحته الحقيقية (og:image) لأنه
// الـ RSS نفسه ما بيحمل صور. نتيجة مؤقتة بالذاكرة (15 دقيقة) حتى ما نضرب
// السيرفر الخارجي بكل فتحة لشاشة الأخبار.
const WEST_BANK_KEYWORDS = [
  'palestin', 'west bank', 'nablus', 'ramallah', 'hebron', 'bethlehem',
  'jenin', 'jericho', 'tulkarm', 'qalqilya', 'salfit', 'gaza',
];
let _liveNewsCache = { at: 0, items: [] };

function decodeEntities(text) {
  return text
    .replace(/&#8217;|&#8216;/g, "'")
    .replace(/&#8211;|&#8212;/g, '-')
    .replace(/&#8220;|&#8221;/g, '"')
    .replace(/&#038;|&amp;/g, '&')
    .replace(/&#039;/g, "'")
    .replace(/&quot;/g, '"')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>');
}

async function fetchOgImage(articleUrl) {
  try {
    const res = await fetch(articleUrl, { signal: AbortSignal.timeout(6000) });
    if (!res.ok) return null;
    const html = await res.text();
    const match = html.match(/<meta[^>]+property=["']og:image["'][^>]+content=["']([^"']+)["']/i);
    return match ? decodeEntities(match[1]) : null;
  } catch {
    return null;
  }
}

router.get('/live', async (req, res) => {
  const FIFTEEN_MIN = 15 * 60 * 1000;
  if (Date.now() - _liveNewsCache.at < FIFTEEN_MIN && _liveNewsCache.items.length) {
    return res.json(_liveNewsCache.items);
  }

  const feedRes = await fetch('https://www.aljazeera.com/xml/rss/all.xml', {
    signal: AbortSignal.timeout(10000),
  });
  if (!feedRes.ok) return res.status(502).json({ error: 'تعذّر جلب الأخبار الآن' });
  const xml = await feedRes.text();

  const itemBlocks = xml.match(/<item>[\s\S]*?<\/item>/g) || [];
  const parsed = itemBlocks.map((block) => {
    const title = decodeEntities((block.match(/<title>([\s\S]*?)<\/title>/) || [, ''])[1]);
    const description = decodeEntities(
      (block.match(/<description><!\[CDATA\[([\s\S]*?)\]\]><\/description>/) || [, ''])[1],
    );
    const link = (block.match(/<link>([\s\S]*?)<\/link>/) || [, ''])[1];
    const pubDate = (block.match(/<pubDate>([\s\S]*?)<\/pubDate>/) || [, ''])[1];
    const category = (block.match(/<category>([\s\S]*?)<\/category>/) || [, ''])[1];
    return { title, description, link, pubDate, category };
  });

  const matched = parsed
    .filter((a) => {
      const haystack = `${a.title} ${a.description}`.toLowerCase();
      return WEST_BANK_KEYWORDS.some((k) => haystack.includes(k));
    })
    .slice(0, 8);

  const withImages = await Promise.all(
    matched.map(async (a) => ({ ...a, imageUrl: await fetchOgImage(a.link) })),
  );

  _liveNewsCache = { at: Date.now(), items: withImages };
  res.json(withImages);
});

router.get('/:id', async (req, res) => {
  const item = await prisma.newsArticle.findUnique({ where: { id: req.params.id } });
  if (!item) return res.status(404).json({ error: 'الخبر غير موجود' });
  res.json(item);
});

router.post('/', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const b = req.body;
  const item = await prisma.newsArticle.create({
    data: {
      titleAr: b.titleAr || '',
      titleEn: b.titleEn || '',
      dateAr: b.dateAr || '',
      dateEn: b.dateEn || '',
      categoryAr: b.categoryAr || '',
      categoryEn: b.categoryEn || '',
      categoryKey: b.categoryKey || 'events',
      summaryAr: b.summaryAr || '',
      summaryEn: b.summaryEn || '',
      bodyAr: b.bodyAr || '',
      bodyEn: b.bodyEn || '',
      imageUrl: req.file ? `/uploads/${req.file.filename}` : null,
    },
  });
  res.status(201).json(item);
});

router.put('/:id', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const existing = await prisma.newsArticle.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'الخبر غير موجود' });

  const b = req.body;
  let imageUrl = existing.imageUrl;
  if (req.file) {
    if (existing.imageUrl) {
      fs.unlink(path.join(__dirname, '..', '..', existing.imageUrl.replace(/^\//, '')), () => {});
    }
    imageUrl = `/uploads/${req.file.filename}`;
  } else if (b.removeImage === 'true') {
    if (existing.imageUrl) {
      fs.unlink(path.join(__dirname, '..', '..', existing.imageUrl.replace(/^\//, '')), () => {});
    }
    imageUrl = null;
  }

  const item = await prisma.newsArticle.update({
    where: { id: req.params.id },
    data: {
      titleAr: b.titleAr ?? existing.titleAr,
      titleEn: b.titleEn ?? existing.titleEn,
      dateAr: b.dateAr ?? existing.dateAr,
      dateEn: b.dateEn ?? existing.dateEn,
      categoryAr: b.categoryAr ?? existing.categoryAr,
      categoryEn: b.categoryEn ?? existing.categoryEn,
      categoryKey: b.categoryKey ?? existing.categoryKey,
      summaryAr: b.summaryAr ?? existing.summaryAr,
      summaryEn: b.summaryEn ?? existing.summaryEn,
      bodyAr: b.bodyAr ?? existing.bodyAr,
      bodyEn: b.bodyEn ?? existing.bodyEn,
      imageUrl,
    },
  });
  res.json(item);
});

router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  const existing = await prisma.newsArticle.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'الخبر غير موجود' });
  if (existing.imageUrl) {
    fs.unlink(path.join(__dirname, '..', '..', existing.imageUrl.replace(/^\//, '')), () => {});
  }
  await prisma.newsArticle.delete({ where: { id: req.params.id } });
  res.json({ success: true });
});

module.exports = router;
