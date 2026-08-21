import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/auth/auth_service.dart';
import 'package:kokotoba_flutter_app/ui/auth/login_screen.dart';
import 'package:kokotoba_flutter_app/ui/kokotoba_app.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        final user = snapshot.data;
        if (user == null) return LoginScreen(authService: authService);

        return KokotobaApp(
          authUser: user,
          onSignOut: authService.signOut,
          onSendEmailVerification: authService.sendEmailVerification,
        );
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ココトバ', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              const SizedBox.square(
                dimension: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
