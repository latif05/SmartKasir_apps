// ========================================
// SmartKasir UI/UX - Main JavaScript
// Handles UI interactions and responsive behavior
// ========================================

document.addEventListener('DOMContentLoaded', function() {
    initSidebar();
    initModals();
    initToasts();
    initForms();
});

// ========================================
// Sidebar Navigation
// ========================================
function initSidebar() {
    const menuToggle = document.querySelector('.menu-toggle');
    const sidebar = document.querySelector('.sidebar');
    const overlay = document.querySelector('.overlay');
    
    // Mobile menu toggle
    if (menuToggle) {
        menuToggle.addEventListener('click', function() {
            sidebar.classList.toggle('active');
            
            // Create overlay for mobile
            if (sidebar.classList.contains('active')) {
                createOverlay();
            } else {
                removeOverlay();
            }
        });
    }
    
    // Close sidebar when clicking overlay
    document.addEventListener('click', function(e) {
        if (window.innerWidth <= 768 && sidebar.classList.contains('active')) {
            if (!sidebar.contains(e.target) && !menuToggle.contains(e.target)) {
                sidebar.classList.remove('active');
                removeOverlay();
            }
        }
    });
    
    // Close sidebar on window resize
    window.addEventListener('resize', function() {
        if (window.innerWidth > 768 && sidebar.classList.contains('active')) {
            sidebar.classList.remove('active');
            removeOverlay();
        }
    });
}

function createOverlay() {
    const overlay = document.createElement('div');
    overlay.className = 'overlay';
    overlay.style.cssText = 'position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 999;';
    document.body.appendChild(overlay);
    
    overlay.addEventListener('click', function() {
        const sidebar = document.querySelector('.sidebar');
        sidebar.classList.remove('active');
        removeOverlay();
    });
}

function removeOverlay() {
    const overlay = document.querySelector('.overlay');
    if (overlay) {
        overlay.remove();
    }
}

// ========================================
// Modal Handling
// ========================================
function initModals() {
    // Open modal triggers
    document.querySelectorAll('[data-modal]').forEach(trigger => {
        trigger.addEventListener('click', function(e) {
            e.preventDefault();
            const modalId = this.getAttribute('data-modal');
            openModal(modalId);
        });
    });
    
    // Close modal buttons
    document.querySelectorAll('.modal-close').forEach(btn => {
        btn.addEventListener('click', function() {
            const modal = this.closest('.modal');
            closeModal(modal.id);
        });
    });
    
    // Close modal on outside click
    document.querySelectorAll('.modal').forEach(modal => {
        modal.addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal(this.id);
            }
        });
    });
    
    // Close modal on ESC key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            const openModal = document.querySelector('.modal.active');
            if (openModal) {
                closeModal(openModal.id);
            }
        }
    });
}

function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('active');
        document.body.style.overflow = '';
    }
}

// ========================================
// Toast Notifications
// ========================================
function initToasts() {
    // Create toast container if it doesn't exist
    if (!document.querySelector('.toast-container')) {
        const container = document.createElement('div');
        container.className = 'toast-container';
        document.body.appendChild(container);
    }
}

function showToast(type, title, message) {
    const container = document.querySelector('.toast-container');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    
    toast.innerHTML = `
        <div class="toast-icon">
            <i class="fas fa-${getToastIcon(type)}"></i>
        </div>
        <div class="toast-content">
            <div class="toast-title">${title}</div>
            <div class="toast-message">${message}</div>
        </div>
        <button class="toast-close" onclick="this.parentElement.remove()">
            <i class="fas fa-times"></i>
        </button>
    `;
    
    container.appendChild(toast);
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        toast.remove();
    }, 5000);
}

function getToastIcon(type) {
    const icons = {
        success: 'check-circle',
        error: 'exclamation-circle',
        warning: 'exclamation-triangle',
        info: 'info-circle'
    };
    return icons[type] || 'info-circle';
}

