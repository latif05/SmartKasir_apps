import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smartkasir/src/core/error/app_exception.dart';
import 'package:smartkasir/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:smartkasir/src/features/categories/domain/entities/category.dart';
import 'package:smartkasir/src/features/categories/presentation/providers/category_providers.dart';
import 'package:smartkasir/src/features/products/domain/entities/product.dart';

import '../providers/product_providers.dart';

enum _StockFilter { all, low, out }

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  late final TextEditingController _searchController;
  String _searchKeyword = '';
  String _selectedCategory = 'all';
  _StockFilter _stockFilter = _StockFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..addListener(() {
        setState(() {
          _searchKeyword = _searchController.text.toLowerCase();
        });
      });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setStockFilter(_StockFilter filter) {
    if (_stockFilter == filter) return;
    setState(() => _stockFilter = filter);
  }

  Future<void> _openProductForm(
    List<Category> categories, {
    Product? product,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _ProductFormDialog(categories: categories, initial: product),
    );

    if (result == true && mounted) {
      final message = product == null
          ? 'Produk berhasil ditambahkan'
          : 'Produk berhasil diperbarui';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDeleteDialog(
        title: 'Hapus Produk',
        message:
            'Produk "${product.name}" akan dihapus dari daftar. Tindakan ini tidak dapat dibatalkan.',
        confirmLabel: 'Hapus',
      ),
    );

    if (confirmed != true) return;

    final notifier = ref.read(productListNotifierProvider.notifier);
    try {
      await notifier.deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus')));
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat menghapus produk'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final canManageProducts = (authState.user?.role ?? 'cashier') == 'admin';

    final productState = ref.watch(productListNotifierProvider);
    final categoryState = ref.watch(categoryListNotifierProvider);
    final categories = categoryState.categories;

    final categoryNameMap = {
      for (final category in categories) category.id: category.name,
    };

    final effectiveCategory =
        _selectedCategory != 'all' &&
            !categoryNameMap.containsKey(_selectedCategory)
        ? 'all'
        : _selectedCategory;

    final products = productState.products;
    final lowStockProducts = products.where(_isLowStock).toList();
    final outOfStockProducts = products.where(_isOutOfStock).toList();

    final stockFiltered = products.where((product) {
      switch (_stockFilter) {
        case _StockFilter.low:
          return _isLowStock(product);
        case _StockFilter.out:
          return _isOutOfStock(product);
        case _StockFilter.all:
          return true;
      }
    }).toList();

    final filteredProducts = stockFiltered.where((product) {
      final matchesCategory =
          effectiveCategory == 'all' || product.categoryId == effectiveCategory;
      final matchesSearch =
          _searchKeyword.isEmpty ||
          product.name.toLowerCase().contains(_searchKeyword);
      return matchesCategory && matchesSearch;
    }).toList();

    final tableItems = filteredProducts
        .map(
          (product) => _ProductRowData(
            product: product,
            categoryName:
                categoryNameMap[product.categoryId] ??
                'Kategori tidak diketahui',
            purchasePrice: _formatCurrency(product.purchasePrice),
            sellingPrice: _formatCurrency(product.sellingPrice),
            stockLabel: product.stock.toString(),
            isLowStock: _isLowStock(product),
            isOutOfStock: _isOutOfStock(product),
          ),
        )
        .toList();

    final dropdownItems = categories
        .map(
          (category) =>
              DropdownMenuItem(value: category.id, child: Text(category.name)),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                searchController: _searchController,
                onAdd: () => _openProductForm(categories),
                canManage: canManageProducts,
              ),
              if (!canManageProducts) ...[
                const SizedBox(height: 12),
                const _ViewOnlyBanner(),
              ],
              const SizedBox(height: 20),
              _StockSummary(
                totalProducts: products.length,
                lowStockCount: lowStockProducts.length,
                outOfStockCount: outOfStockProducts.length,
                currentFilter: _stockFilter,
                onFilterSelected: _setStockFilter,
              ),
              const SizedBox(height: 24),
              _ProductTable(
                items: tableItems,
                isLoading: productState.isLoading,
                errorMessage: productState.errorMessage,
                selectedCategory: effectiveCategory,
                onCategoryChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                categoryOptions: dropdownItems,
                onEdit: (product) =>
                    _openProductForm(categories, product: product),
                onDelete: _deleteProduct,
                canManage: canManageProducts,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.searchController,
    required this.onAdd,
    required this.canManage,
  });

  final TextEditingController searchController;
  final VoidCallback onAdd;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 900;

    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Produk',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2430),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Kelola data produk, harga, dan stok dengan mudah.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );

    final searchField = SizedBox(
      width: isCompact ? double.infinity : 320,
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Cari produk...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6A7BFF)),
          ),
        ),
      ),
    );

    final addButton = canManage
        ? FilledButton.icon(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6A7BFF),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Produk'),
          )
        : null;

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          const SizedBox(height: 16),
          searchField,
          if (addButton != null) ...[const SizedBox(height: 12), addButton],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: titleSection),
        const SizedBox(width: 16),
        searchField,
        if (addButton != null) ...[const SizedBox(width: 16), addButton],
      ],
    );
  }
}

