-- CreateTable
CREATE TABLE "Review" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userEmail" TEXT NOT NULL,
    "userName" TEXT NOT NULL,
    "placeType" TEXT NOT NULL,
    "placeNameEn" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT NOT NULL DEFAULT '',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "Feedback" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL DEFAULT '',
    "type" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "relatedPlace" TEXT,
    "read" BOOLEAN NOT NULL DEFAULT false,
    "reply" TEXT,
    "repliedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateIndex
CREATE INDEX "Review_placeType_placeNameEn_idx" ON "Review"("placeType", "placeNameEn");

-- CreateIndex
CREATE UNIQUE INDEX "Review_userEmail_placeType_placeNameEn_key" ON "Review"("userEmail", "placeType", "placeNameEn");

-- CreateIndex
CREATE INDEX "Feedback_email_idx" ON "Feedback"("email");
