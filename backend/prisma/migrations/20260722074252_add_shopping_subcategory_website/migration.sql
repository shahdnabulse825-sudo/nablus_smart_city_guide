-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
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
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_ShoppingVenue" ("aboutAr", "aboutEn", "colorValue", "createdAt", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "phone", "rating", "reviews", "typeAr", "typeEn", "updatedAt") SELECT "aboutAr", "aboutEn", "colorValue", "createdAt", "hoursAr", "hoursEn", "iconCodePoint", "id", "imageUrl", "isFeatured", "lat", "lng", "locationAr", "locationEn", "nameAr", "nameEn", "phone", "rating", "reviews", "typeAr", "typeEn", "updatedAt" FROM "ShoppingVenue";
DROP TABLE "ShoppingVenue";
ALTER TABLE "new_ShoppingVenue" RENAME TO "ShoppingVenue";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
