const express = require('express');
const prisma = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// ==================== مفضلة المستخدم الحالي ====================
router.get('/', requireAuth, async (req, res) => {
  const rows = await prisma.favorite.findMany({
    where: { userEmail: req.user.email },
    orderBy: { createdAt: 'desc' },
  });
  res.json(rows.map((r) => ({ nameEn: r.nameEn, createdAt: r.createdAt })));
});

// ==================== إضافة مكان للمفضلة (idempotent — نفس المكان مرتين ما بيعمل مشكلة) ====================
router.post('/', requireAuth, async (req, res) => {
  const { nameEn } = req.body;
  if (!nameEn) return res.status(400).json({ error: 'nameEn مطلوب' });
  const row = await prisma.favorite.upsert({
    where: { userEmail_nameEn: { userEmail: req.user.email, nameEn } },
    create: { userEmail: req.user.email, nameEn },
    update: {},
  });
  res.status(201).json(row);
});

// ==================== حذف مكان من المفضلة ====================
router.delete('/:nameEn', requireAuth, async (req, res) => {
  await prisma.favorite
    .delete({
      where: { userEmail_nameEn: { userEmail: req.user.email, nameEn: req.params.nameEn } },
    })
    .catch(() => {}); // أصلًا مش موجودة — نفس نتيجة الحذف الناجح من منظور العميل
  res.json({ success: true });
});

module.exports = router;
