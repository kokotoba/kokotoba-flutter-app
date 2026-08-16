import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/model/registered_card.dart';
import 'package:kokotoba_flutter_app/core/util/speech_util.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';

class PhraseCard extends StatelessWidget {
  const PhraseCard({
    super.key,
    required this.card,
    required this.onDelete,
    this.reorderIndex,
  });

  final RegisteredCard card;
  final VoidCallback? onDelete;
  final int? reorderIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReorderHandle(index: reorderIndex),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 17, 17, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.text,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SmallIconAction(
                          icon: Icons.volume_up_outlined,
                          label: '読む',
                          onTap: () => SpeechUtil.speak(card.text),
                        ),
                        const SmallIconAction(
                          icon: Icons.edit_outlined,
                          label: '編集',
                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ReorderHandle extends StatelessWidget {
  const _ReorderHandle({required this.index});

  final int? index;

  @override
  Widget build(BuildContext context) {
    final handle = Semantics(
      label: '長押しして並べ替え',
      button: true,
      child: Container(
        width: 46,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(20),
          ),
        ),
        child: Icon(
          Icons.drag_indicator,
          color: index == null
              ? Theme.of(context).disabledColor
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    final currentIndex = index;
    if (currentIndex == null) return handle;
    return ReorderableDelayedDragStartListener(
      index: currentIndex,
      child: handle,
    );
  }
}
