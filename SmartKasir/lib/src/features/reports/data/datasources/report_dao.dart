import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

class ReportDao {
  ReportDao(this._database);

  final AppDatabase _database;

  Future<SalesAggregateRow> fetchSalesAggregate({
    required DateTime start,
    required DateTime end,
  }) async {
    final result = await _database.customSelect(
      '''
      SELECT 
        COUNT(t.id) AS trxCount,
        COALESCE(SUM(t.total_amount), 0) AS grossSales,
        COALESCE(SUM(t.discount_amount), 0) AS discountTotal,
        COALESCE(SUM(t.final_amount), 0) AS netSales
      FROM transactions t
      WHERE t.is_deleted = 0
        AND t.transaction_date BETWEEN ? AND ?
      ''',
      variables: [
        Variable<DateTime>(start),
        Variable<DateTime>(end),
      ],
      readsFrom: { _database.transactions },
    ).getSingle();

    final itemsResult = await _database.customSelect(
      '''
      SELECT COALESCE(SUM(ti.quantity), 0) AS totalItems
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      WHERE t.is_deleted = 0
        AND t.transaction_date BETWEEN ? AND ?
      ''',
      variables: [
        Variable<DateTime>(start),
        Variable<DateTime>(end),
      ],
      readsFrom: { _database.transactionItems, _database.transactions },
    ).getSingle();

    return SalesAggregateRow(
      totalTransactions: result.data['trxCount'] as int? ?? 0,
      totalItems: itemsResult.data['totalItems'] as int? ?? 0,
      grossSales: (result.data['grossSales'] as num?)?.toDouble() ?? 0,
      discountTotal: (result.data['discountTotal'] as num?)?.toDouble() ?? 0,
      netSales: (result.data['netSales'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<List<TopProductRowData>> fetchTopProducts({
    required DateTime start,
    required DateTime end,
    required int limit,
  }) async {
    final rows = await _database.customSelect(
      '''
      SELECT 
        ti.product_id AS productId,
        ti.product_name AS productName,
        COALESCE(SUM(ti.quantity), 0) AS qty,
        COALESCE(SUM(ti.subtotal), 0) AS revenue
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      WHERE t.is_deleted = 0
        AND t.transaction_date BETWEEN ? AND ?
      GROUP BY ti.product_id, ti.product_name
      ORDER BY qty DESC, revenue DESC
      LIMIT ?
      ''',
      variables: [
        Variable<DateTime>(start),
        Variable<DateTime>(end),
        Variable<int>(limit),
      ],
      readsFrom: { _database.transactionItems, _database.transactions },
    ).get();

    return rows
        .map(
          (row) => TopProductRowData(
            productId: row.data['productId'] as String? ?? '',
            productName: row.data['productName'] as String? ?? 'Produk',
            quantity: (row.data['qty'] as int?) ?? 0,
            revenue: (row.data['revenue'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();
  }

  Future<List<StockAlertRowData>> fetchLowStock({int? limit}) async {
    final query = _database.select(_database.products)
      ..where((tbl) => tbl.isDeleted.equals(0))
      ..where((tbl) => tbl.stock.isSmallerOrEqual(tbl.stockMin))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.stock)]);

    if (limit != null) {
      query.limit(limit);
    }

    final rows = await query.get();
    return rows
        .map(
          (row) => StockAlertRowData(
            productId: row.id,
            productName: row.name,
            stock: row.stock,
            stockMin: row.stockMin,
          ),
        )
        .toList();
  }

  Future<List<DailyBreakdownRow>> fetchDailyBreakdown({
    required DateTime start,
    required DateTime end,
  }) async {
    final rows = await _database.customSelect(
      '''
      SELECT 
        DATE(t.transaction_date) AS trxDate,
        COUNT(t.id) AS trxCount,
        COALESCE(SUM(t.total_amount), 0) AS grossSales,
        COALESCE(SUM(t.discount_amount), 0) AS discountTotal,
        COALESCE(SUM(t.final_amount), 0) AS netSales
      FROM transactions t
      WHERE t.is_deleted = 0
        AND t.transaction_date BETWEEN ? AND ?
      GROUP BY DATE(t.transaction_date)
      ORDER BY trxDate DESC
      ''',
      variables: [
        Variable<DateTime>(start),
        Variable<DateTime>(end),
      ],
      readsFrom: {_database.transactions},
    ).get();

    final itemRows = await _database.customSelect(
      '''
      SELECT 
        DATE(t.transaction_date) AS trxDate,
        COALESCE(SUM(ti.quantity), 0) AS totalItems
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      WHERE t.is_deleted = 0
        AND t.transaction_date BETWEEN ? AND ?
      GROUP BY DATE(t.transaction_date)
      ''',
      variables: [
        Variable<DateTime>(start),
        Variable<DateTime>(end),
      ],
      readsFrom: {_database.transactionItems, _database.transactions},
    ).get();

    final itemsMap = {
      for (final row in itemRows)
        row.data['trxDate'] as String: (row.data['totalItems'] as int?) ?? 0,
    };

    return rows
        .map(
          (row) => DailyBreakdownRow(
            dateString: row.data['trxDate'] as String,
            totalTransactions: row.data['trxCount'] as int? ?? 0,
            totalItems: itemsMap[row.data['trxDate']] ?? 0,
            grossSales: (row.data['grossSales'] as num?)?.toDouble() ?? 0,
            discountTotal: (row.data['discountTotal'] as num?)?.toDouble() ?? 0,
            netSales: (row.data['netSales'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();
  }

  Future<StockSummaryRow> fetchStockSummary() async {
    final totals = await _database.customSelect(
      '''
      SELECT 
        COUNT(p.id) AS totalProducts,
        COALESCE(SUM(p.stock), 0) AS totalStock,
        COUNT(CASE WHEN p.stock = 0 THEN 1 END) AS outOfStock
      FROM products p
      WHERE p.is_deleted = 0
      ''',
      readsFrom: {_database.products},
    ).getSingle();

    final lowStockRows = await _database.customSelect(
      '''
      SELECT COUNT(p.id) AS lowStock
      FROM products p
      WHERE p.is_deleted = 0
        AND p.stock <= p.stock_min
      ''',
      readsFrom: {_database.products},
    ).getSingle();

    return StockSummaryRow(
      totalProducts: totals.data['totalProducts'] as int? ?? 0,
      totalStockUnits: (totals.data['totalStock'] as int?) ?? 0,
      outOfStockCount: totals.data['outOfStock'] as int? ?? 0,
      lowStockCount: lowStockRows.data['lowStock'] as int? ?? 0,
    );
  }
}

class SalesAggregateRow {
  const SalesAggregateRow({
    required this.totalTransactions,
    required this.totalItems,
    required this.grossSales,
    required this.discountTotal,
    required this.netSales,
  });

  final int totalTransactions;
  final int totalItems;
  final double grossSales;
  final double discountTotal;
  final double netSales;
}

class TopProductRowData {
  const TopProductRowData({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.revenue,
  });

  final String productId;
  final String productName;
  final int quantity;
  final double revenue;
}

class StockAlertRowData {
  const StockAlertRowData({
    required this.productId,
    required this.productName,
    required this.stock,
    required this.stockMin,
  });

  final String productId;
  final String productName;
  final int stock;
  final int stockMin;
}

class DailyBreakdownRow {
  const DailyBreakdownRow({
    required this.dateString,
    required this.totalTransactions,
    required this.totalItems,
    required this.grossSales,
    required this.discountTotal,
    required this.netSales,
  });

  final String dateString;
  final int totalTransactions;
  final int totalItems;
  final double grossSales;
  final double discountTotal;
  final double netSales;
}

class StockSummaryRow {
  const StockSummaryRow({
    required this.totalProducts,
    required this.totalStockUnits,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  final int totalProducts;
  final int totalStockUnits;
  final int lowStockCount;
  final int outOfStockCount;
}
