import '../entities/transaction_record.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions {
  const GetTransactions(this._repository);

  final TransactionRepository _repository;

  Future<List<TransactionRecord>> call({int? limit}) {
    return _repository.getTransactions(limit: limit);
  }
}
