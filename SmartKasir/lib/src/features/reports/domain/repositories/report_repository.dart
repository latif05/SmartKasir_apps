import '../entities/sales_summary.dart';
import '../entities/stock_alert.dart';
import '../entities/stock_summary.dart';
import '../entities/top_product.dart';
import '../entities/daily_sales.dart';

abstract class ReportRepository {
  Future<SalesSummary> getDailySummary(DateTime date);

  Future<SalesSummary> getPeriodicSummary(DateTime start, DateTime end);

  Future<List<TopProduct>> getTopProducts({
    required DateTime start,
    required DateTime end,
    int limit,
  });

  Future<List<StockAlert>> getLowStockProducts({int? limit});

  Future<List<DailySales>> getDailyBreakdown({
    required DateTime start,
    required DateTime end,
  });

  Future<StockSummary> getStockSummary();
}
