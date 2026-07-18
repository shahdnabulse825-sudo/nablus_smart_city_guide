-- CreateTable
CREATE TABLE "Event" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "titleAr" TEXT NOT NULL,
    "titleEn" TEXT NOT NULL,
    "venueAr" TEXT NOT NULL DEFAULT '',
    "venueEn" TEXT NOT NULL DEFAULT '',
    "day" TEXT NOT NULL DEFAULT '',
    "monthAr" TEXT NOT NULL DEFAULT '',
    "monthEn" TEXT NOT NULL DEFAULT '',
    "timeAr" TEXT NOT NULL DEFAULT '',
    "timeEn" TEXT NOT NULL DEFAULT '',
    "aboutAr" TEXT NOT NULL DEFAULT '',
    "aboutEn" TEXT NOT NULL DEFAULT '',
    "photoQuery" TEXT NOT NULL DEFAULT 'nablus palestine city',
    "imageUrl" TEXT,
    "iconCodePoint" INTEGER NOT NULL DEFAULT 57918,
    "colorValue" INTEGER NOT NULL DEFAULT 3946230,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "VisitCounter" (
    "id" TEXT NOT NULL PRIMARY KEY DEFAULT 'main',
    "count" INTEGER NOT NULL DEFAULT 0
);
