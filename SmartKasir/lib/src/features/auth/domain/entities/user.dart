import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    this.isActive = true,
  });

  final String id;
  final String username;
  final String displayName;
  final String role;
  final bool isActive;

  @override
  List<Object?> get props => [id, username, displayName, role, isActive];
}
