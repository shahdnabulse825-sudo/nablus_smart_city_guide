const express = require('express');
const fs = require('fs');
const path = require('path');
const prisma = require('../db');
const upload = require('../middleware/upload');
const { requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();

function unlinkImage(imageUrl) {
  if (!imageUrl) return;
  fs.unlink(path.join(__dirname, '..', '..', imageUrl.replace(/^\//, '')), () => {});
}

// ==================== كل صور التصنيفات (عام — بدون تسجيل دخول) ====================
// بترجع خريطة {categoryKey: imageUrl} بس للتصنيفات يلي عندها صورة مخصّصة فعليًا
// (بقية التصنيفات بتضل تعتمد على الصورة الافتراضية الجاهزة بالتطبيق نفسه).
router.get('/', async (req, res) => {
  const rows = await prisma.categoryImage.findMany();
  const map = {};
  for (const r of rows) {
    if (r.imageUrl) map[r.categoryKey] = r.imageUrl;
  }
  res.json(map);
});

// ==================== رفع/استبدال صورة تصنيف (أدمن فقط) ====================
router.put('/:categoryKey', requireAuth, requireAdmin, upload.single('image'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'لازم ترفعي صورة' });
  }
  const { categoryKey } = req.params;
  const existing = await prisma.categoryImage.findUnique({ where: { categoryKey } });
  if (existing?.imageUrl) unlinkImage(existing.imageUrl);

  const imageUrl = `/uploads/${req.file.filename}`;
  const row = await prisma.categoryImage.upsert({
    where: { categoryKey },
    create: { categoryKey, imageUrl },
    update: { imageUrl },
  });
  res.json(row);
});

// ==================== حذف صورة تصنيف والرجوع للصورة الافتراضية (أدمن فقط) ====================
router.delete('/:categoryKey', requireAuth, requireAdmin, async (req, res) => {
  const { categoryKey } = req.params;
  const existing = await prisma.categoryImage.findUnique({ where: { categoryKey } });
  if (!existing || !existing.imageUrl) {
    return res.json({ success: true }); // أصلًا مفيش صورة مخصّصة، الحالة مطابقة
  }
  unlinkImage(existing.imageUrl);
  await prisma.categoryImage.update({
    where: { categoryKey },
    data: { imageUrl: null },
  });
  res.json({ success: true });
});

module.exports = router;
