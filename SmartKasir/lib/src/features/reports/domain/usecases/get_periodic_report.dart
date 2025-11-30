import '../entities/sales_summary.dart';
import '../repositories/report_repository.dart';

class GetPeriodicReport {
  const GetPeriodicReport(this._repository);

  final ReportRepository _repository;

  Future<SalesSummary> call({
    required DateTime start,
    required DateTime end,
  }) {
    return _repository.getPeriodicSummary(start, end);
  }
}
