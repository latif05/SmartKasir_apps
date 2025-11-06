**SOFTWARE REQUIREMENTS SPECIFICATION (SRS)**
**Nama Produk:** SmartKasir
**Versi:** 1.0 (MVP)
**Tanggal:** 26 Mei 2024
**Penulis:** Abdul Latif, Bima Agung F.

---

### **1. Pendahuluan**

Dokumen Software Requirements Specification (SRS) ini merinci persyaratan fungsional dan non-fungsional untuk aplikasi SmartKasir versi 1.0 (MVP). SmartKasir adalah aplikasi kasir digital berbasis mobile yang dirancang untuk membantu Usaha Mikro, Kecil, dan Menengah (UMKM) dalam mengelola transaksi penjualan, stok produk, dan laporan keuangan sederhana secara efisien. Dokumen ini bertujuan untuk menjadi referensi utama bagi tim pengembangan, pengujian, dan manajemen proyek.

**1.1. Tujuan**
*   Menyediakan deskripsi yang jelas dan lengkap tentang fungsi dan fitur SmartKasir.
*   Menjadi dasar untuk perencanaan, pengembangan, dan pengujian.
*   Memastikan pemahaman yang konsisten antara semua pemangku kepentingan mengenai lingkup proyek.

**1.2. Lingkup Produk (MVP)**
SmartKasir MVP akan mencakup fitur inti untuk manajemen produk, pencatatan transaksi penjualan dasar, pelaporan sederhana, dan pengaturan aplikasi. Fokus utama adalah pada kemudahan penggunaan dan fungsionalitas offline dengan kemampuan sinkronisasi data. Fitur seperti multi-user, multi-cabang, manajemen pembelian, dan integrasi hardware eksternal yang lebih kompleks akan ditunda untuk rilis selanjutnya.

**1.3. Audiens Dokumen**
*   Product Manager
*   Pengembang (Frontend Flutter, Backend Node.js)
*   Quality Assurance (QA) Engineer
*   UI/UX Designer
*   Tim Manajemen Proyek

### **2. Deskripsi Umum**

**2.1. Perspektif Produk**
SmartKasir adalah aplikasi mandiri yang dirancang untuk perangkat Android. Aplikasi ini akan berkomunikasi dengan backend Node.js melalui API untuk sinkronisasi data dan penyimpanan terpusat, namun dapat beroperasi secara penuh dalam mode offline menggunakan database SQLite lokal.

**2.2. Fitur Produk (Detail dari PRD)**

Berikut adalah fitur utama yang akan diimplementasikan pada MVP SmartKasir:

*   **Manajemen Produk:**
    *   Tambah, Edit, Hapus Produk
    *   Daftar & Pencarian Produk
    *   Manajemen Kategori
    *   Update Stok Otomatis (saat transaksi)
    *   Notifikasi Stok Minimum (visual)
*   **Transaksi Penjualan:**
    *   Pembuatan Transaksi Baru
    *   Penambahan Item (pencarian, scan barcode, pilih dari daftar)
    *   Edit Kuantitas & Hapus Item
    *   Perhitungan Total Otomatis
    *   Penerapan Diskon (persentase/nominal)
    *   Proses Pembayaran (Tunai, Non-Tunai)
    *   Perhitungan Kembalian Otomatis
    *   Penyelesaian Transaksi (simpan, kurangi stok)
    *   Tampilan Struk Digital
    *   Riwayat & Detail Transaksi
*   **Laporan Sederhana:**
    *   Laporan Penjualan Harian/Periodik
    *   Laporan Produk Terlaris
    *   Laporan Stok
*   **Pengaturan Aplikasi:**
    *   Pengaturan Informasi Toko (nama, alamat)

