### **Skema Database SmartKasir**

**Tujuan:** Mendefinisikan struktur tabel, kolom, tipe data, kunci utama, dan kunci asing untuk menyimpan data aplikasi SmartKasir baik secara lokal maupun remote.

**Basis Data:**
*   **Lokal:** SQLite - menampung seluruh data operasional (produk, kategori, transaksi, laporan, pengaturan) agar aplikasi tetap berjalan saat offline.
*   **Remote:** MySQL - menyimpan data autentikasi pengguna (`users` table) yang diakses backend Express untuk proses login dan sinkronisasi manual saat koneksi tersedia.

**Arsitektur Aplikasi:**
*   **Flutter (Clean Architecture):** Presentation -> Domain -> Data dipisah per fitur agar mudah diuji dan dirawat.
*   **Backend Express.js (Modular Pattern):** Routes -> Controllers -> Services -> Repositories dengan konfigurasi database terpisah untuk MySQL.
*   **Offline-First:** Aplikasi utama bekerja sepenuhnya di SQLite dan melakukan sinkronisasi manual ke server ketika internet tersedia.

---

### **Entitas Utama & Tabel**

Kita akan mendefinisikan tabel-tabel berikut:

1.  `categories` (Kategori Produk)
2.  `products` (Produk)
3.  `transactions` (Transaksi Penjualan)
4.  `transaction_items` (Item dalam Transaksi)
5.  `settings` (Pengaturan Aplikasi)
6.  `sync_logs` (Log sinkronisasi opsional untuk mencatat proses ekspor / impor data saat manual sync)

---

#### **1. Tabel `categories`**

*   **Tujuan:** Menyimpan daftar kategori untuk mengorganisir produk.
*   **Relasi:** One-to-Many dengan `products` (satu kategori memiliki banyak produk).
*   **Database:** SQLite (lokal).

| Kolom             | Tipe Data (SQLite) | Batasan                      | Deskripsi                              |
| :---------------- | :----------------- | :--------------------------- | :------------------------------------- |
| `id`              | `TEXT`             | PRIMARY KEY, NOT NULL, UNIQUE | ID unik kategori (UUID untuk sinkronisasi) |
| `name`            | `TEXT`             | NOT NULL                     | Nama kategori (misal: "Minuman", "Makanan", "Fashion") |
| `description`     | `TEXT`             | NULL                         | Deskripsi kategori                     |
| `created_at`      | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan record                 |
| `updated_at`      | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu terakhir diupdate record         |
| `is_deleted`      | `INTEGER`          | NOT NULL, DEFAULT 0          | Status penghapusan (soft delete)       |

**Indeks:** `name`

---

#### **2. Tabel `products`**

*   **Tujuan:** Menyimpan informasi detail setiap produk yang dijual.
*   **Relasi:** Many-to-One dengan `categories` (banyak produk milik satu kategori).
*   **Relasi:** One-to-Many dengan `transaction_items` (satu produk bisa ada di banyak item transaksi).
*   **Database:** SQLite (lokal).

| Kolom                 | Tipe Data (SQLite) | Batasan                      | Deskripsi                              |
| :-------------------- | :----------------- | :--------------------------- | :------------------------------------- |
| `id`                  | `TEXT`             | PRIMARY KEY, NOT NULL, UNIQUE | ID unik produk (UUID untuk sinkronisasi) |
| `category_id`         | `TEXT`             | NOT NULL, FOREIGN KEY (categories.id) | Kunci asing ke tabel `categories`      |
| `name`                | `TEXT`             | NOT NULL                     | Nama produk                            |
| `barcode`             | `TEXT`             | UNIQUE (NULLable)            | Kode barcode produk (opsional, unik jika ada) |
| `purchase_price`      | `REAL`             | NOT NULL                     | Harga beli produk                      |
| `selling_price`       | `REAL`             | NOT NULL                     | Harga jual produk                      |
| `stock`               | `INTEGER`          | NOT NULL, DEFAULT 0          | Jumlah stok saat ini                   |
| `unit`                | `TEXT`             | NULL                         | Satuan produk (misal: 'pcs', 'kg', 'liter') |
| `image_url`           | `TEXT`             | NULL                         | URL gambar produk (opsional)           |
| `created_at`          | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan record                 |
| `updated_at`          | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu terakhir diupdate record         |
| `is_deleted`          | `INTEGER`          | NOT NULL, DEFAULT 0          | Status penghapusan (soft delete)       |
| `last_synced_at`      | `TEXT`             | NULL                         | Waktu terakhir produk disinkronkan (untuk lokal) |
| `sync_status`         | `TEXT`             | NULL                         | 'pending', 'synced', 'error' (untuk lokal) |

