import '../repositories/settings_repository.dart';

class BackupDatabase {
  const BackupDatabase(this._repository);

  final SettingsRepository _repository;

  Future<String> call() => _repository.backupDatabase();
}
