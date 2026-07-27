import 'package:flutter/material.dart';

import '../components.dart';
import '../speech_service.dart';
import '../theme.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final phrases = <String>[
    'うまく話せないため、アプリを使っています',
    'もう一度ゆっくり話してください',
    '少し考える時間をください',
    'ありがとうございます',
    '助けてください',
  ];

  Future<void> _addPhrase() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しい文章'),
        content: TextField(
          controller: controller,
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
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('追加'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty) {
      setState(() => phrases.insert(0, result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'よく使う文章',
      subtitle: 'タップして選択できます',
      child: ListView.separated(
        itemCount: phrases.length + 1,
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
          final phraseIndex = index - 1;
          final text = phrases[phraseIndex];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: Theme.of(context).textTheme.titleMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SmallIconAction(
                        icon: Icons.volume_up_outlined,
                        label: '読む',
                        onTap: () => SpeechService.speak(text),
                      ),
                      const SmallIconAction(
                        icon: Icons.edit_outlined,
                        label: '編集',
                      ),
                      SmallIconAction(
                        icon: Icons.delete_outline,
                        label: '削除',
                        onTap: () =>
                            setState(() => phrases.removeAt(phraseIndex)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

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
                  onPressed: () => SpeechService.speak(text),
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

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('今日  10:42', '近くのクリニック', '体調と症状について話しました', '「昨日から頭が痛いです」'),
      ('7月21日  16:18', '場所は保存されていません', '予定の時間について確認しました', '「14時でお願いします」'),
      ('7月18日  12:05', '場所は保存されていません', '昼食について話しました', '「同じものをお願いします」'),
    ];
    return PageLayout(
      title: '会話の履歴',
      subtitle: '新しい順',
      child: ListView.separated(
        itemCount: rows.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index == 0) return const PrivacyNotice();
          final row = rows[index - 1];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.$1,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: rose700),
                  ),
                  Text(
                    row.$2,
                    style: const TextStyle(color: mutedInk, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(row.$3, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(row.$4, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          showMessage(context, '${row.$3}\n${row.$4}'),
                      child: const Text('詳細を見る  ›'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final toggles = <String, bool>{
    '履歴を候補に利用': true,
    '位置情報を候補に利用': false,
    '登録情報を候補に利用': true,
    '選択後に確認画面を表示': true,
    '会話履歴を保存': true,
    '外部通信を利用': false,
  };

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '設定',
      subtitle: '使いやすさを調整',
      child: ListView(
        children: [
          const _SettingsGroup(
            title: '表示',
            rows: [
              ('文字サイズ', '大きい'),
              ('ボタンサイズ', '大きい'),
              ('コントラスト', '標準'),
              ('候補表示数', '3件'),
            ],
          ),
          const SizedBox(height: 20),
          const _SettingsGroup(
            title: '音声',
            rows: [('読み上げ速度', '標準'), ('読み上げ音量', '80%'), ('読み上げ音声', '日本語 1')],
          ),
          const SizedBox(height: 20),
          _ToggleGroup(
            title: '会話支援',
            labels: toggles.keys.take(4).toList(),
            values: toggles,
            onChanged: (key, value) => setState(() => toggles[key] = value),
          ),
          const SizedBox(height: 20),
          _ToggleGroup(
            title: 'プライバシー',
            labels: toggles.keys.skip(4).toList(),
            values: toggles,
            onChanged: (key, value) => setState(() => toggles[key] = value),
          ),
          const SizedBox(height: 20),
          Card(
            color: rose050,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: rose700, size: 25),
                  SizedBox(width: 12),
                  Expanded(child: Text('音声認識と文章候補は、基本的に端末内で処理されます。')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                InkWell(
                  onTap: () =>
                      showMessage(context, '${rows[i].$1}: ${rows[i].$2}'),
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            rows[i].$1,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Text(
                          rows[i].$2,
                          style: const TextStyle(
                            color: rose700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text('  ›', style: TextStyle(color: mutedInk)),
                      ],
                    ),
                  ),
                ),
                if (i != rows.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleGroup extends StatelessWidget {
  const _ToggleGroup({
    required this.title,
    required this.labels,
    required this.values,
    required this.onChanged,
  });

  final String title;
  final List<String> labels;
  final Map<String, bool> values;
  final void Function(String, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          labels[i],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Switch(
                        value: values[labels[i]]!,
                        onChanged: (value) => onChanged(labels[i], value),
                      ),
                    ],
                  ),
                ),
                if (i != labels.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  var selected = 1;

  @override
  Widget build(BuildContext context) {
    const labels = ['標準', '大きい', 'とても大きい'];
    const sizes = [16.0, 20.0, 24.0];
    return PageLayout(
      title: 'はじめの設定',
      subtitle: '1 / 8',
      onBack: widget.onBack,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const LinearProgressIndicator(value: .125),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '文字の大きさを選ぶ',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 6, bottom: 22),
                    child: Text(
                      'あとから設定で変更できます。',
                      style: TextStyle(color: mutedInk),
                    ),
                  ),
                  for (var i = 0; i < labels.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        color: i == selected ? rose050 : warmWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: i == selected ? rose700 : outline,
                            width: i == selected ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => setState(() => selected = i),
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Text(
                                '伝えたい言葉  —  ${labels[i]}',
                                style: TextStyle(
                                  fontSize: sizes[i],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton(
                      onPressed: () {
                        showMessage(context, '「${labels[selected]}」に設定しました');
                        widget.onBack();
                      },
                      child: const Text('次へ'),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: widget.onBack,
                      child: const Text('あとで設定する'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
