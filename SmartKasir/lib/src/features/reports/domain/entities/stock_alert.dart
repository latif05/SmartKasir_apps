class StockAlert {
  const StockAlert({
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
