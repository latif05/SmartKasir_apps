import '../../../../core/error/app_exception.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  const UpdateProduct(this._repository);

  final ProductRepository _repository;

  Future<void> call({
    required String id,
    String? categoryId,
    String? name,
    double? purchasePrice,
    double? sellingPrice,
    int? stock,
    int? stockMin,
    String? unit,
    String? barcode,
    String? imageUrl,
  }) {
    if (id.trim().isEmpty) {
      throw const ValidationException('ID produk tidak valid');
    }

    final sanitizedCategoryId = categoryId == null ? null : _requireNotEmpty(categoryId, 'Kategori wajib diisi');
    final sanitizedName = name == null ? null : _requireNotEmpty(name, 'Nama produk wajib diisi');

    final validatedPurchase = purchasePrice == null ? null : _ensureNonNegativeDouble(purchasePrice);
    final validatedSelling = sellingPrice == null ? null : _ensureNonNegativeDouble(sellingPrice);

    if (validatedSelling != null && validatedPurchase != null && validatedSelling < validatedPurchase) {
      throw const ValidationException('Harga jual tidak boleh lebih rendah dari harga beli');
    }

    final validatedStock = stock == null ? null : _ensureNonNegativeInt(stock);
    final validatedStockMin = stockMin == null ? null : _ensureNonNegativeInt(stockMin);

    return _repository.updateProduct(
      id: id,
      categoryId: sanitizedCategoryId,
      name: sanitizedName,
      purchasePrice: validatedPurchase,
      sellingPrice: validatedSelling,
      stock: validatedStock,
      stockMin: validatedStockMin,
      unit: _trimToNull(unit),
      barcode: _trimToNull(barcode),
      imageUrl: _trimToNull(imageUrl),
    );
  }
}

String _requireNotEmpty(String value, String message) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    throw ValidationException(message);
  }
  return trimmed;
}

double _ensureNonNegativeDouble(double value) {
  if (value < 0) {
    throw const ValidationException('Harga tidak boleh bernilai negatif');
  }
  return value;
}

int _ensureNonNegativeInt(int value) {
  if (value < 0) {
    throw const ValidationException('Stok tidak boleh bernilai negatif');
  }
  return value;
}

String? _trimToNull(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

