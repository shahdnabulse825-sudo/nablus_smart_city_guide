const express = require('express');
const prisma = require('../db');
const { requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();

// تنبيه واحد فعّال بحد أقصى — بنتعامل معه كـ"سجل وحيد حالي" بدل قائمة، لأن
// الواجهة ما بتحتاج أكتر من تنبيه واحد ظاهر بنفس الوقت.
async function currentAlert() {
  return prisma.trafficAlert.findFirst({
    where: { active: true },
    orderBy: { updatedAt: 'desc' },
  });
}

router.get('/current', async (req, res) => {
  const alert = await currentAlert();
  res.json(alert || { active: false });
});

router.put('/current', requireAuth, requireAdmin, async (req, res) => {
  const b = req.body;
  const existing = await currentAlert();
  const data = {
    active: b.active === true || b.active === 'true',
    textAr: b.textAr || '',
    textEn: b.textEn || '',
    altRouteAr: b.altRouteAr || '',
    altRouteEn: b.altRouteEn || '',
    updatedBy: req.user?.email || '',
  };
  const item = existing
    ? await prisma.trafficAlert.update({ where: { id: existing.id }, data })
    : await prisma.trafficAlert.create({ data });
  res.json(item);
});

module.exports = router;
