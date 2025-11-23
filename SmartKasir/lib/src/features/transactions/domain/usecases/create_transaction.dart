import '../entities/cart_item.dart';
import '../entities/discount.dart';
import '../entities/transaction_record.dart';
import '../repositories/transaction_repository.dart';

class CreateTransaction {
  const CreateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<TransactionRecord> call({
    required List<CartItem> items,
    DiscountType discountType = DiscountType.none,
    double discountValue = 0,
    String paymentMethod = 'cash',
    double amountPaid = 0,
    String? createdBy,
  }) {
    return _repository.createTransaction(
      items: items,
      discountType: discountType,
      discountValue: discountValue,
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      createdBy: createdBy,
    );
  }
}
