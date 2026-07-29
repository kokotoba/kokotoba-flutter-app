import 'package:flutter/material.dart';

import '../common/components/kokotoba_components.dart';
import 'components/card_components.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final phrases = <String>[
    'うまく話せないため、アプリを使っています',
    'もう一度ゆっくり話してください',
    '少し考える時間をください',
    'ありがとうございます',
    '助けてください',
  ];

  Future<void> _addPhrase() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しい文章'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'よく使う文章を入力'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('追加'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty) {
      setState(() => phrases.insert(0, result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'よく使う文章',
      subtitle: 'タップして選択できます',
      child: ListView.separated(
        itemCount: phrases.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _addPhrase,
                child: const Text('＋  新しい文章を追加'),
              ),
            );
          }
          final phraseIndex = index - 1;
          return PhraseCard(
            text: phrases[phraseIndex],
            onDelete: () => setState(() => phrases.removeAt(phraseIndex)),
          );
        },
      ),
    );
  }
}
