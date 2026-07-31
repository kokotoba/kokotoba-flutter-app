import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/ui/theme/color.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: rose700,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'こ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
