# Ringkasan Dokumen Proyek SmartKasir

## 1. PRD (Product Requirements Document)

**Tujuan:** Membuat aplikasi kasir pintar untuk UMKM agar pencatatan transaksi, stok, dan laporan jadi lebih cepat, simple, dan efisien.

**Target Pengguna:** Pemilik warung, toko kelontong, kedai kopi, butik kecil, UMKM dengan kebutuhan kasir sederhana.

**Lingkup MVP (Minimum Viable Product):**

* **Produk:** tambah/edit/hapus produk, pencarian, kategori, update stok otomatis, notifikasi stok minimum.
* **Transaksi:** buat transaksi baru, tambah item (search, pilih daftar), ubah qty, hapus item, total otomatis, diskon (persen/nominal), pembayaran tunai, hitung kembalian, simpan transaksi, tampilkan struk digital, riwayat transaksi.
* **Laporan:** penjualan harian/periodik, produk terlaris, ringkasan stok.
* **Pengaturan:** info toko (nama, alamat), manajemen kategori.
* **Non-Fungsional:** loading < 3 detik, transaksi selesai < 2 detik, offline mode dengan sinkronisasi ke server, keamanan data dasar (PIN/Password admin).

---

## 2. ERD (Entity Relationship Diagram / Database)

**Tujuan:** Definisi tabel untuk data lokal (SQLite) & remote (MySQL).

**Tabel utama:**

1. **categories** → kategori produk (id, name, desc).
2. **products** → data produk (id, category_id, nama, harga beli, harga jual, stok, created_at, updated_at).
3. **transactions** → data transaksi (id, tanggal, total, diskon, final_amount, payment_method, status).
4. **transaction_items** → detail barang dalam transaksi (id, product_id, qty, harga jual, subtotal).
5. **settings** → pengaturan aplikasi (store_name, store_address).
6. **sync_logs** → log sinkronisasi (opsional, untuk audit).

**Catatan:**

* UUID atau AUTO_INCREMENT dapat dipakai sebagai primary key.
* Kolom sinkronisasi (`sync_status`, `is_synced`, `updated_at`) digunakan untuk mode offline → online.
* Relasi: kategori ↔ produk (1-n), produk ↔ transaksi_item (1-n), transaksi ↔ transaksi_item (1-n).

---

## 3. SRS (Software Requirements Specification)

**Fungsional (apa yang harus ada):**

* **Produk:** CRUD produk, kategori, stok otomatis, notifikasi stok minimum.
* **Transaksi:** buat transaksi, tambah item, hitung total, diskon, pembayaran tunai, hitung kembalian, simpan transaksi, tampilkan struk digital, riwayat + detail transaksi.
* **Laporan:** omzet harian/periodik, produk terlaris, laporan stok & stok minimum.
* **Pengaturan:** info toko, kategori.
* **Sinkronisasi:** otomatis/manual, konflik diselesaikan dengan `updated_at` terbaru, status sinkronisasi terlihat.

**Non-Fungsional:**

* Performa cepat (loading < 3 detik, transaksi < 2 detik).
* Usability: UI simpel, minimal klik, **sidebar responsive** untuk navigasi yang lebih efisien.
* **Responsive Design:** Layout aplikasi menyesuaikan dengan berbagai ukuran layar (mobile, tablet, desktop).
* Keamanan: HTTPS, autentikasi dasar.
* Skalabilitas: database siap tambah fitur.
* Lingkungan: Android 8+, Backend Node.js, MySQL, SQLite.

---

## 4. SDD (Software Design Document)

**Arsitektur Sistem:**

* **Frontend (Flutter, Clean Architecture):**
  * *Presentation layer:* UI/UX responsive dengan **sidebar navigation**, state management.
  * *Domain layer:* entities (Product, Transaction), use cases (CreateTransaction, SyncData).
  * *Data layer:* repository implementasi, local (SQLite), remote (API).

* **Backend (Node.js + Express.js):**
  * Controller → Service → Repository → Database.
  * REST API utama: `/products`, `/categories`, `/transactions`, `/transactions/sync`, `/settings`.

* **Database:** MySQL (server), SQLite (lokal).

**Sinkronisasi:**

* Push data lokal yang pending → server.
* Pull data terbaru dari server → lokal.
* Konflik: pakai `updated_at` terbaru.

**Struktur Proyek:**

* Flutter: `lib/features/produk/`, `lib/features/transaksi/`, dll.
* Node.js: modular (routes, controllers, services, repositories).

**Testing:**

* Unit test (frontend & backend).
* Integration test (API ↔ DB).
* End-to-end test (simulasi transaksi + sinkronisasi).
* Performance & security test.

---

