import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smartkasir/src/features/categories/presentation/providers/category_providers.dart';
import 'package:smartkasir/src/features/products/domain/entities/product.dart';
import 'package:smartkasir/src/features/products/presentation/providers/product_providers.dart';
import 'package:smartkasir/src/features/transactions/domain/entities/transaction_record.dart';
import 'package:smartkasir/src/features/transactions/presentation/providers/transaction_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productListNotifierProvider);
    final categoryState = ref.watch(categoryListNotifierProvider);
    final transactionsFuture =
        ref.watch(getTransactionsProvider).call(limit: 50);

    final products = productState.products;
    final activeCategories = categoryState.categories
        .where((category) => !category.isDeleted)
        .toList();
    final lowStockProducts = products.where(_isLowStock).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));
    final outOfStockCount = products
        .where((product) => product.stock == 0)
        .length;

    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: FutureBuilder<List<TransactionRecord>>(
          future: transactionsFuture,
          builder: (context, snapshot) {
            final isLoading = productState.isLoading ||
                categoryState.isLoading ||
                snapshot.connectionState == ConnectionState.waiting;

            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (productState.errorMessage != null ||
                categoryState.errorMessage != null ||
                snapshot.hasError) {
              return Center(
                child: Text(
                  productState.errorMessage ??
                      categoryState.errorMessage ??
                      'Gagal memuat data dashboard',
                ),
              );
            }

            final transactions = (snapshot.data ?? [])
              ..sort((a, b) => b.date.compareTo(a.date));
            final today = DateTime.now();
            final todayCount =
                transactions.where((trx) => _isSameDay(trx.date, today)).length;
            final totalSales = transactions.fold<double>(
              0,
              (sum, trx) => sum + trx.finalAmount,
            );

            final stats = _DashboardStats(
              totalProducts: products.length,
              totalCategories: activeCategories.length,
              lowStockCount: lowStockProducts.length,
              outOfStockCount: outOfStockCount,
              lowStockProducts: lowStockProducts.take(6).toList(),
              totalSales: totalSales,
              todayTransactions: todayCount,
              latestTransactions: transactions.take(5).toList(),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(theme: theme),
                  const SizedBox(height: 24),
                  _KpiSection(isWide: isWide, stats: stats),
                  const SizedBox(height: 24),
                  _BottomSection(
                    isWide: isWide,
                    lowStockProducts: stats.lowStockProducts,
                    latestTransactions: stats.latestTransactions,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardStats {
  const _DashboardStats({
    required this.totalProducts,
    required this.totalCategories,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.lowStockProducts,
    required this.totalSales,
    required this.todayTransactions,
    required this.latestTransactions,
  });

  final int totalProducts;
  final int totalCategories;
  final int lowStockCount;
  final int outOfStockCount;
  final List<Product> lowStockProducts;
  final double totalSales;
  final int todayTransactions;
  final List<TransactionRecord> latestTransactions;
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 700;

    final searchField = SizedBox(
      width: isCompact ? double.infinity : 340,
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Cari...',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2430),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          searchField,
        ],
      );
    }

    return Row(
      children: [
        Text(
          'Dashboard',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2430),
          ),
        ),
        const Spacer(),
        Flexible(flex: 0, child: searchField),
      ],
    );
  }
}

class _KpiSection extends StatelessWidget {
  const _KpiSection({required this.isWide, required this.stats});

