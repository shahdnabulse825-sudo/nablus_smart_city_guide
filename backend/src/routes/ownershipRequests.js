const express = require('express');
const prisma = require('../db');
const { requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();

// كل قسم "تجاري" ممكن صاحبه يطلب ربط حساب فيه، مع نموذج Prisma المطابق له
const PLACE_MODELS = {
  restaurant: () => prisma.restaurant,
  hotel: () => prisma.hotel,
  pharmacy: () => prisma.pharmacy,
  shopping: () => prisma.shoppingVenue,
};

const PLACE_NOT_FOUND_AR = 'المكان غير موجود';

// ==================== صاحب المحل يطلب ربط حسابه بمحل موجود ====================
router.post('/', requireAuth, async (req, res) => {
  const { placeType, placeId, message } = req.body;
  const model = PLACE_MODELS[placeType];
  if (!model) return res.status(400).json({ error: 'نوع مكان غير مدعوم' });
  if (!placeId) return res.status(400).json({ error: 'معرف المكان مطلوب' });

  const place = await model().findUnique({ where: { id: placeId } });
  if (!place) return res.status(404).json({ error: PLACE_NOT_FOUND_AR });

  if (place.ownerEmail && place.ownerEmail === req.user.email) {
    return res.status(409).json({ error: 'هاد المكان مربوط بحسابك فعلًا' });
  }

  const existingPending = await prisma.ownershipRequest.findFirst({
    where: { placeType, placeId, requesterEmail: req.user.email, status: 'pending' },
  });
  if (existingPending) {
    return res.status(409).json({ error: 'عندك طلب قيد المراجعة على هاد المكان فعلًا' });
  }

  const requester = await prisma.user.findUnique({ where: { id: req.user.id } });

  const request = await prisma.ownershipRequest.create({
    data: {
      placeType,
      placeId,
      placeNameAr: place.nameAr || '',
      placeNameEn: place.nameEn || '',
      requesterEmail: req.user.email,
      requesterName: requester?.name || '',
      message: message || '',
    },
  });
  res.status(201).json(request);
});

// ==================== طلبات المستخدم الحالي (كل الحالات) ====================
router.get('/mine', requireAuth, async (req, res) => {
  const items = await prisma.ownershipRequest.findMany({
    where: { requesterEmail: req.user.email },
    orderBy: { createdAt: 'desc' },
  });
  res.json(items);
});

// ==================== محلات المستخدم الحالي المعتمدة (لشاشة "أعمالي") ====================
router.get('/my-listings', requireAuth, async (req, res) => {
  const results = await Promise.all(
    Object.entries(PLACE_MODELS).map(async ([placeType, model]) => {
      const items = await model().findMany({ where: { ownerEmail: req.user.email } });
      return items.map((item) => ({ ...item, placeType }));
    })
  );
  res.json(results.flat());
});

// ==================== الأدمن: كل الطلبات (فلترة اختيارية حسب الحالة) ====================
router.get('/', requireAuth, requireAdmin, async (req, res) => {
  const { status } = req.query;
  const items = await prisma.ownershipRequest.findMany({
    where: status ? { status } : undefined,
    orderBy: { createdAt: 'desc' },
  });
  res.json(items);
});

// ==================== الأدمن: الموافقة على طلب (بيربط المحل بحساب صاحب الطلب) ====================
router.put('/:id/approve', requireAuth, requireAdmin, async (req, res) => {
  const request = await prisma.ownershipRequest.findUnique({ where: { id: req.params.id } });
  if (!request) return res.status(404).json({ error: 'الطلب غير موجود' });
  if (request.status !== 'pending') {
    return res.status(400).json({ error: 'هذا الطلب تمت مراجعته مسبقًا' });
  }

  const model = PLACE_MODELS[request.placeType];
  if (!model) return res.status(400).json({ error: 'نوع مكان غير مدعوم' });
  const place = await model().findUnique({ where: { id: request.placeId } });
  if (!place) return res.status(404).json({ error: PLACE_NOT_FOUND_AR });

  await model().update({ where: { id: request.placeId }, data: { ownerEmail: request.requesterEmail } });
  const updated = await prisma.ownershipRequest.update({
    where: { id: req.params.id },
    data: { status: 'approved', reviewedBy: req.user.email },
  });
  res.json(updated);
});

// ==================== الأدمن: رفض طلب ====================
router.put('/:id/reject', requireAuth, requireAdmin, async (req, res) => {
  const request = await prisma.ownershipRequest.findUnique({ where: { id: req.params.id } });
  if (!request) return res.status(404).json({ error: 'الطلب غير موجود' });
  if (request.status !== 'pending') {
    return res.status(400).json({ error: 'هذا الطلب تمت مراجعته مسبقًا' });
  }

  const updated = await prisma.ownershipRequest.update({
    where: { id: req.params.id },
    data: { status: 'rejected', reviewedBy: req.user.email, reviewNote: req.body.reviewNote || '' },
  });
  res.json(updated);
});

module.exports = router;
