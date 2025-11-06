**CHECKLIST TIMELINE PEKERJAAN SPRINT MVP - SmartKasir v1.0**

**Tujuan Keseluruhan MVP:**
Mengimplementasikan fungsionalitas inti SmartKasir untuk pencatatan transaksi, manajemen produk dasar, laporan penjualan sederhana, dan sinkronisasi data offline-first.
Untuk tujuan ini, saya akan mengasumsikan:
*   Setiap Sprint adalah 10 hari kerja (2 minggu).
*   Penomoran Hari akan bersifat kumulatif (Hari 1 sampai Hari 50 untuk 5 sprint).
*   Status awal semua tugas adalah "To Do".
*   Arsitektur hybrid: backend Node.js + MySQL hanya menangani autentikasi pengguna (`users`) dan layanan sinkronisasi; seluruh data operasional dikelola pada SQLite lokal di aplikasi Flutter. 

---

### **Sprint 1: Inisialisasi Proyek & Basis Data (Hari 1 - 10)**

| Hari | Task ID      | Tugas                                       | Keterangan & Dependencies                                     | Status    |
| :--- | :----------- | :------------------------------------------ | :------------------------------------------------------------ | :-------- |
| 1-2  | S1-BE-001    | Setup Proyek Backend                        | Inisialisasi Node.js, Express.js, struktur folder, .env.    | Done      |
| 1-2  | S1-FE-001    | Setup Proyek Frontend                       | Inisialisasi Flutter, pubspec.yaml (dependencies), struktur folder. | Done      |
| 3-4  | S1-BE-002    | Setup MySQL (users) & ORM                   | Install MySQL, tool admin (DBeaver), integrasi Sequelize/Knex.js. | Done      |
| 3-5  | S1-FE-002    | Setup SQLite & Integrasi Drift/sqflite      | Install `drift`/`sqflite`, konfigurasi database lokal.      | Done      |
| 5-6  | S1-BE-003    | Rancang Storage Sinkronisasi & Metadata     | Struktur penyimpanan paket (disk/S3) + tabel metadata (MySQL). Depends: S1-BE-002. | Done      |
| 6-7  | S1-FE-003    | Buat Skema DB Lokal `categories`, `products`, `transactions`, `transaction_items` (FE) | Sesuai ERD, tambahkan kolom sync. Depends: S1-FE-002.        | Done      |
| 7-8  | S1-BE-004    | Migrasi DB Awal & Seed User (BE)            | Membuat tabel `users` di MySQL + admin default. Depends: S1-BE-003. | Done      |
| 8-9  | S1-FE-004    | Setup `LocalDataSource` Dasar (FE)          | Untuk interaksi CRUD dasar dengan SQLite. Depends: S1-FE-003. | Done      |
| 9-10 | S1-BE-005    | Implementasi Core API (Error Handling, Logging) & `/health` endpoint | Setup middleware dasar.                                       | Done      |
| 9-10 | S1-FE-005    | Setup Tema & Bottom Nav Bar Dasar (FE)      | Implementasi UI tanpa fungsi. Depends: S1-FE-001.             | Done      |

---

### **Sprint 2: Autentikasi & Manajemen Kategori (Hari 11 - 20)**

| Hari | Task ID      | Tugas                                       | Keterangan & Dependencies                                     | Status    |
| :--- | :----------- | :------------------------------------------ | :------------------------------------------------------------ | :-------- |
| 11   | S2-BE-001    | Buat Model/Tabel `users` (BE)               | Untuk menyimpan kredensial login. Depends: S1-BE-004.         | Done      |
| 11-12| S2-BE-002    | Implementasi Auth Module (BE)               | Controller (`/auth/login`), Service, Repository, JWT. Depends: S2-BE-001. | Done      |
| 11-13| S2-FE-001    | Implementasi Auth Domain Layer (FE)         | Entities, Use Cases (`LoginUseCase`), Abstract Repo.          | Done      |
| 13-14| S2-FE-002    | Implementasi Auth Data Layer (FE)           | Remote/Local DataSource, Repo Impl. Depends: S2-FE-001.       | To Do     |
| 14-15| S2-FE-003    | Buat Login Screen & Integrasi State Mgmt (FE)| UI login, panggil `LoginUseCase`. Depends: S2-FE-002.        | To Do     |
| 16-17| S2-FE-004    | Implementasi Category Domain Layer (FE)     | Entities, Use Cases (CRUD), Abstract Repo (lokal).            | To Do     |
| 17-18| S2-FE-005    | Implementasi Category Data Layer (FE)       | Local DataSource (SQLite) & Repo Impl. Depends: S2-FE-004.    | To Do     |
| 18-19| S2-FE-006    | Buat Category List Screen (FE)              | UI, daftar kategori, FAB Tambah. Depends: S2-FE-005.          | To Do     |
| 19-20| S2-FE-007    | Buat Category Form Screen (FE)              | UI, tambah/edit kategori. Depends: S2-FE-005.                 | To Do     |

---

