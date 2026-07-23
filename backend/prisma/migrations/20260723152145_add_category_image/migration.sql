-- CreateTable
CREATE TABLE "CategoryImage" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "categoryKey" TEXT NOT NULL,
    "imageUrl" TEXT,
    "updatedAt" DATETIME NOT NULL
);

-- CreateIndex
CREATE UNIQUE INDEX "CategoryImage_categoryKey_key" ON "CategoryImage"("categoryKey");
