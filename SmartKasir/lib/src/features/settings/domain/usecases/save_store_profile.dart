import '../entities/store_profile.dart';
import '../repositories/settings_repository.dart';

class SaveStoreProfile {
  const SaveStoreProfile(this._repository);

  final SettingsRepository _repository;

  Future<void> call(StoreProfile profile) => _repository.saveStoreProfile(profile);
}
