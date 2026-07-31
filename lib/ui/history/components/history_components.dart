import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/model/conversation_history.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.history});

  final ConversationHistory history;

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
              history.time,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: rose700),
            ),
            Text(
              history.place,
              style: const TextStyle(color: mutedInk, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              history.summary,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(history.phrase, maxLines: 1, overflow: TextOverflow.ellipsis),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => showMessage(
                  context,
                  '${history.summary}\n${history.phrase}',
                ),
                child: const Text('詳細を見る  ›'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
