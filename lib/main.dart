import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  runApp(const KokotobaApplication());
}

class KokotobaApplication extends StatelessWidget {
  const KokotobaApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ココトバ',
      debugShowCheckedModeBanner: false,
      theme: kokotobaTheme(),
      home: const KokotobaApp(),
    );
  }
}
