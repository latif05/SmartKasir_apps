# SmartKasir UI/UX Mockup

UI/UX mockup untuk aplikasi SmartKasir menggunakan HTML, CSS, dan JavaScript dengan server Node.js/Express.

## 📁 Struktur Project

```
UI-UX/
├── index.html          # Halaman Dashboard
├── login.html          # Halaman Login
├── register.html       # Halaman Registrasi
├── produk.html         # Halaman Manajemen Produk
├── kategori.html       # Halaman Manajemen Kategori
├── transaksi.html      # Halaman Transaksi
├── laporan.html        # Halaman Laporan
├── pengaturan.html     # Halaman Pengaturan
├── style.css           # Stylesheet global
├── app.js              # JavaScript untuk interaktivitas UI
├── server.js           # Node.js server dengan Express
├── package.json        # Dependencies project
└── README.md           # Dokumentasi project
```

## 🚀 Cara Menjalankan

### 1. Install Dependencies

```bash
cd UI-UX
npm install
```

### 2. Jalankan Server

```bash
npm start
```

Atau untuk development mode dengan auto-reload:

```bash
npm run dev
```

### 3. Buka Browser

Akses aplikasi di: `http://localhost:3000`

**Mulai dari halaman Login**: `http://localhost:3000/login.html`

### 4. Login dengan Kredensial Demo

Untuk mengakses aplikasi, gunakan kredensial berikut:

- **Username:** `admin` atau `admin@smartkasir.com`
- **Password:** `password` atau `123456`

## 📱 Halaman yang Tersedia

- **Login** (`/login.html`) - Halaman masuk akun
- **Registrasi** (`/register.html`) - Halaman pendaftaran akun baru
- **Dashboard** (`/index.html`) - Halaman utama dengan statistik dan ringkasan
- **Produk** (`/produk.html`) - Manajemen produk (CRUD)
- **Kategori** (`/kategori.html`) - Manajemen kategori produk
- **Transaksi** (`/transaksi.html`) - Proses transaksi penjualan
- **Laporan** (`/laporan.html`) - Laporan penjualan dan analisis
- **Pengaturan** (`/pengaturan.html`) - Pengaturan aplikasi dan toko

## 🎨 Fitur

### Responsive Design
- **Mobile** (< 768px): Sidebar tersembunyi, hamburger menu
- **Tablet** (768px - 1024px): Sidebar compact dengan ikon
- **Desktop** (> 1024px): Sidebar full dengan teks dan ikon

### Interaktivitas
- Modal untuk form tambah/edit
- Sidebar navigation yang responsive
- Search functionality
- Form validation
- Toast notifications
- Shopping cart untuk transaksi
- Social login buttons (UI only)

### API Mock Data
- `/api/products` - Daftar produk
- `/api/categories` - Daftar kategori
- `/api/transactions` - Riwayat transaksi

## 🛠️ Teknologi yang Digunakan

- **HTML5** - Struktur halaman
- **CSS3** - Styling dengan CSS Variables dan Grid/Flexbox
- **JavaScript (ES6+)** - Interaktivitas UI
- **Font Awesome** - Ikon
- **Node.js** - Runtime environment
- **Express.js** - Web server

## 🎯 Flow Aplikasi

1. User membuka halaman **Login** (`login.html`)
2. Setelah login berhasil, redirect ke **Dashboard** (`index.html`)
3. User dapat navigasi ke berbagai halaman:
   - Dashboard - melihat ringkasan bisnis
   - Produk - mengelola produk
   - Kategori - mengelola kategori
   - Transaksi - membuat transaksi penjualan
   - Laporan - melihat laporan bisnis
   - Pengaturan - mengatur aplikasi dan akun
4. User dapat **Logout** untuk kembali ke halaman login

## 📝 Catatan

Ini adalah mockup UI/UX, bukan aplikasi penuh dengan backend database. Semua data adalah mock data untuk keperluan demonstrasi desain.

## 👤 Pengembang

SmartKasir Project Team

## 📄 License

MIT License

