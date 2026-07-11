const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET;

function signToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '30d' });
}

/// يتحقق من وجود رمز دخول صالح (Authorization: Bearer <token>)
function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) {
    return res.status(401).json({ error: 'يلزم تسجيل الدخول' });
  }
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch (e) {
    return res.status(401).json({ error: 'رمز الدخول غير صالح أو منتهي' });
  }
}

/// يتحقق إضافيًا إن المستخدم أدمن (لازم requireAuth قبله)
function requireAdmin(req, res, next) {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ error: 'هذا الإجراء يتطلب صلاحية أدمن' });
  }
  next();
}

module.exports = { signToken, requireAuth, requireAdmin };
