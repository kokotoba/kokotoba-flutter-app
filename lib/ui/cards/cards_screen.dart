import 'dart:async';

import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/controller/registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/model/registered_card.dart';
import 'package:kokotoba_flutter_app/ui/cards/components/card_components.dart';
import 'package:kokotoba_flutter_app/ui/common/components/delayed_loading_indicator.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

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
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddPhraseSheet(),
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

  Future<void> _reorderPhrases(int oldIndex, int newIndex) async {
    if (saving || oldIndex == newIndex) return;

    final previousOrder = List<RegisteredCard>.of(cards!);
    final reordered = List<RegisteredCard>.of(cards!);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    setState(() {
      cards = reordered;
      saving = true;
    });

    try {
      await widget.controller.reorderRegisteredCards(
        reordered.map((card) => card.id).toList(growable: false),
      );
      if (mounted) showMessage(context, '並び順を保存しました');
    } catch (error, stackTrace) {
      debugPrint('Failed to reorder frequent phrases: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => cards = previousOrder);
      showMessage(context, '並び順を保存できませんでした');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'よく使う文章',
      subtitle: '左端を長押しして並べ替え',
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

    return Column(
      children: [
        SizedBox(
          height: 4,
          child: saving ? const LinearProgressIndicator() : null,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton(
            onPressed: saving ? null : _addPhrase,
            child: const Text('＋  新しい文章を追加'),
          ),
        ),
        const SizedBox(height: 12),
        if (cards!.isEmpty)
          const Expanded(child: Center(child: Text('ありません')))
        else
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: cards!.length,
              onReorderItem: (oldIndex, newIndex) {
                unawaited(_reorderPhrases(oldIndex, newIndex));
              },
              proxyDecorator: (child, index, animation) => Material(
                color: Colors.transparent,
                elevation: 7,
                borderRadius: BorderRadius.circular(20),
                child: child,
              ),
              itemBuilder: (context, index) {
                final card = cards![index];
                return Padding(
                  key: ValueKey(card.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PhraseCard(
                    card: card,
                    reorderIndex: saving ? null : index,
                    onDelete: saving ? null : () => _deletePhrase(card),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _AddPhraseSheet extends StatefulWidget {
  const _AddPhraseSheet();

  @override
  State<_AddPhraseSheet> createState() => _AddPhraseSheetState();
}

class _AddPhraseSheetState extends State<_AddPhraseSheet> {
  final textController = TextEditingController();

  String get phrase => textController.text.trim();

  void _submit() {
    if (phrase.isNotEmpty) Navigator.pop(context, phrase);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final length = textController.text.runes.length;
    final canSubmit = phrase.isNotEmpty;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: rose050,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.bookmark_add_outlined,
                      color: rose700,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('よく使う文章を登録', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 3),
                        Text(
                          '会話中にすぐ呼び出せる文章を保存します',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '閉じる',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('文章', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    '$length / 500',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              TextField(
                controller: textController,
                autofocus: true,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      required maxLength,
                    }) => null,
                textInputAction: TextInputAction.newline,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '例：もう一度ゆっくりお願いします',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: softSurface,
                  contentPadding: const EdgeInsets.all(17),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: rose700, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: canSubmit
                    ? Container(
                        key: const ValueKey('preview'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: rose050,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 17,
                                  color: rose700,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '登録後のプレビュー',
                                  style: TextStyle(
                                    color: rose700,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(phrase, style: theme.textTheme.titleMedium),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: canSubmit ? _submit : null,
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: const Text('登録する'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
