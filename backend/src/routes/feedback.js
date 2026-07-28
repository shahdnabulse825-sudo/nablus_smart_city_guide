const express = require('express');
const prisma = require('../db');
const { requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();

// ==================== إرسال رسالة تواصل (زائر أو مستخدم، بدون تسجيل دخول لازم) ====================
router.post('/', async (req, res) => {
  const { name, email, type, message, relatedPlace } = req.body;
  if (!name || !name.toString().trim()) return res.status(400).json({ error: 'الاسم مطلوب' });
  if (!message || !message.toString().trim()) return res.status(400).json({ error: 'الرسالة مطلوبة' });

  const row = await prisma.feedback.create({
    data: {
      name: name.toString().trim(),
      email: (email || '').toString().trim().toLowerCase(),
      type: ['suggestion', 'issue', 'question'].includes(type) ? type : 'question',
      message: message.toString().trim(),
      relatedPlace: relatedPlace || null,
    },
  });
  res.status(201).json(row);
});

// ==================== كل الرسائل (لوحة الأدمن فقط) ====================
router.get('/', requireAuth, requireAdmin, async (req, res) => {
  const rows = await prisma.feedback.findMany({ orderBy: { createdAt: 'desc' } });
  res.json(rows);
});

// ==================== رسائل زائر معيّن حسب بريده (لعرض ردود الأدمن له) ====================
router.get('/mine', async (req, res) => {
  const email = (req.query.email || '').toString().trim().toLowerCase();
  if (!email) return res.json([]);
  const rows = await prisma.feedback.findMany({
    where: { email },
    orderBy: { createdAt: 'desc' },
  });
  res.json(rows);
});

// ==================== تعليم كمقروءة / الرد (أدمن فقط) ====================
router.patch('/:id', requireAuth, requireAdmin, async (req, res) => {
  const { read, reply } = req.body;
  const data = {};
  if (typeof read === 'boolean') data.read = read;
  if (typeof reply === 'string' && reply.trim()) {
    data.reply = reply.trim();
    data.repliedAt = new Date();
    data.read = true;
  }
  const row = await prisma.feedback.update({ where: { id: req.params.id }, data }).catch(() => null);
  if (!row) return res.status(404).json({ error: 'الرسالة غير موجودة' });
  res.json(row);
});

// ==================== حذف رسالة (أدمن فقط) ====================
router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  await prisma.feedback.delete({ where: { id: req.params.id } }).catch(() => {});
  res.json({ success: true });
});

module.exports = router;
