import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../activation/presentation/providers/activation_providers.dart';
import '../../../billing/presentation/providers/billing_providers.dart';
import '../../domain/entities/sales_summary.dart';
import '../../domain/entities/top_product.dart';
import '../../domain/entities/stock_alert.dart';
import '../providers/report_providers.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  DateTimeRange? _customRange;
  Future<SalesSummary>? _customSummaryFuture;
  Future<List<TopProduct>>? _customTopFuture;

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange:
          _customRange ?? DateTimeRange(start: startOfMonth, end: now),
    );
    if (picked == null) return;
    setState(() {
      _customRange = picked;
      _customSummaryFuture = ref
          .read(getPeriodicReportProvider)
          .call(start: picked.start, end: picked.end);
      _customTopFuture = ref
          .read(getTopProductsReportProvider)
          .call(start: picked.start, end: picked.end, limit: 5);
    });
  }

  void _clearRange() {
    setState(() {
      _customRange = null;
      _customSummaryFuture = null;
      _customTopFuture = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activationState = ref.watch(activationNotifierProvider);
    final isPremium = activationState.isPremium;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Laporan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isPremium) ...[_PremiumGate(ref: ref)],
            if (isPremium) ...[
              const SizedBox(height: 16),
              _SummarySection(ref: ref),
              const SizedBox(height: 16),
              _StockSummarySection(ref: ref),
              const SizedBox(height: 16),
              _CustomRangeSection(
                range: _customRange,
                onPickRange: _pickRange,
                onClear: _clearRange,
                summaryFuture: _customSummaryFuture,
                topProductsFuture: _customTopFuture,
              ),
              const SizedBox(height: 16),
              _TopProductsSection(ref: ref),
              const SizedBox(height: 16),
              _LowStockSection(ref: ref),
            ],
          ],
        ),
      ),
    );
  }
}

class _PremiumGate extends ConsumerWidget {
  const _PremiumGate({this.ref});

  final WidgetRef? ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final effectiveRef = ref ?? widgetRef;
    final billingState = effectiveRef.watch(billingNotifierProvider);
    final billingNotifier = effectiveRef.read(billingNotifierProvider.notifier);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.lock_outline, color: Color(0xFF7F4FD7)),
                SizedBox(width: 8),
                Text(
                  'Premium diperlukan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Premium cukup sekali bayar Rp30.000 untuk akses laporan lengkap seumur hidup.',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _Chip(text: 'Ringkasan penjualan'),
                _Chip(text: 'Top produk'),
                _Chip(text: 'Stok minimum'),
                _Chip(text: 'Manajemen pengguna'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A7BFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: billingState.purchasePending
                      ? null
                      : () => billingNotifier.buyPremium(),
                  icon: billingState.purchasePending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.flash_on_outlined, size: 18),
                  label: Text(
                    billingState.purchasePending
                        ? 'Memproses...'
                        : 'Beli Premium',
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: billingState.purchasePending
                      ? null
                      : () => billingNotifier.restore(),
                  child: const Text('Pulihkan Pembelian'),
                ),
              ],
            ),
            if (billingState.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                billingState.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4F46E5),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final daily = ref.watch(dailyReportFutureProvider);
    final weekly = ref.watch(weeklyReportFutureProvider);
    final monthly = ref.watch(monthlyReportFutureProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Penjualan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(title: 'Hari ini', snapshot: daily),
            _SummaryCard(title: '7 hari', snapshot: weekly),
            _SummaryCard(title: '30 hari', snapshot: monthly),
          ],
        ),
      ],
    );
  }
}

