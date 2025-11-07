### **Skema Database SmartKasir (Offline Only)**

**Tujuan:** Mendefinisikan struktur tabel SQLite yang menyimpan seluruh data operasional aplikasi SmartKasir, termasuk role pengguna dan status premium tanpa bergantung pada backend eksternal.

**Basis Data:**
- **SQLite (lokal)** – satu-satunya sumber data. Seluruh tabel berada pada perangkat; backup dilakukan secara manual (ekspor file .db).

**Arsitektur Aplikasi Singkat:**
- Flutter (Clean Architecture) dengan layer Presentation → Domain → Data.
- Data Layer menggunakan Drift/SQLite; tidak ada repository remote atau sinkronisasi cloud.

---

### **Daftar Tabel**

1. `users`
2. `activation_status`
3. `activation_codes` (opsional untuk stok kode)
4. `categories`
5. `products`
6. `transactions`
7. `transaction_items`
8. `settings`

---

#### **1. Tabel `users`**

| Kolom         | Tipe (SQLite) | Batasan                                | Deskripsi                                        |
|---------------|---------------|----------------------------------------|--------------------------------------------------|
| `id`          | TEXT          | PRIMARY KEY (UUID)                     | ID unik user                                     |
| `username`    | TEXT          | UNIQUE, NOT NULL                       | Username login                                   |
| `password_hash` | TEXT       | NOT NULL                               | Hash password (bcrypt/argon hash)                |
| `display_name`| TEXT          | NOT NULL                               | Nama tampilan                                    |
| `role`        | TEXT          | NOT NULL, DEFAULT 'cashier'            | `admin` atau `cashier`                           |
| `is_active`   | INTEGER       | NOT NULL, DEFAULT 1                    | Soft delete/disable akun                         |
| `created_at`  | TEXT          | NOT NULL, DEFAULT CURRENT_TIMESTAMP    | Timestamp buat                                    |
| `updated_at`  | TEXT          | NOT NULL, DEFAULT CURRENT_TIMESTAMP    | Timestamp update                                 |

**Catatan:** Minimal 1 user admin harus ada untuk mengatur kasir & aktivasi premium.

---

#### **2. Tabel `activation_status`**

| Kolom         | Tipe | Batasan | Deskripsi |
|---------------|------|---------|-----------|
| `id`          | INTEGER | PRIMARY KEY AUTOINCREMENT | Satu baris status |
| `is_premium`  | INTEGER | NOT NULL, DEFAULT 0       | 1 jika premium aktif |
| `activated_at`| TEXT    | NULL                      | Waktu aktivasi terakhir |
| `code_used`   | TEXT    | NULL                      | Kode aktivasi yang digunakan |
| `note`        | TEXT    | NULL                      | Catatan tambahan (misal masa berlaku) |

---

#### **3. Tabel `activation_codes` (opsional)**

Digunakan jika aplikasi ingin menyimpan daftar kode yang boleh dipakai.

| Kolom        | Tipe | Batasan | Deskripsi |
|--------------|------|---------|-----------|
| `code`       | TEXT | PRIMARY KEY | Nilai kode |
| `description`| TEXT | NULL | Keterangan paket |
| `max_use`    | INTEGER | NULL | Batas penggunaan |
| `already_used` | INTEGER | NOT NULL, DEFAULT 0 | Penanda apakah kode sudah dipakai |

---

#### **4. Tabel `categories`**

| Kolom       | Tipe | Batasan | Deskripsi |
|-------------|------|---------|-----------|
| `id`        | TEXT | PRIMARY KEY | UUID |
| `name`      | TEXT | NOT NULL | Nama kategori |
| `description` | TEXT | NULL | Keterangan |
| `is_deleted` | INTEGER | NOT NULL, DEFAULT 0 | Soft delete |
| `created_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | |
| `updated_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | |

---

#### **5. Tabel `products`**

