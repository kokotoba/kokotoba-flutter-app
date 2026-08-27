import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kokotoba_flutter_app/core/auth/auth_service.dart';
import 'package:kokotoba_flutter_app/core/auth/firebase_auth_service.dart';
import 'package:kokotoba_flutter_app/core/controller/kokotoba_controllers.dart';
import 'package:kokotoba_flutter_app/ui/auth/auth_gate.dart';
import 'package:kokotoba_flutter_app/ui/kokotoba_app.dart';
import 'package:kokotoba_flutter_app/ui/theme/theme.dart';

const _authMode = String.fromEnvironment('AUTH_MODE', defaultValue: 'firebase');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  final useDevAuth = _authMode == 'dev';
  if (!useDevAuth) {
    await Firebase.initializeApp();
  }
  runApp(
    KokotobaApplication(
      controllers: KokotobaControllers.live(),
      authService: useDevAuth ? null : FirebaseAuthService(),
    ),
  );
}

class KokotobaApplication extends StatelessWidget {
  const KokotobaApplication({
    super.key,
    required this.controllers,
    this.authService,
  });

  final KokotobaControllers controllers;
  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ココトバ',
      debugShowCheckedModeBanner: false,
      theme: kokotobaTheme(),
      home: authService == null
          ? KokotobaApp(controllers: controllers)
          : AuthGate(authService: authService!, controllers: controllers),
    );
  }
}
