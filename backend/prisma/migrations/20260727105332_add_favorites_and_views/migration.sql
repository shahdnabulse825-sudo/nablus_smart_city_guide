-- CreateTable
CREATE TABLE "Favorite" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userEmail" TEXT NOT NULL,
    "nameEn" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "PlaceView" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userEmail" TEXT NOT NULL,
    "nameEn" TEXT NOT NULL,
    "viewedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateIndex
CREATE INDEX "Favorite_userEmail_idx" ON "Favorite"("userEmail");

-- CreateIndex
CREATE UNIQUE INDEX "Favorite_userEmail_nameEn_key" ON "Favorite"("userEmail", "nameEn");

-- CreateIndex
CREATE INDEX "PlaceView_userEmail_idx" ON "PlaceView"("userEmail");