### **Sprint 3: Manajemen Produk Dasar (Hari 21 - 30)**

| Hari | Task ID      | Tugas                                       | Keterangan & Dependencies                                     | Status    |
| :--- | :----------- | :-------------------------------------------- | :------------------------------------------------------------ | :-------- |
| 21-23| S3-FE-001    | Implementasi Product Domain Layer (FE)      | Entities, Use Cases (CRUD), Abstract Repo (lokal).            | To Do     |
| 23-24| S3-FE-002    | Implementasi Product Data Layer (FE)        | Local DataSource (SQLite) & Repo Impl. Depends: S3-FE-001.    | To Do     |
| 25-26| S3-FE-003    | Buat Product List Screen (FE)               | UI, daftar produk, filter, pencarian, notifikasi stok minimum. Depends: S3-FE-002, S2-FE-006. | To Do     |
| 27-28| S3-FE-004    | Buat Product Form Screen (FE)               | UI, tambah/edit produk, pilih kategori. Depends: S3-FE-002, S2-FE-007. | To Do     |
| 29   | S3-FE-005    | Integrasi Barcode Scanner (FE)              | Untuk input produk baru/edit.                                 | To Do     |
| 30   | S3-FE-006    | Implementasi Notifikasi Stok Minimum (FE)   | Visual di daftar produk. Depends: S3-FE-003.                  | To Do     |

---

### **Sprint 4: Inti Transaksi Penjualan & Sinkronisasi (Hari 31 - 40)**

| Hari | Task ID      | Tugas                                       | Keterangan & Dependencies                                     | Status    |
| :--- | :----------- | :-------------------------------------------- | :------------------------------------------------------------ | :-------- |
| 31-32| S4-BE-001    | Implementasi Sync API (BE)                  | `POST /sync/upload`, `GET /sync/download`, `GET /sync/status`. Depends: S1-BE-003, S2-BE-002. | To Do     |
| 31-33| S4-FE-001    | Implementasi Transaction Domain Layer (FE)  | Entities, Use Cases (local POS), Abstract Repo.               | To Do     |
| 33-34| S4-FE-002    | Implementasi Transaction Data Layer (FE)    | Local DataSource (SQLite) & Repo Impl. Depends: S4-FE-001.    | To Do     |
| 35-36| S4-FE-003    | Buat Transaction POS Screen (FE)            | UI, keranjang, tambah item (scan/search). Depends: S4-FE-002, S3-FE-005. | To Do     |
| 36-37| S4-FE-004    | Buat Payment Screen & Logic (FE)            | UI, metode bayar, input uang, kembalian. Depends: S4-FE-003.  | To Do     |
| 38-39| S4-FE-005    | Implementasi `SyncDataUseCase` (FE)         | Orkestrasi ekspor/impor paket, penanganan konflik lokal. Depends: S4-FE-002, S4-BE-001. | To Do     |
| 39-40| S4-FE-006    | Trigger Sinkronisasi Otomatis/Manual (FE)   | Background task, tombol sync. Depends: S4-FE-005.             | To Do     |
| 40   | S4-FE-007    | Buat Transaction History & Detail Screens (FE)| UI daftar transaksi, detail. Depends: S4-FE-002.             | To Do     |

---

### **Sprint 5: Laporan Sederhana & Pengaturan (Hari 41 - 50)**

| Hari | Task ID      | Tugas                                       | Keterangan & Dependencies                                     | Status    |
| :--- | :----------- | :-------------------------------------------- | :------------------------------------------------------------ | :-------- |
| 41-43| S5-FE-001    | Implementasi Report Domain & Data Layer (FE) | Use Cases, Repo Impl untuk laporan lokal (aggregasi SQLite). Depends: S4-FE-002. | To Do     |
| 44   | S5-FE-002    | Buat Report Screens (FE)                    | UI untuk laporan penjualan, produk terlaris, stok. Depends: S5-FE-001. | To Do     |
| 45-46| S5-FE-003    | Implementasi Settings Domain & Data Layer (FE)| Use Cases, Repo Impl untuk pengaturan lokal.                  | To Do     |
| 47   | S5-FE-004    | Buat Settings Screen & Integrasi (FE)       | UI info toko, integrasi manajemen kategori. Depends: S5-FE-003, S2-FE-006. | To Do     |
| 48   | S5-FE-005    | Finalisasi Struk Digital (FE)               | Tampilan ringkasan transaksi setelah selesai. Depends: S4-FE-004. | To Do     |
| 48-49| S5-QA-001    | Uji Coba End-to-End & Perbaikan Bug Minor   | Pengujian lengkap, perbaikan UI/UX.                           | To Do     |
| 50   | S5-PM-001    | Review MVP & Persiapan Deployment           | Finalisasi dokumentasi, persiapan rilis.                       | To Do     |

---

Ini adalah struktur timeline yang lebih terperinci. Ingat bahwa ini adalah estimasi awal dan bisa disesuaikan seiring berjalannya proyek. Kolom `Status` akan diupdate secara berkala oleh tim pengembangan.