**2.3. Karakteristik Pengguna**
*   **Tipe:** Pemilik UMKM, Kasir.
*   **Tingkat Pengalaman:** Variatif, namun diasumsikan mungkin kurang familiar dengan sistem POS yang kompleks. Aplikasi harus intuitif dan mudah dipelajari.
*   **Tujuan:** Mencatat penjualan, memantau stok, dan mendapatkan laporan dasar dengan cepat dan efisien.

**2.4. Kendala Umum**
*   **Perangkat Keras:** Aplikasi ditujukan untuk perangkat Android (ponsel atau tablet).
*   **Konektivitas:** Harus berfungsi penuh secara offline; koneksi internet diperlukan hanya untuk sinkronisasi data ke server pusat.
*   **Kompleksitas:** Fitur harus tetap sederhana dan menghindari kompleksitas yang tidak perlu untuk mencapai tujuan efisiensi dan kemudahan penggunaan.

### **3. Persyaratan Fungsional (Fungsional Requirements)**

Ini adalah deskripsi detail tentang apa yang harus dilakukan sistem.

**3.1. User Management (Basic)**
*   **FR-UM-001: Login Sederhana:** Aplikasi harus memiliki mekanisme login sederhana (misal: satu set kredensial admin) untuk mengakses fitur utama. (Pada MVP, tidak ada fitur multi-user atau registrasi).

**3.2. Product Management**
*   **FR-PM-001: Tambah Kategori Produk:** Pengguna harus dapat menambahkan kategori produk baru (nama, deskripsi).
    *   *Input:* Nama Kategori (string, max 255), Deskripsi (string, opsional).
    *   *Output:* Kategori baru tersimpan. Validasi nama kategori tidak boleh kosong.
*   **FR-PM-002: Edit Kategori Produk:** Pengguna harus dapat mengedit detail kategori produk yang sudah ada.
*   **FR-PM-003: Hapus Kategori Produk:** Pengguna harus dapat menghapus kategori produk. (Jika kategori memiliki produk, hapus tidak diizinkan atau produk-produk tersebut dipindahkan ke kategori "Default"/'Uncategorized').
*   **FR-PM-004: Tambah Produk Baru:** Pengguna harus dapat menambahkan produk baru.
    *   *Input:* Nama Produk (string, max 255), Kategori (pilih dari daftar), Harga Beli (numeric, min 0), Harga Jual (numeric, min 0, harus >= Harga Beli), Stok Awal (integer, min 0), Barcode (string, opsional, unik jika diisi), Satuan (string, opsional).
    *   *Output:* Produk baru tersimpan. Validasi semua input wajib.
*   **FR-PM-005: Edit Detail Produk:** Pengguna harus dapat mengedit informasi produk yang sudah ada.
*   **FR-PM-006: Hapus Produk:** Pengguna harus dapat menghapus produk. (Soft delete: set `is_deleted = TRUE`).
*   **FR-PM-007: Daftar Produk:** Sistem harus menampilkan daftar semua produk yang tidak terhapus.
    *   *Fungsionalitas:* Pencarian (berdasarkan nama, barcode), Filter (berdasarkan kategori), Sorting (nama, stok, harga).
*   **FR-PM-008: Notifikasi Stok Minimum:** Produk dengan stok <= 10 (atau nilai default yang belum bisa dikonfigurasi di MVP) harus ditandai secara visual di daftar produk.
*   **FR-PM-009: Scan Barcode (untuk Produk):** Aplikasi harus dapat membaca barcode produk menggunakan kamera perangkat.

**3.3. Transaction Management**
*   **FR-TM-001: Memulai Transaksi Baru:** Sistem harus menyediakan antarmuka untuk memulai transaksi penjualan baru.
*   **FR-TM-002: Menambah Item ke Keranjang:** Pengguna dapat menambahkan produk ke keranjang transaksi melalui:
    *   Pencarian teks produk (autocomplete).
    *   Scan barcode produk.
    *   Memilih dari daftar produk yang ditampilkan.
*   **FR-TM-003: Mengelola Item di Keranjang:**
    *   Mengubah kuantitas item (numeric, min 1).
    *   Menghapus item dari keranjang.
