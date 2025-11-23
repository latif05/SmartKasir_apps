import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../products/data/datasources/product_dao.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/discount.dart';
import '../../domain/entities/transaction_detail.dart';
import '../../domain/entities/transaction_line.dart';
import '../../domain/entities/transaction_record.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(
    this._localDataSource,
    this._productDao,
  );

  final TransactionLocalDataSource _localDataSource;
  final ProductDao _productDao;
  final _uuid = const Uuid();

  @override
  Future<TransactionRecord> createTransaction({
    required List<CartItem> items,
    required DiscountType discountType,
    required double discountValue,
    required String paymentMethod,
    required double amountPaid,
    String? createdBy,
  }) async {
    if (items.isEmpty) {
      throw const ValidationException('Keranjang kosong');
    }

    final totals = _calculateTotals(
      items: items,
      discountType: discountType,
      discountValue: discountValue,
      amountPaid: amountPaid,
    );

    final now = DateTime.now();
    final transactionId = _uuid.v4();
    final code = _generateTransactionCode(now);

    try {
      await _localDataSource.createTransaction(
        transaction: db.TransactionsCompanion(
          id: Value(transactionId),
          transactionCode: Value(code),
          transactionDate: Value(now),
          totalAmount: Value(totals.totalAmount),
          discountAmount: Value(totals.discountAmount),
          finalAmount: Value(totals.finalAmount),
          amountPaid: Value(totals.amountPaid),
          changeAmount: Value(totals.changeAmount),
          paymentMethod: Value(paymentMethod),
          status: const Value('completed'),
          createdBy: Value(createdBy),
          createdAt: Value(now),
          updatedAt: Value(now),
          isDeleted: const Value(0),
        ),
        items: items
            .map(
              (item) => db.TransactionItemsCompanion(
                id: Value(_uuid.v4()),
                transactionId: Value(transactionId),
                productId: Value(item.productId),
                productName: Value(item.productName),
                quantity: Value(item.quantity),
                priceAtSale: Value(item.price),
                subtotal: Value(item.subtotal),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            )
            .toList(),
      );

      // Update stock after successful insert
      for (final item in items) {
        final product = await _productDao.getById(item.productId);
        if (product == null || product.isDeleted == 1) {
          throw const ValidationException('Produk tidak ditemukan untuk update stok');
        }
        final newStock = product.stock - item.quantity;
        if (newStock < 0) {
          throw const ValidationException('Stok tidak mencukupi');
        }
        await _productDao.updateStock(productId: item.productId, newStock: newStock);
      }

      return TransactionRecord(
        id: transactionId,
        code: code,
        date: now,
        totalAmount: totals.totalAmount,
        discountAmount: totals.discountAmount,
        finalAmount: totals.finalAmount,
        paymentMethod: paymentMethod,
        amountPaid: totals.amountPaid,
        changeAmount: totals.changeAmount,
        status: 'completed',
        createdBy: createdBy,
      );
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error('Gagal membuat transaksi', error, stackTrace);
      throw const ValidationException('Gagal menyimpan transaksi');
    }
  }

  @override
  Future<List<TransactionRecord>> getTransactions({int? limit}) async {
    final rows = await _localDataSource.fetchTransactions(limit: limit);
    return rows
        .map(
          (trx) => TransactionRecord(
            id: trx.id,
            code: trx.transactionCode,
            date: trx.transactionDate,
            totalAmount: trx.totalAmount,
            discountAmount: trx.discountAmount,
            finalAmount: trx.finalAmount,
            paymentMethod: trx.paymentMethod,
            amountPaid: trx.amountPaid,
            changeAmount: trx.changeAmount,
            status: trx.status,
            createdBy: trx.createdBy,
          ),
        )
        .toList();
  }

  @override
  Future<TransactionDetail> getTransactionDetail(String id) async {
    final data = await _localDataSource.fetchTransactionWithItems(id);
    if (data == null) {
      throw const ValidationException('Transaksi tidak ditemukan');
    }

    final lines = data.items
        .map(
          (item) => TransactionLine(
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
            price: item.priceAtSale,
            subtotal: item.subtotal,
          ),
        )
        .toList();

    final trx = data.transaction;
    return TransactionDetail(
      id: trx.id,
      code: trx.transactionCode,
      date: trx.transactionDate,
      totalAmount: trx.totalAmount,
      discountAmount: trx.discountAmount,
      finalAmount: trx.finalAmount,
      paymentMethod: trx.paymentMethod,
      amountPaid: trx.amountPaid,
      changeAmount: trx.changeAmount,
      status: trx.status,
      createdBy: trx.createdBy,
      lines: lines,
    );
  }

  _Totals _calculateTotals({
    required List<CartItem> items,
    required DiscountType discountType,
    required double discountValue,
    required double amountPaid,
  }) {
    final totalAmount =
        items.fold<double>(0, (sum, item) => sum + item.subtotal);
    double discountAmount = 0;
    if (discountType == DiscountType.nominal) {
      discountAmount = discountValue.clamp(0, totalAmount).toDouble();
    } else if (discountType == DiscountType.percentage) {
      discountAmount =
          (totalAmount * (discountValue / 100)).clamp(0, totalAmount).toDouble();
    }
    final finalAmount =
        (totalAmount - discountAmount).clamp(0, double.infinity).toDouble();

    if (amountPaid < finalAmount) {
      throw const ValidationException('Jumlah bayar kurang dari total');
    }

    final changeAmount =
        (amountPaid - finalAmount).clamp(0, double.infinity).toDouble();

    return _Totals(
      totalAmount: totalAmount,
      discountAmount: discountAmount,
      finalAmount: finalAmount,
      amountPaid: amountPaid,
      changeAmount: changeAmount,
    );
  }

  String _generateTransactionCode(DateTime now) {
    final datePart =
        '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final shortId = _uuid.v4().split('-').first.toUpperCase();
    return 'INV-$datePart-$shortId';
  }
}

class _Totals {
  const _Totals({
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.amountPaid,
    required this.changeAmount,
  });

  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final double amountPaid;
  final double changeAmount;
}
