const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files from current directory
app.use(express.static(__dirname));

// Mock data API routes
app.get('/api/products', (req, res) => {
    res.json(mockProducts);
});

app.get('/api/categories', (req, res) => {
    res.json(mockCategories);
});

app.get('/api/transactions', (req, res) => {
    res.json(mockTransactions);
});

// Mock data
const mockCategories = [
    { id: 1, name: 'Makanan & Minuman', description: 'Kategori makanan dan minuman' },
    { id: 2, name: 'Elektronik', description: 'Barang elektronik' },
    { id: 3, name: 'Pakaian', description: 'Pakaian dan aksesoris' },
    { id: 4, name: 'Sembako', description: 'Sembilan bahan pokok' }
];

const mockProducts = [
    { id: 1, name: 'Ayam Goreng', category: 'Makanan & Minuman', hargaBeli: 8000, hargaJual: 12000, stok: 50 },
    { id: 2, name: 'Nasi Goreng', category: 'Makanan & Minuman', hargaBeli: 5000, hargaJual: 8000, stok: 30 },
    { id: 3, name: 'Mie Goreng', category: 'Makanan & Minuman', hargaBeli: 4000, hargaJual: 7000, stok: 25 },
    { id: 4, name: 'Kopi Hitam', category: 'Makanan & Minuman', hargaBeli: 3000, hargaJual: 5000, stok: 100 },
    { id: 5, name: 'Teh Manis', category: 'Makanan & Minuman', hargaBeli: 2000, hargaJual: 4000, stok: 80 },
    { id: 6, name: 'Beras Premium', category: 'Sembako', hargaBeli: 12000, hargaJual: 15000, stok: 200 }
];

const mockTransactions = [
    { id: 1, tanggal: '2025-11-02', total: 32000, diskon: 2000, finalAmount: 30000, items: 3 },
    { id: 2, tanggal: '2025-11-02', total: 18000, diskon: 0, finalAmount: 18000, items: 2 },
    { id: 3, tanggal: '2025-11-01', total: 45000, diskon: 5000, finalAmount: 40000, items: 4 }
];

// Start server
app.listen(PORT, () => {
    console.log(`🚀 SmartKasir UI/UX server running on http://localhost:${PORT}`);
    console.log(`📱 Open http://localhost:${PORT}/index.html to view the application`);
});
