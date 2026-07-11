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
