import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/state/auth_state.dart';
import '../main_navigation_shell.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    switch (authState.status) {
      case AuthStatus.initial:
        return const LoginPage();
      case AuthStatus.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator.adaptive()),
        );
      case AuthStatus.authenticated:
        return const MainNavigationShell();
      case AuthStatus.error:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final messenger = ScaffoldMessenger.maybeOf(context);
          if (messenger != null && authState.errorMessage != null) {
            messenger.showSnackBar(
              SnackBar(content: Text(authState.errorMessage!)),
            );
          }
        });
        return const LoginPage();
    }
  }
}
