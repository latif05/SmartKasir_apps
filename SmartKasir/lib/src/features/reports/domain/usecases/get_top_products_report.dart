import '../entities/top_product.dart';
import '../repositories/report_repository.dart';

class GetTopProductsReport {
  const GetTopProductsReport(this._repository);

  final ReportRepository _repository;

  Future<List<TopProduct>> call({
    required DateTime start,
    required DateTime end,
    int limit = 5,
  }) {
    return _repository.getTopProducts(
      start: start,
      end: end,
      limit: limit,
    );
  }
}
