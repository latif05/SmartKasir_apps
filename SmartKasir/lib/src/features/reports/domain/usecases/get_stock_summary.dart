import '../entities/stock_summary.dart';
import '../repositories/report_repository.dart';

class GetStockSummary {
  const GetStockSummary(this._repository);

  final ReportRepository _repository;

  Future<StockSummary> call() {
    return _repository.getStockSummary();
  }
}
