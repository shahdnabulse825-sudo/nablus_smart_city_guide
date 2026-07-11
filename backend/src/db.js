const { PrismaClient } = require('@prisma/client');

// نسخة واحدة مشتركة من Prisma Client لكل السيرفر
const prisma = new PrismaClient();

module.exports = prisma;
