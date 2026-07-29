import 'package:flutter/material.dart';

import '../../core/util/speech_util.dart';
import '../common/components/kokotoba_components.dart';

class ManualInputScreen extends StatefulWidget {
  const ManualInputScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '文字から伝える',
      subtitle: '自由に文章を作れます',
      onBack: widget.onBack,
      child: ListView(
        children: [
          LargeTextEditor(controller: controller, hint: 'ここに伝えたいことを入力'),
          const SizedBox(height: 18),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  selected: true,
                  onSelected: null,
                  label: Text('よく使う単語'),
                ),
                SizedBox(width: 8),
                FilterChip(
                  selected: false,
                  onSelected: null,
                  label: Text('過去の文章'),
                ),
                SizedBox(width: 8),
                FilterChip(
                  selected: false,
                  onSelected: null,
                  label: Text('お気に入り'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['はい', 'いいえ', 'お願いします', '分かりません', '少し待ってください']
                  .map(
                    (word) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AssistPill(
                        word,
                        onTap: () {
                          final separator = controller.text.isEmpty ? '' : ' ';
                          controller.text = '${controller.text}$separator$word';
                          controller.selection = TextSelection.collapsed(
                            offset: controller.text.length,
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 60,
            child: FilledButton.icon(
              onPressed: () => SpeechUtil.speak(controller.text),
              icon: const Icon(Icons.volume_up_outlined),
              label: const Text('音声で読み上げる'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: () => showMessage(
                context,
                controller.text.isEmpty ? '文章を入力してください' : controller.text,
              ),
              child: const Text('相手に画面を見せる'),
            ),
          ),
          TextButton.icon(
            onPressed: () => showMessage(context, 'お気に入りに保存しました'),
            icon: const Icon(Icons.star_border),
            label: const Text('お気に入りに保存'),
          ),
        ],
      ),
    );
  }
}
