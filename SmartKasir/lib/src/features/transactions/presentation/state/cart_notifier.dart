import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/discount.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/entities/transaction_record.dart';
import 'cart_state.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier(this._createTransaction) : super(const CartState());

  final CreateTransaction _createTransaction;

  void addProduct(Product product) {
    final items = [...state.cart.items];
    final index = items.indexWhere((i) => i.productId == product.id);
    if (index == -1) {
      if (product.stock <= 0) {
        throw const ValidationException('Stok produk habis');
      }
      items.add(
        CartItem(
          productId: product.id,
          productName: product.name,
          price: product.sellingPrice,
          quantity: 1,
          availableStock: product.stock,
        ),
      );
    } else {
      final item = items[index];
      if (item.quantity + 1 > item.availableStock) {
        throw const ValidationException('Jumlah melebihi stok tersedia');
      }
      items[index] = item.copyWith(quantity: item.quantity + 1);
    }
    state = state.copyWith(
      cart: state.cart.copyWith(items: items),
      resetError: true,
    );
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }

    final items = [...state.cart.items];
    final index = items.indexWhere((i) => i.productId == productId);
    if (index == -1) return;

    final item = items[index];
    if (quantity > item.availableStock) {
      throw const ValidationException('Jumlah melebihi stok tersedia');
    }

    items[index] = item.copyWith(quantity: quantity);
    state = state.copyWith(
      cart: state.cart.copyWith(items: items),
      resetError: true,
    );
  }

  void removeProduct(String productId) {
    final items = state.cart.items.where((i) => i.productId != productId).toList();
    state = state.copyWith(
      cart: state.cart.copyWith(items: items),
      resetError: true,
    );
  }

  void setDiscountNominal(double value) {
    state = state.copyWith(
      cart: state.cart.copyWith(
        discountType: value > 0 ? DiscountType.nominal : DiscountType.none,
        discountValue: value,
      ),
      resetError: true,
    );
  }

  void setDiscountPercentage(double value) {
    state = state.copyWith(
      cart: state.cart.copyWith(
        discountType: value > 0 ? DiscountType.percentage : DiscountType.none,
        discountValue: value,
      ),
      resetError: true,
    );
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(
      cart: state.cart.copyWith(paymentMethod: method),
      resetError: true,
    );
  }

  void setAmountPaid(double amount) {
    state = state.copyWith(
      cart: state.cart.copyWith(amountPaid: amount),
      resetError: true,
    );
  }

  Future<TransactionRecord> checkout({String? createdBy}) async {
    final cart = state.cart;
    state = state.copyWith(isProcessing: true, resetError: true);
    try {
      final record = await _createTransaction(
        items: cart.items,
        discountType: cart.discountType,
        discountValue: cart.discountValue,
        paymentMethod: cart.paymentMethod,
        amountPaid: cart.amountPaid,
        createdBy: createdBy,
      );
      state = const CartState(
        cart: Cart(),
        isProcessing: false,
        errorMessage: null,
      );
      return record;
    } on AppException catch (error) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: error.message,
      );
      rethrow;
    } catch (_) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Terjadi kesalahan saat memproses transaksi',
      );
      rethrow;
    }
  }

  void clear() {
    state = const CartState(cart: Cart());
  }
}
