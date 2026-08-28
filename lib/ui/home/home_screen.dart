import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/controller/registered_card_controller.dart';
import 'package:kokotoba_flutter_app/core/model/registered_card.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/home/components/home_components.dart';
import 'package:kokotoba_flutter_app/ui/onboarding/onboarding_screen.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.startConversation,
    required this.manualInput,
    required this.openCards,
    required this.registeredCardController,
  });

  final VoidCallback startConversation;
  final VoidCallback manualInput;
  final VoidCallback openCards;
  final RegisteredCardController registeredCardController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var showingOnboarding = false;
  List<RegisteredCard>? quickCards;
  bool savingCard = false;

  @override
  void initState() {
    super.initState();
    _loadQuickCards();
  }

  Future<void> _loadQuickCards() async {
    try {
      final cards = await widget.registeredCardController
          .fetchRegisteredCards();
      if (!mounted) return;
      setState(() => quickCards = cards.take(2).toList(growable: true));
    } catch (error, stackTrace) {
      debugPrint('Failed to load home quick phrases: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) setState(() => quickCards = const []);
    }
  }

  Future<void> _addQuickCard() async {
    if (savingCard || (quickCards?.length ?? 2) >= 2) return;
    final text = await showDialog<String>(
      context: context,
      builder: (context) => const _AddQuickCardDialog(),
    );
    if (text == null || text.isEmpty) return;

    setState(() => savingCard = true);
    try {
      final created = await widget.registeredCardController
          .createRegisteredCard(text);
      if (!mounted) return;
      setState(() => quickCards!.add(created));
      showMessage(context, 'ホームに文章を登録しました');
    } catch (error, stackTrace) {
      debugPrint('Failed to create home quick phrase: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) showMessage(context, '文章を登録できませんでした');
    } finally {
      if (mounted) setState(() => savingCard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showingOnboarding) {
      return OnboardingScreen(
        onBack: () => setState(() => showingOnboarding = false),
      );
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ホーム',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              RoundIconButton(
                icon: Icons.settings_outlined,
                tooltip: '初期設定',
                onPressed: () => setState(() => showingOnboarding = true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            color: rose700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.startConversation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 34,
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 38,
                      backgroundColor: Color(0x29FFFFFF),
                      child: Icon(
                        Icons.mic_none,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '会話をはじめる',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '相手の話を聞いて、伝えたい文章を提案します',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xE6FFFFFF)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HomeAction(
                  icon: Icons.keyboard_alt_outlined,
                  title: '文字から伝える',
                  detail: '自分で入力',
                  onTap: widget.manualInput,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HomeAction(
                  icon: Icons.copy_outlined,
                  title: 'よく使う文章',
                  detail: 'すぐに選ぶ',
                  onTap: widget.openCards,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (quickCards == null)
            const SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            for (final card in quickCards!) ...[
              HomeQuickPhraseCard(card: card),
              const SizedBox(height: 10),
            ],
            if (quickCards!.length < 2)
              HomeQuickPhraseAddCard(
                enabled: !savingCard,
                onTap: _addQuickCard,
              ),
          ],
        ],
      ),
    );
  }
}

class _AddQuickCardDialog extends StatefulWidget {
  const _AddQuickCardDialog();

  @override
  State<_AddQuickCardDialog> createState() => _AddQuickCardDialogState();
}

class _AddQuickCardDialogState extends State<_AddQuickCardDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = controller.text.trim();
    return AlertDialog(
      title: const Text('すぐに使う文章を登録'),
      content: TextField(
        controller: controller,
        autofocus: true,
        minLines: 2,
        maxLines: 4,
        maxLength: 500,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(hintText: '文章を入力'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: text.isEmpty ? null : () => Navigator.pop(context, text),
          child: const Text('登録する'),
        ),
      ],
    );
  }
}
