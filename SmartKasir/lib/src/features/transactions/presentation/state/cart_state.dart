import '../../domain/entities/cart.dart';

class CartState {
  const CartState({
    this.cart = const Cart(),
    this.isProcessing = false,
    this.errorMessage,
  });

  final Cart cart;
  final bool isProcessing;
  final String? errorMessage;

  CartState copyWith({
    Cart? cart,
    bool? isProcessing,
    String? errorMessage,
    bool resetError = false,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: resetError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
