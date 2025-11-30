import '../entities/sales_summary.dart';
import '../repositories/report_repository.dart';

class GetDailyReport {
  const GetDailyReport(this._repository);

  final ReportRepository _repository;

  Future<SalesSummary> call(DateTime date) {
    return _repository.getDailySummary(date);
  }
}
