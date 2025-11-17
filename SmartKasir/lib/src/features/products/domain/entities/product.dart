import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    this.barcode,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
    required this.stockMin,
    this.unit,
    this.imageUrl,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String categoryId;
  final String name;
  final String? barcode;
  final double purchasePrice;
  final double sellingPrice;
  final int stock;
  final int stockMin;
  final String? unit;
  final String? imageUrl;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        categoryId,
        name,
        barcode,
        purchasePrice,
        sellingPrice,
        stock,
        stockMin,
        unit,
        imageUrl,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
