import 'dart:async';

import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/controller/conversation_controller.dart';
import 'package:kokotoba_flutter_app/core/controller/speech_recognition_controller.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/conversation/components/conversation_components.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({
    super.key,
    required this.onBack,
    required this.speechRecognitionController,
    required this.onRecognized,
    required this.showManualInput,
    required this.suggestionMode,
    required this.onSuggestionModeChanged,
  });

  final VoidCallback onBack;
  final SpeechRecognitionController speechRecognitionController;
  final ValueChanged<String> onRecognized;
  final VoidCallback showManualInput;
  final SuggestionMode suggestionMode;
  final ValueChanged<SuggestionMode> onSuggestionModeChanged;

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  final ScrollController _transcriptScrollController = ScrollController();

  bool initialized = false;
  bool listening = false;
  bool sessionStarted = false;
  bool busy = false;
  bool disposing = false;
  String transcript = '';
  String? errorMessage;

  Future<void> _toggleListening() async {
    if (busy) return;
    if (listening) {
      await _stopAndUseResult();
      return;
    }
    if (sessionStarted && transcript.trim().isNotEmpty) {
      widget.onRecognized(transcript.trim());
      return;
    }
    await _startListening();
  }

  Future<void> _startListening() async {
    setState(() {
      busy = true;
      errorMessage = null;
      transcript = '';
    });
    try {
      if (!initialized) {
        initialized = await widget.speechRecognitionController.initialize(
          onResult: (text, _) {
            if (disposing || !mounted) return;
            _updateTranscript(text);
          },
          onError: (message) {
            if (disposing || !mounted) return;
            setState(() {
              listening = false;
              errorMessage = _localizedError(message);
            });
          },
          onListeningChanged: (value) {
            if (disposing || !mounted) return;
            setState(() => listening = value);
          },
        );
      }
      if (!initialized) {
        if (!mounted) return;
        setState(() => errorMessage = 'マイクまたは音声認識の利用が許可されていません');
        return;
      }

      await widget.speechRecognitionController.start();
      if (!mounted) return;
      setState(() {
        listening = true;
        sessionStarted = true;
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to start speech recognition: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) setState(() => errorMessage = '音声認識を開始できませんでした');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _stopAndUseResult() async {
    setState(() => busy = true);
    try {
      await widget.speechRecognitionController.stop();
      if (!mounted) return;
      setState(() => listening = false);
      final recognized = transcript.trim();
      if (recognized.isEmpty) {
        setState(() {
          sessionStarted = false;
          errorMessage = '音声を認識できませんでした。もう一度お試しください';
        });
        return;
      }
      widget.onRecognized(recognized);
    } catch (error, stackTrace) {
      debugPrint('Failed to stop speech recognition: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) setState(() => errorMessage = '音声認識を停止できませんでした');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _showManualInput() async {
    await widget.speechRecognitionController.cancel();
    if (mounted) widget.showManualInput();
  }

  Future<void> _goBack() async {
    await widget.speechRecognitionController.cancel();
    if (mounted) widget.onBack();
  }

  String _localizedError(String message) {
    if (message.contains('permission')) {
      return 'マイクまたは音声認識の利用を許可してください';
    }
    if (message.contains('no_match') || message.contains('speech_timeout')) {
      return '音声を認識できませんでした。もう一度お試しください';
    }
    return '音声認識でエラーが発生しました';
  }

  void _updateTranscript(String text) {
    setState(() => transcript = text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (disposing || !_transcriptScrollController.hasClients) return;
      _transcriptScrollController.jumpTo(
        _transcriptScrollController.position.maxScrollExtent,
      );
    });
  }

  @override
  void dispose() {
    disposing = true;
    unawaited(widget.speechRecognitionController.cancel());
    _transcriptScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTranscript = transcript.trim().isNotEmpty;
    return PageLayout(
      title: '会話',
      subtitle: listening ? '相手の話を聞いています' : '音声または文字で入力できます',
      onBack: () => unawaited(_goBack()),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '候補生成モード',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<SuggestionMode>(
                      segments: const [
                        ButtonSegment(
                          value: SuggestionMode.fast,
                          icon: Icon(Icons.bolt_outlined),
                          label: Text('高速'),
                        ),
                        ButtonSegment(
                          value: SuggestionMode.quality,
                          icon: Icon(Icons.auto_awesome_outlined),
                          label: Text('高品質'),
                        ),
                      ],
                      selected: {widget.suggestionMode},
                      onSelectionChanged: busy || listening
                          ? null
                          : (selection) {
                              widget.onSuggestionModeChanged(selection.first);
                            },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.suggestionMode == SuggestionMode.fast
                        ? 'すばやく文章候補を作ります'
                        : '履歴や関連情報を詳しく参照します',
                    style: const TextStyle(color: mutedInk),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 152,
                        height: 152,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: listening ? rose100 : rose050,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: listening ? rose700 : mutedInk,
                          child: Icon(
                            listening ? Icons.mic : Icons.mic_none,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        listening
                            ? '聞き取り中'
                            : hasTranscript
                            ? '聞き取りが終了しました'
                            : '聞き取りを開始',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        listening ? '終わったらもう一度ボタンを押します' : 'ボタンを押してマイクを開始します',
                        style: const TextStyle(color: mutedInk),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      AnimatedOpacity(
                        opacity: listening ? 1 : 0.25,
                        duration: const Duration(milliseconds: 180),
                        child: const SoundBars(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(errorMessage!)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ),
          if (hasTranscript) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 128,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: softSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: rose100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '認識中の文章',
                      style: TextStyle(
                        color: rose700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Scrollbar(
                        controller: _transcriptScrollController,
                        child: SingleChildScrollView(
                          controller: _transcriptScrollController,
                          child: Text(
                            transcript,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: FilledButton.icon(
              onPressed: busy ? null : _toggleListening,
              icon: Icon(
                listening
                    ? Icons.stop_circle_outlined
                    : hasTranscript
                    ? Icons.check_circle_outline
                    : Icons.mic_none,
              ),
              label: Text(
                busy
                    ? '準備中...'
                    : listening
                    ? '聞き取りを停止'
                    : hasTranscript
                    ? '認識結果を使う'
                    : '聞き取りを始める',
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: busy ? null : () => unawaited(_showManualInput()),
              icon: const Icon(Icons.keyboard_alt_outlined),
              label: const Text('文字で入力する'),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
