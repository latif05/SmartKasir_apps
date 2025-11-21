import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smartkasir/src/core/error/app_exception.dart';
import 'package:smartkasir/src/features/categories/domain/entities/category.dart';
import 'package:smartkasir/src/features/categories/presentation/providers/category_providers.dart';
import 'package:smartkasir/src/features/products/presentation/providers/product_providers.dart';

enum _CategoryStatusFilter { aktif, semua, terhapus }

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  late final TextEditingController _searchController;
  _CategoryStatusFilter _statusFilter = _CategoryStatusFilter.aktif;
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..addListener(() {
        setState(() => _searchKeyword = _searchController.text.toLowerCase());
      });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({Category? category}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CategoryFormDialog(initial: category),
    );

    if (result == true && mounted) {
      final message = category == null
          ? 'Kategori berhasil ditambahkan'
          : 'Kategori berhasil diperbarui';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _handleDelete(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDeleteDialog(
        title: 'Hapus Kategori',
        message:
            'Kategori "${category.name}" akan dihapus dari daftar. Tindakan ini tidak dapat dibatalkan.',
        confirmLabel: 'Hapus',
      ),
    );

    if (confirmed != true) return;

    final notifier = ref.read(categoryListNotifierProvider.notifier);
    try {
      await notifier.deleteCategory(category.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori berhasil dihapus')),
      );
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat menghapus kategori'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changeStatusFilter(_CategoryStatusFilter value) async {
    if (_statusFilter == value) return;
    setState(() => _statusFilter = value);

    final includeDeleted = value != _CategoryStatusFilter.aktif;
    final notifier = ref.read(categoryListNotifierProvider.notifier);
    final state = ref.read(categoryListNotifierProvider);
    if (state.includeDeleted != includeDeleted) {
      await notifier.loadCategories(includeDeleted: includeDeleted);
    }
  }

  List<Category> _filterCategories(List<Category> categories) {
    return categories.where((category) {
      final matchesSearch =
          _searchKeyword.isEmpty ||
          category.name.toLowerCase().contains(_searchKeyword) ||
          (category.description ?? '').toLowerCase().contains(_searchKeyword);

      final matchesStatus = switch (_statusFilter) {
        _CategoryStatusFilter.aktif => !category.isDeleted,
        _CategoryStatusFilter.semua => true,
        _CategoryStatusFilter.terhapus => category.isDeleted,
      };

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryListNotifierProvider);
    final productState = ref.watch(productListNotifierProvider);

    final categories = _filterCategories(categoryState.categories);
    final Map<String, int> productCountByCategory = {};
    for (final product in productState.products) {
      productCountByCategory.update(
        product.categoryId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

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
                onAdd: () => _openForm(),
              ),
              const SizedBox(height: 20),
              if (categoryState.errorMessage != null)
                _ErrorBanner(message: categoryState.errorMessage!),
              if (categories.isNotEmpty)
                _CategoryGrid(
                  items: categories,
                  productCounts: productCountByCategory,
                  onEdit: (item) => _openForm(category: item),
                  onDelete: _handleDelete,
                )
              else if (!categoryState.isLoading)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Belum ada kategori sesuai pencarian/filter.'),
                  ),
                ),
              const SizedBox(height: 24),
              _CategoryTable(
                items: categories,
                productCounts: productCountByCategory,
                isLoading: categoryState.isLoading,
                onEdit: (item) => _openForm(category: item),
                onDelete: _handleDelete,
                statusFilter: _statusFilter,
                onStatusChanged: _changeStatusFilter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.searchController, required this.onAdd});

  final TextEditingController searchController;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 900;

    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2430),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Kelola kategori produk untuk memudahkan pencarian dan laporan.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );

    final searchField = SizedBox(
      width: isCompact ? double.infinity : 280,
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Cari kategori...',
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

    final addButton = FilledButton.icon(
      onPressed: onAdd,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF6A7BFF),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.add),
      label: const Text('Tambah Kategori'),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          const SizedBox(height: 16),
          searchField,
          const SizedBox(height: 12),
          addButton,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleSection),
        const SizedBox(width: 16),
        searchField,
        const SizedBox(width: 16),
        addButton,
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.items,
    required this.productCounts,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Category> items;
  final Map<String, int> productCounts;
  final void Function(Category category) onEdit;
  final void Function(Category category) onDelete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxis = constraints.maxWidth ~/ 280;
        final count = crossAxis.clamp(1, 3);
        final spacing = 16.0;
        final itemWidth = count == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing * (count - 1)) / count;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final category in items)
              SizedBox(
                width: itemWidth,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            if (category.isDeleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1F2),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Terhapus',
                                  style: TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.description ?? 'Belum ada deskripsi',
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${productCounts[category.id] ?? 0} produk',
                          style: const TextStyle(
                            color: Color(0xFF1F2430),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _ActionChip(
                              icon: Icons.edit_outlined,
                              color: const Color(0xFF5B5BD6),
                              onTap: () => onEdit(category),
                            ),
                            const SizedBox(width: 10),
                            _ActionChip(
                              icon: Icons.delete_outline,
                              color: const Color(0xFFF87171),
                              onTap: () => onDelete(category),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryTable extends StatelessWidget {
  const _CategoryTable({
    required this.items,
    required this.productCounts,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
    required this.statusFilter,
    required this.onStatusChanged,
  });

  final List<Category> items;
  final Map<String, int> productCounts;
  final bool isLoading;
  final void Function(Category category) onEdit;
  final void Function(Category category) onDelete;
  final _CategoryStatusFilter statusFilter;
  final ValueChanged<_CategoryStatusFilter> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 720;
            final tableWidth = constraints.maxWidth < 760
                ? 760.0
                : constraints.maxWidth;

            final filterDropdown = SizedBox(
              width: isCompact ? double.infinity : 200,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<_CategoryStatusFilter>(
                    value: statusFilter,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: _CategoryStatusFilter.aktif,
                        child: Text('Aktif'),
                      ),
                      DropdownMenuItem(
                        value: _CategoryStatusFilter.semua,
                        child: Text('Semua'),
                      ),
                      DropdownMenuItem(
                        value: _CategoryStatusFilter.terhapus,
                        child: Text('Terhapus'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onStatusChanged(value);
                      }
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
                        'Daftar Kategori',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      filterDropdown,
                    ],
                  )
                : Row(
                    children: [
                      const Text(
                        'Daftar Kategori',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      filterDropdown,
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
                child: Center(child: Text('Belum ada kategori.')),
              );
            } else {
              tableBody = Column(
                children: items
                    .map(
                      (category) => _TableRowItem(
                        category: category,
                        productCount: productCounts[category.id] ?? 0,
                        onEdit: () => onEdit(category),
                        onDelete: () => onDelete(category),
                      ),
                    )
                    .toList(),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerSection,
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _TableHeader(),
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
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'ID',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Nama Kategori',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Deskripsi',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Jumlah Produk',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              'Aksi',
              style: TextStyle(
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
    required this.category,
    required this.productCount,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final int productCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
              category.id,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2430),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              category.description ?? '-',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$productCount produk',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: category.isDeleted
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF1F2430),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFDC2626)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFDC2626)),
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

class _CategoryFormDialog extends ConsumerStatefulWidget {
  const _CategoryFormDialog({this.initial});

  final Category? initial;

  @override
  ConsumerState<_CategoryFormDialog> createState() =>
      _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isSubmitting = false;
  String? _error;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.initial?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final notifier = ref.read(categoryListNotifierProvider.notifier);
    try {
      if (_isEdit) {
        await notifier.updateCategory(
          id: widget.initial!.id,
          name: _nameController.text,
          description: _descriptionController.text,
        );
      } else {
        await notifier.createCategory(
          name: _nameController.text,
          description: _descriptionController.text,
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
    return AlertDialog(
      title: Text(_isEdit ? 'Ubah Kategori' : 'Tambah Kategori'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama kategori wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
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
