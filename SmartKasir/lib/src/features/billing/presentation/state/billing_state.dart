import 'package:in_app_purchase/in_app_purchase.dart';

class BillingState {
  const BillingState({
    this.isLoading = false,
    this.purchasePending = false,
    this.errorMessage,
    this.products = const [],
  });

  final bool isLoading;
  final bool purchasePending;
  final String? errorMessage;
  final List<ProductDetails> products;

  BillingState copyWith({
    bool? isLoading,
    bool? purchasePending,
    String? errorMessage,
    List<ProductDetails>? products,
  }) {
    return BillingState(
      isLoading: isLoading ?? this.isLoading,
      purchasePending: purchasePending ?? this.purchasePending,
      errorMessage: errorMessage,
      products: products ?? this.products,
    );
  }
}
