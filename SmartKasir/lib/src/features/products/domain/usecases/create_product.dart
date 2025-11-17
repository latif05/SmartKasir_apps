import '../../../../core/error/app_exception.dart';
import '../repositories/product_repository.dart';

class CreateProduct {
  const CreateProduct(this._repository);

  final ProductRepository _repository;

  Future<void> call({
    required String categoryId,
    required String name,
    double? purchasePrice,
    double? sellingPrice,
    int? stock,
    int? stockMin,
    String? unit,
    String? barcode,
    String? imageUrl,
  }) {
    final trimmedCategory = categoryId.trim();
    if (trimmedCategory.isEmpty) {
      throw const ValidationException('Kategori wajib dipilih');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationException('Nama produk wajib diisi');
    }

    final validatedPurchase = _ensureNonNegativeDouble(purchasePrice ?? 0);
    final validatedSelling = _ensureNonNegativeDouble(sellingPrice ?? 0);
    if (validatedSelling < validatedPurchase) {
      throw const ValidationException('Harga jual tidak boleh lebih rendah dari harga beli');
    }

    final validatedStock = _ensureNonNegativeInt(stock ?? 0);
    final validatedStockMin = _ensureNonNegativeInt(stockMin ?? 0);

    return _repository.createProduct(
      categoryId: trimmedCategory,
      name: trimmedName,
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

