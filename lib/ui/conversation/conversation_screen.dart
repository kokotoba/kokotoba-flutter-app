import 'dart:async';

import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/controller/conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/conversation_history_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/speech_recognition_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_history.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_result.dart';
import 'package:kokotoba_flutter_app/core/util/speech_util.dart';
import 'package:kokotoba_flutter_app/ui/cards/confirm_screen.dart';
import 'package:kokotoba_flutter_app/ui/cards/edit_screen.dart';
import 'package:kokotoba_flutter_app/ui/common/components/delayed_loading_indicator.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/conversation/components/conversation_components.dart';
import 'package:kokotoba_flutter_app/ui/conversation/listening_screen.dart';
import 'package:kokotoba_flutter_app/ui/conversation/manual_input_screen.dart';

enum ConversationEntry { suggestions, listening, manual }

enum _ConversationPage { suggestions, listening, confirm, edit, manual }

enum _SessionChoice { resume, startNew }

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.controller,
    required this.historyController,
    required this.speechRecognitionController,
    this.initialEntry = ConversationEntry.suggestions,
  });

  final ConversationController controller;
  final ConversationHistoryController historyController;
  final SpeechRecognitionController speechRecognitionController;
  final ConversationEntry initialEntry;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late _ConversationPage page;
  Future<ConversationResult>? conversationResultFuture;
  ConversationResult? latestResult;
  String selectedPhrase = '';
  String? recognizedText;
  SuggestionMode suggestionMode = SuggestionMode.fast;
  Future<ConversationHistory?>? sessionFuture;
  Future<void> historyWriteQueue = Future.value();
  final recordedSuggestionApiSelections = <String>{};
  final recordedSuggestionUtterances = <String>{};

  @override
  void initState() {
    super.initState();
    page = _pageForEntry(widget.initialEntry);
    if (widget.initialEntry == ConversationEntry.suggestions) {
      conversationResultFuture = _fetch();
    }
    unawaited(_ensureSession());
  }

  Future<ConversationResult> _fetch([String question = '']) async {
    final result = await widget.controller.fetchConversationResult(
      question: question,
      mode: suggestionMode,
    );
    latestResult = result;
    return result;
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
    _recordUtterance(ConversationSpeaker.partner, text);
    setState(() {
      recognizedText = text;
      conversationResultFuture = _fetch(text);
      page = _ConversationPage.suggestions;
    });
  }

  void showListening() {
    setState(() => page = _ConversationPage.listening);
  }

  void showSelectedSuggestion(String text) {
    _recordSuggestionSelection(text);
    showConfirm(text);
  }

  void speakSelectedSuggestion(String text) {
    _recordSuggestionSelection(text);
    unawaited(SpeechUtil.speak(text));
  }

  void _recordSuggestionSelection(String text) {
    final result = latestResult;
    final suggestion = result?.suggestions
        .where((suggestion) => suggestion.text == text)
        .firstOrNull;
    final suggestionKey = result?.suggestionId ?? 'local';
    final utteranceKey = '$suggestionKey:${suggestion?.id ?? text}';

    if (recordedSuggestionApiSelections.add(suggestionKey)) {
      unawaited(_selectCard(text));
    }
    if (recordedSuggestionUtterances.add(utteranceKey)) {
      _recordUtterance(ConversationSpeaker.user, text);
    }
  }

  void showConfirm(String text) {
    setState(() {
      selectedPhrase = text;
      page = _ConversationPage.confirm;
    });
  }

  Future<void> _selectCard(String text) async {
    final result = latestResult;
    final suggestionId = result?.suggestionId;
    if (suggestionId == null) return;
    final cardId = result?.suggestions
        .where((suggestion) => suggestion.text == text)
        .map((suggestion) => suggestion.id)
        .firstOrNull;
    if (cardId == null) return;

    try {
      await widget.controller.selectCard(
        suggestionId: suggestionId,
        cardId: cardId,
      );
    } catch (error) {
      debugPrint('Failed to select card: $error');
    }
  }

  void showEdit() {
    setState(() => page = _ConversationPage.edit);
  }

  void showManualInput() {
    setState(() => page = _ConversationPage.manual);
  }

  Future<ConversationHistory?> _ensureSession() {
    final existing = sessionFuture;
    if (existing != null) return existing;
    final started = _startSession();
    sessionFuture = started;
    return started;
  }

  Future<ConversationHistory?> _startSession() async {
    try {
      final session = await widget.historyController.startOrResumeSession();
      if (session.utterances.isEmpty || !mounted) return session;

      final choice = await _chooseExistingSession(session);
      if (choice == _SessionChoice.resume) return session;

      await widget.historyController.endSession(session.id);
      return await widget.historyController.startOrResumeSession();
    } catch (error, stackTrace) {
      debugPrint('Failed to start conversation session: $error');
      debugPrintStack(stackTrace: stackTrace);
      sessionFuture = null;
      return null;
    }
  }

  Future<_SessionChoice> _chooseExistingSession(
    ConversationHistory session,
  ) async {
    final frameReady = Completer<void>();
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) => frameReady.complete());
    binding.ensureVisualUpdate();
    await frameReady.future;
    if (!mounted) return _SessionChoice.resume;

    return await showDialog<_SessionChoice>(
          context: context,
          barrierDismissible: false,
          builder: (context) => PopScope(
            canPop: false,
            child: AlertDialog(
              icon: const Icon(Icons.history),
              title: const Text('前の会話が残っています'),
              content: Text(
                '前回の${session.utterances.length}件の発言から再開しますか？'
                ' 新しく始めても、前の会話は履歴に残ります。',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, _SessionChoice.startNew),
                  child: const Text('終了して新しく始める'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, _SessionChoice.resume),
                  child: const Text('続きから再開'),
                ),
              ],
            ),
          ),
        ) ??
        _SessionChoice.resume;
  }

  void _recordUtterance(ConversationSpeaker speaker, String text) {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return;
    historyWriteQueue = historyWriteQueue.then((_) async {
      try {
        final session = await _ensureSession();
        if (session == null) return;
        await widget.historyController.addUtterance(
          sessionId: session.id,
          speaker: speaker,
          text: normalizedText,
        );
      } catch (error, stackTrace) {
        debugPrint('Failed to save conversation utterance: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (page) {
      _ConversationPage.listening => ListeningScreen(
        onBack: showSuggestions,
        speechRecognitionController: widget.speechRecognitionController,
        onRecognized: showRecognizedSuggestions,
        showManualInput: showManualInput,
        suggestionMode: suggestionMode,
        onSuggestionModeChanged: (mode) {
          setState(() => suggestionMode = mode);
        },
      ),
      _ConversationPage.suggestions => _ConversationSuggestionsView(
        conversationResultFuture: conversationResultFuture,
        confirm: showSelectedSuggestion,
        speak: speakSelectedSuggestion,
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
      _ConversationPage.manual => ManualInputScreen(
        onBack: showListening,
        onCommunicated: (text) =>
            _recordUtterance(ConversationSpeaker.user, text),
      ),
    };
  }
}

class _ConversationSuggestionsView extends StatelessWidget {
  const _ConversationSuggestionsView({
    required this.conversationResultFuture,
    required this.confirm,
    required this.speak,
    required this.manualInput,
    required this.listenAgain,
    this.recognizedText,
  });

  final Future<ConversationResult>? conversationResultFuture;
  final ValueChanged<String> confirm;
  final ValueChanged<String> speak;
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
          if (conversationResultFuture == null) {
            return const Center(child: Text('まず聞き取りを始めてください'));
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const DelayedLoadingIndicator();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('文章候補を読み込めませんでした'));
          }

          final result = snapshot.data!;
          return ListView(
            children: [
              HeardCard(text: recognizedText ?? result.recognizedText),
              const SizedBox(height: 14),
              Text('伝えたい文章の候補', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              for (final suggestion in result.suggestions) ...[
                SuggestionCard(
                  text: suggestion.text,
                  recommended: suggestion.recommended,
                  onSelect: () => confirm(suggestion.text),
                  onSpeak: () => speak(suggestion.text),
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
