const express = require('express');
const prisma = require('../db');
const { requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();

const VALID_STATUSES = ['unknown', 'open', 'congested', 'closed'];

router.get('/', async (req, res) => {
  const items = await prisma.checkpoint.findMany({ orderBy: { nameEn: 'asc' } });
  res.json(items);
});

router.post('/', requireAuth, requireAdmin, async (req, res) => {
  const b = req.body;
  const status = VALID_STATUSES.includes(b.status) ? b.status : 'unknown';
  const item = await prisma.checkpoint.create({
    data: {
      nameAr: b.nameAr || '',
      nameEn: b.nameEn || '',
      locationAr: b.locationAr || '',
      locationEn: b.locationEn || '',
      status,
      altRouteAr: b.altRouteAr || '',
      altRouteEn: b.altRouteEn || '',
      updatedBy: req.user?.email || '',
    },
  });
  res.status(201).json(item);
});

router.put('/:id', requireAuth, requireAdmin, async (req, res) => {
  const existing = await prisma.checkpoint.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'الحاجز غير موجود' });

  const b = req.body;
  const status = b.status !== undefined
    ? (VALID_STATUSES.includes(b.status) ? b.status : existing.status)
    : existing.status;
  const item = await prisma.checkpoint.update({
    where: { id: req.params.id },
    data: {
      nameAr: b.nameAr ?? existing.nameAr,
      nameEn: b.nameEn ?? existing.nameEn,
      locationAr: b.locationAr ?? existing.locationAr,
      locationEn: b.locationEn ?? existing.locationEn,
      status,
      altRouteAr: b.altRouteAr ?? existing.altRouteAr,
      altRouteEn: b.altRouteEn ?? existing.altRouteEn,
      updatedBy: req.user?.email || existing.updatedBy,
    },
  });
  res.json(item);
});

router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  const existing = await prisma.checkpoint.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'الحاجز غير موجود' });
  await prisma.checkpoint.delete({ where: { id: req.params.id } });
  res.json({ success: true });
});

module.exports = router;
