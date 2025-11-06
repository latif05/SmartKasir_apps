**PRODUCT REQUIREMENTS DOCUMENT (PRD)**
**Nama Produk:** SmartKasir
**Versi:** 1.0 (MVP)
**Tanggal:** 26 Mei 2024
**Penulis:** Abdul Latif, Bima Agung F.

---

### **1. Pendahuluan**

Dokumen ini menjelaskan persyaratan fungsional dan non-fungsional untuk pengembangan aplikasi "Kasir Pintar", sebuah alat bantu digital berbasis mobile yang bertujuan untuk mencatat transaksi penjualan, mengelola stok, dan menghasilkan laporan keuangan sederhana secara otomatis. Aplikasi ini dirancang untuk menjadi solusi yang efisien, mudah digunakan, dan ringan bagi pelaku Usaha Mikro, Kecil, dan Menengah (UMKM) dan bisnis retail kecil.

### **2. Tujuan Proyek**

*   Menyediakan aplikasi kasir digital yang **lebih efisien** dibandingkan sistem manual.
*   Memudahkan pengguna dalam **mencatat transaksi penjualan** secara akurat dan cepat.
*   Mengotomatiskan **pengelolaan stok** untuk menghindari kehabisan atau kelebihan barang.
*   Menghasilkan **laporan penjualan dan laba/rugi sederhana** secara otomatis untuk membantu pengambilan keputusan bisnis.
*   Membangun aplikasi dengan **antarmuka yang sangat simple dan intuitif** untuk pengalaman pengguna yang optimal.
*   Menyediakan solusi yang **ringan dan cepat** dalam operasionalnya.

### **3. Visi Produk**

Menjadi aplikasi kasir pilihan utama bagi UMKM di Indonesia, yang dikenal karena kemudahan penggunaan, efisiensi, dan keandalan dalam membantu pertumbuhan bisnis.

### **4. Target Pengguna**

*   Pemilik Toko Kelontong
*   Pemilik Kedai Kopi / Kafe Kecil
*   Pemilik Warung Makan Sederhana
*   Pemilik Butik Pakaian Kecil
*   UMKM lain yang membutuhkan pencatatan transaksi dan pengelolaan stok dasar.

**Karakteristik Pengguna:**
*   Mungkin kurang familiar dengan teknologi kompleks.
*   Prioritas pada kecepatan dan kemudahan penggunaan.
*   Membutuhkan informasi bisnis yang cepat dan akurat.

### **5. Lingkup (Scope) MVP - Minimum Viable Product**

MVP ini akan fokus pada fitur-fitur inti yang paling esensial untuk memecahkan masalah utama target pengguna, yaitu pencatatan transaksi, manajemen stok dasar, dan pelaporan penjualan sederhana. Fitur-fitur yang lebih canggih akan dipertimbangkan pada fase pengembangan berikutnya.

### **6. Fitur Fungsional**

**6.1. Modul Produk**
*   **PRD-PROD-001: Tambah Produk:** Pengguna dapat menambahkan produk baru dengan detail seperti Nama Produk, Harga Beli, Harga Jual, Stok Awal, Barcode (input manual atau scan), dan Kategori.
*   **PRD-PROD-002: Edit Produk:** Pengguna dapat mengubah detail produk yang sudah ada.
*   **PRD-PROD-003: Hapus Produk:** Pengguna dapat menghapus produk.
*   **PRD-PROD-004: Daftar Produk:** Menampilkan daftar semua produk dengan kemampuan pencarian (berdasarkan nama/barcode) dan filter (berdasarkan kategori).
*   **PRD-PROD-005: Update Stok Otomatis:** Stok produk akan berkurang secara otomatis setiap kali produk tersebut terjual dalam transaksi.
*   **PRD-PROD-006: Notifikasi Stok Minimum:** Aplikasi akan memberikan indikasi visual (misal: warna merah, ikon peringatan) jika stok produk mencapai atau di bawah batas minimum yang ditetapkan (batas minimum belum bisa dikonfigurasi di MVP).

**6.2. Modul Transaksi Penjualan**
*   **PRD-TRANS-001: Buat Transaksi Baru:** Pengguna dapat memulai transaksi penjualan baru.
*   **PRD-TRANS-002: Tambah Item ke Transaksi:** Pengguna dapat menambahkan produk ke keranjang transaksi melalui:
    *   Pencarian produk berdasarkan nama.
    *   Scan barcode produk.
    *   Memilih dari daftar produk yang tersedia.
