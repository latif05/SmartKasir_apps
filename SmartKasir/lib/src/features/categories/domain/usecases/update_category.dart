import '../../../../core/error/app_exception.dart';
import '../repositories/category_repository.dart';

class UpdateCategory {
  const UpdateCategory(this._repository);

  final CategoryRepository _repository;

  Future<void> call({
    required String id,
    required String name,
    String? description,
  }) {
    if (id.trim().isEmpty) {
      throw const ValidationException('ID kategori tidak valid');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationException('Nama kategori wajib diisi');
    }

    final sanitizedDesc = _sanitize(description);

    return _repository.updateCategory(
      id: id,
      name: trimmedName,
      description: sanitizedDesc,
    );
  }
}

String? _sanitize(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