class _ViewOnlyBanner extends StatelessWidget {
  const _ViewOnlyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCCFCC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF97316)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Akses kasir hanya dapat melihat daftar produk. Aksi tambah/ubah/hapus hanya tersedia untuk admin.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9A3412)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockSummary extends StatelessWidget {
  const _StockSummary({
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final _StockFilter currentFilter;
  final ValueChanged<_StockFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Stok ($totalProducts produk)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2430),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StockCard(
                title: 'Stok Menipis',
                count: lowStockCount,
                description: lowStockCount > 0
                    ? 'Segera restock agar stok tidak habis'
                    : 'Semua stok aman',
                color: const Color(0xFFFFEDD5),
                accentColor: const Color(0xFFFB923C),
                isActive: currentFilter == _StockFilter.low,
                onTap: () => onFilterSelected(_StockFilter.low),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StockCard(
                title: 'Stok Habis',
                count: outOfStockCount,
                description: outOfStockCount > 0
                    ? 'Ada produk yang sudah habis'
                    : 'Belum ada stok habis',
                color: const Color(0xFFFFE4E6),
                accentColor: const Color(0xFFFB5A74),
                isActive: currentFilter == _StockFilter.out,
                onTap: () => onFilterSelected(_StockFilter.out),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _StockFilterChip(
              label: 'Semua',
              isSelected: currentFilter == _StockFilter.all,
              onSelected: () => onFilterSelected(_StockFilter.all),
            ),
            _StockFilterChip(
              label: 'Stok menipis',
              isSelected: currentFilter == _StockFilter.low,
              onSelected: () => onFilterSelected(_StockFilter.low),
            ),
            _StockFilterChip(
              label: 'Stok habis',
              isSelected: currentFilter == _StockFilter.out,
              onSelected: () => onFilterSelected(_StockFilter.out),
            ),
          ],
        ),
      ],
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({
    required this.title,
    required this.count,
    required this.description,
    required this.color,
    required this.accentColor,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final int count;
  final String description;
  final Color color;
  final Color accentColor;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? accentColor : Colors.transparent,
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w700, color: accentColor),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2430),
            ),
          ),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 12),
          TextButton(onPressed: onTap, child: const Text('Lihat detail')),
        ],
      ),
    );
  }
}

class _StockFilterChip extends StatelessWidget {
  const _StockFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: const Color(0xFFEEF2FF),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF4338CA) : const Color(0xFF4B5563),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ProductTable extends StatelessWidget {
  const _ProductTable({
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.categoryOptions,
    required this.onEdit,
    required this.onDelete,
    required this.canManage,
  });

  final List<_ProductRowData> items;
  final bool isLoading;
  final String? errorMessage;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final List<DropdownMenuItem<String>> categoryOptions;
  final void Function(Product product) onEdit;
  final void Function(Product product) onDelete;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 760;
            final tableWidth = constraints.maxWidth < 800
                ? 800.0
                : constraints.maxWidth;

            final dropdown = SizedBox(
              width: isCompact ? double.infinity : 220,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: 'all',
                        child: Text('Semua Kategori'),
                      ),
                      ...categoryOptions,
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      onCategoryChanged(value);
                    },
                  ),
                ),
              ),
            );

            final headerSection = isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daftar Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      dropdown,
                    ],
                  )
                : Row(
                    children: [
                      const Text(
                        'Daftar Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      dropdown,
                    ],
                  );

            Widget tableBody;
            if (isLoading && items.isEmpty) {
              tableBody = const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (items.isEmpty) {
              tableBody = const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('Belum ada produk.')),
              );
            } else {
              tableBody = Column(
                children: items
                    .map(
                      (item) => _TableRowItem(
                        item: item,
                        onEdit: () => onEdit(item.product),
                        onDelete: () => onDelete(item.product),
                        canManage: canManage,
                      ),
                    )
                    .toList(),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerSection,
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Color(0xFFDC2626)),
                    ),
                  ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TableHeader(canManage: canManage),
                        const Divider(height: 1),
                        tableBody,
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.canManage});

  final bool canManage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text(
              'ID',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          const Expanded(
            flex: 4,
            child: Text(
              'Nama Produk',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              'Kategori',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              'Harga Beli',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              'Harga Jual',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'Stok',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              canManage ? 'Aksi' : 'Aksi (Admin)',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRowItem extends StatelessWidget {
  const _TableRowItem({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.canManage,
  });

  final _ProductRowData item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final stockColor = item.isOutOfStock
        ? const Color(0xFFDC2626)
        : item.isLowStock
        ? const Color(0xFFF97316)
        : const Color(0xFF1F2430);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item.id,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2430),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.categoryName,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.purchasePrice,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.sellingPrice,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2430),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  item.stockLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: stockColor,
                  ),
                ),
                if (item.isOutOfStock)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                  )
                else if (item.isLowStock)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.trending_down,
                      color: Color(0xFFF97316),
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: canManage
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _ActionChip(
                        icon: Icons.edit_outlined,
                        color: const Color(0xFF5B5BD6),
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 10),
                      _ActionChip(
                        icon: Icons.delete_outline,
                        color: const Color(0xFFF87171),
                        onTap: onDelete,
                      ),
                    ],
                  )
                : const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '-',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _ProductRowData {
  const _ProductRowData({
    required this.product,
    required this.categoryName,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stockLabel,
    required this.isLowStock,
    required this.isOutOfStock,
  });

  final Product product;
  final String categoryName;
  final String purchasePrice;
  final String sellingPrice;
  final String stockLabel;
  final bool isLowStock;
  final bool isOutOfStock;

  String get id => product.id;
  String get name => product.name;
}

