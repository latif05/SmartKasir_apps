class SalesSummary {
  const SalesSummary({
    required this.startDate,
    required this.endDate,
    required this.totalTransactions,
    required this.totalItems,
    required this.grossSales,
    required this.discountTotal,
    required this.netSales,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int totalTransactions;
  final int totalItems;
  final double grossSales;
  final double discountTotal;
  final double netSales;
}
