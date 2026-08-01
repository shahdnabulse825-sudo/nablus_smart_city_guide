const express = require('express');
const fs = require('fs');
const path = require('path');
const prisma = require('../db');
const upload = require('../middleware/upload');
const { requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();

function optDate(v) {
  if (v === undefined || v === null || v === '') return null;
  const d = new Date(v);
  return isNaN(d.getTime()) ? null : d;
}

function optDateUpdate(v, existing) {
  if (v === undefined) return existing;
  return optDate(v);
}

// عام: بيرجّع بس العروض السارية حاليًا (ضمن فترة الصلاحية لو محدّدة) — الأدمن
// بيشوف كل العروض (بما فيها المنتهية) من مسار /all المخصّص إله.
router.get('/', async (req, res) => {
  const now = new Date();
  const items = await prisma.promotion.findMany({
    where: {
      AND: [
        { OR: [{ startDate: null }, { startDate: { lte: now } }] },
        { OR: [{ endDate: null }, { endDate: { gte: now } }] },
      ],
    },
    orderBy: { createdAt: 'desc' },
  });
  res.json(items);
});

router.get('/all', requireAuth, requireAdmin, async (req, res) => {
  const items = await prisma.promotion.findMany({ orderBy: { createdAt: 'desc' } });
  res.json(items);
});

router.get('/:id', async (req, res) => {
  const item = await prisma.promotion.findUnique({ where: { id: req.params.id } });
  if (!item) return res.status(404).json({ error: 'العرض غير موجود' });
  res.json(item);
});

router.post('/', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const b = req.body;
  const item = await prisma.promotion.create({
    data: {
      titleAr: b.titleAr || '',
      titleEn: b.titleEn || '',
      descriptionAr: b.descriptionAr || '',
      descriptionEn: b.descriptionEn || '',
      discountCode: b.discountCode || '',
      placeNameAr: b.placeNameAr || '',
      placeNameEn: b.placeNameEn || '',
      categoryKey: b.categoryKey || '',
      imageUrl: req.file ? `/uploads/${req.file.filename}` : null,
      startDate: optDate(b.startDate),
      endDate: optDate(b.endDate),
    },
  });
  res.status(201).json(item);
});

router.put('/:id', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const existing = await prisma.promotion.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'العرض غير موجود' });

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

  const item = await prisma.promotion.update({
    where: { id: req.params.id },
    data: {
      titleAr: b.titleAr ?? existing.titleAr,
      titleEn: b.titleEn ?? existing.titleEn,
      descriptionAr: b.descriptionAr ?? existing.descriptionAr,
      descriptionEn: b.descriptionEn ?? existing.descriptionEn,
      discountCode: b.discountCode ?? existing.discountCode,
      placeNameAr: b.placeNameAr ?? existing.placeNameAr,
      placeNameEn: b.placeNameEn ?? existing.placeNameEn,
      categoryKey: b.categoryKey ?? existing.categoryKey,
      imageUrl,
      startDate: optDateUpdate(b.startDate, existing.startDate),
      endDate: optDateUpdate(b.endDate, existing.endDate),
    },
  });
  res.json(item);
});

router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  const existing = await prisma.promotion.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'العرض غير موجود' });
  if (existing.imageUrl) {
    fs.unlink(path.join(__dirname, '..', '..', existing.imageUrl.replace(/^\//, '')), () => {});
  }
  await prisma.promotion.delete({ where: { id: req.params.id } });
  res.json({ success: true });
});

module.exports = router;
