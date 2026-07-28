const express = require('express');
const prisma = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// ==================== مراجعات مكان معيّن + متوسط التقييم الحقيقي ====================
router.get('/', async (req, res) => {
  const { placeType, placeNameEn } = req.query;
  if (!placeType || !placeNameEn) {
    return res.status(400).json({ error: 'placeType و placeNameEn مطلوبين' });
  }
  const rows = await prisma.review.findMany({
    where: { placeType, placeNameEn },
    orderBy: { createdAt: 'desc' },
  });
  const average = rows.length
    ? rows.reduce((sum, r) => sum + r.rating, 0) / rows.length
    : null;
  res.json({
    average,
    count: rows.length,
    reviews: rows.map((r) => ({
      id: r.id,
      userName: r.userName,
      userEmail: r.userEmail,
      rating: r.rating,
      comment: r.comment,
      createdAt: r.createdAt,
    })),
  });
});

// ==================== إضافة/تعديل مراجعتي لمكان (مراجعة وحدة لكل مستخدم لكل مكان) ====================
router.post('/', requireAuth, async (req, res) => {
  const { placeType, placeNameEn, rating, comment } = req.body;
  if (!placeType || !placeNameEn) {
    return res.status(400).json({ error: 'placeType و placeNameEn مطلوبين' });
  }
  const ratingNum = Number(rating);
  if (!Number.isInteger(ratingNum) || ratingNum < 1 || ratingNum > 5) {
    return res.status(400).json({ error: 'التقييم لازم يكون رقم صحيح من 1 إلى 5' });
  }

  const user = await prisma.user.findUnique({ where: { email: req.user.email } });
  if (!user) return res.status(401).json({ error: 'الحساب غير موجود' });

  const row = await prisma.review.upsert({
    where: {
      userEmail_placeType_placeNameEn: {
        userEmail: req.user.email,
        placeType,
        placeNameEn,
      },
    },
    create: {
      userEmail: req.user.email,
      userName: user.name,
      placeType,
      placeNameEn,
      rating: ratingNum,
      comment: (comment || '').toString().trim(),
    },
    update: {
      rating: ratingNum,
      comment: (comment || '').toString().trim(),
    },
  });
  res.status(201).json(row);
});

// ==================== حذف مراجعتي (بس صاحبة المراجعة تقدر تحذفها) ====================
router.delete('/:id', requireAuth, async (req, res) => {
  await prisma.review
    .delete({ where: { id: req.params.id, userEmail: req.user.email } })
    .catch(() => {});
  res.json({ success: true });
});

module.exports = router;
