import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/transaction_detail.dart';
import '../../domain/entities/transaction_record.dart';
import '../providers/transaction_providers.dart';
import '../widgets/cart_panel.dart';
import '../widgets/payment_sheet.dart';
import '../widgets/product_grid_panel.dart';
import '../widgets/receipt_sheet.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  late Future<List<TransactionRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<TransactionRecord>> _load() {
    return ref.read(getTransactionsProvider).call(limit: 50);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productListNotifierProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          title: const Text(
            'Transaksi',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          bottom: const TabBar(
            labelColor: Color(0xFF6A7BFF),
            unselectedLabelColor: Color(0xFF6B7280),
            tabs: [
              Tab(text: 'POS'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildPosView(
                    context,
                    productState,
                    cartState,
                    cartNotifier,
                  ),
                  _buildHistoryView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosView(
    BuildContext context,
    dynamic productState,
    dynamic cartState,
    dynamic cartNotifier,
  ) {
    final isCompact = MediaQuery.sizeOf(context).width < 900;
    if (isCompact) {
      return _CompactPosView(
        isLoading: productState.isLoading,
        products: productState.products,
        errorMessage: productState.errorMessage,
        cartState: cartState,
        onAddToCart: (product) {
          try {
            cartNotifier.addProduct(product);
          } on AppException catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onUpdateQuantity: (id, qty) {
          try {
            cartNotifier.updateQuantity(id, qty);
          } on AppException catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onRemove: (id) => cartNotifier.removeProduct(id),
        onDiscountNominal: cartNotifier.setDiscountNominal,
        onDiscountPercent: cartNotifier.setDiscountPercentage,
        onPaymentMethod: cartNotifier.setPaymentMethod,
        onAmountPaid: cartNotifier.setAmountPaid,
        onSubmitPayment: () =>
            _openPaymentSheet(context, cartState.cart, cartNotifier),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: ProductGridPanel(
            isLoading: productState.isLoading,
            products: productState.products,
            errorMessage: productState.errorMessage,
            onAddToCart: (product) {
              try {
                cartNotifier.addProduct(product);
              } on AppException catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: CartPanel(
            cartState: cartState,
            onUpdateQuantity: (id, qty) {
              try {
                cartNotifier.updateQuantity(id, qty);
              } on AppException catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            onRemove: (id) => cartNotifier.removeProduct(id),
            onDiscountNominal: cartNotifier.setDiscountNominal,
            onDiscountPercent: cartNotifier.setDiscountPercentage,
            onPaymentMethod: cartNotifier.setPaymentMethod,
            onAmountPaid: cartNotifier.setAmountPaid,
            onSubmitPayment: () =>
                _openPaymentSheet(context, cartState.cart, cartNotifier),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<TransactionRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(onRetry: _refresh);
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(
              child: Text('Belum ada transaksi.'),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final trx = data[index];
                return _TransactionTile(
                  record: trx,
                  onTap: () => _openDetail(trx.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _openPaymentSheet(
    BuildContext context,
    Cart cart,
    dynamic cartNotifier,
  ) async {
    if (cart.items.isEmpty) return;
    final snapshot = cart;
    final result = await showModalBottomSheet<PaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentSheet(total: cart.total),
    );
    if (result == null || !context.mounted) return;

    cartNotifier.setPaymentMethod(result.method);
    cartNotifier.setAmountPaid(result.amount);

    final messenger = ScaffoldMessenger.of(context);
    try {
      final record = await cartNotifier.checkout();
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil')),
      );
      if (!context.mounted) return;
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => ReceiptSheet(
          record: record,
          items: snapshot.items,
        ),
      );
      await _refresh();
    } on AppException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _openDetail(String id) async {
    final ctx = context;
    final detail = await ref.read(getTransactionDetailProvider).call(id);
    if (!ctx.mounted) return;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetailSheet(detail: detail),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.record, required this.onTap});

  final TransactionRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isComplete = record.status == 'completed';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isComplete
                      ? const Color(0xFFECFDF3)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  record.code ?? record.id.substring(0, 8).toUpperCase(),
                  style: TextStyle(
                    color: isComplete
                        ? const Color(0xFF047857)
                        : const Color(0xFFF97316),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatCurrency(record.finalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(record.date),
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record.paymentMethod == 'cash' ? 'Tunai' : 'Non-Tunai',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isComplete ? 'Selesai' : record.status,
                    style: TextStyle(
                      color: isComplete
                          ? const Color(0xFF047857)
                          : const Color(0xFFF97316),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.detail});

  final TransactionDetail detail;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                detail.code ?? detail.id,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_formatDate(detail.date)} • ${detail.paymentMethod == 'cash' ? 'Tunai' : 'Non-Tunai'}',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              ...detail.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${line.quantity} x ${_formatCurrency(line.price)}',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatCurrency(line.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              _SummaryRow(
                label: 'Subtotal',
                value: _formatCurrency(detail.totalAmount),
              ),
              _SummaryRow(
                label: 'Diskon',
                value: '- ${_formatCurrency(detail.discountAmount)}',
                valueColor: const Color(0xFFDC2626),
              ),
              const Divider(),
              _SummaryRow(
                label: 'Total Bayar',
                value: _formatCurrency(detail.finalAmount),
                bold: true,
              ),
              _SummaryRow(
                label: 'Dibayar',
                value: _formatCurrency(detail.amountPaid),
              ),
              _SummaryRow(
                label: 'Kembalian',
                value: _formatCurrency(detail.changeAmount),
                valueColor: const Color(0xFF10B981),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: valueColor ?? const Color(0xFF1F2430),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Gagal memuat transaksi'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}

String _formatCurrency(double value) {
  final intValue = value.round();
  final text = intValue.toString();
  final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
  final formatted = text.replaceAllMapped(regex, (m) => '${m.group(1)}.');
  return 'Rp $formatted';
}

String _formatDate(DateTime date) {
  final d = date;
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  final year = d.year;
  return '$day/$month/$year ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniButton(
          icon: Icons.remove,
          onTap: () => onChanged(value - 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        _MiniButton(
          icon: Icons.add,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _CompactPosView extends StatefulWidget {
  const _CompactPosView({
    required this.isLoading,
    required this.products,
    required this.errorMessage,
    required this.cartState,
    required this.onAddToCart,
    required this.onUpdateQuantity,
    required this.onRemove,
    required this.onDiscountNominal,
    required this.onDiscountPercent,
    required this.onPaymentMethod,
    required this.onAmountPaid,
    required this.onSubmitPayment,
  });

  final bool isLoading;
  final List products;
  final String? errorMessage;
  final dynamic cartState;
  final void Function(dynamic product) onAddToCart;
  final void Function(String id, int qty) onUpdateQuantity;
  final void Function(String id) onRemove;
  final void Function(double) onDiscountNominal;
  final void Function(double) onDiscountPercent;
  final void Function(String) onPaymentMethod;
  final void Function(double) onAmountPaid;
  final VoidCallback onSubmitPayment;

  @override
  State<_CompactPosView> createState() => _CompactPosViewState();
}

class _CompactPosViewState extends State<_CompactPosView> {
  late final TextEditingController _searchController;
  final ValueNotifier<String> _keyword = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..addListener(() => _keyword.value = _searchController.text.toLowerCase());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _keyword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cartState.cart as Cart;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
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
          ),
          const SizedBox(height: 12),
          if (widget.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (widget.errorMessage != null)
            Center(child: Text(widget.errorMessage!))
          else
            ValueListenableBuilder<String>(
              valueListenable: _keyword,
              builder: (_, keyword, __) {
                final filtered = widget.products.where((p) {
                  final name = p.name.toLowerCase();
                  return keyword.isEmpty || name.contains(keyword);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Tidak ada produk sesuai filter.'),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (_, index) {
                    final product = filtered[index];
                    final isOut = product.stock == 0;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatCurrency(product.sellingPrice)),
                          Text(
                            isOut ? 'Stok habis' : 'Stok: ${product.stock}',
                            style: TextStyle(
                              color: isOut
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: isOut ? null : () => widget.onAddToCart(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A7BFF),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFE5E7EB),
                          disabledForegroundColor: const Color(0xFF9CA3AF),
                        ),
                        child: const Text('Tambah'),
                      ),
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 16),
          _CompactCartSummary(
            cart: cart,
            onRemove: widget.onRemove,
            onUpdateQuantity: widget.onUpdateQuantity,
            onDiscountNominal: widget.onDiscountNominal,
            onDiscountPercent: widget.onDiscountPercent,
            onPaymentMethod: widget.onPaymentMethod,
            onAmountPaid: widget.onAmountPaid,
            onSubmitPayment: widget.onSubmitPayment,
          ),
        ],
      ),
    );
  }
}

class _CompactCartSummary extends StatefulWidget {
  const _CompactCartSummary({
    required this.cart,
    required this.onRemove,
    required this.onUpdateQuantity,
    required this.onDiscountNominal,
    required this.onDiscountPercent,
    required this.onPaymentMethod,
    required this.onAmountPaid,
    required this.onSubmitPayment,
  });

  final Cart cart;
  final void Function(String id) onRemove;
  final void Function(String id, int qty) onUpdateQuantity;
  final void Function(double) onDiscountNominal;
  final void Function(double) onDiscountPercent;
  final void Function(String) onPaymentMethod;
  final void Function(double) onAmountPaid;
  final VoidCallback onSubmitPayment;

  @override
  State<_CompactCartSummary> createState() => _CompactCartSummaryState();
}

class _CompactCartSummaryState extends State<_CompactCartSummary> {
  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    final hasItems = cart.items.isNotEmpty;
    if (hasItems && cart.amountPaid != cart.total) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onAmountPaid(cart.total);
      });
    } else if (!hasItems && cart.amountPaid != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onAmountPaid(0);
      });
    }

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!hasItems)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Keranjang kosong'),
              )
            else
              ...cart.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              _formatCurrency(item.price),
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                            Text(
                              'Stok: ${item.availableStock}',
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _MiniStepper(
                        value: item.quantity,
                        onChanged: (qty) =>
                            widget.onUpdateQuantity(item.productId, qty),
                      ),
                      const SizedBox(width: 8),
                      Text(_formatCurrency(item.subtotal)),
                      IconButton(
                        onPressed: () => widget.onRemove(item.productId),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Diskon Nominal',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) =>
                        widget.onDiscountNominal(double.tryParse(v) ?? 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Diskon (%)',
                      suffixText: '%',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) =>
                        widget.onDiscountPercent(double.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: cart.paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Metode',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Tunai')),
                DropdownMenuItem(value: 'transfer', child: Text('Non-Tunai')),
              ],
              onChanged: (v) {
                if (v != null) widget.onPaymentMethod(v);
              },
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Subtotal',
              value: _formatCurrency(cart.subtotal),
            ),
            _SummaryRow(
              label: 'Diskon',
              value: '- ${_formatCurrency(cart.discountAmount)}',
              valueColor: const Color(0xFFDC2626),
            ),
            _SummaryRow(
              label: 'Total',
              value: _formatCurrency(cart.total),
              bold: true,
            ),
            _SummaryRow(
              label: 'Kembalian',
              value: _formatCurrency(cart.change),
              valueColor: const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: hasItems ? widget.onSubmitPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B5ED7),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Bayar ${_formatCurrency(cart.total)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
