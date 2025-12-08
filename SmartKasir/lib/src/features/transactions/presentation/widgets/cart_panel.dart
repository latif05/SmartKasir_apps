import 'package:flutter/material.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/discount.dart';
import '../state/cart_state.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({
    super.key,
    required this.cartState,
    required this.onUpdateQuantity,
    required this.onRemove,
    required this.onDiscountNominal,
    required this.onDiscountPercent,
    required this.onPaymentMethod,
    required this.onAmountPaid,
    required this.onSubmitPayment,
  });

  final CartState cartState;
  final void Function(String productId, int qty) onUpdateQuantity;
  final void Function(String productId) onRemove;
  final void Function(double value) onDiscountNominal;
  final void Function(double value) onDiscountPercent;
  final void Function(String method) onPaymentMethod;
  final void Function(double amount) onAmountPaid;
  final VoidCallback onSubmitPayment;

  @override
  Widget build(BuildContext context) {
    final cart = cartState.cart;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(-4, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Keranjang',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '${cart.items.length} item',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Text('Keranjang masih kosong'),
                  )
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (_, index) {
                      final item = cart.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => onRemove(item.productId),
                                  icon: const Icon(Icons.close, size: 18),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  _formatCurrency(item.price),
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const Spacer(),
                                _QuantityStepper(
                                  value: item.quantity,
                                  onChanged: (qty) =>
                                      onUpdateQuantity(item.productId, qty),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Subtotal: ${_formatCurrency(item.subtotal)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (item.quantity >= item.availableStock)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Stok maksimum tercapai',
                                  style: TextStyle(
                                    color: Color(0xFFF97316),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          if (cartState.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Text(
                cartState.errorMessage!,
                style: const TextStyle(color: Color(0xFFDC2626)),
              ),
            ),
          _PaymentSection(
            cart: cart,
            onDiscountNominal: onDiscountNominal,
            onDiscountPercent: onDiscountPercent,
            onPaymentMethod: onPaymentMethod,
            onAmountPaid: onAmountPaid,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: cart.items.isEmpty || cartState.isProcessing
                  ? null
                  : onSubmitPayment,
              icon: cartState.isProcessing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.payment),
              label: Text(
                cartState.isProcessing ? 'Memproses...' : 'Selesaikan Pembayaran',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A7BFF),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                disabledForegroundColor: const Color(0xFF9CA3AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove,
          onTap: () => onChanged(value - 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _PaymentSection extends StatefulWidget {
  const _PaymentSection({
    required this.cart,
    required this.onDiscountNominal,
    required this.onDiscountPercent,
    required this.onPaymentMethod,
    required this.onAmountPaid,
  });

  final Cart cart;
  final void Function(double value) onDiscountNominal;
  final void Function(double value) onDiscountPercent;
  final void Function(String value) onPaymentMethod;
  final void Function(double value) onAmountPaid;

  @override
  State<_PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<_PaymentSection> {
  final _discountNominalController = TextEditingController();
  final _discountPercentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _discountNominalController.text =
        widget.cart.discountType == DiscountType.nominal
            ? widget.cart.discountValue.toString()
            : '';
    _discountPercentController.text =
        widget.cart.discountType == DiscountType.percentage
            ? widget.cart.discountValue.toString()
            : '';
  }

  @override
  void dispose() {
    _discountNominalController.dispose();
    _discountPercentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _discountNominalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Diskon Nominal',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) {
                  final nominal = double.tryParse(value) ?? 0;
                  widget.onDiscountNominal(nominal);
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _discountPercentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Diskon (%)',
                  suffixText: '%',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) {
                  final percent = double.tryParse(value) ?? 0;
                  widget.onDiscountPercent(percent);
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: cart.paymentMethod,
          decoration: const InputDecoration(
            labelText: 'Metode Pembayaran',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(value: 'cash', child: Text('Tunai')),
            DropdownMenuItem(value: 'transfer', child: Text('Non-Tunai/Transfer')),
          ],
          onChanged: (value) {
            if (value != null) widget.onPaymentMethod(value);
          },
        ),
        const SizedBox(height: 10),
        _SummaryRow(label: 'Subtotal', value: _formatCurrency(cart.subtotal)),
        _SummaryRow(
          label: 'Diskon',
          value: '- ${_formatCurrency(cart.discountAmount)}',
          valueColor: const Color(0xFFDC2626),
        ),
        const Divider(),
        _SummaryRow(
          label: 'Total Bayar',
          value: _formatCurrency(cart.total),
          valueStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        _SummaryRow(
          label: 'Kembalian',
          value: _formatCurrency(cart.change),
          valueColor: const Color(0xFF10B981),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueStyle,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Text(
            value,
            style: valueStyle ??
                TextStyle(
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? const Color(0xFF1F2430),
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