*   **FR-TM-004: Perhitungan Total Transaksi:** Sistem harus secara real-time menghitung subtotal dan total akhir transaksi.
*   **FR-TM-005: Menerapkan Diskon:** Pengguna dapat menerapkan diskon pada total transaksi:
    *   Diskon Persentase (0-100%).
    *   Diskon Nominal (harus <= total transaksi).
*   **FR-TM-006: Memilih Metode Pembayaran:** Pengguna dapat memilih metode pembayaran (Tunai, Non-Tunai).
*   **FR-TM-007: Input Pembayaran Tunai & Kembalian:** Jika metode Tunai, pengguna harus menginput jumlah uang yang diterima, dan sistem otomatis menghitung kembalian.
*   **FR-TM-008: Menyelesaikan Transaksi:** Setelah pembayaran, transaksi harus disimpan, stok produk yang terjual harus berkurang, dan struk digital ditampilkan.
    *   `transactions.status` diatur menjadi 'completed'.
*   **FR-TM-009: Melihat Riwayat Transaksi:** Sistem harus menampilkan daftar transaksi yang sudah selesai.
    *   *Fungsionalitas:* Filter berdasarkan tanggal (hari ini, kemarin, minggu ini, bulan ini, kustom).
*   **FR-TM-010: Melihat Detail Transaksi:** Pengguna dapat melihat detail lengkap dari transaksi yang dipilih (item yang dibeli, harga jual saat itu, total, diskon, pembayaran).

**3.4. Reporting**
*   **FR-RP-001: Laporan Penjualan Harian:** Menampilkan total omzet penjualan untuk hari ini.
*   **FR-RP-002: Laporan Penjualan Periodik:** Menampilkan total omzet penjualan untuk periode yang dipilih (mingguan, bulanan, kustom).
*   **FR-RP-003: Laporan Produk Terlaris:** Menampilkan daftar produk dengan jumlah penjualan tertinggi dalam periode tertentu.
*   **FR-RP-004: Laporan Stok Saat Ini:** Menampilkan ringkasan stok produk (jumlah item, nilai stok).
*   **FR-RP-005: Laporan Produk Stok Minimum:** Menampilkan daftar produk yang stoknya di bawah batas minimum.

**3.5. Application Settings**
*   **FR-AS-001: Konfigurasi Info Toko:** Pengguna dapat mengisi/mengedit nama toko dan alamat, yang akan digunakan pada struk digital.
*   **FR-AS-002: Konfigurasi Kategori:** Pengguna dapat menambah, mengedit, dan menghapus kategori produk.

**3.6. Data Synchronization**
*   **FR-DS-001: Sinkronisasi Manual:** Aplikasi harus mendeteksi ketersediaan internet dan memberikan opsi sinkronisasi (ekspor/impor) antara database lokal SQLite dan layanan backend ketika dibutuhkan. Backend memanfaatkan MySQL hanya untuk autentikasi pengguna sebelum menerima/menyediakan paket data.
*   **FR-DS-002: Penanganan Konflik Dasar:** Untuk MVP, ketika pengguna mengimpor data hasil sinkronisasi dari perangkat lain, prioritas akan diberikan pada data lokal dan perubahan terbaru (`updated_at`) saat melakukan merge.
*   **FR-DS-003: Indikator Status Sinkronisasi:** Pengguna harus dapat melihat status sinkronisasi (misal: "Sedang Sinkronisasi...", "Terakhir disinkronkan: ...", "Offline").
*   **FR-DS-004: Manual Trigger Sinkronisasi:** Pengguna harus dapat secara manual memicu proses sinkronisasi.

### **4. Persyaratan Non-Fungsional (Non-Functional Requirements)**

