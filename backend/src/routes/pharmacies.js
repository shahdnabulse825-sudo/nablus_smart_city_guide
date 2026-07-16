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

// نخزّن القوائم (tags) كنص واحد مفصول بفواصل (SQLite ما بيدعم مصفوفات)
function listField(v) {
  if (Array.isArray(v)) return v.map((s) => String(s).trim()).filter(Boolean).join(',');
  if (typeof v === 'string') return v.split(',').map((s) => s.trim()).filter(Boolean).join(',');
  return '';
}

function boolField(v, fallback) {
  if (v === undefined) return fallback;
  return v === 'true' || v === true;
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

router.get('/', async (req, res) => {
  const items = await prisma.pharmacy.findMany({ orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }] });
  res.json(items);
});

router.get('/:id', async (req, res) => {
  const item = await prisma.pharmacy.findUnique({ where: { id: req.params.id } });
  if (!item) return res.status(404).json({ error: 'الصيدلية غير موجودة' });
  res.json(item);
});

router.post('/', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const b = req.body;
  const item = await prisma.pharmacy.create({
    data: {
      nameAr: b.nameAr || '',
      nameEn: b.nameEn || '',
      locationAr: b.locationAr || '',
      locationEn: b.locationEn || '',
      rating: numField(b.rating, 4.0),
      reviews: Math.round(numField(b.reviews, 0)),
      hoursAr: b.hoursAr || '',
      hoursEn: b.hoursEn || '',
      is24Hours: boolField(b.is24Hours, false),
      hasDelivery: boolField(b.hasDelivery, false),
      aboutAr: b.aboutAr || '',
      aboutEn: b.aboutEn || '',
      phone: b.phone || '',
      imageUrl: req.file ? `/uploads/${req.file.filename}` : null,
      tags: listField(b.tags),
      iconCodePoint: numField(b.iconCodePoint, 0xe92b),
      colorValue: numField(b.colorValue, 0x3b82f6) & 0xffffff,
      isFeatured: boolField(b.isFeatured, false),
      lat: optCoord(b.lat),
      lng: optCoord(b.lng),
    },
  });
  res.status(201).json(item);
});

router.put('/:id', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const existing = await prisma.pharmacy.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'الصيدلية غير موجودة' });

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

  const item = await prisma.pharmacy.update({
    where: { id: req.params.id },
    data: {
      nameAr: b.nameAr ?? existing.nameAr,
      nameEn: b.nameEn ?? existing.nameEn,
      locationAr: b.locationAr ?? existing.locationAr,
      locationEn: b.locationEn ?? existing.locationEn,
      rating: b.rating !== undefined ? numField(b.rating, existing.rating) : existing.rating,
      reviews:
        b.reviews !== undefined ? Math.round(numField(b.reviews, existing.reviews)) : existing.reviews,
      hoursAr: b.hoursAr ?? existing.hoursAr,
      hoursEn: b.hoursEn ?? existing.hoursEn,
      is24Hours: boolField(b.is24Hours, existing.is24Hours),
      hasDelivery: boolField(b.hasDelivery, existing.hasDelivery),
      aboutAr: b.aboutAr ?? existing.aboutAr,
      aboutEn: b.aboutEn ?? existing.aboutEn,
      phone: b.phone ?? existing.phone,
      tags: b.tags !== undefined ? listField(b.tags) : existing.tags,
      isFeatured: boolField(b.isFeatured, existing.isFeatured),
      imageUrl,
      lat: optCoordUpdate(b.lat, existing.lat),
      lng: optCoordUpdate(b.lng, existing.lng),
    },
  });
  res.json(item);
});

router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  const existing = await prisma.pharmacy.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'الصيدلية غير موجودة' });
  if (existing.imageUrl) {
    fs.unlink(path.join(__dirname, '..', '..', existing.imageUrl.replace(/^\//, '')), () => {});
  }
  await prisma.pharmacy.delete({ where: { id: req.params.id } });
  res.json({ success: true });
});

module.exports = router;
