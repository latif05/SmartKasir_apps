import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/store_profile.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  static const _nameKey = 'store_name';
  static const _addressKey = 'store_address';
  static const _phoneKey = 'store_phone';
  static const _emailKey = 'store_email';

  @override
  Future<StoreProfile> getStoreProfile() async {
    final name = await _localDataSource.readValue(_nameKey) ?? '';
    final address = await _localDataSource.readValue(_addressKey) ?? '';
    final phone = await _localDataSource.readValue(_phoneKey) ?? '';
    final email = await _localDataSource.readValue(_emailKey) ?? '';
    return StoreProfile(
      name: name,
      address: address,
      phone: phone,
      email: email,
    );
  }

  @override
  Future<void> saveStoreProfile(StoreProfile profile) async {
    await _localDataSource.saveValue(key: _nameKey, value: profile.name);
    await _localDataSource.saveValue(key: _addressKey, value: profile.address);
    await _localDataSource.saveValue(key: _phoneKey, value: profile.phone);
    await _localDataSource.saveValue(key: _emailKey, value: profile.email);
  }

  @override
  Future<String> backupDatabase() async {
    final docs = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docs.path, 'smartkasir.db');
    final srcFile = File(dbPath);
    if (!await srcFile.exists()) {
      throw Exception('Berkas database tidak ditemukan');
    }
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final backupName = 'smartkasir_backup_$timestamp.db';
    final backupDir = Directory(p.join(docs.path, 'backup'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    final dstFile = File(p.join(backupDir.path, backupName));
    await srcFile.copy(dstFile.path);
    return dstFile.path;
  }
}
