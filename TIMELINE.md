**TIMELINE SPRINT MVP SMARTKASIR (OFFLINE PREMIUM)**

**Tujuan Umum:** Merampungkan aplikasi kasir offline dengan role user (Admin Premium & Kasir), aktivasi premium lokal, manajemen produk, transaksi, laporan, dan pengaturan toko tanpa backend.

Setiap sprint ≈ 10 hari kerja. Status terakhir diperbarui setelah revisi arsitektur (6 Nov 2025).

---

### Sprint 1 – Pondasi Proyek & Database (Hari 1–10)

| Hari | Task ID    | Tugas                                                                 | Status |
|------|------------|-----------------------------------------------------------------------|--------|
| 1-2  | S1-FE-001  | Setup proyek Flutter, dependency (Riverpod, Drift, get_it)           | Done   |
| 2-4  | S1-DB-001  | Definisikan skema SQLite (users, activation, produk, transaksi)       | Done   |
| 3-5  | S1-DB-002  | Implementasi Drift database & migrasi awal                            | Done   |
| 4-6  | S1-FE-002  | Setup DI/ProviderScope + bootstrap AuthGate                           | Done   |
| 5-7  | S1-UX-001  | Desain & implementasi UI login (gradient card)                        | Done   |
| 6-8  | S1-FE-003  | Local data source dasar (kategori, produk, transaksi, settings)       | Done   |
| 8-10 | S1-FE-004  | Tema global + MainNavigationShell responsif                           | Done   |

---

### Sprint 2 – Autentikasi, Role & Aktivasi Premium (Hari 11–20)

| Hari | Task ID    | Tugas                                                                  | Status       |
|------|------------|------------------------------------------------------------------------|--------------|
| 11-12| S2-FE-001  | Auth domain layer (entities & use case login/cached/logout)            | Done         |
| 12-13| S2-FE-002  | Auth data layer (User repository Drift, hashing util)                  | Done         |
| 13-14| S2-UX-002  | Finalisasi UI login + remember me + feedback error                     | Done         |
| 14-15| S2-FE-003  | Role-based navigation guard (Admin vs Kasir)                           | Done         |
| 15-17| S2-FE-004  | Aktivasi premium lokal (kode input, verifikasi, penyimpanan status)    | Done         |
| 17-18| S2-FE-005  | Manajemen akun kasir (CRUD user lokal oleh Admin)                      | Done         |
| 18-20| S2-FE-006  | Content gating (banner upsell pada laporan/pengaturan bila non-premium)| Done         |

---

### Sprint 3 – Kategori & Produk (Hari 21–30)

| Hari | Task ID    | Tugas                                                                  | Status |
|------|------------|------------------------------------------------------------------------|--------|
| 21-22| S3-FE-001  | Domain kategori & produk (CRUD use cases, validation)                  | Done  |
| 22-23| S3-FE-002  | Repository/DAO kategori & produk (Drift)                               | Done  |
| 23-25| S3-UX-001  | UI kategori (list, filter, form, soft delete)                          | Done  |
| 25-27| S3-UX-002  | UI produk (list + search + stok minimum highlight)                     | Done  |
| 27-28| S3-FE-003  | Form produk (admin only), upload barcode manual                        | To Do  |
| 28-29| S3-FE-004  | Stok minimum notifier & dashboard widget                               | To Do  |
| 29-30| S3-FE-005  | Integrasi scanner (opsional, placeholder)                              | To Do  |

---

### Sprint 4 – Transaksi & Struk (Hari 31–40)

| Hari | Task ID    | Tugas                                                                  | Status |
|------|------------|------------------------------------------------------------------------|--------|
| 31-32| S4-FE-001  | Domain transaksi (cart, diskon, pembayaran)                            | To Do  |
| 32-33| S4-FE-002  | Repository/DAO transaksi + item, join & histori                        | To Do  |
| 33-35| S4-UX-001  | POS screen (pencarian produk, keranjang, ringkasan)                    | To Do  |
| 35-36| S4-UX-002  | Payment sheet (tunai/non-tunai, kembalian)                             | To Do  |
| 36-37| S4-FE-003  | Struk digital + share/export pdf (opsional)                            | To Do  |
| 37-39| S4-FE-004  | Riwayat transaksi & detail (role Admin & Kasir)                        | To Do  |
| 39-40| S4-QA-001  | Uji beban transaksi + validasi stok otomatis                           | To Do  |

---

### Sprint 5 – Laporan, Pengaturan & QA (Hari 41–50)

| Hari | Task ID    | Tugas                                                                  | Status |
|------|------------|------------------------------------------------------------------------|--------|
| 41-43| S5-FE-001  | Domain + data laporan (daily, periodic, top product, stok minimum)     | To Do  |
| 43-44| S5-UX-001  | UI laporan (dengan gating premium)                                     | To Do  |
| 44-46| S5-FE-002  | Pengaturan toko (info toko, preferensi) + backup lokal                 | To Do  |
| 46-47| S5-FE-003  | Halaman aktivasi premium final (copywriting, status indikator)         | To Do  |
| 47-48| S5-QA-001  | End-to-End testing (Admin premium, Kasir, skenario error)              | To Do  |
| 48-49| S5-QA-002  | Perbaikan bug & polishing UI/UX                                        | To Do  |
| 50   | S5-PM-001  | Review MVP & dokumentasi rilis                                        | To Do  |

---

Catatan:
- Status akan diperbarui setiap kali task selesai.
- Jika diperlukan buffer untuk riset monetisasi/pembayaran, sisipkan pada Sprint 5 setelah aktivasi premium stabil.