// ========================================
// Form Handling
// ========================================
function initForms() {
    // Format currency input
    document.querySelectorAll('.currency-input').forEach(input => {
        input.addEventListener('input', formatCurrency);
        input.addEventListener('blur', formatCurrencyFinal);
    });
    
    // Number input validation
    document.querySelectorAll('.number-input').forEach(input => {
        input.addEventListener('input', function(e) {
            e.target.value = e.target.value.replace(/[^0-9]/g, '');
        });
    });
    
    // Prevent form submission and show validation
    document.querySelectorAll('form').forEach(form => {
        form.addEventListener('submit', function(e) {
            if (!validateForm(this)) {
                e.preventDefault();
                showToast('error', 'Validasi Error', 'Mohon lengkapi semua field yang wajib diisi!');
            }
        });
    });
}

function validateForm(form) {
    let isValid = true;
    const requiredFields = form.querySelectorAll('[required]');
    
    requiredFields.forEach(field => {
        if (!field.value.trim()) {
            isValid = false;
            field.classList.add('error');
        } else {
            field.classList.remove('error');
        }
    });
    
    return isValid;
}

function formatCurrency(e) {
    let value = e.target.value.replace(/\D/g, '');
    if (value) {
        value = parseInt(value).toLocaleString('id-ID');
        e.target.value = value;
    }
}

function formatCurrencyFinal(e) {
    let value = e.target.value.replace(/\D/g, '');
    if (value) {
        e.target.value = 'Rp ' + parseInt(value).toLocaleString('id-ID');
    }
}

// ========================================
// Table Operations
// ========================================
function deleteRow(button, confirmMessage = 'Apakah Anda yakin?') {
    if (confirm(confirmMessage)) {
        const row = button.closest('tr');
        row.style.transition = 'opacity 0.3s';
        row.style.opacity = '0';
        setTimeout(() => {
            row.remove();
            showToast('success', 'Berhasil', 'Data berhasil dihapus');
        }, 300);
    }
}

function editRow(button, rowId) {
    // This will be implemented based on specific page needs
    console.log('Edit row:', rowId);
}

