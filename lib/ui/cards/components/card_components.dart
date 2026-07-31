import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/model/registered_card.dart';
import 'package:kokotoba_flutter_app/core/util/speech_util.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';

class PhraseCard extends StatelessWidget {
  const PhraseCard({super.key, required this.card, required this.onDelete});

  final RegisteredCard card;
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
            Text(card.text, style: Theme.of(context).textTheme.titleMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SmallIconAction(
                  icon: Icons.volume_up_outlined,
                  label: '読む',
                  onTap: () => SpeechUtil.speak(card.text),
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
