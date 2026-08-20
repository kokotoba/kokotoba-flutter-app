import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/controller/conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/speech_recognition_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_result.dart';
import 'package:kokotoba_flutter_app/ui/cards/confirm_screen.dart';
import 'package:kokotoba_flutter_app/ui/cards/edit_screen.dart';
import 'package:kokotoba_flutter_app/ui/common/components/delayed_loading_indicator.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/conversation/components/conversation_components.dart';
import 'package:kokotoba_flutter_app/ui/conversation/listening_screen.dart';
import 'package:kokotoba_flutter_app/ui/conversation/manual_input_screen.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

enum ConversationEntry { suggestions, listening, manual }

enum _ConversationPage { suggestions, listening, confirm, edit, manual }

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.controller,
    required this.speechRecognitionController,
    this.initialEntry = ConversationEntry.suggestions,
  });

  final ConversationController controller;
  final SpeechRecognitionController speechRecognitionController;
  final ConversationEntry initialEntry;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late _ConversationPage page;
  late final Future<ConversationResult> conversationResultFuture;
  String selectedPhrase = '';
  String? recognizedText;

  @override
  void initState() {
    super.initState();
    page = _pageForEntry(widget.initialEntry);
    conversationResultFuture = widget.controller.fetchConversationResult('');
  }

  _ConversationPage _pageForEntry(ConversationEntry entry) {
    return switch (entry) {
      ConversationEntry.suggestions => _ConversationPage.suggestions,
      ConversationEntry.listening => _ConversationPage.listening,
      ConversationEntry.manual => _ConversationPage.manual,
    };
  }

  void showSuggestions() {
    setState(() => page = _ConversationPage.suggestions);
  }

  void showRecognizedSuggestions(String text) {
    setState(() {
      recognizedText = text;
      page = _ConversationPage.suggestions;
    });
  }

  void showListening() {
    setState(() => page = _ConversationPage.listening);
  }

  void showConfirm(String text) {
    setState(() {
      selectedPhrase = text;
      page = _ConversationPage.confirm;
    });
  }

  void showEdit() {
    setState(() => page = _ConversationPage.edit);
  }

  void showManualInput() {
    setState(() => page = _ConversationPage.manual);
  }

  @override
  Widget build(BuildContext context) {
    return switch (page) {
      _ConversationPage.listening => ListeningScreen(
        onBack: showSuggestions,
        speechRecognitionController: widget.speechRecognitionController,
        onRecognized: showRecognizedSuggestions,
        showManualInput: showManualInput,
      ),
      _ConversationPage.suggestions => _ConversationSuggestionsView(
        conversationResultFuture: conversationResultFuture,
        confirm: showConfirm,
        manualInput: showManualInput,
        listenAgain: showListening,
        recognizedText: recognizedText,
      ),
      _ConversationPage.confirm => ConfirmScreen(
        text: selectedPhrase,
        onBack: showSuggestions,
        onEdit: showEdit,
      ),
      _ConversationPage.edit => EditScreen(
        initialText: selectedPhrase,
        onCancel: () => setState(() => page = _ConversationPage.confirm),
        onSave: (value) => showConfirm(value),
      ),
      _ConversationPage.manual => ManualInputScreen(onBack: showListening),
    };
  }
}

class _ConversationSuggestionsView extends StatelessWidget {
  const _ConversationSuggestionsView({
    required this.conversationResultFuture,
    required this.confirm,
    required this.manualInput,
    required this.listenAgain,
    this.recognizedText,
  });

  final Future<ConversationResult> conversationResultFuture;
  final ValueChanged<String> confirm;
  final VoidCallback manualInput;
  final VoidCallback listenAgain;
  final String? recognizedText;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '会話',
      subtitle: '候補を選んでください',
      child: FutureBuilder<ConversationResult>(
        future: conversationResultFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const DelayedLoadingIndicator();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('文章候補を読み込めませんでした'));
          }

          final result = snapshot.data!;
          return ListView(
            children: [
              const StatusBanner(
                title: '聞き取りました',
                detail: '内容が違うときは修正できます',
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 14),
              HeardCard(text: recognizedText ?? result.recognizedText),
              const SizedBox(height: 18),
              Text('伝えたい文章の候補', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 3),
              const Text(
                '候補は参考です。選んだあとに内容を確認できます。',
                style: TextStyle(color: mutedInk),
              ),
              const SizedBox(height: 14),
              for (final suggestion in result.suggestions) ...[
                SuggestionCard(
                  text: suggestion.text,
                  reason: suggestion.reason,
                  recommended: suggestion.recommended,
                  onSelect: () => confirm(suggestion.text),
                ),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 18),
              Text('すぐに伝える', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (
                      var index = 0;
                      index < result.quickPhrases.length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(width: 8),
                      AssistPill(result.quickPhrases[index]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  CompactAction(
                    icon: Icons.refresh,
                    label: '聞き直す',
                    onTap: listenAgain,
                  ),
                  const SizedBox(width: 10),
                  CompactAction(
                    icon: Icons.keyboard_alt_outlined,
                    label: '自分で入力',
                    onTap: manualInput,
                  ),
                  const SizedBox(width: 10),
                  const CompactAction(icon: Icons.more_horiz, label: '別の候補'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