*   **PRD-TRANS-003: Edit Kuantitas Item:** Pengguna dapat mengubah kuantitas produk dalam keranjang transaksi.
*   **PRD-TRANS-004: Hapus Item dari Transaksi:** Pengguna dapat menghapus produk dari keranjang transaksi.
*   **PRD-TRANS-005: Perhitungan Total Otomatis:** Aplikasi akan secara otomatis menghitung subtotal dan total harga transaksi.
*   **PRD-TRANS-006: Diskon Transaksi:** Pengguna dapat menerapkan diskon (persentase atau nominal) pada total transaksi.
*   **PRD-TRANS-007: Proses Pembayaran:** Pengguna dapat memilih metode pembayaran (Tunai, Non-Tunai) dan memasukkan jumlah uang yang diterima (untuk tunai).
*   **PRD-TRANS-008: Perhitungan Kembalian:** Aplikasi akan menghitung dan menampilkan jumlah kembalian secara otomatis untuk pembayaran tunai.
*   **PRD-TRANS-009: Selesaikan Transaksi:** Menyimpan transaksi ke database dan mengurangi stok produk yang terjual.
*   **PRD-TRANS-010: Struk Digital:** Menampilkan ringkasan transaksi (struk digital) setelah pembayaran berhasil.
*   **PRD-TRANS-011: Riwayat Transaksi:** Menampilkan daftar transaksi yang sudah selesai dengan filter tanggal.
*   **PRD-TRANS-012: Detail Transaksi:** Menampilkan detail lengkap dari transaksi yang dipilih dari riwayat.

**6.3. Modul Laporan**
*   **PRD-LAP-001: Laporan Penjualan Harian:** Menampilkan total omzet penjualan untuk hari ini.
*   **PRD-LAP-002: Laporan Penjualan Periodik:** Menampilkan total omzet penjualan untuk periode yang dipilih (mingguan/bulanan).
*   **PRD-LAP-003: Laporan Produk Terlaris:** Menampilkan daftar produk dengan volume penjualan tertinggi dalam periode tertentu.
*   **PRD-LAP-004: Laporan Stok:** Menampilkan ringkasan stok produk saat ini (jumlah total, produk dengan stok di bawah minimum).

**6.4. Modul Pengaturan (Settings)**
*   **PRD-SET-001: Pengaturan Informasi Toko:** Pengguna dapat mengisi/mengedit nama toko dan alamat yang akan muncul di struk.
*   **PRD-SET-002: Manajemen Kategori Produk:** Pengguna dapat menambah, mengedit, dan menghapus kategori produk.

**6.5. Modul Kategori (Category)**
*   **PRD-CAT-002: Manajemen Kategori Produk:** Pengguna dapat menambah, mengedit, dan menghapus kategori produk.

### **7. Fitur Non-Fungsional**

*   **NFR-PERF-001 (Performa):** Waktu loading layar utama/dashboard dan layar transaksi tidak lebih dari 3 detik. Proses penyelesaian transaksi tidak lebih dari 2 detik.
*   **NFR-USAB-001 (Usability):** Antarmuka pengguna harus intuitif, mudah dipelajari, dan minim langkah untuk menyelesaikan tugas-tugas utama (misal: 3-5 klik untuk menyelesaikan transaksi).
*   **NFR-USAB-002 (Responsif):** Aplikasi harus responsif dan berfungsi baik di berbagai ukuran layar perangkat Android.
*   **NFR-SCAL-001 (Skalabilitas):** Arsitektur backend harus mendukung penambahan fitur di masa depan dan peningkatan jumlah transaksi/pengguna.
*   **NFR-SEC-001 (Keamanan):** Data transaksi dan produk harus dilindungi dari akses tidak sah. (Autentikasi sederhana untuk MVP, misal: PIN/password admin tunggal).
*   **NFR-AVAIL-001 (Ketersediaan):** Aplikasi lokal (Flutter + SQLite) harus dapat berfungsi penuh tanpa koneksi internet.
*   **NFR-AVAIL-002 (Sinkronisasi Data):** Data lokal (SQLite) tetap menjadi sumber kebenaran, namun aplikasi harus menyediakan mekanisme sinkronisasi manual ke backend (Node.js + MySQL untuk autentikasi) saat koneksi tersedia, misalnya untuk backup atau rekonsiliasi data antar perangkat.
*   **NFR-MAINT-001 (Maintainability):** Kode harus ditulis menggunakan prinsip Clean Architecture (Flutter & Node.js) agar mudah dipelihara dan dikembangkan oleh tim.
*   **NFR-TEST-001 (Testability):** Setiap komponen kunci harus dapat diuji secara terpisah (unit testing, widget testing untuk Flutter).

