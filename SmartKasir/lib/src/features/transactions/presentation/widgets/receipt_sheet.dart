import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/entities/transaction_record.dart';

class ReceiptSheet extends StatelessWidget {
  const ReceiptSheet({
    super.key,
    required this.record,
    required this.items,
  });

  final TransactionRecord record;
  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    final text = _buildReceiptText(record, items);
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
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
          child: Column(
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Struk Digital',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  record.code ?? record.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.quantity} x ${_formatCurrency(item.price)}',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatCurrency(item.subtotal),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              _Row(label: 'Subtotal', value: _formatCurrency(record.totalAmount)),
              _Row(
                label: 'Diskon',
                value: '- ${_formatCurrency(record.discountAmount)}',
                valueColor: const Color(0xFFDC2626),
              ),
              _Row(
                label: 'Total Bayar',
                value: _formatCurrency(record.finalAmount),
                bold: true,
              ),
              _Row(
                label: 'Dibayar',
                value: _formatCurrency(record.amountPaid),
              ),
              _Row(
                label: 'Kembalian',
                value: _formatCurrency(record.changeAmount),
                valueColor: const Color(0xFF10B981),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: text));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Struk disalin ke clipboard')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Salin Struk'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
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

String _buildReceiptText(TransactionRecord record, List<CartItem> items) {
  final buffer = StringBuffer()
    ..writeln('SmartKasir')
    ..writeln(record.code ?? record.id)
    ..writeln(_formatCurrency(record.finalAmount))
    ..writeln('Metode: ${record.paymentMethod}')
    ..writeln('---------------------------');

  for (final item in items) {
    buffer.writeln(
        '${item.productName} | ${item.quantity} x ${_formatCurrency(item.price)} = ${_formatCurrency(item.subtotal)}');
  }

  buffer
    ..writeln('---------------------------')
    ..writeln('Subtotal: ${_formatCurrency(record.totalAmount)}')
    ..writeln('Diskon: ${_formatCurrency(record.discountAmount)}')
    ..writeln('Total: ${_formatCurrency(record.finalAmount)}')
    ..writeln('Bayar: ${_formatCurrency(record.amountPaid)}')
    ..writeln('Kembali: ${_formatCurrency(record.changeAmount)}');

  return buffer.toString();
}

String _formatCurrency(double value) {
  final intValue = value.round();
  final text = intValue.toString();
  final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
  final formatted = text.replaceAllMapped(regex, (m) => '${m.group(1)}.');
  return 'Rp $formatted';
}