class _StockSummarySection extends StatelessWidget {
  const _StockSummarySection({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final stockSummary = ref.watch(stockSummaryReportFutureProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Stok',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: stockSummary.when(
              data: (data) {
                return Column(
                  children: [
                    _StatRow(
                      label: 'Total Produk',
                      value: '${data.totalProducts}',
                    ),
                    _StatRow(
                      label: 'Total Unit Stok',
                      value: '${data.totalStockUnits}',
                    ),
                    _StatRow(
                      label: 'Stok Menipis/Habis',
                      value: '${data.lowStockCount}',
                    ),
                    _StatRow(
                      label: 'Stok Habis',
                      value: '${data.outOfStockCount}',
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (error, _) => _ErrorText(message: error.toString()),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.snapshot});

  final String title;
  final AsyncValue<SalesSummary> snapshot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: snapshot.when(
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                _StatRow(
                  label: 'Transaksi',
                  value: '${data.totalTransactions}',
                ),
                _StatRow(label: 'Item terjual', value: '${data.totalItems}'),
                _StatRow(
                  label: 'Bruto',
                  value: _formatCurrency(data.grossSales),
                ),
                _StatRow(
                  label: 'Diskon',
                  value: _formatCurrency(data.discountTotal),
                ),
                _StatRow(label: 'Netto', value: _formatCurrency(data.netSales)),
              ],
            ),
            loading: () => const SizedBox(
              height: 90,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (error, _) => _ErrorText(message: error.toString()),
          ),
        ),
      ),
    );
  }
}

class _TopProductsSection extends StatelessWidget {
  const _TopProductsSection({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final topProducts = ref.watch(topProductsReportFutureProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Produk (30 hari)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: topProducts.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Text('Belum ada data transaksi.');
                }
                return Column(
                  children: [
                    for (final product in items)
                      _TopProductTile(product: product),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (error, _) => _ErrorText(message: error.toString()),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomRangeSection extends StatelessWidget {
  const _CustomRangeSection({
    required this.range,
    required this.onPickRange,
    required this.onClear,
    required this.summaryFuture,
    required this.topProductsFuture,
  });

  final DateTimeRange? range;
  final VoidCallback onPickRange;
  final VoidCallback onClear;
  final Future<SalesSummary>? summaryFuture;
  final Future<List<TopProduct>>? topProductsFuture;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Laporan Kustom',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            TextButton(
              onPressed: onPickRange,
              child: const Text('Pilih rentang tanggal'),
            ),
            if (range != null)
              TextButton(onPressed: onClear, child: const Text('Reset')),
          ],
        ),
        if (range == null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Pilih rentang tanggal untuk melihat ringkasan dan top produk.',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          )
        else ...[
          const SizedBox(height: 8),
          Text(
            '${_formatDate(range!.start)} - ${_formatDate(range!.end)}',
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          if (summaryFuture != null)
            FutureBuilder<SalesSummary>(
              future: summaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _ErrorText(message: snapshot.error.toString());
                }
                final data = snapshot.data;
                if (data == null) {
                  return const _ErrorText(message: 'Tidak ada data.');
                }
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatRow(
                          label: 'Transaksi',
                          value: '${data.totalTransactions}',
                        ),
                        _StatRow(
                          label: 'Item terjual',
                          value: '${data.totalItems}',
                        ),
                        _StatRow(
                          label: 'Bruto',
                          value: _formatCurrency(data.grossSales),
                        ),
                        _StatRow(
                          label: 'Diskon',
                          value: _formatCurrency(data.discountTotal),
                        ),
                        _StatRow(
                          label: 'Netto',
                          value: _formatCurrency(data.netSales),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
          if (topProductsFuture != null)
            FutureBuilder<List<TopProduct>>(
              future: topProductsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _ErrorText(message: snapshot.error.toString());
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Text('Belum ada transaksi pada rentang ini.');
                }
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top Produk (rentang dipilih)',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        for (final product in items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product.quantitySold} terjual',
                                        style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatCurrency(product.revenue),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ],
    );
  }
}

class _TopProductTile extends StatelessWidget {
  const _TopProductTile({required this.product});

  final TopProduct product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.quantitySold} terjual',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(product.revenue),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _LowStockSection extends StatelessWidget {
  const _LowStockSection({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final lowStock = ref.watch(lowStockReportFutureProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stok Minimum',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: lowStock.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Text('Tidak ada produk dengan stok minimum.');
                }
                return Column(
                  children: [
                    for (final alert in items) _LowStockTile(alert: alert),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (error, _) => _ErrorText(message: error.toString()),
            ),
          ),
        ),
      ],
    );
  }
}

class _LowStockTile extends StatelessWidget {
  const _LowStockTile({required this.alert});

  final StockAlert alert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.productName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok: ${alert.stock} • Minimum: ${alert.stockMin}',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFF97316)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(message, style: const TextStyle(color: Color(0xFFDC2626)));
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

String _formatDate(DateTime date) {
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
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}
