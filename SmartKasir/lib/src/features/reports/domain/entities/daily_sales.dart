class DailySales {
  const DailySales({
    required this.date,
    required this.totalTransactions,
    required this.totalItems,
    required this.grossSales,
    required this.discountTotal,
    required this.netSales,
  });

  final DateTime date;
  final int totalTransactions;
  final int totalItems;
  final double grossSales;
  final double discountTotal;
  final double netSales;

  double get averageTicket =>
      totalTransactions == 0 ? 0 : netSales / totalTransactions;
}
