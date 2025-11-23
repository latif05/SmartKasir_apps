import '../entities/transaction_detail.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionDetail {
  const GetTransactionDetail(this._repository);

  final TransactionRepository _repository;

  Future<TransactionDetail> call(String id) {
    return _repository.getTransactionDetail(id);
  }
}
