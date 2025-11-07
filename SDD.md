**SOFTWARE DESIGN DOCUMENT (SDD)**
**Nama Produk:** SmartKasir
**Versi:** 1.0 (MVP – Offline Only)
**Tanggal:** 6 November 2025
**Penulis:** Tim SmartKasir

---

## 1. Pendahuluan

Dokumen ini mendeskripsikan desain teknis aplikasi SmartKasir setelah revisi arah proyek. Fokus utama adalah aplikasi kasir **offline-only** berbasis Flutter yang menyimpan seluruh data di SQLite dan mendukung monetisasi premium serta role user (Admin vs Kasir).

### 1.1 Tujuan
1. Menjabarkan arsitektur sistem yang sepenuhnya berjalan di perangkat mobile.
2. Menyediakan detail desain untuk tiap modul (auth, aktivasi premium, produk, transaksi, laporan, pengaturan).
3. Menjadi panduan pengembang & QA dalam melakukan implementasi dan pengujian.

### 1.2 Referensi
- PRD SmartKasir v1.0 (revisi offline premium)
- SRS SmartKasir v1.0 (revisi offline premium)
- ERD SmartKasir v1.0 (SQLite-only)

---

## 2. Arsitektur Sistem

SmartKasir menggunakan pendekatan **Clean Architecture** pada aplikasi Flutter:

```
Presentation  -> Widgets, Routes, Controllers, Riverpod Notifiers
Domain        -> Entities, Use Cases (pure Dart), Repository contracts
Data          -> Repository implementations + Drift (SQLite) data sources
```

Seluruh data pipeline berada di perangkat (tidak ada API call). Aktivasi premium, role management, dan kontrol akses diurus oleh domain & data layer lokal.

### 2.1 Modul Utama
1. **Auth & Role**
   - Login username/password.
   - Role-based navigation (Admin / Kasir).
   - Logout, remember me.
2. **Premium Activation**
   - Input kode aktivasi lokal.
   - Validasi kode (checksum atau tabel kode).
   - Menyimpan status premium + tanggal aktivasi.
3. **Produk & Stok**
   - CRUD kategori, produk, stok otomatis.
   - Notifikasi stok minimum.
4. **Transaksi**
   - Keranjang, diskon, pembayaran tunai/non-tunai, struk digital, riwayat.
5. **Laporan (Premium Only)**
   - Omzet harian/periodik, produk terlaris, stok minimum.
6. **Pengaturan**
   - Info toko, kategori (admin only), backup lokal (ekspor database).

### 2.2 Alur Data
1. User login → Domain Auth memanggil repository `UserRepository`.
2. Repository membaca tabel `users` di SQLite via Drift.
3. Setelah login, `AuthGate` menentukan navigasi (Main shell vs login).
4. Premium activation menulis status ke tabel `settings` / `activation_status`.
5. Modul lain (produk, transaksi) membaca status role/premium untuk menentukan akses UI.

### 2.3 Dependensi Utama
- Flutter 3.x
- Riverpod + get_it untuk DI
- Drift + sqlite3_flutter_libs
- Shared preferences optional (remember me)

---

## 3. Desain Komponen

### 3.1 Auth & Role
- **Entities:** `User`, `Role`, `ActivationStatus`.
- **Use Cases:**
  - `LoginWithCredentials`
  - `GetCachedUser`
  - `Logout`
  - `CreateCashier`, `ToggleUserActive` (backlog)
- **State Management:** `AuthNotifier` (Riverpod) menyimpan status (initial/loading/authenticated/error) dan user.
- **UI:** `LoginPage` dengan gradient card, form, ingat saya, CTA daftar.
- **Access Control:** `MainNavigationShell` mem-filter menu berdasarkan role (`NavigationDestination.visibleFor` - future enhancement).

### 3.2 Premium Activation
- **Data:** tabel `activation_status` (`id`, `is_premium`, `activated_at`, `code_used`, `expires_at` opsional).
- **Use Cases:**
  - `VerifyActivationCode`
  - `ActivatePremium`
  - `GetPremiumStatus`
- **UI Flow:**
  1. Admin membuka layar Aktivasi Premium.
  2. Input kode → validasi lokal (regex + referensi tabel kode atau algoritma checksum).
  3. Jika valid, update `activation_status` + `settings`.
  4. Navigasi & menu diperbaharui otomatis.

### 3.3 Produk & Stok
- **Entities:** `Category`, `Product`.
- **Use Cases:** `CreateProduct`, `UpdateProduct`, `DeleteProduct`, `AdjustStock`.
- **Data Source:** `ProductLocalDataSource` & `CategoryLocalDataSource` (Drift DAO).
- **UI:** Halaman daftar produk (search, filter), form modal, highlight stok minimum, scanning barcode (future).

### 3.4 Transaksi
- **Entities:** `Transaction`, `TransactionItem`.
- **Use Cases:** `CreateTransaction`, `GetTransactions`, `GetTransactionDetail`.
- **Data Source:** `TransactionLocalDataSource` (Drift transaction + join).
- **UI:** POS page (list produk, cart, summary), Payment sheet (tunai / non-tunai), struk digital.
- **Role Guard:** Kasir dapat membuat transaksi; Admin juga bisa.

