import '../../../auth/domain/entities/user.dart';

class UserManagementState {
  const UserManagementState({
    this.users = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final List<User> users;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  UserManagementState copyWith({
    List<User>? users,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}
