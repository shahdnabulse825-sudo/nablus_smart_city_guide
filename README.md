# NabliGo — Nablus Smart City Guide

A full-stack, bilingual (Arabic/English, Arabic-first RTL) city guide app for **Nablus, Palestine**. Built with **Flutter** (mobile, desktop, and web) on the frontend and **Node.js/Express + Prisma/SQLite** on the backend.

NabliGo helps residents and visitors discover restaurants, hotels, pharmacies, tourist attractions, and shopping venues in Nablus, with real business data, live weather and currency rates, an AI assistant (trip planning and tour narration powered by Groq), interactive maps, and an admin panel for managing content.

## Features

- **Place directories**: restaurants, hotels, pharmacies, attractions, shopping venues, and general listings (transport, health, education, banks, entertainment, government), each with search, filters, and detail pages.
- **AI Assistant**: general Q&A, a day-trip planner, and a "tour narrator" that writes an evocative walking narration for a real Nablus landmark — all grounded in the app's own place/event/weather/currency data (Groq API, `qwen/qwen3.6-27b` for complex tasks, `allam-2-7b` for everyday chat).
- **Interactive map** with real coordinates for every place.
- **Voice**: speech-to-text (Whisper) for asking the assistant by voice, and text-to-speech (Orpheus) for listening to narrated stories.
- **Real accounts**: registration/login, favorites, visit history, and reviews synced to the backend.
- **Business ownership**: business owners can request to claim and manage their own listing; admins approve/reject requests.
- **Admin panel**: manage every place category, news, events, promotions, traffic alerts, checkpoints, and category images.
- **Live data**: current weather (Open-Meteo) and currency exchange rates (open.er-api.com).
- **Premium subscriptions** (demo-only, no real payment gateway): unlimited AI text/voice usage and priority model access.

## Tech stack

| Layer | Stack |
|---|---|
| Frontend | Flutter (Dart), Hive (local storage), `flutter_map`, `google_fonts`, `http` |
| Backend | Node.js, Express, Prisma ORM, SQLite |
| AI | Groq API (chat, Whisper transcription, Orpheus text-to-speech) |

## Project structure

```
lib/                  Flutter app source
  screens/            One folder per feature area (restaurants, hotels, ai_assistant, admin, map, ...)
  services/           API client, local DB (Hive), weather, favorites, etc.
  theme/              Colors and typography
  widgets/            Shared widgets

backend/
  src/
    server.js         Express app + server bootstrap (used for `npm start` / `npm run dev`)
    routes/           One file per resource (restaurants, hotels, aiChat, auth, ...)
    middleware/       JWT auth (requireAuth / requireAdmin / optionalAuth), file upload
    db.js             Shared Prisma Client instance
  prisma/
    schema.prisma     Database schema (SQLite)
    migrations/       Migration history
    seed.js           Seeds the database from seed_data.json (first run only)

test/                 _export_seed_test.dart regenerates seed_export.json from the Dart
                      seed data (a dev utility, not an automated test)
```

## Getting started

### Prerequisites

- Flutter SDK (`^3.12.2` — see `pubspec.yaml`)
- Node.js 18+ and npm
- A [Groq API key](https://console.groq.com) (free tier) for the AI assistant features — the app runs fine without one, the AI assistant just responds with a "not configured" message

### 1. Backend

```bash
cd backend
npm install
cp .env.example .env      # then edit JWT_SECRET / ADMIN_USERNAME / ADMIN_PASSWORD / GROQ_API_KEY
npx prisma migrate deploy # creates/updates backend/prisma/dev.db
npm run seed               # optional: populate the database from prisma/seed_data.json
npm run dev                 # starts the server on http://localhost:4000 (nodemon, auto-reload)
```

The database is a single SQLite file (`backend/prisma/dev.db`) — no external database server needed.

Health check: `curl http://localhost:4000/api/health`

### 2. Frontend

```bash
flutter pub get
flutter run -d windows   # or: -d chrome / -d <device-id> for Android/iOS
```

The app talks to the backend at `http://localhost:4000/api` by default (`http://10.0.2.2:4000/api` automatically on the Android emulator). To test on a physical phone on the same Wi‑Fi network, change `baseUrl` in `lib/services/api_service.dart` to the backend machine's LAN IP.

If the backend isn't running, the app still works using its built-in local seed data — server sync just fails silently and the app falls back to what's already cached locally.

## Building a release

Because some place icons are chosen dynamically from data stored in the database (not known at compile time), Flutter's icon tree-shaking must be disabled for release builds:

```bash
flutter build apk --release --no-tree-shake-icons
```

## Notes

- All secrets (`backend/.env`) are excluded from version control — copy `backend/.env.example` and fill in your own values.
- The seed data in `backend/prisma/seed_data.json` is kept in sync with the Flutter app's own local seed data (`test/_export_seed_test.dart` regenerates it from the Dart source of truth).
