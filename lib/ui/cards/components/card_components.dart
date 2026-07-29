import 'package:flutter/material.dart';

import '../../../speech_service.dart';
import '../../common/components/kokotoba_components.dart';

class PhraseCard extends StatelessWidget {
  const PhraseCard({super.key, required this.text, required this.onDelete});

  final String text;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: Theme.of(context).textTheme.titleMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SmallIconAction(
                  icon: Icons.volume_up_outlined,
                  label: '読む',
                  onTap: () => SpeechService.speak(text),
                ),
                const SmallIconAction(icon: Icons.edit_outlined, label: '編集'),
                SmallIconAction(
                  icon: Icons.delete_outline,
                  label: '削除',
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
