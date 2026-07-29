import 'package:flutter/material.dart';

import '../../speech_service.dart';
import '../common/components/kokotoba_components.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({
    super.key,
    required this.initialText,
    required this.onCancel,
    required this.onSave,
  });

  final String initialText;
  final VoidCallback onCancel;
  final ValueChanged<String> onSave;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _append(String word) {
    final separator = controller.text.isEmpty ? '' : ' ';
    setState(() {
      controller.text = '${controller.text}$separator$word';
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '文章を編集',
      subtitle: '言いやすい表現に直せます',
      onBack: widget.onCancel,
      child: ListView(
        children: [
          LargeTextEditor(controller: controller),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => controller.text = widget.initialText),
                  icon: const Icon(Icons.refresh),
                  label: const Text('元に戻す'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(controller.clear),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  label: Text(
                    '全文削除',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('タップして追加', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['はい', 'いいえ', 'お願いします', '痛いです', 'もう一度', 'ゆっくり']
                  .map(
                    (word) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AssistPill(word, onTap: () => _append(word)),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => SpeechService.speak(controller.text),
              icon: const Icon(Icons.volume_up_outlined),
              label: const Text('音声で確認する'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  showMessage(context, '文章を入力してください');
                  return;
                }
                widget.onSave(controller.text.trim());
              },
              child: const Text('この文章を使用する'),
            ),
          ),
        ],
      ),
    );
  }
}
