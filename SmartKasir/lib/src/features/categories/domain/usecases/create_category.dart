import '../../../../core/error/app_exception.dart';
import '../repositories/category_repository.dart';

class CreateCategory {
  const CreateCategory(this._repository);

  final CategoryRepository _repository;

  Future<void> call({required String name, String? description}) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationException('Nama kategori wajib diisi');
    }

    final sanitizedDesc = _sanitize(description);

    return _repository.createCategory(
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

