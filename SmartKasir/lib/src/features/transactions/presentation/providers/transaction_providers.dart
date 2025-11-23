import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../data/datasources/transaction_local_data_source.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/get_transaction_detail.dart';
import '../../domain/usecases/get_transactions.dart';
import '../state/cart_notifier.dart';
import '../state/cart_state.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    serviceLocator<TransactionLocalDataSource>(),
    serviceLocator(),
  );
});

final createTransactionProvider = Provider<CreateTransaction>((ref) {
  return CreateTransaction(ref.read(transactionRepositoryProvider));
});

final getTransactionsProvider = Provider<GetTransactions>((ref) {
  return GetTransactions(ref.read(transactionRepositoryProvider));
});

final getTransactionDetailProvider = Provider<GetTransactionDetail>((ref) {
  return GetTransactionDetail(ref.read(transactionRepositoryProvider));
});

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref.read(createTransactionProvider));
});
