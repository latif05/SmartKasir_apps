import '../entities/stock_alert.dart';
import '../repositories/report_repository.dart';

class GetLowStockReport {
  const GetLowStockReport(this._repository);

  final ReportRepository _repository;

  Future<List<StockAlert>> call({int? limit}) {
    return _repository.getLowStockProducts(limit: limit);
  }
}
