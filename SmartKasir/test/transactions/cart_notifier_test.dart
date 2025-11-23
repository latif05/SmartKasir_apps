import 'package:flutter_test/flutter_test.dart';

import 'package:smartkasir/src/core/error/app_exception.dart';
import 'package:smartkasir/src/features/products/domain/entities/product.dart';
import 'package:smartkasir/src/features/transactions/domain/entities/cart_item.dart';
import 'package:smartkasir/src/features/transactions/domain/entities/discount.dart';
import 'package:smartkasir/src/features/transactions/domain/entities/transaction_detail.dart';
import 'package:smartkasir/src/features/transactions/domain/entities/transaction_record.dart';
import 'package:smartkasir/src/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:smartkasir/src/features/transactions/domain/usecases/create_transaction.dart';
import 'package:smartkasir/src/features/transactions/presentation/state/cart_notifier.dart';

void main() {
  group('CartNotifier + CreateTransaction', () {
    late FakeTransactionRepository repository;
    late CartNotifier notifier;

    setUp(() {
      repository = FakeTransactionRepository();
      notifier = CartNotifier(CreateTransaction(repository));
    });

    Product buildProduct({
      required String id,
      int stock = 5,
      int stockMin = 0,
      double price = 2000,
    }) {
      final now = DateTime.now();
      return Product(
        id: id,
        categoryId: 'c1',
        name: 'Produk $id',
        purchasePrice: 1000,
        sellingPrice: price,
        stock: stock,
        stockMin: stockMin,
        unit: 'pcs',
        imageUrl: null,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('menambah produk dan menolak melebihi stok', () {
      final product = buildProduct(id: 'p1', stock: 1);

      notifier.addProduct(product);
      expect(notifier.state.cart.items.single.quantity, 1);

      expect(
        () => notifier.addProduct(product),
        throwsA(isA<ValidationException>()),
      );
    });

    test('checkout sukses memanggil repository dan mereset keranjang', () async {
      final product = buildProduct(id: 'p1', price: 1500);
      notifier.addProduct(product);
      notifier.setAmountPaid(2000);

      await notifier.checkout();

      expect(repository.createCalls, 1);
      expect(notifier.state.cart.items, isEmpty);
    });

    test('checkout gagal jika bayar kurang dan errorMessage terisi', () async {
      final product = buildProduct(id: 'p1', price: 3000);
      notifier.addProduct(product);
      notifier.setAmountPaid(1000);

      await notifier.checkout();

      expect(repository.createCalls, 0);
      expect(
        notifier.state.errorMessage,
        'Jumlah bayar kurang dari total',
      );
    });
  });
}

class FakeTransactionRepository implements TransactionRepository {
  int createCalls = 0;
  List<CartItem> lastItems = const [];

  @override
  Future<TransactionRecord> createTransaction({
    required List<CartItem> items,
    required DiscountType discountType,
    required double discountValue,
    required String paymentMethod,
    required double amountPaid,
    String? createdBy,
  }) async {
    final total = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    double discount = 0;
    if (discountType == DiscountType.nominal) {
      discount = discountValue.clamp(0, total).toDouble();
    } else if (discountType == DiscountType.percentage) {
      discount = (total * (discountValue / 100)).clamp(0, total).toDouble();
    }
    final finalAmount = (total - discount).clamp(0, double.infinity).toDouble();

    if (amountPaid < finalAmount) {
      throw const ValidationException('Jumlah bayar kurang dari total');
    }

    createCalls += 1;
    lastItems = items;
    final now = DateTime.now();
    return TransactionRecord(
      id: 'trx-$createCalls',
      code: 'INV-$createCalls',
      date: now,
      totalAmount: total,
      discountAmount: discount,
      finalAmount: finalAmount,
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      changeAmount: amountPaid - finalAmount,
      status: 'completed',
      createdBy: createdBy,
    );
  }

  @override
  Future<TransactionDetail> getTransactionDetail(String id) async {
    final now = DateTime.now();
    return TransactionDetail(
      id: id,
      code: 'INV-$id',
      date: now,
      totalAmount: 0,
      discountAmount: 0,
      finalAmount: 0,
      paymentMethod: 'cash',
      amountPaid: 0,
      changeAmount: 0,
      status: 'completed',
      lines: const [],
      createdBy: null,
    );
  }

  @override
  Future<List<TransactionRecord>> getTransactions({int? limit}) async {
    return const [];
  }
}
