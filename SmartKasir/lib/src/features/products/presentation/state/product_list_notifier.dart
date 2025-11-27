import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/update_product.dart';
import 'product_list_state.dart';

class ProductListNotifier extends StateNotifier<ProductListState> {
  ProductListNotifier({
    required GetProducts getProducts,
    required CreateProduct createProduct,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
  })  : _getProducts = getProducts,
        _createProduct = createProduct,
        _updateProduct = updateProduct,
        _deleteProduct = deleteProduct,
        super(const ProductListState()) {
    _init();
  }

  final GetProducts _getProducts;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  static const _logsKey = 'stock_logs';

  Future<void> _init() async {
    await _loadLogs();
    await loadProducts();
  }

  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_logsKey) ?? [];
      final logs = rawList
          .map(
            (item) =>
                StockLog.fromJson(jsonDecode(item) as Map<String, dynamic>),
          )
          .toList();
      state = state.copyWith(logs: logs);
    } catch (_) {
      // Lewati jika gagal membaca log, tidak blokir UI.
    }
  }

  Future<void> _saveLogs(List<StockLog> logs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = logs.map((log) => jsonEncode(log.toJson())).toList();
      await prefs.setStringList(_logsKey, encoded);
    } catch (_) {
      // Abaikan kegagalan simpan agar tidak ganggu alur utama.
    }
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final products = await _getProducts();
      state = state.copyWith(products: products, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat produk',
      );
    }
  }

  Future<void> createProduct({
    required String categoryId,
    required String name,
    required double purchasePrice,
    required double sellingPrice,
    required int stock,
    required int stockMin,
    String? unit,
  }) {
    return _performAction(
      () => _createProduct(
        categoryId: categoryId,
        name: name,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        stock: stock,
        stockMin: stockMin,
        unit: unit,
      ),
    );
  }

  Future<void> updateProduct({
    required String id,
    required String categoryId,
    required String name,
    required double purchasePrice,
    required double sellingPrice,
    required int stock,
    required int stockMin,
    String? unit,
  }) {
    return _performAction(
      () => _updateProduct(
        id: id,
        categoryId: categoryId,
        name: name,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        stock: stock,
        stockMin: stockMin,
        unit: unit,
      ),
    );
  }

  Future<void> deleteProduct(String id) {
    return _performAction(() => _deleteProduct(id));
  }

  Future<void> adjustStock({
    required String productId,
    required int delta,
  }) async {
    final product = state.products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw ArgumentError('Produk tidak ditemukan'),
    );

    final newStock = product.stock + delta;
    if (newStock < 0) {
      throw ArgumentError('Stok tidak boleh kurang dari 0');
    }

    final updatedProduct = Product(
      id: product.id,
      categoryId: product.categoryId,
      name: product.name,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
      stock: newStock,
      stockMin: product.stockMin,
      unit: product.unit,
      imageUrl: product.imageUrl,
      isDeleted: product.isDeleted,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
    );

    // Optimistic UI update tanpa reload penuh
    final currentList = [...state.products];
    final index = currentList.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      currentList[index] = updatedProduct;
      state = state.copyWith(products: currentList);
    }

    try {
      await _updateProduct(
        id: product.id,
        categoryId: product.categoryId,
        name: product.name,
        purchasePrice: product.purchasePrice,
        sellingPrice: product.sellingPrice,
        stock: newStock,
        stockMin: product.stockMin,
        unit: product.unit,
      );
    } catch (error) {
      // Sinkronisasi ulang jika gagal agar UI tidak menampilkan data salah
      await loadProducts();
      rethrow;
    }

    final log = StockLog(
      productId: product.id,
      productName: product.name,
      delta: delta,
      newStock: newStock,
      timestamp: DateTime.now(),
    );

    final updatedLogs = [...state.logs, log];
    const maxLogs = 200;
    final trimmedLogs = updatedLogs.length > maxLogs
        ? updatedLogs.sublist(updatedLogs.length - maxLogs)
        : updatedLogs;

    state = state.copyWith(
      logs: trimmedLogs,
    );
    await _saveLogs(trimmedLogs);
  }

  Future<void> _performAction(Future<void> Function() runner) async {
    try {
      await runner();
      await loadProducts();
    } catch (error) {
      rethrow;
    }
  }
}
