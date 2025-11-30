import '../entities/store_profile.dart';
import '../repositories/settings_repository.dart';

class GetStoreProfile {
  const GetStoreProfile(this._repository);

  final SettingsRepository _repository;

  Future<StoreProfile> call() => _repository.getStoreProfile();
}
