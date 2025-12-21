import '../../../../core/error/app_exception.dart';
import '../../domain/entities/activation_status.dart';
import '../../domain/repositories/activation_repository.dart';
import '../datasources/activation_local_data_source.dart';

class ActivationRepositoryImpl implements ActivationRepository {
  ActivationRepositoryImpl(this._localDataSource);

  final ActivationLocalDataSource _localDataSource;

  @override
  Future<ActivationStatus> getStatus() async {
    final data = await _localDataSource.getStatus();
    return ActivationStatus(
      isPremium: data.isPremium == 1,
      activatedAt: data.activatedAt,
      codeUsed: data.codeUsed,
    );
  }

  @override
  Future<void> activate(String code) async {
    final normalizedCode = code.trim().toUpperCase();

    final currentStatus = await _localDataSource.getStatus();
    if (currentStatus.isPremium == 1) {
      throw const ActivationException(
        'Akun ini sudah premium seumur hidup. Tidak perlu aktivasi ulang.',
      );
    }

    final record = await _localDataSource.getCode(normalizedCode);
    if (record == null) {
      throw const ActivationException('Kode aktivasi tidak ditemukan');
    }

    final maxUse = record.maxUse ?? 1;
    final alreadyUsed = record.alreadyUsed;
    if (alreadyUsed >= maxUse) {
      throw const ActivationException('Kode aktivasi sudah digunakan');
    }

    await _localDataSource.markStatus(
      isPremium: true,
      codeUsed: normalizedCode,
      activatedAt: DateTime.now(),
    );
    await _localDataSource.markCodeUsed(normalizedCode);
  }
}

