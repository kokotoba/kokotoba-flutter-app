import 'package:flutter/material.dart';

import '../../theme/color.dart';

class HomeAction extends StatelessWidget {
  const HomeAction({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: rose700),
              const SizedBox(height: 18),
              Text(
                title,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(detail, style: const TextStyle(color: mutedInk)),
            ],
          ),
        ),
      ),
    );
  }
}