**4.1. Performa (Performance)**
*   **NFR-PERF-001:** Waktu muat layar utama/dashboard tidak boleh melebihi 3 detik.
*   **NFR-PERF-002:** Waktu proses penyelesaian transaksi (dari klik 'Bayar' hingga struk ditampilkan) tidak boleh melebihi 2 detik.
*   **NFR-PERF-003:** Operasi CRUD dasar (Tambah/Edit/Hapus Produk) harus selesai dalam waktu kurang dari 1 detik.
*   **NFR-PERF-004:** Sinkronisasi data dasar (misal: 100 transaksi + 50 produk baru) harus selesai dalam waktu 30 detik (dengan koneksi internet stabil).

**4.2. Usabilitas (Usability)**
*   **NFR-USAB-001:** Desain UI harus minimalis, bersih, dan intuitif, memungkinkan pengguna menyelesaikan tugas utama dengan sedikit klik.
*   **NFR-USAB-002:** Navigasi antar modul harus jelas dan konsisten.
*   **NFR-USAB-003:** Setiap input pengguna harus memiliki validasi dan pesan kesalahan yang jelas.
*   **NFR-USAB-004:** Aplikasi harus menyediakan umpan balik visual (loading indicator, toast message) untuk setiap aksi pengguna.

**4.3. Keandalan (Reliability)**
*   **NFR-RELI-001:** Aplikasi harus memiliki tingkat ketersediaan 99.9% selama jam operasional (tidak termasuk waktu down server terjadwal).
*   **NFR-RELI-002:** Setiap proses sinkronisasi harus menghasilkan backup atau paket data yang konsisten dengan kondisi database SQLite lokal setelah proses selesai.
*   **NFR-RELI-003:** Mekanisme penanganan error yang baik harus ada untuk transaksi database dan komunikasi API.

**4.4. Keamanan (Security)**
*   **NFR-SEC-001:** Data sensitif (misal: password jika ada user, harga beli) harus disimpan terenkripsi di database remote.
*   **NFR-SEC-002:** Komunikasi antara aplikasi Flutter dan backend Node.js harus menggunakan HTTPS.
*   **NFR-SEC-003:** Autentikasi API harus diterapkan untuk setiap permintaan ke backend.

**4.5. Skalabilitas (Scalability)**
*   **NFR-SCAL-001:** Arsitektur backend harus mampu menangani peningkatan volume data (transaksi, produk) dan jumlah pengguna tanpa penurunan performa yang signifikan.
*   **NFR-SCAL-002:** Desain database harus mendukung penambahan tabel dan kolom baru untuk fitur di masa depan tanpa memerlukan perubahan skema mayor.

**4.6. Maintainabilitas (Maintainability)**
*   **NFR-MAINT-001:** Kode sumber harus mengikuti prinsip Clean Architecture (Domain, Data, Presentation layers) dan Clean Code (konsistensi penamaan, komentar yang jelas, unit testing yang memadai).
*   **NFR-MAINT-002:** Dokumentasi API dan ERD (Entity-Relationship Diagram) harus selalu diperbarui.

**4.7. Lingkungan Operasi (Operational Environment)**
*   **NFR-ENV-001:** **Aplikasi Mobile:** Android 8.0 (Oreo) atau lebih baru.
*   **NFR-ENV-002:** **Backend Server:** Lingkungan Linux/Windows Server yang mendukung Node.js.
*   **NFR-ENV-003:** **Database:** MySQL 8+ (tabel `users` untuk autentikasi), SQLite terbaru untuk data operasional.

### **5. Arsitektur Sistem**

**5.1. Komponen Utama**
*   **Frontend (Mobile App):** Flutter (Dart)
    *   **Layer Presentation:** UI, Widgets, State Management.
    *   **Layer Domain:** Use Cases, Entities, Repositories (interfaces).
    *   **Layer Data:** Implementasi Repositories, Data Sources (Local SQLite, Remote API).
