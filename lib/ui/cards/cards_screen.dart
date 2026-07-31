import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/controller/registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/model/registered_card.dart';
import 'package:kokotoba_flutter_app/ui/cards/components/card_components.dart';
import 'package:kokotoba_flutter_app/ui/common/components/delayed_loading_indicator.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key, required this.controller});

  final RegisteredCardController controller;

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late Future<List<RegisteredCard>> cardsFuture;
  var cards = <RegisteredCard>[];
  var cardsLoaded = false;

  @override
  void initState() {
    super.initState();
    cardsFuture = widget.controller.fetchRegisteredCards();
  }

  Future<void> _addPhrase() async {
    final textController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しい文章'),
        content: TextField(
          controller: textController,
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
            onPressed: () => Navigator.pop(context, textController.text.trim()),
            child: const Text('追加'),
          ),
        ],
      ),
    );
    textController.dispose();
    if (result != null && result.isNotEmpty) {
      setState(() => cards.insert(0, RegisteredCard(text: result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'よく使う文章',
      subtitle: 'タップして選択できます',
      child: FutureBuilder<List<RegisteredCard>>(
        future: cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const DelayedLoadingIndicator();
          }
          if (snapshot.hasError) {
            return const Center(child: Text('登録カードを読み込めませんでした'));
          }
          if (!cardsLoaded) {
            cards = List.of(snapshot.data ?? const []);
            cardsLoaded = true;
          }
          return ListView.separated(
            itemCount: cards.length + 1,
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
              final cardIndex = index - 1;
              return PhraseCard(
                card: cards[cardIndex],
                onDelete: () => setState(() => cards.removeAt(cardIndex)),
              );
            },
          );
        },
      ),
    );
  }
}
