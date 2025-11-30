import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../data/datasources/report_dao.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/get_daily_report.dart';
import '../../domain/usecases/get_low_stock_report.dart';
import '../../domain/usecases/get_periodic_report.dart';
import '../../domain/usecases/get_top_products_report.dart';
import '../../domain/entities/sales_summary.dart';
import '../../domain/entities/top_product.dart';
import '../../domain/entities/stock_alert.dart';
import '../../domain/entities/daily_sales.dart';
import '../../domain/usecases/get_daily_trend.dart';

final reportDaoProvider = Provider<ReportDao>((ref) {
  return serviceLocator<ReportDao>();
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return serviceLocator<ReportRepository>();
});

final getDailyReportProvider = Provider<GetDailyReport>((ref) {
  final repository = ref.read(reportRepositoryProvider);
  return GetDailyReport(repository);
});

final getPeriodicReportProvider = Provider<GetPeriodicReport>((ref) {
  final repository = ref.read(reportRepositoryProvider);
  return GetPeriodicReport(repository);
});

final getTopProductsReportProvider = Provider<GetTopProductsReport>((ref) {
  final repository = ref.read(reportRepositoryProvider);
  return GetTopProductsReport(repository);
});

final getLowStockReportProvider = Provider<GetLowStockReport>((ref) {
  final repository = ref.read(reportRepositoryProvider);
  return GetLowStockReport(repository);
});

final getDailyTrendProvider = Provider<GetDailyTrend>((ref) {
  final repository = ref.read(reportRepositoryProvider);
  return GetDailyTrend(repository);
});

DateTime _todayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

final dailyReportFutureProvider = FutureProvider.autoDispose<SalesSummary>((ref) {
  final usecase = ref.read(getDailyReportProvider);
  return usecase(_todayDate());
});

final weeklyReportFutureProvider = FutureProvider.autoDispose<SalesSummary>((ref) {
  final usecase = ref.read(getPeriodicReportProvider);
  final end = _todayDate().add(const Duration(hours: 23, minutes: 59, seconds: 59));
  final start = end.subtract(const Duration(days: 6));
  return usecase(start: start, end: end);
});

final monthlyReportFutureProvider = FutureProvider.autoDispose<SalesSummary>((ref) {
  final usecase = ref.read(getPeriodicReportProvider);
  final end = _todayDate().add(const Duration(hours: 23, minutes: 59, seconds: 59));
  final start = end.subtract(const Duration(days: 29));
  return usecase(start: start, end: end);
});

final topProductsReportFutureProvider =
    FutureProvider.autoDispose<List<TopProduct>>((ref) {
  final usecase = ref.read(getTopProductsReportProvider);
  final end = _todayDate().add(const Duration(hours: 23, minutes: 59, seconds: 59));
  final start = end.subtract(const Duration(days: 29));
  return usecase(start: start, end: end, limit: 5);
});

final lowStockReportFutureProvider =
    FutureProvider.autoDispose<List<StockAlert>>((ref) {
  final usecase = ref.read(getLowStockReportProvider);
  return usecase(limit: 10);
});

final dailyTrendReportFutureProvider =
    FutureProvider.autoDispose<List<DailySales>>((ref) {
  final usecase = ref.read(getDailyTrendProvider);
  final end = _todayDate().add(const Duration(hours: 23, minutes: 59, seconds: 59));
  final start = end.subtract(const Duration(days: 29));
  return usecase(start: start, end: end);
});
