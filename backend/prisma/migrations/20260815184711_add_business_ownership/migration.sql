-- CreateTable
CREATE TABLE "OwnershipRequest" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "placeType" TEXT NOT NULL,
    "placeId" TEXT NOT NULL,
    "placeNameAr" TEXT NOT NULL DEFAULT '',
    "placeNameEn" TEXT NOT NULL DEFAULT '',
    "requesterEmail" TEXT NOT NULL,
    "requesterName" TEXT NOT NULL DEFAULT '',
    "message" TEXT NOT NULL DEFAULT '',
    "status" TEXT NOT NULL DEFAULT 'pending',
    "reviewedBy" TEXT NOT NULL DEFAULT '',
    "reviewNote" TEXT NOT NULL DEFAULT '',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Hotel" (
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
    "lat" REAL,
    "lng" REAL,
    "ownerEmail" TEXT NOT NULL DEFAULT '',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Hotel" ("aboutAr", "aboutEn", "amenities", "colorValue", "createdAt", "gallery", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "phone", "priceInfoAr", "priceInfoEn", "priceTier", "rating", "reviews", "tags", "typeAr", "typeEn", "updatedAt") SELECT "aboutAr", "aboutEn", "amenities", "colorValue", "createdAt", "gallery", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "phone", "priceInfoAr", "priceInfoEn", "priceTier", "rating", "reviews", "tags", "typeAr", "typeEn", "updatedAt" FROM "Hotel";
DROP TABLE "Hotel";
ALTER TABLE "new_Hotel" RENAME TO "Hotel";
CREATE TABLE "new_Pharmacy" (
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
    "lat" REAL,
    "lng" REAL,
    "ownerEmail" TEXT NOT NULL DEFAULT '',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Pharmacy" ("aboutAr", "aboutEn", "colorValue", "createdAt", "hasDelivery", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "is24Hours", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "phone", "rating", "reviews", "tags", "updatedAt") SELECT "aboutAr", "aboutEn", "colorValue", "createdAt", "hasDelivery", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "is24Hours", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "phone", "rating", "reviews", "tags", "updatedAt" FROM "Pharmacy";
DROP TABLE "Pharmacy";
ALTER TABLE "new_Pharmacy" RENAME TO "Pharmacy";
CREATE TABLE "new_Restaurant" (
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
    "lat" REAL,
    "lng" REAL,
    "ownerEmail" TEXT NOT NULL DEFAULT '',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Restaurant" ("aboutAr", "aboutEn", "categoryAr", "categoryEn", "colorValue", "createdAt", "cuisineKey", "iconCodePoint", "id", "imageUrl", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "phone", "priceRange", "priceTier", "rating", "reviews", "time", "updatedAt") SELECT "aboutAr", "aboutEn", "categoryAr", "categoryEn", "colorValue", "createdAt", "cuisineKey", "iconCodePoint", "id", "imageUrl", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "phone", "priceRange", "priceTier", "rating", "reviews", "time", "updatedAt" FROM "Restaurant";
DROP TABLE "Restaurant";
ALTER TABLE "new_Restaurant" RENAME TO "Restaurant";
CREATE INDEX "Restaurant_cuisineKey_idx" ON "Restaurant"("cuisineKey");
CREATE TABLE "new_ShoppingVenue" (
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
    "lat" REAL,
    "lng" REAL,
    "subCategory" TEXT NOT NULL DEFAULT '',
    "website" TEXT NOT NULL DEFAULT '',
    "ownerEmail" TEXT NOT NULL DEFAULT '',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_ShoppingVenue" ("aboutAr", "aboutEn", "colorValue", "createdAt", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "phone", "rating", "reviews", "subCategory", "typeAr", "typeEn", "updatedAt", "website") SELECT "aboutAr", "aboutEn", "colorValue", "createdAt", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "phone", "rating", "reviews", "subCategory", "typeAr", "typeEn", "updatedAt", "website" FROM "ShoppingVenue";
DROP TABLE "ShoppingVenue";
ALTER TABLE "new_ShoppingVenue" RENAME TO "ShoppingVenue";
CREATE TABLE "new_User" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'user',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "premiumText" BOOLEAN NOT NULL DEFAULT false,
    "premiumVoice" BOOLEAN NOT NULL DEFAULT false,
    "premiumPriority" BOOLEAN NOT NULL DEFAULT false,
    "aiTextCount" INTEGER NOT NULL DEFAULT 0,
    "aiVoiceCount" INTEGER NOT NULL DEFAULT 0,
    "aiUsageDate" TEXT NOT NULL DEFAULT ''
);
INSERT INTO "new_User" ("createdAt", "email", "id", "name", "passwordHash", "role") SELECT "createdAt", "email", "id", "name", "passwordHash", "role" FROM "User";
DROP TABLE "User";
ALTER TABLE "new_User" RENAME TO "User";
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

-- CreateIndex
CREATE INDEX "OwnershipRequest_status_idx" ON "OwnershipRequest"("status");

-- CreateIndex
CREATE INDEX "OwnershipRequest_requesterEmail_idx" ON "OwnershipRequest"("requesterEmail");
