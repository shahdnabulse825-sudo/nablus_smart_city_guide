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
  const items = await prisma.shoppingVenue.findMany({ orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }] });
  res.json(items);
});

router.get('/:id', async (req, res) => {
  const item = await prisma.shoppingVenue.findUnique({ where: { id: req.params.id } });
  if (!item) return res.status(404).json({ error: 'المركز التجاري غير موجود' });
  res.json(item);
});

router.post('/', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const b = req.body;
  const item = await prisma.shoppingVenue.create({
    data: {
      nameAr: b.nameAr || '',
      nameEn: b.nameEn || '',
      typeAr: b.typeAr || '',
      typeEn: b.typeEn || '',
      locationAr: b.locationAr || '',
      locationEn: b.locationEn || '',
      rating: numField(b.rating, 4.0),
      reviews: Math.round(numField(b.reviews, 0)),
      hoursAr: b.hoursAr || '',
      hoursEn: b.hoursEn || '',
      aboutAr: b.aboutAr || '',
      aboutEn: b.aboutEn || '',
      phone: b.phone || '',
      imageUrl: req.file ? `/uploads/${req.file.filename}` : null,
      iconCodePoint: numField(b.iconCodePoint, 0xe59c),
      colorValue: numField(b.colorValue, 0x3b82f6) & 0xffffff,
      isFeatured: boolField(b.isFeatured, false),
      lat: optCoord(b.lat),
      lng: optCoord(b.lng),
      subCategory: b.subCategory || '',
      website: b.website || '',
    },
  });
  res.status(201).json(item);
});

router.put('/:id', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const existing = await prisma.shoppingVenue.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'المركز التجاري غير موجود' });

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

  const item = await prisma.shoppingVenue.update({
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
      hoursAr: b.hoursAr ?? existing.hoursAr,
      hoursEn: b.hoursEn ?? existing.hoursEn,
      aboutAr: b.aboutAr ?? existing.aboutAr,
      aboutEn: b.aboutEn ?? existing.aboutEn,
      phone: b.phone ?? existing.phone,
      isFeatured: boolField(b.isFeatured, existing.isFeatured),
      imageUrl,
      lat: optCoordUpdate(b.lat, existing.lat),
      lng: optCoordUpdate(b.lng, existing.lng),
      subCategory: b.subCategory ?? existing.subCategory,
      website: b.website ?? existing.website,
    },
  });
  res.json(item);
});

router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  const existing = await prisma.shoppingVenue.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'المركز التجاري غير موجود' });
  if (existing.imageUrl) {
    fs.unlink(path.join(__dirname, '..', '..', existing.imageUrl.replace(/^\//, '')), () => {});
  }
  await prisma.shoppingVenue.delete({ where: { id: req.params.id } });
  res.json({ success: true });
});

module.exports = router;
