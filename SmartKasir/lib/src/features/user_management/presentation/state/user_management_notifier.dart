import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/repositories/user_management_repository.dart';
import 'user_management_state.dart';

class UserManagementNotifier extends StateNotifier<UserManagementState> {
  UserManagementNotifier(this._repository)
      : super(const UserManagementState()) {
    loadUsers();
  }

  final UserManagementRepository _repository;

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final users = await _repository.getUsers();
      state = state.copyWith(users: users, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat daftar kasir',
      );
    }
  }

  Future<String?> createUser({
    required String username,
    required String displayName,
    required String password,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.createUser(
        username: username,
        displayName: displayName,
        password: password,
      );
      await loadUsers();
      return null;
    } on ValidationException catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.message);
      return e.message;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan kasir',
      );
      return 'Gagal menyimpan kasir';
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<String?> updateUser({
    required String id,
    String? displayName,
    String? password,
    bool? isActive,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.updateUser(
        id: id,
        displayName: displayName,
        password: password?.isEmpty == true ? null : password,
        isActive: isActive,
      );
      await loadUsers();
      return null;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal memperbarui kasir',
      );
      return 'Gagal memperbarui kasir';
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<void> deactivate(String id) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.deactivateUser(id);
      await loadUsers();
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menonaktifkan kasir',
      );
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}
