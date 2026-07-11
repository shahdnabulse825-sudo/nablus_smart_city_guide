const express = require('express');
const bcrypt = require('bcryptjs');
const prisma = require('../db');
const { signToken } = require('../middleware/auth');

const router = express.Router();

const EMAIL_REGEX = /^[\w.-]+@[\w-]+\.[a-zA-Z]{2,}$/;

function publicUser(user) {
  return { id: user.id, name: user.name, email: user.email, role: user.role };
}

// ==================== تسجيل حساب جديد ====================
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  const cleanEmail = (email || '').trim().toLowerCase();

  if (!name || !name.trim()) return res.status(400).json({ error: 'الرجاء إدخال الاسم' });
  if (!EMAIL_REGEX.test(cleanEmail)) {
    return res.status(400).json({ error: 'صيغة البريد الإلكتروني غير صحيحة' });
  }
  if (!password || password.length < 6) {
    return res.status(400).json({ error: 'كلمة المرور لازم تكون 6 أحرف على الأقل' });
  }

  const existing = await prisma.user.findUnique({ where: { email: cleanEmail } });
  if (existing) return res.status(409).json({ error: 'هذا البريد الإلكتروني مسجّل مسبقًا' });

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await prisma.user.create({
    data: { name: name.trim(), email: cleanEmail, passwordHash, role: 'user' },
  });

  const token = signToken({ id: user.id, role: user.role });
  res.status(201).json({ token, user: publicUser(user) });
});

// ==================== تسجيل دخول مستخدم عادي ====================
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const cleanEmail = (email || '').trim().toLowerCase();

  if (!cleanEmail || !password) {
    return res.status(400).json({ error: 'الرجاء إدخال البريد الإلكتروني وكلمة المرور' });
  }

  const user = await prisma.user.findUnique({ where: { email: cleanEmail } });
  if (!user) return res.status(404).json({ error: 'لا يوجد حساب بهذا البريد الإلكتروني' });

  const match = await bcrypt.compare(password, user.passwordHash);
  if (!match) return res.status(401).json({ error: 'كلمة المرور غير صحيحة' });

  const token = signToken({ id: user.id, role: user.role });
  res.json({ token, user: publicUser(user) });
});

// ==================== تسجيل دخول الأدمن ====================
router.post('/admin-login', async (req, res) => {
  const { username, password } = req.body;
  const cleanUsername = (username || '').trim().toLowerCase();

  const admin = await prisma.user.findFirst({ where: { email: cleanUsername, role: 'admin' } });
  if (!admin) return res.status(401).json({ error: 'اسم المستخدم أو كلمة المرور غير صحيحة' });

  const match = await bcrypt.compare(password || '', admin.passwordHash);
  if (!match) return res.status(401).json({ error: 'اسم المستخدم أو كلمة المرور غير صحيحة' });

  const token = signToken({ id: admin.id, role: admin.role });
  res.json({ token, user: publicUser(admin) });
});

// ==================== التحقق من وجود بريد إلكتروني (خطوة نسيت كلمة السر) ====================
router.get('/check-email/:email', async (req, res) => {
  const cleanEmail = (req.params.email || '').trim().toLowerCase();
  const user = await prisma.user.findUnique({ where: { email: cleanEmail } });
  res.json({ exists: !!user });
});

// ==================== إعادة تعيين كلمة المرور ====================
router.post('/reset-password', async (req, res) => {
  const { email, newPassword } = req.body;
  const cleanEmail = (email || '').trim().toLowerCase();

  if (!EMAIL_REGEX.test(cleanEmail)) {
    return res.status(400).json({ error: 'صيغة البريد الإلكتروني غير صحيحة' });
  }
  if (!newPassword || newPassword.length < 6) {
    return res.status(400).json({ error: 'كلمة المرور لازم تكون 6 أحرف على الأقل' });
  }

  const user = await prisma.user.findUnique({ where: { email: cleanEmail } });
  if (!user) return res.status(404).json({ error: 'لا يوجد حساب بهذا البريد الإلكتروني' });

  const passwordHash = await bcrypt.hash(newPassword, 10);
  await prisma.user.update({ where: { email: cleanEmail }, data: { passwordHash } });
  res.json({ success: true });
});

module.exports = router;
