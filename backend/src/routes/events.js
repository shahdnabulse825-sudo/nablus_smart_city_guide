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

router.get('/', async (req, res) => {
  const items = await prisma.event.findMany({ orderBy: { createdAt: 'desc' } });
  res.json(items);
});

router.get('/:id', async (req, res) => {
  const item = await prisma.event.findUnique({ where: { id: req.params.id } });
  if (!item) return res.status(404).json({ error: 'الفعالية غير موجودة' });
  res.json(item);
});

router.post('/', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const b = req.body;
  const item = await prisma.event.create({
    data: {
      titleAr: b.titleAr || '',
      titleEn: b.titleEn || '',
      venueAr: b.venueAr || '',
      venueEn: b.venueEn || '',
      day: b.day || '',
      monthAr: b.monthAr || '',
      monthEn: b.monthEn || '',
      timeAr: b.timeAr || '',
      timeEn: b.timeEn || '',
      aboutAr: b.aboutAr || '',
      aboutEn: b.aboutEn || '',
      photoQuery: b.photoQuery || 'nablus palestine city',
      imageUrl: req.file ? `/uploads/${req.file.filename}` : null,
      iconCodePoint: numField(b.iconCodePoint, 0xe23e),
      colorValue: numField(b.colorValue, 0x3b82f6) & 0xffffff,
    },
  });
  res.status(201).json(item);
});

router.put('/:id', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  const existing = await prisma.event.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'الفعالية غير موجودة' });

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

  const item = await prisma.event.update({
    where: { id: req.params.id },
    data: {
      titleAr: b.titleAr ?? existing.titleAr,
      titleEn: b.titleEn ?? existing.titleEn,
      venueAr: b.venueAr ?? existing.venueAr,
      venueEn: b.venueEn ?? existing.venueEn,
      day: b.day ?? existing.day,
      monthAr: b.monthAr ?? existing.monthAr,
      monthEn: b.monthEn ?? existing.monthEn,
      timeAr: b.timeAr ?? existing.timeAr,
      timeEn: b.timeEn ?? existing.timeEn,
      aboutAr: b.aboutAr ?? existing.aboutAr,
      aboutEn: b.aboutEn ?? existing.aboutEn,
      photoQuery: b.photoQuery ?? existing.photoQuery,
      imageUrl,
    },
  });
  res.json(item);
});

router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  const existing = await prisma.event.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'الفعالية غير موجودة' });
  if (existing.imageUrl) {
    fs.unlink(path.join(__dirname, '..', '..', existing.imageUrl.replace(/^\//, '')), () => {});
  }
  await prisma.event.delete({ where: { id: req.params.id } });
  res.json({ success: true });
});

module.exports = router;
