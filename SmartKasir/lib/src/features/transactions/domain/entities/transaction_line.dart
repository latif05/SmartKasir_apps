import 'package:equatable/equatable.dart';

class TransactionLine extends Equatable {
  const TransactionLine({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  @override
  List<Object?> get props => [
        productId,
        productName,
        quantity,
        price,
        subtotal,
      ];
}
