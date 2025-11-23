import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../categories/presentation/providers/category_providers.dart';

class ProductGridPanel extends ConsumerWidget {
  const ProductGridPanel({
    super.key,
    required this.isLoading,
    required this.products,
    required this.errorMessage,
    required this.onAddToCart,
  });

  final bool isLoading;
  final List<Product> products;
  final String? errorMessage;
  final void Function(Product product) onAddToCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController();
    final categories = ref.watch(categoryListNotifierProvider).categories;
    final categoryFilter = ValueNotifier<String>('all');

    return Container(
      color: const Color(0xFFF6F7FB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterBar(
            searchController: searchController,
            categories: categories,
            categoryFilter: categoryFilter,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : ValueListenableBuilder<String>(
                        valueListenable: categoryFilter,
                        builder: (_, filter, __) {
                          final keyword = searchController.text.toLowerCase();
                          final filtered = products.where((p) {
                            final matchesKeyword = keyword.isEmpty ||
                                p.name.toLowerCase().contains(keyword);
                            final matchesCategory =
                                filter == 'all' || p.categoryId == filter;
                            return matchesKeyword && matchesCategory;
                          }).toList();

                          if (filtered.isEmpty) {
                            return const Center(
                              child: Text('Tidak ada produk sesuai filter.'),
                            );
                          }

                          final isWide = MediaQuery.sizeOf(context).width > 1100;
                          final crossAxisCount = isWide ? 3 : 2;

                          return GridView.builder(
                            padding: const EdgeInsets.only(
                              left: 12,
                              right: 12,
                              bottom: 12,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.8,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (_, index) {
                              final product = filtered[index];
                              return _ProductCard(
                                product: product,
                                onAdd: () => onAddToCart(product),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.searchController,
    required this.categories,
    required this.categoryFilter,
  });

  final TextEditingController searchController;
  final List categories;
  final ValueNotifier<String> categoryFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              onChanged: (_) => categoryFilter.value = categoryFilter.value,
            ),
          ),
          const SizedBox(width: 12),
          DropdownButtonHideUnderline(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButton<String>(
                value: categoryFilter.value,
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('Semua')),
                  ...categories.map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) categoryFilter.value = value;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onAdd});

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isLow = product.stockMin > 0 && product.stock > 0 && product.stock <= product.stockMin;
    final isOut = product.stock == 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOut
              ? const Color(0xFFFFCDD2)
              : isLow
                  ? const Color(0xFFFFF7ED)
                  : const Color(0xFFE5E7EB),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOut
                      ? const Color(0xFFFFE4E6)
                      : isLow
                          ? const Color(0xFFFFF7ED)
                          : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isOut
                      ? 'Habis'
                      : isLow
                          ? 'Menipis'
                          : 'Stok ${product.stock}',
                  style: TextStyle(
                    color: isOut
                        ? const Color(0xFFDC2626)
                        : isLow
                            ? const Color(0xFFF97316)
                            : const Color(0xFF4B5563),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _formatCurrency(product.sellingPrice),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: isOut ? null : onAdd,
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Tambah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A7BFF),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                disabledForegroundColor: const Color(0xFF9CA3AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
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
