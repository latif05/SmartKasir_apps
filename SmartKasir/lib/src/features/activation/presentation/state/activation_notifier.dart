import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/activation_status.dart';
import '../../domain/usecases/activate_with_code.dart';
import '../../domain/usecases/activate_from_purchase.dart';
import '../../domain/usecases/get_activation_status.dart';
import 'activation_state.dart';

class ActivationNotifier extends StateNotifier<ActivationState> {
  ActivationNotifier(
    this._getActivationStatus,
    this._activateWithCode,
    this._activateFromPurchase,
  ) : super(const ActivationState()) {
    loadStatus();
  }

  final GetActivationStatus _getActivationStatus;
  final ActivateWithCode _activateWithCode;
  final ActivateFromPurchase _activateFromPurchase;

  Future<void> loadStatus() async {
    state = state.copyWith(isLoading: true, resetMessages: true);
    try {
      final ActivationStatus status = await _getActivationStatus(
        const NoParams(),
      );
      state = state.copyWith(
        isPremium: status.isPremium,
        activatedAt: status.activatedAt,
        codeUsed: status.codeUsed,
        isLoading: false,
        resetMessages: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat status aktivasi',
        resetMessages: false,
      );
      // ignore log for now
    }
  }

  Future<void> activate(String code) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      if (code.trim().isEmpty) {
        throw const ActivationException('Kode tidak boleh kosong');
      }

      await _activateWithCode(ActivateWithCodeParams(code.trim()));
      final ActivationStatus status = await _getActivationStatus(
        const NoParams(),
      );
      state = state.copyWith(
        isPremium: status.isPremium,
        activatedAt: status.activatedAt,
        codeUsed: status.codeUsed,
        isLoading: false,
        successMessage: 'Aktivasi berhasil. Terima kasih!',
      );
    } on ActivationException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan saat aktivasi',
      );
    }
  }

  Future<void> activateFromPurchase() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );
    try {
      await _activateFromPurchase(const NoParams());
      final ActivationStatus status = await _getActivationStatus(
        const NoParams(),
      );
      state = state.copyWith(
        isPremium: status.isPremium,
        activatedAt: status.activatedAt,
        codeUsed: status.codeUsed,
        isLoading: false,
        successMessage: 'Pembelian premium berhasil dipulihkan.',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memperbarui status premium',
      );
    }
  }
}
