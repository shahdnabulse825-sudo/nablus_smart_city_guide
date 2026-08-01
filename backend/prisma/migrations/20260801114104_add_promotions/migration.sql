-- CreateTable
CREATE TABLE "Promotion" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "titleAr" TEXT NOT NULL,
    "titleEn" TEXT NOT NULL,
    "descriptionAr" TEXT NOT NULL DEFAULT '',
    "descriptionEn" TEXT NOT NULL DEFAULT '',
    "discountCode" TEXT NOT NULL DEFAULT '',
    "placeNameAr" TEXT NOT NULL DEFAULT '',
    "placeNameEn" TEXT NOT NULL DEFAULT '',
    "categoryKey" TEXT NOT NULL DEFAULT '',
    "imageUrl" TEXT,
    "startDate" DATETIME,
    "endDate" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
