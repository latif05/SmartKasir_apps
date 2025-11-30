import '../entities/daily_sales.dart';
import '../repositories/report_repository.dart';

class GetDailyTrend {
  const GetDailyTrend(this._repository);

  final ReportRepository _repository;

  Future<List<DailySales>> call({
    required DateTime start,
    required DateTime end,
  }) {
    return _repository.getDailyBreakdown(start: start, end: end);
  }
}
