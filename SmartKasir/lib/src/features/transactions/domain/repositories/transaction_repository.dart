import '../entities/cart_item.dart';
import '../entities/discount.dart';
import '../entities/transaction_detail.dart';
import '../entities/transaction_record.dart';

abstract class TransactionRepository {
  Future<TransactionRecord> createTransaction({
    required List<CartItem> items,
    required DiscountType discountType,
    required double discountValue,
    required String paymentMethod,
    required double amountPaid,
    String? createdBy,
  });

  Future<List<TransactionRecord>> getTransactions({int? limit});

  Future<TransactionDetail> getTransactionDetail(String id);
}