**Indeks:** `category_id`, `name`, `barcode`

---

#### **3. Tabel `transactions`**

*   **Tujuan:** Menyimpan informasi umum dari setiap transaksi penjualan.
*   **Relasi:** One-to-Many dengan `transaction_items` (satu transaksi memiliki banyak item).
*   **Database:** SQLite (lokal).

| Kolom             | Tipe Data (SQLite) | Batasan                      | Deskripsi                              |
| :---------------- | :----------------- | :--------------------------- | :------------------------------------- |
| `id`              | `TEXT`             | PRIMARY KEY, NOT NULL, UNIQUE | ID unik transaksi (UUID untuk sinkronisasi) |
| `transaction_code` | `TEXT`             | UNIQUE                       | Kode transaksi unik yang dibuat aplikasi (misal: INV-YYYYMMDD-XXXX) |
| `transaction_date`| `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Tanggal dan waktu transaksi            |
| `total_amount`    | `REAL`             | NOT NULL                     | Total jumlah transaksi sebelum diskon |
| `discount_amount` | `REAL`             | NOT NULL, DEFAULT 0.0        | Jumlah diskon yang diterapkan          |
| `final_amount`    | `REAL`             | NOT NULL                     | Total akhir yang harus dibayar setelah diskon |
| `amount_paid`     | `REAL`             | NOT NULL                     | Jumlah uang yang dibayarkan pelanggan  |
| `change_amount`   | `REAL`             | NOT NULL                     | Jumlah kembalian                       |
| `payment_method`  | `TEXT`             | NOT NULL                     | Metode pembayaran (misal: 'Cash', 'Card', 'E-Wallet') |
| `status`          | `TEXT`             | NOT NULL, DEFAULT 'completed' | Status transaksi (misal: 'completed', 'cancelled') |
| `created_at`      | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan record                 |
| `updated_at`      | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu terakhir diupdate record         |
| `is_synced`       | `INTEGER`          | NOT NULL, DEFAULT 0          | Status sinkronisasi ke server (hanya untuk lokal) |

**Indeks:** `transaction_date`, `transaction_code`

---

#### **4. Tabel `transaction_items`**

*   **Tujuan:** Menyimpan detail setiap produk yang termasuk dalam suatu transaksi.
*   **Relasi:** Many-to-One dengan `transactions` (banyak item transaksi milik satu transaksi).
*   **Relasi:** Many-to-One dengan `products` (banyak item transaksi terkait dengan satu produk).
*   **Database:** SQLite (lokal).

| Kolom             | Tipe Data (SQLite) | Batasan                      | Deskripsi                              |
| :---------------- | :----------------- | :--------------------------- | :------------------------------------- |
| `id`              | `TEXT`             | PRIMARY KEY, NOT NULL, UNIQUE | ID unik item transaksi                 |
| `transaction_id`  | `TEXT`             | NOT NULL, FOREIGN KEY (transactions.id) | Kunci asing ke tabel `transactions`    |
| `product_id`      | `TEXT`             | NOT NULL, FOREIGN KEY (products.id) | Kunci asing ke tabel `products`        |
| `product_name`    | `TEXT`             | NOT NULL                     | Nama produk saat transaksi (untuk historis) |
| `quantity`        | `INTEGER`          | NOT NULL                     | Jumlah produk yang dibeli              |
| `price_at_sale`   | `REAL`             | NOT NULL                     | Harga jual produk saat transaksi (untuk historis) |
| `subtotal`        | `REAL`             | NOT NULL                     | `quantity` * `price_at_sale`           |
| `created_at`      | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan record                 |
| `updated_at`      | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu terakhir diupdate record         |

**Indeks:** `transaction_id`, `product_id`

---

#### **5. Tabel `settings`**

*   **Tujuan:** Menyimpan pengaturan aplikasi seperti nama toko, alamat, dll.
*   **Database:** SQLite (lokal).
*   **Relasi:** Tidak ada relasi langsung dengan tabel lain (self-contained).

| Kolom         | Tipe Data (SQLite) | Batasan                      | Deskripsi                              |
| :------------ | :----------------- | :--------------------------- | :------------------------------------- |
| `key`         | `TEXT`             | PRIMARY KEY, NOT NULL, UNIQUE | Kunci pengaturan (misal: 'store_name', 'store_address') |
| `value`       | `TEXT`             | NULL                         | Nilai pengaturan                       |
| `created_at`  | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan record                 |
| `updated_at`  | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu terakhir diupdate record         |

---

#### **6. Tabel `users` (Opsional untuk MVP Awal, tetapi penting untuk masa depan)**

*   **Tujuan:** Menyimpan informasi pengguna yang dapat login ke aplikasi (misal: Admin, Kasir).
*   **Relasi:** Tidak ada relasi langsung di MVP awal.
*   **Database:** MySQL (remote).

| Kolom        | Tipe Data (MySQL) | Batasan                      | Deskripsi                              |
| :----------- | :---------------- | :--------------------------- | :------------------------------------- |
| `id`         | `CHAR(36)`        | PRIMARY KEY, NOT NULL, UNIQUE | ID unik pengguna                       |
| `username`   | `VARCHAR(255)`    | NOT NULL, UNIQUE             | Nama pengguna untuk login              |
| `password`   | `TEXT`            | NOT NULL                     | Hash password pengguna                 |
| `role`       | `VARCHAR(50)`     | NOT NULL, DEFAULT 'cashier'  | Peran pengguna (misal: 'admin', 'cashier') |
| `created_at` | `DATETIME`        | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan record                 |
| `updated_at` | `DATETIME`        | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu terakhir diupdate record         |

**Indeks:** `username`

---

#### **Perbedaan Implementasi (SQLite vs. MySQL):**

*   **UUID:** SQLite tidak memiliki tipe data UUID native. Kita akan menyimpannya sebagai `TEXT`, sedangkan di MySQL disimpan sebagai `CHAR(36)` (atau bisa dipertimbangkan `BINARY(16)` untuk optimasi) agar format tetap konsisten saat sinkronisasi.
*   **Datetime/Timestamp:** SQLite menyimpannya sebagai `TEXT` dalam format ISO8601 string, sementara MySQL menggunakan `DATETIME` (atau `TIMESTAMP`) dengan dukungan fungsi tanggal bawaan.
*   **Boolean:** SQLite menggunakan `INTEGER` (0 untuk false, 1 untuk true). Di MySQL kita menggunakan `TINYINT(1)` untuk mewakili nilai boolean.
*   **DEFAULT CURRENT_TIMESTAMP:** SQLite mendukung trigger default ini melalui teks, sedangkan MySQL menyediakan default pada kolom `DATETIME`/`TIMESTAMP`.
*   **`is_synced`, `last_synced_at`, `sync_status`:** Kolom-kolom ini *sangat relevan* untuk database lokal (SQLite) guna melacak status sinkronisasi item data individu. Tabel `users` di MySQL tidak memerlukan kolom tersebut karena hanya menangani autentikasi, sementara backend dapat menambahkan `sync_logs` terpisah bila dibutuhkan.

---

#### **Visualisasi Relasi (Konseptual):**

```
categories --< products --< transaction_items >-- transactions
           ^                                     ^
           |                                     |
           ----------------- Settings ------------
```
(Panah `--<` menunjukkan One-to-Many, kepala panah ke sisi "Many")

---

**Pertimbangan Penting untuk Sinkronisasi:**

*   **UUID sebagai ID Primer:** Penggunaan UUID di semua tabel adalah kunci untuk sinkronisasi data yang mulus antara lokal dan remote tanpa konflik ID.
*   **Timestamp untuk Deteksi Perubahan:** Kolom `updated_at` akan sangat penting untuk mendeteksi perubahan data yang perlu disinkronkan. Jika `updated_at` di lokal lebih baru dari di remote (atau sebaliknya), maka perlu sinkronisasi.
*   **Soft Delete:** Penggunaan `is_deleted` (soft delete) daripada penghapusan fisik membantu menjaga integritas data dan mempermudah sinkronisasi manual. Data dapat dihapus permanen setelah berhasil dibackup atau dibersihkan melalui backend.
*   **Offline First:** Aplikasi Flutter menulis/membaca data ke/dari SQLite terlebih dahulu. Sinkronisasi manual akan mengirim perubahan penting (misal: update stok, transaksi) ke layanan backend ketika internet tersedia, menggunakan MySQL semata-mata untuk autentikasi pengguna.




