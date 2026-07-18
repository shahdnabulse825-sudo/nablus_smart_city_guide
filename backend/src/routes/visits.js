const express = require('express');
const prisma = require('../db');

const router = express.Router();

// صف عدّاد الزوار الوحيد (id ثابت = "main")، بينزاد رقمه كل ما حد يفتح التطبيق.
router.post('/increment', async (req, res) => {
  const counter = await prisma.visitCounter.upsert({
    where: { id: 'main' },
    update: { count: { increment: 1 } },
    create: { id: 'main', count: 1 },
  });
  res.json({ count: counter.count });
});

router.get('/', async (req, res) => {
  const counter = await prisma.visitCounter.findUnique({ where: { id: 'main' } });
  res.json({ count: counter?.count ?? 0 });
});

module.exports = router;
