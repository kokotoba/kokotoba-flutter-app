import 'package:flutter/material.dart';

import '../../common/components/kokotoba_components.dart';
import '../../theme/color.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.row});

  final (String, String, String, String) row;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              row.$1,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: rose700),
            ),
            Text(row.$2, style: const TextStyle(color: mutedInk, fontSize: 13)),
            const SizedBox(height: 12),
            Text(row.$3, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(row.$4, maxLines: 1, overflow: TextOverflow.ellipsis),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => showMessage(context, '${row.$3}\n${row.$4}'),
                child: const Text('詳細を見る  ›'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
