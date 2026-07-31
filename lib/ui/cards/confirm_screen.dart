import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/util/speech_util.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({
    super.key,
    required this.text,
    required this.onBack,
    required this.onEdit,
  });

  final String text;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '発話内容を確認',
      subtitle: 'まだ読み上げられていません',
      onBack: onBack,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StatusBanner(
                title: '内容を確認してください',
                detail: '選択と読み上げは別の操作です',
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 22),
              Text('伝える文章', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: rose050,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('文章を編集する'),
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 64,
                child: FilledButton.icon(
                  onPressed: () => SpeechUtil.speak(text),
                  icon: const Icon(Icons.volume_up_outlined),
                  label: const Text('音声で読み上げる'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: () => showMessage(context, text),
                  icon: const Icon(Icons.person_outline),
                  label: const Text('相手に画面を見せる'),
                ),
              ),
              TextButton(onPressed: onBack, child: const Text('キャンセル')),
            ],
          ),
        ],
      ),
    );
  }
}
