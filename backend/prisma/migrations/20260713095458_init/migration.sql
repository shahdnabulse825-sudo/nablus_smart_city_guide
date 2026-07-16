-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'user',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "Listing" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "category" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,
    "nameEn" TEXT NOT NULL,
    "typeAr" TEXT NOT NULL,
    "typeEn" TEXT NOT NULL,
    "locationAr" TEXT NOT NULL,
    "locationEn" TEXT NOT NULL,
    "rating" REAL NOT NULL DEFAULT 4.0,
    "reviews" INTEGER NOT NULL DEFAULT 0,
    "infoLabelAr" TEXT NOT NULL DEFAULT '',
    "infoLabelEn" TEXT NOT NULL DEFAULT '',
    "aboutAr" TEXT NOT NULL DEFAULT '',
    "aboutEn" TEXT NOT NULL DEFAULT '',
    "phone" TEXT NOT NULL DEFAULT '',
    "photoQuery" TEXT NOT NULL DEFAULT 'nablus palestine city',
    "imageUrl" TEXT,
    "iconCodePoint" INTEGER NOT NULL DEFAULT 58719,
    "colorValue" INTEGER NOT NULL DEFAULT 3946230,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "Hotel" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "nameAr" TEXT NOT NULL,
    "nameEn" TEXT NOT NULL,
    "typeAr" TEXT NOT NULL DEFAULT '',
    "typeEn" TEXT NOT NULL DEFAULT '',
    "locationAr" TEXT NOT NULL,
    "locationEn" TEXT NOT NULL,
    "rating" REAL NOT NULL DEFAULT 4.0,
    "reviews" INTEGER NOT NULL DEFAULT 0,
    "priceInfoAr" TEXT NOT NULL DEFAULT '',
    "priceInfoEn" TEXT NOT NULL DEFAULT '',
    "priceTier" TEXT NOT NULL DEFAULT 'medium',
    "hoursAr" TEXT NOT NULL DEFAULT '',
    "hoursEn" TEXT NOT NULL DEFAULT '',
    "aboutAr" TEXT NOT NULL DEFAULT '',
    "aboutEn" TEXT NOT NULL DEFAULT '',
    "phone" TEXT NOT NULL DEFAULT '',
    "imageUrl" TEXT,
    "gallery" TEXT NOT NULL DEFAULT '',
    "amenities" TEXT NOT NULL DEFAULT '',
    "tags" TEXT NOT NULL DEFAULT '',
    "iconCodePoint" INTEGER NOT NULL DEFAULT 58719,
    "colorValue" INTEGER NOT NULL DEFAULT 7114727,
    "isFeatured" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "Pharmacy" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "nameAr" TEXT NOT NULL,
    "nameEn" TEXT NOT NULL,
    "locationAr" TEXT NOT NULL,
    "locationEn" TEXT NOT NULL,
    "rating" REAL NOT NULL DEFAULT 4.0,
    "reviews" INTEGER NOT NULL DEFAULT 0,
    "hoursAr" TEXT NOT NULL DEFAULT '',
    "hoursEn" TEXT NOT NULL DEFAULT '',
    "is24Hours" BOOLEAN NOT NULL DEFAULT false,
    "hasDelivery" BOOLEAN NOT NULL DEFAULT false,
    "aboutAr" TEXT NOT NULL DEFAULT '',
    "aboutEn" TEXT NOT NULL DEFAULT '',
    "phone" TEXT NOT NULL DEFAULT '',
    "imageUrl" TEXT,
    "tags" TEXT NOT NULL DEFAULT '',
    "iconCodePoint" INTEGER NOT NULL DEFAULT 59691,
    "colorValue" INTEGER NOT NULL DEFAULT 3946230,
    "isFeatured" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "Attraction" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "nameAr" TEXT NOT NULL,
    "nameEn" TEXT NOT NULL,
    "categories" TEXT NOT NULL DEFAULT '',
    "locationAr" TEXT NOT NULL,
    "locationEn" TEXT NOT NULL,
    "rating" REAL NOT NULL DEFAULT 4.0,
    "reviews" INTEGER NOT NULL DEFAULT 0,
    "aboutAr" TEXT NOT NULL DEFAULT '',
    "aboutEn" TEXT NOT NULL DEFAULT '',
    "visitHoursAr" TEXT NOT NULL DEFAULT '',
    "visitHoursEn" TEXT NOT NULL DEFAULT '',
    "entryFeeAr" TEXT NOT NULL DEFAULT '',
    "entryFeeEn" TEXT NOT NULL DEFAULT '',
    "imageUrl" TEXT,
    "iconCodePoint" INTEGER NOT NULL DEFAULT 59217,
    "colorValue" INTEGER NOT NULL DEFAULT 13217575,
    "isFeatured" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "ShoppingVenue" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "nameAr" TEXT NOT NULL,
    "nameEn" TEXT NOT NULL,
    "typeAr" TEXT NOT NULL DEFAULT '',
    "typeEn" TEXT NOT NULL DEFAULT '',
    "locationAr" TEXT NOT NULL,
    "locationEn" TEXT NOT NULL,
    "rating" REAL NOT NULL DEFAULT 4.0,
    "reviews" INTEGER NOT NULL DEFAULT 0,
    "hoursAr" TEXT NOT NULL DEFAULT '',
    "hoursEn" TEXT NOT NULL DEFAULT '',
    "aboutAr" TEXT NOT NULL DEFAULT '',
    "aboutEn" TEXT NOT NULL DEFAULT '',
    "phone" TEXT NOT NULL DEFAULT '',
    "imageUrl" TEXT,
    "iconCodePoint" INTEGER NOT NULL DEFAULT 58728,
    "colorValue" INTEGER NOT NULL DEFAULT 3900918,
    "isFeatured" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "Restaurant" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "nameAr" TEXT NOT NULL,
    "nameEn" TEXT NOT NULL,
    "categoryAr" TEXT NOT NULL,
    "categoryEn" TEXT NOT NULL,
    "cuisineKey" TEXT NOT NULL,
    "locationAr" TEXT NOT NULL,
    "locationEn" TEXT NOT NULL,
    "rating" REAL NOT NULL DEFAULT 4.0,
    "reviews" INTEGER NOT NULL DEFAULT 0,
    "priceRange" TEXT NOT NULL DEFAULT '',
    "priceTier" TEXT NOT NULL DEFAULT 'medium',
    "time" TEXT NOT NULL DEFAULT '',
    "aboutAr" TEXT NOT NULL DEFAULT '',
    "aboutEn" TEXT NOT NULL DEFAULT '',
    "phone" TEXT NOT NULL DEFAULT '',
    "imageUrl" TEXT,
    "iconCodePoint" INTEGER NOT NULL DEFAULT 58732,
    "colorValue" INTEGER NOT NULL DEFAULT 7114727,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "NewsArticle" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "titleAr" TEXT NOT NULL,
    "titleEn" TEXT NOT NULL,
    "dateAr" TEXT NOT NULL,
    "dateEn" TEXT NOT NULL,
    "categoryAr" TEXT NOT NULL,
    "categoryEn" TEXT NOT NULL,
    "categoryKey" TEXT NOT NULL,
    "summaryAr" TEXT NOT NULL DEFAULT '',
    "summaryEn" TEXT NOT NULL DEFAULT '',
    "bodyAr" TEXT NOT NULL DEFAULT '',
    "bodyEn" TEXT NOT NULL DEFAULT '',
    "imageUrl" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "Listing_category_idx" ON "Listing"("category");

-- CreateIndex
CREATE INDEX "Restaurant_cuisineKey_idx" ON "Restaurant"("cuisineKey");

-- CreateIndex
CREATE INDEX "NewsArticle_categoryKey_idx" ON "NewsArticle"("categoryKey");
