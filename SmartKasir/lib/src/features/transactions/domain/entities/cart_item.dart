import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.availableStock,
  });

  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final int availableStock;

  double get subtotal => price * quantity;

  CartItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    int? availableStock,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      availableStock: availableStock ?? this.availableStock,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        productName,
        price,
        quantity,
        availableStock,
      ];
}
