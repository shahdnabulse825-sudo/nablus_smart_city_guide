-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Attraction" (
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
    "lat" REAL,
    "lng" REAL,
    "suspendedUntil" DATETIME,
    "suspendReason" TEXT NOT NULL DEFAULT '',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Attraction" ("aboutAr", "aboutEn", "categories", "colorValue", "createdAt", "entryFeeAr", "entryFeeEn", "iconCodePoint", "id", "imageUrl", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "rating", "reviews", "updatedAt", "visitHoursAr", "visitHoursEn") SELECT "aboutAr", "aboutEn", "categories", "colorValue", "createdAt", "entryFeeAr", "entryFeeEn", "iconCodePoint", "id", "imageUrl", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "rating", "reviews", "updatedAt", "visitHoursAr", "visitHoursEn" FROM "Attraction";
DROP TABLE "Attraction";
ALTER TABLE "new_Attraction" RENAME TO "Attraction";
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
    "suspendedUntil" DATETIME,
    "suspendReason" TEXT NOT NULL DEFAULT '',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Hotel" ("aboutAr", "aboutEn", "amenities", "colorValue", "createdAt", "gallery", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "ownerEmail", "phone", "priceInfoAr", "priceInfoEn", "priceTier", "rating", "reviews", "tags", "typeAr", "typeEn", "updatedAt") SELECT "aboutAr", "aboutEn", "amenities", "colorValue", "createdAt", "gallery", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "ownerEmail", "phone", "priceInfoAr", "priceInfoEn", "priceTier", "rating", "reviews", "tags", "typeAr", "typeEn", "updatedAt" FROM "Hotel";
DROP TABLE "Hotel";
ALTER TABLE "new_Hotel" RENAME TO "Hotel";
CREATE TABLE "new_Listing" (
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
    "suspendedUntil" DATETIME,
    "suspendReason" TEXT NOT NULL DEFAULT '',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Listing" ("aboutAr", "aboutEn", "category", "colorValue", "createdAt", "iconCodePoint", "id", "imageUrl", "infoLabelAr", "infoLabelEn", "locationAr", "locationEn", "nameAr", "nameEn", "phone", "photoQuery", "rating", "reviews", "typeAr", "typeEn", "updatedAt") SELECT "aboutAr", "aboutEn", "category", "colorValue", "createdAt", "iconCodePoint", "id", "imageUrl", "infoLabelAr", "infoLabelEn", "locationAr", "locationEn", "nameAr", "nameEn", "phone", "photoQuery", "rating", "reviews", "typeAr", "typeEn", "updatedAt" FROM "Listing";
DROP TABLE "Listing";
ALTER TABLE "new_Listing" RENAME TO "Listing";
CREATE INDEX "Listing_category_idx" ON "Listing"("category");
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
    "suspendedUntil" DATETIME,
    "suspendReason" TEXT NOT NULL DEFAULT '',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Pharmacy" ("aboutAr", "aboutEn", "colorValue", "createdAt", "hasDelivery", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "is24Hours", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "ownerEmail", "phone", "rating", "reviews", "tags", "updatedAt") SELECT "aboutAr", "aboutEn", "colorValue", "createdAt", "hasDelivery", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "is24Hours", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "ownerEmail", "phone", "rating", "reviews", "tags", "updatedAt" FROM "Pharmacy";
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
    "suspendedUntil" DATETIME,
    "suspendReason" TEXT NOT NULL DEFAULT '',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Restaurant" ("aboutAr", "aboutEn", "categoryAr", "categoryEn", "colorValue", "createdAt", "cuisineKey", "iconCodePoint", "id", "imageUrl", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "ownerEmail", "phone", "priceRange", "priceTier", "rating", "reviews", "time", "updatedAt") SELECT "aboutAr", "aboutEn", "categoryAr", "categoryEn", "colorValue", "createdAt", "cuisineKey", "iconCodePoint", "id", "imageUrl", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "ownerEmail", "phone", "priceRange", "priceTier", "rating", "reviews", "time", "updatedAt" FROM "Restaurant";
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
    "suspendedUntil" DATETIME,
    "suspendReason" TEXT NOT NULL DEFAULT '',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_ShoppingVenue" ("aboutAr", "aboutEn", "colorValue", "createdAt", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "ownerEmail", "phone", "rating", "reviews", "subCategory", "typeAr", "typeEn", "updatedAt", "website") SELECT "aboutAr", "aboutEn", "colorValue", "createdAt", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "ownerEmail", "phone", "rating", "reviews", "subCategory", "typeAr", "typeEn", "updatedAt", "website" FROM "ShoppingVenue";
DROP TABLE "ShoppingVenue";
ALTER TABLE "new_ShoppingVenue" RENAME TO "ShoppingVenue";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