### 3.5 Laporan
- **Use Cases:** `GetDailySales`, `GetPeriodicSales`, `GetTopProducts`, `GetLowStock`.
- **Access:** Hanya Admin Premium. Jika non-premium, halaman menunjukkan banner upsell.
- **Data:** Query aggregator di Drift (SUM, COUNT, GROUP BY).

### 3.6 Pengaturan & Backup
- Pengaturan toko (nama, alamat, logo placeholder) disimpan di `settings`.
- Admin dapat trig eksport database (misal share file `.db`).
- Opsi reset data (konfirmasi berlapis).

---

## 4. Desain Database (SQLite)

| Tabel | Kolom Utama | Keterangan |
| ----- | ----------- | ---------- |
| `users` | `id`, `username`, `password_hash`, `role (admin/cashier)`, `is_active`, `created_at`, `updated_at` | Role & status lokal |
| `activation_status` | `id`, `is_premium`, `activated_at`, `code_used`, `note` | Menyimpan status premium |
| `categories` | `id`, `name`, `description`, `is_deleted`, timestamps | Data kategori |
| `products` | `id`, `category_id`, `name`, `barcode`, `purchase_price`, `selling_price`, `stock`, `stock_min`, `is_deleted`, timestamps | Data produk + sinkron metadata internal |
| `transactions` | `id`, `transaction_code`, `transaction_date`, `total_amount`, `discount_amount`, `final_amount`, `payment_method`, `status`, `created_by` | Header transaksi |
| `transaction_items` | `id`, `transaction_id`, `product_id`, `product_name_snapshot`, `quantity`, `price_at_sale`, `subtotal` | Detail transaksi |
| `settings` | `key`, `value`, timestamps | Info toko, preferensi |
| `activation_codes` (optional) | `code`, `description`, `max_use`, `already_used` | Daftar kode yang bisa diinput |

Semua tabel menggunakan tipe TEXT (UUID) untuk PK, integer untuk flag, dan `updated_at` untuk audit.

---

## 5. Navigasi & State

```
Splash/AuthGate
 ├─ LoginPage
 └─ MainNavigationShell
      ├─ Dashboard (stats ringkas)
      ├─ Produk (admin only)
      ├─ Transaksi (semua role)
      ├─ Laporan (admin premium only)
      └─ Pengaturan (admin only + aktivitas premium)
```

Kontrol akses dilakukan pada level:
1. **Routing:** Navigation shell menentukan menu yang dirender.
2. **Widget Guard:** Setiap page memeriksa `AuthState.user.role` & status premium sebelum memuat konten.
3. **Use Case Validation:** Misal `CreateCategory` hanya dapat dipanggil jika role admin.

---

## 6. Tools & Teknologi

| Bidang | Tools |
| ------ | ----- |
| IDE | Android Studio / VS Code |
| Bahasa | Dart (Flutter) |
| State Management | Riverpod + get_it |
| Database | Drift (SQLite) |
| Lain | flutter_lints, build_runner, json_serializable |

---

## 7. Testing & QA

1. **Unit Test**: Use case (auth, premium, produk) & helper (validator kode).
2. **Widget Test**: LoginPage, Transaction page components, Activation modal.
3. **Integration Test**: Repository ↔ Drift DB.
4. **Scenario Test**: 
   - Admin baru → aktivasi premium → akses laporan.
   - Kasir login → coba akses laporan → tampil banner upsell.
   - Transaksi + update stok.
5. **Performance**: Seed 10k transaksi & uji query laporan.

---

## 8. Struktur Proyek Flutter (Direkomendasikan)

```
lib/
 ├─ main.dart
 ├─ src/
 │   ├─ app/                 # App bootstrap, navigation shell, widgets global
 │   ├─ core/                # config, constants, di, database, utils
 │   ├─ features/
 │   │   ├─ auth/
 │   │   │    ├─ data/
 │   │   │    ├─ domain/
 │   │   │    └─ presentation/
 │   │   ├─ activation/
 │   │   ├─ products/
 │   │   ├─ transactions/
 │   │   ├─ reports/
 │   │   └─ settings/
 │   └─ shared/              # widgets/components reusable
 ├─ test/
 │   └─ ...                  # unit & widget tests
```

Setiap fitur mengikuti pola Clean Architecture (domain/data/presentation) agar mudah dikembangkan secara incremental.

---

## 9. Catatan Implementasi

1. **Aktivasi Premium**: Untuk MVP, kode disimpan di tabel `activation_codes` atau menggunakan algoritma offline (misal hashing `kode + deviceId`). Pastikan mudah diganti ketika integrasi pembayaran sebenarnya tersedia.
2. **Backup/Restore**: Sediakan utility untuk ekspor file database (`path_provider` + `share_plus`) agar admin bisa menyimpan salinan secara manual.
3. **Role Toggle**: Saat status premium berubah, invalidasi cache provider sehingga UI ter-refresh otomatis (misal menggunakan `authNotifier.loadCachedUser()` ulang).
4. **Future Cloud Sync**: Simpan kolom `sync_status` / `last_synced_at` pada tabel penting sebagai persiapan jika fitur online diaktifkan kembali.

---

Dokumen ini menjadi dasar pengembangan implementasi Flutter. Perubahan lebih lanjut harus terus disinkronkan dengan PRD & SRS agar konsisten.
