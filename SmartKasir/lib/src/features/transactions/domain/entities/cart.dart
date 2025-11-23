import 'package:equatable/equatable.dart';

import 'cart_item.dart';
import 'discount.dart';

class Cart extends Equatable {
  const Cart({
    this.items = const [],
    this.discountType = DiscountType.none,
    this.discountValue = 0,
    this.paymentMethod = 'cash',
    this.amountPaid = 0,
  });

  final List<CartItem> items;
  final DiscountType discountType;
  final double discountValue;
  final String paymentMethod;
  final double amountPaid;

  double get subtotal =>
      items.fold(0, (total, item) => total + item.subtotal);

  double get discountAmount {
    if (discountType == DiscountType.none || discountValue <= 0) {
      return 0;
    }
    if (discountType == DiscountType.nominal) {
      return discountValue.clamp(0, subtotal);
    }
    // percentage
    final raw = subtotal * (discountValue / 100);
    return raw.clamp(0, subtotal);
  }

  double get total => (subtotal - discountAmount).clamp(0, double.infinity);

  double get change => (amountPaid - total).clamp(0, double.infinity);

  bool get isPaid => amountPaid >= total && total > 0;

  Cart copyWith({
    List<CartItem>? items,
    DiscountType? discountType,
    double? discountValue,
    String? paymentMethod,
    double? amountPaid,
  }) {
    return Cart(
      items: items ?? this.items,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
    );
  }

  @override
  List<Object?> get props => [
        items,
        discountType,
        discountValue,
        paymentMethod,
        amountPaid,
      ];
}
