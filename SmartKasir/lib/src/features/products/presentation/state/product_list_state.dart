import '../../domain/entities/product.dart';

class ProductListState {
  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
    this.logs = const [],
  });

  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final List<StockLog> logs;

  ProductListState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<StockLog>? logs,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      logs: logs ?? this.logs,
    );
  }
}

class StockLog {
  const StockLog({
    required this.productId,
    required this.productName,
    required this.delta,
    required this.newStock,
    required this.timestamp,
  });

  final String productId;
  final String productName;
  final int delta;
  final int newStock;
  final DateTime timestamp;

  factory StockLog.fromJson(Map<String, dynamic> json) {
    return StockLog(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      delta: json['delta'] as int? ?? 0,
      newStock: json['newStock'] as int? ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'delta': delta,
      'newStock': newStock,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