// ========================================
// Search & Filter
// ========================================
function initSearch(tableSelector, searchSelector) {
    const searchInput = document.querySelector(searchSelector);
    const table = document.querySelector(tableSelector);
    
    if (searchInput && table) {
        searchInput.addEventListener('keyup', function() {
            const searchTerm = this.value.toLowerCase();
            const rows = table.querySelectorAll('tbody tr');
            
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                if (text.includes(searchTerm)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });
    }
}

// ========================================
// Shopping Cart Functions (for Transaction page)
// ========================================
let cart = [];

function addToCart(product) {
    const existingItem = cart.find(item => item.id === product.id);
    
    if (existingItem) {
        existingItem.qty++;
    } else {
        cart.push({
            id: product.id,
            name: product.name,
            price: product.hargaJual,
            qty: 1
        });
    }
    
    updateCartDisplay();
    showToast('success', 'Berhasil', 'Produk ditambahkan ke keranjang');
}

function removeFromCart(id) {
    cart = cart.filter(item => item.id !== id);
    updateCartDisplay();
    showToast('success', 'Berhasil', 'Produk dihapus dari keranjang');
}

function updateCartQuantity(id, qty) {
    const item = cart.find(item => item.id === id);
    if (item) {
        if (qty <= 0) {
            removeFromCart(id);
        } else {
            item.qty = qty;
            updateCartDisplay();
        }
    }
}

function updateCartDisplay() {
    const cartContainer = document.getElementById('cart-items');
    if (!cartContainer) return;
    
    if (cart.length === 0) {
        cartContainer.innerHTML = '<p class="text-center text-gray-500">Keranjang kosong</p>';
        updateCartTotal();
        return;
    }
    
    let html = '';
    cart.forEach(item => {
        const subtotal = item.price * item.qty;
        html += `
            <div class="cart-item">
                <div class="flex-between mb-2">
                    <div>
                        <h4>${item.name}</h4>
                        <p class="text-gray-500">Rp ${item.price.toLocaleString('id-ID')}</p>
                    </div>
                    <button class="btn btn-danger btn-sm" onclick="removeFromCart(${item.id})">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
                <div class="flex-between">
                    <div class="qty-control">
                        <button class="qty-btn" onclick="updateCartQuantity(${item.id}, ${item.qty - 1})">-</button>
                        <input type="number" value="${item.qty}" min="1" 
                               onchange="updateCartQuantity(${item.id}, parseInt(this.value))" 
                               class="qty-input">
                        <button class="qty-btn" onclick="updateCartQuantity(${item.id}, ${item.qty + 1})">+</button>
                    </div>
                    <strong>Rp ${subtotal.toLocaleString('id-ID')}</strong>
                </div>
            </div>
        `;
    });
    
    cartContainer.innerHTML = html;
    updateCartTotal();
}

function updateCartTotal() {
    const total = cart.reduce((sum, item) => sum + (item.price * item.qty), 0);
    const totalElement = document.getElementById('cart-total');
    if (totalElement) {
        totalElement.textContent = 'Rp ' + total.toLocaleString('id-ID');
    }
    
    // Update discount calculation if exists
    const discountInput = document.getElementById('discount');
    if (discountInput) {
        discountInput.addEventListener('input', calculateFinalAmount);
        calculateFinalAmount();
    }
}

function calculateFinalAmount() {
    const subTotal = cart.reduce((sum, item) => sum + (item.price * item.qty), 0);
    const discountInput = document.getElementById('discount');
    const discountType = document.querySelector('input[name="discountType"]:checked')?.value || 'nominal';
    
    let discount = 0;
    if (discountInput && discountInput.value) {
        discount = discountType === 'persen' 
            ? (subTotal * parseFloat(discountInput.value) / 100)
            : parseFloat(discountInput.value);
    }
    
    const finalAmount = subTotal - discount;
    
    document.getElementById('final-amount').textContent = 'Rp ' + finalAmount.toLocaleString('id-ID');
    
    // Update kembalian calculation
    const paymentInput = document.getElementById('payment');
    if (paymentInput) {
        paymentInput.addEventListener('input', calculateChange);
        calculateChange();
    }
}

function calculateChange() {
    const finalAmount = cart.reduce((sum, item) => sum + (item.price * item.qty), 0);
    const discountInput = document.getElementById('discount');
    const discountType = document.querySelector('input[name="discountType"]:checked')?.value || 'nominal';
    
    let discount = 0;
    if (discountInput && discountInput.value) {
        discount = discountType === 'persen' 
            ? (finalAmount * parseFloat(discountInput.value) / 100)
            : parseFloat(discountInput.value);
    }
    
    const subtotal = finalAmount - discount;
    const payment = parseFloat(document.getElementById('payment')?.value || 0);
    const change = payment - subtotal;
    
    const changeElement = document.getElementById('change-amount');
    if (changeElement) {
        changeElement.textContent = 'Rp ' + change.toLocaleString('id-ID');
        changeElement.style.color = change >= 0 ? 'var(--success-color)' : 'var(--danger-color)';
    }
}

// ========================================
// Utility Functions
// ========================================
function formatRupiah(value) {
    return 'Rp ' + parseInt(value).toLocaleString('id-ID');
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('id-ID', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

// ========================================
// API Calls (Mock)
// ========================================
async function fetchData(url) {
    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error('Network response was not ok');
        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error fetching data:', error);
        showToast('error', 'Error', 'Gagal mengambil data');
        return [];
    }
}

// Make functions available globally
window.openModal = openModal;
window.closeModal = closeModal;
window.showToast = showToast;
window.addToCart = addToCart;
window.removeFromCart = removeFromCart;
window.updateCartQuantity = updateCartQuantity;
window.deleteRow = deleteRow;
window.editRow = editRow;
window.formatRupiah = formatRupiah;
window.formatDate = formatDate;

