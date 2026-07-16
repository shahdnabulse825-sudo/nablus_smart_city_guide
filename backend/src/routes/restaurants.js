const express = require('express');
const fs = require('fs');
const path = require('path');
const prisma = require('../db');
const upload = require('../middleware/upload');
const { requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();

function numField(v, fallback) {
  const n = Number(v);
  return Number.isFinite(n) ? n : fallback;
}

// إحداثيات اختيارية (lat/lng) — بتيجي كنص من الفورم، وممكن ما تكون موجودة أصلاً
function optCoord(v) {
  if (v === undefined || v === null || v === '') return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

function optCoordUpdate(v, existing) {
  if (v === undefined) return existing;
  return optCoord(v);
}

router.get('/', async (req, res) => {
  const items = await prisma.restaurant.findMany({ orderBy: { rating: 'desc' } });
  res.json(items);
});

router.get('/:id', async (req, res) => {
  const item = await prisma.restaurant.findUnique({ where: { id: req.params.id } });
  if (!item) return res.status(404).json({ error: 'المطعم غير موجود' });
  res.json(item);
});

router.post('/', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const b = req.body;
  const item = await prisma.restaurant.create({
    data: {
      nameAr: b.nameAr || '',
      nameEn: b.nameEn || '',
      categoryAr: b.categoryAr || '',
      categoryEn: b.categoryEn || '',
      cuisineKey: b.cuisineKey || 'traditional',
      locationAr: b.locationAr || '',
      locationEn: b.locationEn || '',
      rating: numField(b.rating, 4.0),
      reviews: Math.round(numField(b.reviews, 0)),
      priceRange: b.priceRange || '',
      priceTier: b.priceTier || 'medium',
      time: b.time || '',
      aboutAr: b.aboutAr || '',
      aboutEn: b.aboutEn || '',
      phone: b.phone || '',
      imageUrl: req.file ? `/uploads/${req.file.filename}` : null,
      iconCodePoint: numField(b.iconCodePoint, 0xe56c),
      colorValue: numField(b.colorValue, 0x6c5ce7) & 0xffffff,
      lat: optCoord(b.lat),
      lng: optCoord(b.lng),
    },
  });
  res.status(201).json(item);
});

router.put('/:id', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const existing = await prisma.restaurant.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'المطعم غير موجود' });

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

  const item = await prisma.restaurant.update({
    where: { id: req.params.id },
    data: {
      nameAr: b.nameAr ?? existing.nameAr,
      nameEn: b.nameEn ?? existing.nameEn,
      categoryAr: b.categoryAr ?? existing.categoryAr,
      categoryEn: b.categoryEn ?? existing.categoryEn,
      cuisineKey: b.cuisineKey ?? existing.cuisineKey,
      locationAr: b.locationAr ?? existing.locationAr,
      locationEn: b.locationEn ?? existing.locationEn,
      rating: b.rating !== undefined ? numField(b.rating, existing.rating) : existing.rating,
      reviews:
        b.reviews !== undefined ? Math.round(numField(b.reviews, existing.reviews)) : existing.reviews,
      priceRange: b.priceRange ?? existing.priceRange,
      priceTier: b.priceTier ?? existing.priceTier,
      time: b.time ?? existing.time,
      aboutAr: b.aboutAr ?? existing.aboutAr,
      aboutEn: b.aboutEn ?? existing.aboutEn,
      phone: b.phone ?? existing.phone,
      imageUrl,
      lat: optCoordUpdate(b.lat, existing.lat),
      lng: optCoordUpdate(b.lng, existing.lng),
    },
  });
  res.json(item);
});

router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  const existing = await prisma.restaurant.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'المطعم غير موجود' });
  if (existing.imageUrl) {
    fs.unlink(path.join(__dirname, '..', '..', existing.imageUrl.replace(/^\//, '')), () => {});
  }
  await prisma.restaurant.delete({ where: { id: req.params.id } });
  res.json({ success: true });
});

module.exports = router;
