import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kokotoba_flutter_app/core/controller/kokotoba_controllers.dart';
import 'package:kokotoba_flutter_app/ui/kokotoba_app.dart';
import 'package:kokotoba_flutter_app/ui/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(KokotobaApplication(controllers: KokotobaControllers.live()));
}

class KokotobaApplication extends StatelessWidget {
  const KokotobaApplication({super.key, required this.controllers});

  final KokotobaControllers controllers;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ココトバ',
      debugShowCheckedModeBanner: false,
      theme: kokotobaTheme(),
      home: KokotobaApp(controllers: controllers),
    );
  }
}
