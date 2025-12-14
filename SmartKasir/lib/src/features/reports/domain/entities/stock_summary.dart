class StockSummary {
  const StockSummary({
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
