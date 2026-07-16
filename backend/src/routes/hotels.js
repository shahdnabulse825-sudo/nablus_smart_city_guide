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

function optCoord(v) {
  if (v === undefined || v === null || v === '') return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

function optCoordUpdate(v, existing) {
  if (v === undefined) return existing;
  return optCoord(v);
}

// نخزّن القوائم (gallery/amenities/tags) كنص واحد مفصول بفواصل (SQLite ما بيدعم مصفوفات)
function listField(v) {
  if (Array.isArray(v)) return v.map((s) => String(s).trim()).filter(Boolean).join(',');
  if (typeof v === 'string') return v.split(',').map((s) => s.trim()).filter(Boolean).join(',');
  return '';
}

router.get('/', async (req, res) => {
  const items = await prisma.hotel.findMany({ orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }] });
  res.json(items);
});

router.get('/:id', async (req, res) => {
  const item = await prisma.hotel.findUnique({ where: { id: req.params.id } });
  if (!item) return res.status(404).json({ error: 'الفندق غير موجود' });
  res.json(item);
});

router.post('/', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const b = req.body;
  const item = await prisma.hotel.create({
    data: {
      nameAr: b.nameAr || '',
      nameEn: b.nameEn || '',
      typeAr: b.typeAr || '',
      typeEn: b.typeEn || '',
      locationAr: b.locationAr || '',
      locationEn: b.locationEn || '',
      rating: numField(b.rating, 4.0),
      reviews: Math.round(numField(b.reviews, 0)),
      priceInfoAr: b.priceInfoAr || '',
      priceInfoEn: b.priceInfoEn || '',
      priceTier: b.priceTier || 'medium',
      hoursAr: b.hoursAr || '',
      hoursEn: b.hoursEn || '',
      aboutAr: b.aboutAr || '',
      aboutEn: b.aboutEn || '',
      phone: b.phone || '',
      imageUrl: req.file ? `/uploads/${req.file.filename}` : null,
      gallery: listField(b.gallery),
      amenities: listField(b.amenities),
      tags: listField(b.tags),
      iconCodePoint: numField(b.iconCodePoint, 0xe55f),
      colorValue: numField(b.colorValue, 0x6c5ce7) & 0xffffff,
      isFeatured: b.isFeatured === 'true' || b.isFeatured === true,
      lat: optCoord(b.lat),
      lng: optCoord(b.lng),
    },
  });
  res.status(201).json(item);
});

router.put('/:id', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const existing = await prisma.hotel.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'الفندق غير موجود' });

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

  const item = await prisma.hotel.update({
    where: { id: req.params.id },
    data: {
      nameAr: b.nameAr ?? existing.nameAr,
      nameEn: b.nameEn ?? existing.nameEn,
      typeAr: b.typeAr ?? existing.typeAr,
      typeEn: b.typeEn ?? existing.typeEn,
      locationAr: b.locationAr ?? existing.locationAr,
      locationEn: b.locationEn ?? existing.locationEn,
      rating: b.rating !== undefined ? numField(b.rating, existing.rating) : existing.rating,
      reviews:
        b.reviews !== undefined ? Math.round(numField(b.reviews, existing.reviews)) : existing.reviews,
      priceInfoAr: b.priceInfoAr ?? existing.priceInfoAr,
      priceInfoEn: b.priceInfoEn ?? existing.priceInfoEn,
      priceTier: b.priceTier ?? existing.priceTier,
      hoursAr: b.hoursAr ?? existing.hoursAr,
      hoursEn: b.hoursEn ?? existing.hoursEn,
      aboutAr: b.aboutAr ?? existing.aboutAr,
      aboutEn: b.aboutEn ?? existing.aboutEn,
      phone: b.phone ?? existing.phone,
      gallery: b.gallery !== undefined ? listField(b.gallery) : existing.gallery,
      amenities: b.amenities !== undefined ? listField(b.amenities) : existing.amenities,
      tags: b.tags !== undefined ? listField(b.tags) : existing.tags,
      isFeatured: b.isFeatured !== undefined ? (b.isFeatured === 'true' || b.isFeatured === true) : existing.isFeatured,
      imageUrl,
      lat: optCoordUpdate(b.lat, existing.lat),
      lng: optCoordUpdate(b.lng, existing.lng),
    },
  });
  res.json(item);
});

router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  const existing = await prisma.hotel.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'الفندق غير موجود' });
  if (existing.imageUrl) {
    fs.unlink(path.join(__dirname, '..', '..', existing.imageUrl.replace(/^\//, '')), () => {});
  }
  await prisma.hotel.delete({ where: { id: req.params.id } });
  res.json({ success: true });
});

module.exports = router;
