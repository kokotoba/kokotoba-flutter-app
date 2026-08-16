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
  List<RegisteredCard>? cards;
  Object? loadError;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => loadError = null);
    try {
      final fetched = await widget.controller.fetchRegisteredCards();
      if (!mounted) return;
      setState(() => cards = List.of(fetched));
    } catch (error, stackTrace) {
      debugPrint('Failed to load frequent phrases: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => loadError = error);
    }
  }

  Future<void> _addPhrase() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _AddPhraseDialog(),
    );
    if (result == null || result.isEmpty) return;

    setState(() => saving = true);
    try {
      final created = await widget.controller.createRegisteredCard(result);
      if (!mounted) return;
      setState(() => cards!.insert(0, created));
      showMessage(context, '文章を追加しました');
    } catch (error, stackTrace) {
      debugPrint('Failed to create frequent phrase: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) showMessage(context, '文章を追加できませんでした');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _deletePhrase(RegisteredCard card) async {
    setState(() => saving = true);
    try {
      await widget.controller.deleteRegisteredCard(card.id);
      if (!mounted) return;
      setState(() => cards!.removeWhere((value) => value.id == card.id));
      showMessage(context, '文章を削除しました');
    } catch (error, stackTrace) {
      debugPrint('Failed to delete frequent phrase: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) showMessage(context, '文章を削除できませんでした');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'よく使う文章',
      subtitle: 'タップして選択できます',
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (cards == null && loadError == null) {
      return const DelayedLoadingIndicator();
    }
    if (cards == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('登録した文章を読み込めませんでした'),
            const SizedBox(height: 12),
            FilledButton(onPressed: _loadCards, child: const Text('再読み込み')),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (saving) const LinearProgressIndicator(),
        SizedBox(
          height: 54,
          child: FilledButton(
            onPressed: saving ? null : _addPhrase,
            child: const Text('＋  新しい文章を追加'),
          ),
        ),
        if (cards!.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 72),
            child: Center(child: Text('ありません')),
          )
        else
          for (final card in cards!) ...[
            const SizedBox(height: 12),
            PhraseCard(
              card: card,
              onDelete: saving ? null : () => _deletePhrase(card),
            ),
          ],
      ],
    );
  }
}

class _AddPhraseDialog extends StatefulWidget {
  const _AddPhraseDialog();

  @override
  State<_AddPhraseDialog> createState() => _AddPhraseDialogState();
}

class _AddPhraseDialogState extends State<_AddPhraseDialog> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新しい文章'),
      content: TextField(
        controller: textController,
        autofocus: true,
        maxLines: 3,
        maxLength: 500,
        decoration: const InputDecoration(hintText: 'よく使う文章を入力'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: textController,
          builder: (context, value, _) => FilledButton(
            onPressed: value.text.trim().isEmpty
                ? null
                : () => Navigator.pop(context, value.text.trim()),
            child: const Text('追加'),
          ),
        ),
      ],
    );
  }
}