class _ProductFormDialog extends ConsumerStatefulWidget {
  const _ProductFormDialog({required this.categories, this.initial});

  final List<Category> categories;
  final Product? initial;

  @override
  ConsumerState<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _purchaseController;
  late final TextEditingController _sellingController;
  late final TextEditingController _stockController;
  late final TextEditingController _stockMinController;
  late final TextEditingController _unitController;
  String? _selectedCategoryId;
  bool _isSubmitting = false;
  String? _error;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final hasCategory = widget.categories.isNotEmpty;
    _selectedCategoryId =
        widget.initial?.categoryId ??
        (hasCategory ? widget.categories.first.id : null);
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _purchaseController = TextEditingController(
      text: _doubleToText(widget.initial?.purchasePrice),
    );
    _sellingController = TextEditingController(
      text: _doubleToText(widget.initial?.sellingPrice),
    );
    _stockController = TextEditingController(
      text: _intToText(widget.initial?.stock),
    );
    _stockMinController = TextEditingController(
      text: _intToText(widget.initial?.stockMin),
    );
    _unitController = TextEditingController(text: widget.initial?.unit ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchaseController.dispose();
    _sellingController.dispose();
    _stockController.dispose();
    _stockMinController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      setState(() => _error = 'Kategori wajib dipilih');
      return;
    }

    final navigator = Navigator.of(context);

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final notifier = ref.read(productListNotifierProvider.notifier);
    final purchase = _parseDouble(_purchaseController.text);
    final selling = _parseDouble(_sellingController.text);
    final stock = _parseInt(_stockController.text);
    final stockMin = _parseInt(_stockMinController.text);
    final unit = _trimToNull(_unitController.text);

    try {
      if (_isEdit) {
        await notifier.updateProduct(
          id: widget.initial!.id,
          categoryId: _selectedCategoryId!,
          name: _nameController.text,
          purchasePrice: purchase,
          sellingPrice: selling,
          stock: stock,
          stockMin: stockMin,
          unit: unit,
        );
      } else {
        await notifier.createProduct(
          categoryId: _selectedCategoryId!,
          name: _nameController.text,
          purchasePrice: purchase,
          sellingPrice: selling,
          stock: stock,
          stockMin: stockMin,
          unit: unit,
        );
      }

      if (!mounted) return;
      navigator.pop(true);
    } on AppException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(() => _error = 'Terjadi kesalahan, coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropdownItems = widget.categories
        .map(
          (category) =>
              DropdownMenuItem(value: category.id, child: Text(category.name)),
        )
        .toList();

    if (_selectedCategoryId != null &&
        dropdownItems.every((item) => item.value != _selectedCategoryId)) {
      dropdownItems.add(
        DropdownMenuItem(
          value: _selectedCategoryId,
          child: const Text('Kategori tidak tersedia'),
        ),
      );
    }

    return AlertDialog(
      title: Text(_isEdit ? 'Ubah Produk' : 'Tambah Produk'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama produk wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: dropdownItems,
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (_) {
                  if (_selectedCategoryId == null ||
                      _selectedCategoryId!.isEmpty) {
                    return 'Kategori wajib dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _purchaseController,
                      decoration: const InputDecoration(
                        labelText: 'Harga Beli',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _sellingController,
                      decoration: const InputDecoration(
                        labelText: 'Harga Jual',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stok',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockMinController,
                      decoration: const InputDecoration(
                        labelText: 'Stok Minimal',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Satuan',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_isEdit ? 'Simpan Perubahan' : 'Simpan'),
        ),
      ],
    );
  }

  double _parseDouble(String value) {
    if (value.trim().isEmpty) return 0;
    final normalized = value.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  int _parseInt(String value) {
    if (value.trim().isEmpty) return 0;
    return int.tryParse(value) ?? 0;
  }

  String? _trimToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _doubleToText(double? value) {
    if (value == null) return '';
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  String _intToText(int? value) {
    return value == null ? '' : value.toString();
  }
}

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({
    required this.title,
    required this.message,
    this.confirmLabel = 'Hapus',
  });

  final String title;
  final String message;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF87171),
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

String _formatCurrency(double value) {
  final intValue = value.round();
  final text = intValue.toString();
  final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
  final formatted = text.replaceAllMapped(
    regex,
    (match) => '${match.group(1)}.',
  );
  return 'Rp $formatted';
}

bool _isLowStock(Product product) {
  if (product.stockMin <= 0) {
    return product.stock == 0;
  }
  return product.stock <= product.stockMin && product.stock > 0;
}

bool _isOutOfStock(Product product) => product.stock == 0;
