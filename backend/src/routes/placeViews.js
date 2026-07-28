const express = require('express');
const prisma = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// ==================== سجل زيارات المستخدم الحالي (الأحدث أولًا) ====================
router.get('/', requireAuth, async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit, 10) || 100, 200);
  const rows = await prisma.placeView.findMany({
    where: { userEmail: req.user.email },
    orderBy: { viewedAt: 'desc' },
    take: limit,
  });
  res.json(rows.map((r) => ({ nameEn: r.nameEn, viewedAt: r.viewedAt })));
});

// ==================== تسجيل زيارة جديدة (append-only، بدون تكرار-فحص) ====================
router.post('/', requireAuth, async (req, res) => {
  const { nameEn } = req.body;
  if (!nameEn) return res.status(400).json({ error: 'nameEn مطلوب' });
  const row = await prisma.placeView.create({
    data: { userEmail: req.user.email, nameEn },
  });
  res.status(201).json(row);
});

module.exports = router;