### **8. Lingkungan Teknis**

*   **Frontend:** Flutter (Dart)
*   **Backend (API & Server):** Node.js dengan Express.js
*   **Database Remote:** MySQL
*   **Database Lokal (Offline):** SQLite
*   **Arsitektur:** Clean Architecture (Domain, Data, Presentation Layers)
*   **Version Control:** Git

### **9. Alur Pengguna (User Flow - Contoh)**

**Contoh: Alur Penjualan Produk**

1.  Pengguna membuka aplikasi dan masuk ke layar "Transaksi".
2.  Pengguna mencari produk (nama) atau memilih dari daftar.
3.  Produk ditambahkan ke keranjang, menampilkan detail (nama, harga, kuantitas).
4.  Pengguna dapat mengubah kuantitas atau menghapus item.
5.  Jika ada, pengguna memasukkan diskon.
6.  Aplikasi menampilkan total yang harus dibayar.
7.  Pengguna memilih metode pembayaran (Tunai/Non-Tunai).
8.  Jika Tunai, pengguna memasukkan jumlah uang yang diterima.
9.  Aplikasi menampilkan kembalian.
10. Pengguna menekan tombol "Selesaikan Transaksi".
11. Transaksi disimpan, stok berkurang, dan struk digital ditampilkan.

*(Akan lebih baik jika dilengkapi dengan wireframe sederhana untuk setiap alur utama.)*

### **10. Desain & UI/UX (Panduan Awal)**

*   **Estetika:** Bersih, minimalis, modern.
*   **Palet Warna:** Fokus pada warna-warna netral dengan aksen warna cerah untuk call-to-action.
*   **Tipografi:** Font yang mudah dibaca.
*   **Ikona:** Jelas, intuitif, dan konsisten.
*   **Navigasi:** Menggunakan bottom navigation bar untuk modul utama (Transaksi, Stok, Laporan, Pengaturan).
*   **Feedback:** Memberikan umpan balik visual (loading spinner, notifikasi sukses/gagal) pada setiap aksi pengguna.
*   **Fokus pada Kecepatan:** Minim animasi yang berlebihan, transisi cepat antar layar.

*(Direkomendasikan untuk membuat wireframe dan mockup setelah PRD ini disetujui.)*

### **11. Metrik Keberhasilan (Key Performance Indicators - KPI)**

*   **Adopsi:** Jumlah pengguna aktif bulanan (MAU).
*   **Retensi:** Persentase pengguna yang kembali menggunakan aplikasi setelah 30 hari.
*   **Efisiensi Transaksi:** Rata-rata waktu yang dibutuhkan untuk menyelesaikan satu transaksi.
*   **Feedback Pengguna:** Skor kepuasan pengguna (misal: dari survei atau rating aplikasi).
*   **Keandalan Sinkronisasi:** Persentase sinkronisasi data yang berhasil antara lokal dan server.

### **12. Asumsi & Keterbatasan**

*   Pengguna memiliki perangkat Android yang kompatibel.
*   Koneksi internet stabil diperlukan untuk sinkronisasi data ke server backend.
*   MVP tidak akan menyertakan manajemen multi-user atau multi-cabang.
*   Integrasi printer thermal eksternal akan dipertimbangkan pada fase selanjutnya jika ada kebutuhan kuat.

### **13. Tahapan Pengembangan Selanjutnya (Roadmap - Tentatif)**

*   Integrasi printer thermal.
*   Manajemen hak akses pengguna (misal: Admin, Kasir).
*   Laporan yang lebih canggih (laba/rugi detail, laporan penjualan per karyawan).
*   Manajemen pembelian/supplier.
*   Integrasi e-wallet/pembayaran digital.
*   Manajemen pelanggan.
