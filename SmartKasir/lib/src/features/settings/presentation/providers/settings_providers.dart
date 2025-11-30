import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/store_profile.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/backup_database.dart';
import '../../domain/usecases/get_store_profile.dart';
import '../../domain/usecases/save_store_profile.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return serviceLocator<SettingsRepository>();
});

final getStoreProfileProvider = Provider<GetStoreProfile>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return GetStoreProfile(repo);
});

final saveStoreProfileProvider = Provider<SaveStoreProfile>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return SaveStoreProfile(repo);
});

final backupDatabaseProvider = Provider<BackupDatabase>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return BackupDatabase(repo);
});

class StoreProfileState {
  const StoreProfileState({
    required this.profile,
    this.isLoading = false,
    this.error,
    this.message,
  });

  final StoreProfile profile;
  final bool isLoading;
  final String? error;
  final String? message;

  StoreProfileState copyWith({
    StoreProfile? profile,
    bool? isLoading,
    String? error,
    String? message,
  }) {
    return StoreProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      message: message,
    );
  }

  StoreProfileState clearFeedback() =>
      copyWith(error: null, message: null, isLoading: false);
}

class StoreProfileNotifier extends StateNotifier<StoreProfileState> {
  StoreProfileNotifier({
    required GetStoreProfile getStoreProfile,
    required SaveStoreProfile saveStoreProfile,
    required BackupDatabase backupDatabase,
  })  : _getStoreProfile = getStoreProfile,
        _saveStoreProfile = saveStoreProfile,
        _backupDatabase = backupDatabase,
        super(StoreProfileState(profile: StoreProfile.empty())) {
    load();
  }

  final GetStoreProfile _getStoreProfile;
  final SaveStoreProfile _saveStoreProfile;
  final BackupDatabase _backupDatabase;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final profile = await _getStoreProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat profil toko',
      );
    }
  }

  Future<void> save(StoreProfile profile) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      await _saveStoreProfile(profile);
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        message: 'Pengaturan toko tersimpan',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal menyimpan pengaturan',
      );
    }
  }

  Future<String?> backup() async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final path = await _backupDatabase();
      state = state.copyWith(
        isLoading: false,
        message: 'Backup tersimpan di $path',
      );
      return path;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal membuat backup',
      );
      return null;
    }
  }
}

final storeProfileNotifierProvider =
    StateNotifierProvider<StoreProfileNotifier, StoreProfileState>((ref) {
  final getProfile = ref.read(getStoreProfileProvider);
  final saveProfile = ref.read(saveStoreProfileProvider);
  final backup = ref.read(backupDatabaseProvider);
  return StoreProfileNotifier(
    getStoreProfile: getProfile,
    saveStoreProfile: saveProfile,
    backupDatabase: backup,
  );
});
