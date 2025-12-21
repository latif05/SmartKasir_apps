import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/cart.dart';
import '../widgets/cart_panel.dart';
import '../widgets/product_grid_panel.dart';
import '../widgets/payment_sheet.dart';
import '../widgets/receipt_sheet.dart';

class TransactionsPlaceholderPage extends ConsumerStatefulWidget {
  const TransactionsPlaceholderPage({super.key});

  @override
  ConsumerState<TransactionsPlaceholderPage> createState() =>
      _TransactionsPlaceholderPageState();
}

class _TransactionsPlaceholderPageState
    extends ConsumerState<TransactionsPlaceholderPage> {
  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productListNotifierProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Transaksi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Row(
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
                  ref.read(cartNotifierProvider.notifier).addProduct(product);
                } on AppException catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              isCompact: MediaQuery.sizeOf(context).width < 900,
            ),
          ),
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
              onDiscountNominal: (value) =>
                  cartNotifier.setDiscountNominal(value),
              onDiscountPercent: (value) =>
                  cartNotifier.setDiscountPercentage(value),
              onPaymentMethod: (method) =>
                  cartNotifier.setPaymentMethod(method),
              onAmountPaid: (amount) =>
                  cartNotifier.setAmountPaid(amount),
              onSubmitPayment: () => _openPaymentSheet(context, cartState.cart),
              // compact mode handled in main POS page; keep default layout here
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPaymentSheet(BuildContext context, Cart cart) async {
    if (cart.items.isEmpty) return;
    final cartSnapshot = cart;
    final result = await showModalBottomSheet<PaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentSheet(total: cart.total),
    );

    if (result == null) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(cartNotifierProvider.notifier);
    notifier.setPaymentMethod(result.method);
    notifier.setAmountPaid(result.amount);

    try {
      final record = await notifier.checkout();
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
          items: cartSnapshot.items,
        ),
      );
    } on AppException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    }
  }
}