*   **Backend (API Server):** Node.js dengan Express.js
    *   **Controller:** Menangani permintaan HTTP, memanggil Service.
    *   **Service:** Logika bisnis inti (autentikasi, validasi, sinkronisasi paket data), memanggil Repository.
    *   **Repository:** Berinteraksi dengan MySQL (tabel `users`) untuk autentikasi dan modul penyimpanan sinkronisasi (misal berkas/objek storage).
    *   **Database:** MySQL (hanya tabel `users` untuk kredensial).

**5.2. Skema Database (Detail dari Dokumen Skema Database)**
(Semua data operasional — `categories`, `products`, `transactions`, `transaction_items`, `settings` — disimpan di SQLite lokal dengan UUID dan kolom sinkronisasi. Database MySQL di backend hanya memiliki tabel `users` untuk autentikasi dan tidak menyimpan data transaksi/produk.)

**5.3. Mekanisme Sinkronisasi**
*   **Push:** Perubahan data di lokal (`products` dengan `sync_status = 'pending'`, `transactions` dengan `is_synced = FALSE`) diekspor menjadi paket sinkronisasi (JSON/ZIP) lalu dikirim ke backend setelah pengguna terautentikasi di MySQL.
*   **Pull:** Perangkat dapat mengunduh paket sinkronisasi yang pernah diunggah untuk kemudian di-merge kembali ke SQLite lokal.
*   **Deteksi Perubahan:** Menggunakan kolom `updated_at` untuk menentukan data mana yang perlu dimasukkan dalam paket sinkronisasi.
*   **Resolusi Konflik:** Prioritas pada data lokal; perubahan baru diimpor hanya jika `updated_at` lebih terbaru dari data lokal.

### **6. Desain UI/UX (Gambaran Umum)**

*   **Antarmuka:** Desain material (Material Design untuk Flutter) dengan penekanan pada kejelasan dan kesederhanaan.
*   **Navigasi:** Bottom navigation bar untuk navigasi utama (Transaksi, Stok, Laporan, Pengaturan).
*   **Konsistensi:** Konsistensi dalam penggunaan warna, tipografi, dan ikon di seluruh aplikasi.
*   **Error Handling:** Pesan error yang informatif dan mudah dipahami.
*   **Feedback:** Animasi loading, pesan toast/snackbar untuk konfirmasi aksi.

*(Dibutuhkan dokumen terpisah berupa wireframe dan mockup untuk detail desain.)*

### **7. Metrik Keberhasilan (KPI)**

*   **Tingkat Adopsi:** Target X pengguna aktif bulanan dalam 3 bulan pertama.
*   **Efisiensi Transaksi:** Rata-rata waktu transaksi < 5 detik.
*   **Kepuasan Pengguna:** Skor rata-rata 4.0+ di platform Android Play Store.
*   **Keandalan Sinkronisasi:** 98% proses sinkronisasi manual (unggah/unduh paket) selesai tanpa error.

### **8. Rencana Pengujian (High-Level)**

*   **Unit Testing:** Untuk logika bisnis inti di Domain Layer (Flutter & Node.js).
*   **Widget Testing (Flutter):** Untuk menguji komponen UI secara terisolasi.
*   **Integration Testing:** Menguji interaksi antar komponen (misal: Flutter dengan SQLite, Node.js dengan MySQL untuk autentikasi).
*   **End-to-End Testing:** Mensimulasikan alur pengguna secara lengkap, termasuk sinkronisasi.
*   **Performance Testing:** Menguji performa aplikasi di bawah beban tertentu.
*   **User Acceptance Testing (UAT):** Pengujian oleh pengguna akhir/perwakilan UMKM.

### **9. Asumsi & Ketergantungan**

*   Ketersediaan tim dengan keahlian Flutter, Node.js, MySQL (autentikasi), dan SQLite.
*   Ketersediaan infrastruktur server untuk backend Node.js, layanan sinkronisasi, dan database MySQL (tabel `users`).
*   Akses ke perangkat Android untuk pengujian.

---
