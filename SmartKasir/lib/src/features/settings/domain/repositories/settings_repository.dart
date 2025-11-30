import '../entities/store_profile.dart';

abstract class SettingsRepository {
  Future<StoreProfile> getStoreProfile();

  Future<void> saveStoreProfile(StoreProfile profile);

  /// Membuat salinan database lokal dan mengembalikan path file backup.
  Future<String> backupDatabase();
}