  final bool isWide;
  final _DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiCard(
        title: 'Total Penjualan',
        value: _formatCurrency(stats.totalSales),
        changeLabel: stats.totalSales > 0
            ? 'Data penjualan tersimpan'
            : 'Belum ada transaksi',
        changeColor:
            stats.totalSales > 0 ? const Color(0xFF10B981) : const Color(0xFF6B7280),
        changeIcon: stats.totalSales > 0 ? Icons.arrow_upward : Icons.info_outline,
      ),
      _KpiCard(
        title: 'Transaksi Hari Ini',
        value: '${stats.todayTransactions}',
        changeLabel: stats.todayTransactions > 0
            ? '${stats.todayTransactions} transaksi'
            : 'Belum ada transaksi',
        changeColor: stats.todayTransactions > 0
            ? const Color(0xFF10B981)
            : const Color(0xFF6B7280),
        changeIcon:
            stats.todayTransactions > 0 ? Icons.arrow_upward : Icons.info_outline,
      ),
      _KpiCard(
        title: 'Total Produk',
        value: '${stats.totalProducts}',
        changeLabel: 'Tercatat di database',
        changeColor: const Color(0xFF6B7280),
        changeIcon: Icons.inventory_2,
      ),
      _KpiCard(
        title: 'Stok Perlu Aksi',
        value: '${stats.lowStockCount + stats.outOfStockCount}',
        changeLabel: stats.lowStockCount + stats.outOfStockCount > 0
            ? '${stats.lowStockCount} menipis / ${stats.outOfStockCount} habis'
            : 'Semua stok aman',
        changeColor: (stats.lowStockCount + stats.outOfStockCount) > 0
            ? Colors.red
            : const Color(0xFF10B981),
        changeIcon: (stats.lowStockCount + stats.outOfStockCount) > 0
            ? Icons.warning
            : Icons.check_circle,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactWidth = constraints.maxWidth < 600;
        final targetItemWidth = isCompactWidth ? constraints.maxWidth : 260;
        final crossAxisCount = (constraints.maxWidth / targetItemWidth)
            .floor()
            .clamp(1, 4);
        final aspectRatio = isWide
            ? 3.4
            : isCompactWidth
            ? 1.8
            : 2.4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: aspectRatio,
          ),
          itemCount: cards.length,
          itemBuilder: (_, i) => cards[i],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.changeLabel,
    required this.changeColor,
    required this.changeIcon,
  });

  final String title;
  final String value;
  final String changeLabel;
  final Color changeColor;
  final IconData changeIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2430),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(changeIcon, size: 16, color: changeColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  changeLabel,
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.isWide,
    required this.lowStockProducts,
    required this.latestTransactions,
  });

  final bool isWide;
  final List<Product> lowStockProducts;
  final List<TransactionRecord> latestTransactions;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _LatestTransactionsCard(transactions: latestTransactions),
          ),
          const SizedBox(width: 20),
          Expanded(child: _LowStockCard(products: lowStockProducts)),
        ],
      );
    }

    return Column(
      children: [
        _LatestTransactionsCard(transactions: latestTransactions),
        const SizedBox(height: 20),
        _LowStockCard(products: lowStockProducts),
      ],
    );
  }
}

class _LatestTransactionsCard extends StatelessWidget {
  const _LatestTransactionsCard({required this.transactions});

  final List<TransactionRecord> transactions;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Transaksi Terbaru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Belum ada transaksi.'),
              )
            else
              ...transactions.map((trx) => _TransactionRow(trx: trx)),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.trx});

  final TransactionRecord trx;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(trx.code ?? trx.id.substring(0, 8).toUpperCase())),
          Expanded(child: Text(_formatShortDate(trx.date))),
          Expanded(child: Text(_formatCurrency(trx.finalAmount))),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(label: trx.status),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF10B981),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  const _LowStockCard({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Perlu Restock',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                if (products.isNotEmpty)
                  Text(
                    '${products.length} produk',
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  )
                else
                  const Text(
                    'Semua stok aman',
                    style: TextStyle(color: Color(0xFF10B981)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: const Text(
                  'Tidak ada produk dengan stok menipis atau habis.',
                ),
              )
            else
                ...products.map(
                  (product) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stok ${product.stock} | Minimum ${product.stockMin}',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: product.stock == 0
                              ? const Color(0xFFFFE4E6)
                              : const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          product.stock == 0 ? 'Stok habis' : 'Restock',
                          style: TextStyle(
                            color: product.stock == 0
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFF97316),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
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

String _formatShortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final day = date.day.toString().padLeft(2, '0');
  final month = months[date.month - 1];
  final year = date.year.toString();
  return '$day $month $year';
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool _isLowStock(Product product) {
  if (product.stockMin <= 0) {
    return product.stock == 0;
  }
  return product.stock <= product.stockMin && product.stock > 0;
}
