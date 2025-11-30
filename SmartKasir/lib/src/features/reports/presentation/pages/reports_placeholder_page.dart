import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../activation/presentation/providers/activation_providers.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/sales_summary.dart';
import '../../domain/entities/top_product.dart';
import '../../domain/entities/stock_alert.dart';
import '../../domain/entities/daily_sales.dart';
import '../providers/report_providers.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activationState = ref.watch(activationNotifierProvider);
    final isPremium = activationState.isPremium;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Laporan'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isPremium)
              _PremiumGate(
                onActivateTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
            const SizedBox(height: 16),
            _SummarySection(ref: ref),
            const SizedBox(height: 16),
            _TopProductsSection(ref: ref),
            const SizedBox(height: 16),
            _LowStockSection(ref: ref),
            const SizedBox(height: 16),
            _DailyTrendSection(ref: ref),
          ],
        ),
      ),
    );
  }
}

class _PremiumGate extends StatelessWidget {
  const _PremiumGate({required this.onActivateTap});

  final VoidCallback onActivateTap;

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Akses laporan hanya tersedia untuk Admin Premium. Aktifkan paket premium Rp30.000 untuk membuka laporan dan fitur lanjutan.',
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
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A7BFF),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onActivateTap,
                icon: const Icon(Icons.flash_on_outlined, size: 18),
                label: const Text('Aktifkan Premium'),
              ),
            ),
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
                _StatRow(label: 'Transaksi', value: '${data.totalTransactions}'),
                _StatRow(label: 'Item terjual', value: '${data.totalItems}'),
                _StatRow(label: 'Bruto', value: _formatCurrency(data.grossSales)),
                _StatRow(label: 'Diskon', value: _formatCurrency(data.discountTotal)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      _TopProductTile(
                        product: product,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
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
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: lowStock.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Text('Tidak ada produk dengan stok minimum.');
                }
                return Column(
                  children: [
                    for (final alert in items)
                      _LowStockTile(
                        alert: alert,
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

class _DailyTrendSection extends StatelessWidget {
  const _DailyTrendSection({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final trend = ref.watch(dailyTrendReportFutureProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Harian (30 hari)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: trend.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Text('Belum ada data transaksi 30 hari terakhir.');
                }
                final limited = items.take(10).toList();
                return Column(
                  children: [
                    for (final day in limited)
                      _DailyRow(day: day),
                    if (items.length > limited.length)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Menampilkan 10 hari terbaru',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
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

class _DailyRow extends StatelessWidget {
  const _DailyRow({required this.day});

  final DailySales day;

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDate(day.date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${day.totalTransactions} trx • ${day.totalItems} item',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(day.netSales),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Avg: ${_formatCurrency(day.averageTicket)}',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
            ],
          ),
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
    return Text(
      message,
      style: const TextStyle(color: Color(0xFFDC2626)),
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


