import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(theme: theme),
              const SizedBox(height: 24),
              _KpiSection(isWide: isWide),
              const SizedBox(height: 24),
              _BottomSection(isWide: isWide),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
        Flexible(
          flex: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
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
          ),
        ),
        const SizedBox(width: 12),
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () {},
            ),
            Container(
              margin: const EdgeInsets.only(top: 6, right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '3',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiSection extends StatelessWidget {
  const _KpiSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final cards = const [
      _KpiCard(
        title: 'Total Penjualan',
        value: 'Rp 15.500.000',
        changeLabel: '12% dari bulan lalu',
        changeColor: Color(0xFF10B981),
        changeIcon: Icons.arrow_upward,
      ),
      _KpiCard(
        title: 'Transaksi Hari Ini',
        value: '147',
        changeLabel: '8 transaksi',
        changeColor: Color(0xFF10B981),
        changeIcon: Icons.arrow_upward,
      ),
      _KpiCard(
        title: 'Total Produk',
        value: '285',
        changeLabel: 'Tidak berubah',
        changeColor: Color(0xFF6B7280),
        changeIcon: Icons.remove,
      ),
      _KpiCard(
        title: 'Stok Minimum',
        value: '12',
        changeLabel: 'Perlu restock',
        changeColor: Colors.red,
        changeIcon: Icons.arrow_downward,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 250).floor().clamp(1, 4);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isWide ? 3.4 : 3.0,
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(changeIcon, size: 16, color: changeColor),
              ),
              const SizedBox(width: 8),
              Text(
                changeLabel,
                style: TextStyle(
                  color: changeColor,
                  fontWeight: FontWeight.w700,
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
  const _BottomSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _LatestTransactionsCard(),
          ),
          const SizedBox(width: 16),
          const Expanded(
            flex: 1,
            child: _TopProductsCard(),
          ),
        ],
      );
    }

    return const Column(
      children: [
        _LatestTransactionsCard(),
        SizedBox(height: 16),
        _TopProductsCard(),
      ],
    );
  }
}

class _LatestTransactionsCard extends StatelessWidget {
  const _LatestTransactionsCard();

  final List<Map<String, String>> _data = const [
    {'id': '#TRX001', 'date': '02 Nov 2025', 'total': 'Rp 85.000', 'status': 'Selesai'},
    {'id': '#TRX002', 'date': '02 Nov 2025', 'total': 'Rp 125.000', 'status': 'Selesai'},
    {'id': '#TRX003', 'date': '02 Nov 2025', 'total': 'Rp 45.000', 'status': 'Selesai'},
    {'id': '#TRX004', 'date': '01 Nov 2025', 'total': 'Rp 200.000', 'status': 'Selesai'},
    {'id': '#TRX005', 'date': '01 Nov 2025', 'total': 'Rp 90.000', 'status': 'Selesai'},
  ];

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
                const Text(
                  'Transaksi Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF6A7BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.w700))),
                  Expanded(child: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w700))),
                  Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w700))),
                  Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ..._data.map((trx) => _TransactionRow(trx: trx)),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.trx});

  final Map<String, String> trx;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(trx['id']!)),
          Expanded(child: Text(trx['date']!)),
          Expanded(child: Text(trx['total']!)),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(label: trx['status']!),
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

class _TopProductsCard extends StatelessWidget {
  const _TopProductsCard();

  final List<Map<String, String>> _products = const [
    {'name': 'Ayam Goreng', 'sold': '147 terjual'},
    {'name': 'Nasi Goreng', 'sold': '125 terjual'},
    {'name': 'Kopi Hitam', 'sold': '98 terjual'},
    {'name': 'Teh Manis', 'sold': '87 terjual'},
    {'name': 'Mie Goreng', 'sold': '72 terjual'},
  ];

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
              'Produk Terlaris',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ..._products.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}.',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.value['sold']!,
                            style: const TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ],
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



