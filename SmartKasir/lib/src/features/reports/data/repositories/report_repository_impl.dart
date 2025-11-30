import '../../domain/entities/sales_summary.dart';
import '../../domain/entities/stock_alert.dart';
import '../../domain/entities/top_product.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_dao.dart';
import '../../domain/entities/daily_sales.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._reportDao);

  final ReportDao _reportDao;

  @override
  Future<SalesSummary> getDailySummary(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return _buildSummary(start, end);
  }

  @override
  Future<SalesSummary> getPeriodicSummary(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    return _buildSummary(normalizedStart, normalizedEnd);
  }

  Future<SalesSummary> _buildSummary(DateTime start, DateTime end) async {
    final aggregate = await _reportDao.fetchSalesAggregate(start: start, end: end);
    return SalesSummary(
      startDate: start,
      endDate: end,
      totalTransactions: aggregate.totalTransactions,
      totalItems: aggregate.totalItems,
      grossSales: aggregate.grossSales,
      discountTotal: aggregate.discountTotal,
      netSales: aggregate.netSales,
    );
  }

  @override
  Future<List<TopProduct>> getTopProducts({
    required DateTime start,
    required DateTime end,
    int limit = 5,
  }) async {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    final rows = await _reportDao.fetchTopProducts(
      start: normalizedStart,
      end: normalizedEnd,
      limit: limit,
    );

    return rows
        .map(
          (row) => TopProduct(
            productId: row.productId,
            productName: row.productName,
            quantitySold: row.quantity,
            revenue: row.revenue,
          ),
        )
        .toList();
  }

  @override
  Future<List<StockAlert>> getLowStockProducts({int? limit}) async {
    final rows = await _reportDao.fetchLowStock(limit: limit);
    return rows
        .map(
          (row) => StockAlert(
            productId: row.productId,
            productName: row.productName,
            stock: row.stock,
            stockMin: row.stockMin,
          ),
        )
        .toList();
  }

  @override
  Future<List<DailySales>> getDailyBreakdown({
    required DateTime start,
    required DateTime end,
  }) async {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    final rows = await _reportDao.fetchDailyBreakdown(
      start: normalizedStart,
      end: normalizedEnd,
    );

    return rows
        .map((row) {
          final date = DateTime.tryParse(row.dateString) ??
              DateTime(
                normalizedStart.year,
                normalizedStart.month,
                normalizedStart.day,
              );
          return DailySales(
            date: date,
            totalTransactions: row.totalTransactions,
            totalItems: row.totalItems,
            grossSales: row.grossSales,
            discountTotal: row.discountTotal,
            netSales: row.netSales,
          );
        })
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // terbaru di atas
  }
}
