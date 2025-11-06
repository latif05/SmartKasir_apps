# SmartKasir Backend

Backend service untuk aplikasi SmartKasir menggunakan Express.js (TypeScript) dengan pola modular (route → controller → service → repository). Layanan ini fokus pada autentikasi menggunakan database MySQL dan endpoint sinkronisasi untuk menampung data dari aplikasi mobile (SQLite).

## Fitur Utama Sprint 1
- Endpoint `/api/auth/login` untuk autentikasi pengguna (validasi kredensial terhadap tabel `users` di MySQL, menghasilkan JWT).
- Skeleton endpoint `/api/sync/pull` dan `/api/sync/push` untuk proses sinkronisasi offline-first.
- Middleware global (helmet, cors, morgan) dan error handler terpusat.
- Konfigurasi lingkungan melalui file `.env`.

## Struktur Proyek
```
backend/
├── src/
│   ├── app.ts                     # Inisialisasi Express dan middleware
│   ├── server.ts                  # Bootstrap aplikasi + cek koneksi MySQL
│   ├── config/env.ts              # Loader variabel environment
│   ├── core/http/                 # Helper response & middleware error/not found
│   ├── database/mysqlClient.ts    # Pool koneksi MySQL (mysql2/promise)
│   ├── database/setup.ts          # Migrasi awal + seed admin
│   ├── modules/
│   │   ├── auth/                  # Modul autentikasi
│   │   │   ├── http/              # Route & controller
│   │   │   ├── services/          # Business logic login
│   │   │   ├── repositories/      # Query ke MySQL (tabel users)
│   │   │   ├── validators/        # Validasi payload (zod)
│   │   │   └── models/            # Definisi entity User
│   │   └── sync/                  # Skeleton modul sinkronisasi
│   │       ├── sync.controller.ts
│   │       └── sync.service.ts
├── tsconfig.json
├── package.json
└── .env.example
```

## Perintah Penting
```bash
# Install dependencies
npm install

# Jalankan migrasi & seed admin default
npm run db:setup

# Menjalankan server dalam mode development (hot reload)
npm run dev

# Build TypeScript → JavaScript
npm run build

# Menjalankan hasil build (dist/server.js)
npm start
```

## Catatan Syncronization
- `SyncService` masih berupa stub untuk Sprint 1. Implementasi detail (merge data produk, transaksi, dll.) akan dilakukan pada sprint berikutnya.
- Konflik data akan diselesaikan menggunakan kolom `updated_at` sesuai dokumen SRS/SDD.
- Kredensial admin default dapat diatur melalui variabel lingkungan:
  - `SEED_ADMIN_USERNAME` (default: `admin`)
  - `SEED_ADMIN_PASSWORD` (default: `admin123`)
  - `SEED_ADMIN_DISPLAY_NAME` (default: `Administrator`)

## TODO Selanjutnya
- Proteksi endpoint sync dengan JWT middleware.
- Implementasi detail push/pull sinkronisasi (produk, kategori, transaksi).
- Menambahkan lapisan logging terstruktur dan pengujian otomatis.