| Kolom             | Tipe  | Batasan | Deskripsi |
|-------------------|-------|---------|-----------|
| `id`              | TEXT  | PRIMARY KEY | UUID |
| `category_id`     | TEXT  | FK → categories.id | Relasi kategori |
| `name`            | TEXT  | NOT NULL | Nama produk |
| `barcode`         | TEXT  | UNIQUE NULLABLE | Barcode opsional |
| `purchase_price`  | REAL  | NOT NULL | Harga beli |
| `selling_price`   | REAL  | NOT NULL | Harga jual |
| `stock`           | INTEGER | DEFAULT 0 | Stok saat ini |
| `stock_min`       | INTEGER | DEFAULT 0 | Ambang stok minimum |
| `unit`            | TEXT  | NULL | Satuan |
| `image_path`      | TEXT  | NULL | Path gambar lokal (jika ada) |
| `is_deleted`      | INTEGER | DEFAULT 0 | Soft delete |
| `created_at` / `updated_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Audit |

---

#### **6. Tabel `transactions`**

| Kolom            | Tipe | Batasan | Deskripsi |
|------------------|------|---------|-----------|
| `id`             | TEXT | PRIMARY KEY | UUID |
| `transaction_code` | TEXT | UNIQUE | Format INV-YYYYMMDD-XXXX |
| `transaction_date` | TEXT | DEFAULT CURRENT_TIMESTAMP | Waktu transaksi |
| `total_amount`   | REAL | NOT NULL | Total sebelum diskon |
| `discount_amount`| REAL | DEFAULT 0 | Diskon total |
| `final_amount`   | REAL | NOT NULL | Total bayar |
| `payment_method` | TEXT | NOT NULL | cash / transfer / e-wallet (opsional) |
| `amount_paid`    | REAL | DEFAULT 0 | Jumlah uang diterima |
| `change_amount`  | REAL | DEFAULT 0 | Kembalian |
| `status`         | TEXT | DEFAULT 'completed' | completed/cancelled |
| `created_by`     | TEXT | FK → users.id | User pembuat |
| `created_at` / `updated_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Audit |

---

#### **7. Tabel `transaction_items`**

| Kolom            | Tipe | Batasan | Deskripsi |
|------------------|------|---------|-----------|
| `id`             | TEXT | PRIMARY KEY | UUID |
| `transaction_id` | TEXT | FK → transactions.id | Relasi transaksi |
| `product_id`     | TEXT | FK → products.id | Referensi produk |
| `product_name_snapshot` | TEXT | NOT NULL | Nama produk saat transaksi (untuk histori) |
| `quantity`       | INTEGER | NOT NULL | Jumlah |
| `price_at_sale`  | REAL | NOT NULL | Harga jual saat itu |
| `subtotal`       | REAL | NOT NULL | quantity * price |
| `created_at` / `updated_at` | TEXT | DEFAULT CURRENT_TIMESTAMP |

---

#### **8. Tabel `settings`**

| Kolom | Tipe | Batasan | Deskripsi |
|-------|------|---------|-----------|
| `key`   | TEXT | PRIMARY KEY | Misal: `store_name`, `store_address`, `printer_enabled` |
| `value` | TEXT | NULL | Nilai terkait |
| `created_at` / `updated_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Audit |

---

### **Relasi Konseptual**

```
users ------< transactions
                 |
categories --< products --< transaction_items >-- transactions

activation_status (1 row) + activation_codes (opsional) terpisah
settings menyimpan key-value (store info, theme, premium flag mirror)
```

---

### **Pertimbangan Implementasi**

1. **UUID vs INTEGER:** Gunakan UUID (TEXT) untuk konsistensi ketika ekspor/import manual.
2. **Role-based Access:** Field `role` dan `is_premium` menentukan menu/fungsi yang ditampilkan.
3. **Backup:** Berikan utilitas ekspor database/JSON agar admin dapat menyimpan salinan data.
4. **Future Cloud Sync:** Pertahankan kolom `updated_at` agar mudah menambah fitur sinkronisasi di masa depan tanpa migrasi besar.
5. **Integrity:** Gunakan constraint FK di Drift untuk menjaga relasi dan aktifkan `PRAGMA foreign_keys = ON`.
