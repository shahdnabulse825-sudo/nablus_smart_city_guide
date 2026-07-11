const express = require('express');
const fs = require('fs');
const path = require('path');
const prisma = require('../db');
const upload = require('../middleware/upload');
const { requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();

const VALID_CATEGORIES = [
  'hotels',
  'attractions',
  'shopping',
  'transport',
  'health',
  'pharmacies',
  'education',
  'banks',
  'entertainment',
  'government',
];

function numField(v, fallback) {
  const n = Number(v);
  return Number.isFinite(n) ? n : fallback;
}

// ==================== كل العناصر (فلترة اختيارية حسب category) ====================
router.get('/', async (req, res) => {
  const { category } = req.query;
  if (category && !VALID_CATEGORIES.includes(category)) {
    return res.status(400).json({ error: 'تصنيف غير معروف' });
  }
  const items = await prisma.listing.findMany({
    where: category ? { category } : undefined,
    orderBy: { rating: 'desc' },
  });
  res.json(items);
});

// ==================== عنصر واحد ====================
router.get('/:id', async (req, res) => {
  const item = await prisma.listing.findUnique({ where: { id: req.params.id } });
  if (!item) return res.status(404).json({ error: 'العنصر غير موجود' });
  res.json(item);
});

// ==================== إضافة عنصر جديد (أدمن فقط) ====================
router.post('/', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const b = req.body;
  if (!VALID_CATEGORIES.includes(b.category)) {
    return res.status(400).json({ error: 'تصنيف غير معروف' });
  }
  const item = await prisma.listing.create({
    data: {
      category: b.category,
      nameAr: b.nameAr || '',
      nameEn: b.nameEn || '',
      typeAr: b.typeAr || '',
      typeEn: b.typeEn || '',
      locationAr: b.locationAr || '',
      locationEn: b.locationEn || '',
      rating: numField(b.rating, 4.0),
      reviews: Math.round(numField(b.reviews, 0)),
      infoLabelAr: b.infoLabelAr || '',
      infoLabelEn: b.infoLabelEn || '',
      aboutAr: b.aboutAr || '',
      aboutEn: b.aboutEn || '',
      phone: b.phone || '+970 59 000 0000',
      photoQuery: b.photoQuery || 'nablus palestine city',
      imageUrl: req.file ? `/uploads/${req.file.filename}` : null,
      iconCodePoint: numField(b.iconCodePoint, 0xe55f),
      colorValue: numField(b.colorValue, 0x3b82f6) & 0xffffff,
    },
  });
  res.status(201).json(item);
});

// ==================== تعديل عنصر (أدمن فقط) ====================
router.put('/:id', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const existing = await prisma.listing.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'العنصر غير موجود' });

  const b = req.body;
  let imageUrl = existing.imageUrl;
  if (req.file) {
    // نحذف الصورة القديمة المرفوعة سابقًا (لو موجودة) قبل استبدالها
    if (existing.imageUrl) {
      const oldPath = path.join(__dirname, '..', '..', existing.imageUrl.replace(/^\//, ''));
      fs.unlink(oldPath, () => {});
    }
    imageUrl = `/uploads/${req.file.filename}`;
  } else if (b.removeImage === 'true') {
    if (existing.imageUrl) {
      const oldPath = path.join(__dirname, '..', '..', existing.imageUrl.replace(/^\//, ''));
      fs.unlink(oldPath, () => {});
    }
    imageUrl = null;
  }

  const item = await prisma.listing.update({
    where: { id: req.params.id },
    data: {
      category: b.category || existing.category,
      nameAr: b.nameAr ?? existing.nameAr,
      nameEn: b.nameEn ?? existing.nameEn,
      typeAr: b.typeAr ?? existing.typeAr,
      typeEn: b.typeEn ?? existing.typeEn,
      locationAr: b.locationAr ?? existing.locationAr,
      locationEn: b.locationEn ?? existing.locationEn,
      rating: b.rating !== undefined ? numField(b.rating, existing.rating) : existing.rating,
      reviews:
        b.reviews !== undefined ? Math.round(numField(b.reviews, existing.reviews)) : existing.reviews,
      infoLabelAr: b.infoLabelAr ?? existing.infoLabelAr,
      infoLabelEn: b.infoLabelEn ?? existing.infoLabelEn,
      aboutAr: b.aboutAr ?? existing.aboutAr,
      aboutEn: b.aboutEn ?? existing.aboutEn,
      phone: b.phone ?? existing.phone,
      photoQuery: b.photoQuery ?? existing.photoQuery,
      imageUrl,
    },
  });
  res.json(item);
});

// ==================== حذف عنصر (أدمن فقط) ====================
router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  const existing = await prisma.listing.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'العنصر غير موجود' });
  if (existing.imageUrl) {
    const oldPath = path.join(__dirname, '..', '..', existing.imageUrl.replace(/^\//, ''));
    fs.unlink(oldPath, () => {});
  }
  await prisma.listing.delete({ where: { id: req.params.id } });
  res.json({ success: true });
});

module.exports = router;