## 5. UI/UX Design & Responsive Layout

**Navigasi Sidebar Responsive:**

* **Desktop/Tablet:** Sidebar tetap terbuka di sisi kiri dengan menu lengkap dan ikon
* **Mobile:** Sidebar dapat disembunyikan/ditampilkan dengan hamburger menu untuk menghemat ruang layar
* **Adaptive Behavior:** Sidebar secara otomatis menyesuaikan lebar berdasarkan ukuran layar
* **Touch-Friendly:** Semua elemen navigasi dioptimalkan untuk interaksi touch pada perangkat mobile

**Layout Responsive:**

* **Breakpoints:** 
  - Mobile: < 768px (sidebar tersembunyi, hamburger menu)
  - Tablet: 768px - 1024px (sidebar compact dengan ikon)
  - Desktop: > 1024px (sidebar full dengan teks dan ikon)
* **Grid System:** Layout menggunakan sistem grid yang fleksibel untuk berbagai ukuran layar
* **Typography:** Ukuran font dan spacing menyesuaikan dengan ukuran layar
* **Touch Targets:** Minimal 44px untuk elemen yang dapat disentuh pada mobile

**Keunggulan Sidebar vs Navbar:**

* **Efisiensi Ruang:** Sidebar tidak memakan ruang vertikal seperti navbar tradisional
* **Skalabilitas:** Mudah menambah menu baru tanpa mengganggu layout
* **Konsistensi:** Navigasi yang konsisten di semua halaman aplikasi
* **Accessibility:** Lebih mudah diakses dengan keyboard navigation

---

## 6. Timeline (Sprint Plan, total ± 50 hari kerja / 5 sprint)

# Checklist Timeline Sprint MVP SmartKasir

| Sprint                  | Durasi   | Task                                                                                                                                                                                                                    | Deliverable                                      |
| ----------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| **Sprint 1**            | 1 minggu | - Setup project Flutter<br>- Setup backend Node.js + Express<br>- Setup database Drift (SQLite) & MySQL<br>- Struktur folder proyek<br>- **Implementasi sidebar responsive dan layout responsive**                                                                                     | Project setup dengan DB siap, API dasar tersedia, UI responsive |
| **Sprint 2**            | 1 minggu | - Implementasi modul **User (Login/Register)**<br>- Implementasi modul **Category** (CRUD kategori)<br>- **Integrasi sidebar responsive di semua halaman**                                                                                                                     | Login/Register, CRUD kategori, navigasi responsive                    |
| **Sprint 3**            | 1 minggu | - Implementasi modul **Produk** (CRUD produk: tambah, edit, hapus, cari)<br>- **Optimasi layout responsive untuk halaman produk**                                                                                                          | CRUD produk dengan UI responsive                                      |
| **Sprint 4**            | 1 minggu | - Implementasi modul **Transaksi** (shopping cart, tambah item, qty, diskon, pembayaran tunai, kembalian)<br>- Update stok otomatis<br>- Simpan riwayat transaksi<br>- **Responsive design untuk halaman transaksi dan shopping cart**                                                      | CRUD transaksi + update stok otomatis dengan UI responsive            |
| **Sprint 5**            | 1 minggu | - Implementasi modul **Laporan** (penjualan harian/periodik, produk terlaris, stok minimum)<br>- Implementasi modul **Pengaturan Toko**<br>- Sinkronisasi data offline (SQLite ↔ MySQL)<br>- Integrasi semua modul<br>- **Responsive design untuk halaman laporan dan pengaturan** | Laporan, pengaturan toko, fitur sinkronisasi dengan UI responsive     |
| **Sprint 6 (opsional)** | 1 minggu | - Testing end-to-end<br>- Dokumentasi<br>- Polish UI/UX responsive<br>- Integrasi printer & struk digital<br>- **Testing responsive design di berbagai device**                                                                                                                          | Aplikasi stabil siap demo/deploy                 |

---

# Kesimpulan

* **MVP fokus pada transaksi, stok, laporan sederhana, offline mode + sinkronisasi.**
* **Desain dibuat simple agar programmer pemula bisa cepat paham:**
  frontend = Flutter dengan Clean Architecture dan **UI responsive dengan sidebar navigation**, backend = Node.js REST API, DB = MySQL (server) & SQLite (offline).
* **Timeline sprint jelas (1–5),** tiap tahap menambah fitur inti secara bertahap.
* Programmer pemula bisa mulai dengan Sprint 1 (setup project + DB) lalu lanjut sesuai urutan.
* **UI/UX Enhancement:** Semua halaman menggunakan sidebar responsive yang menyesuaikan dengan ukuran layar untuk pengalaman pengguna yang lebih baik.
