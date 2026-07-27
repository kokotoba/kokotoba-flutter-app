import 'package:flutter/material.dart';

import '../components.dart';
import '../speech_service.dart';
import '../theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.startConversation,
    required this.manualInput,
    required this.openCards,
    required this.openOnboarding,
  });

  final VoidCallback startConversation;
  final VoidCallback manualInput;
  final VoidCallback openCards;
  final VoidCallback openOnboarding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: rose700,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'こ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ココトバ', style: Theme.of(context).textTheme.titleLarge),
                    const Text(
                      'あなたの言葉を、いっしょに。',
                      style: TextStyle(color: mutedInk),
                    ),
                  ],
                ),
              ),
              RoundIconButton(
                icon: Icons.settings_outlined,
                tooltip: '初期設定',
                onPressed: openOnboarding,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const StatusBanner(
            title: '会話を開始できます',
            detail: 'マイク待機中',
            icon: Icons.mic_none,
          ),
          const SizedBox(height: 16),
          Card(
            color: rose700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: startConversation,
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
                child: _HomeAction(
                  icon: Icons.keyboard_alt_outlined,
                  title: '文字から伝える',
                  detail: '自分で入力',
                  onTap: manualInput,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HomeAction(
                  icon: Icons.copy_outlined,
                  title: 'よく使う文章',
                  detail: 'すぐに選ぶ',
                  onTap: openCards,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PrivacyNotice(),
        ],
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: rose700),
              const SizedBox(height: 18),
              Text(
                title,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(detail, style: const TextStyle(color: mutedInk)),
            ],
          ),
        ),
      ),
    );
  }
}

class ListeningScreen extends StatelessWidget {
  const ListeningScreen({
    super.key,
    required this.onBack,
    required this.showExample,
  });

  final VoidCallback onBack;
  final VoidCallback showExample;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '会話',
      subtitle: '相手の話を聞いています',
      onBack: onBack,
      child: ListView(
        children: [
          Column(
            children: [
              const SizedBox(height: 34),
              Container(
                width: 152,
                height: 152,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: rose050,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 52,
                  backgroundColor: rose700,
                  child: Icon(Icons.mic_none, color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: 28),
              Text('聞き取り中', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              const Text('端末を相手に向けてください', style: TextStyle(color: mutedInk)),
              const SizedBox(height: 22),
              const _SoundBars(),
            ],
          ),
          const SizedBox(height: 30),
          Column(
            children: [
              const PrivacyNotice(),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  onPressed: showExample,
                  child: const Text('認識結果のUIを見る'),
                ),
              ),
              TextButton(onPressed: onBack, child: const Text('聞き取りをやめる')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoundBars extends StatelessWidget {
  const _SoundBars();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [20.0, 34.0, 48.0, 30.0, 18.0]
          .map(
            (height) => Container(
              width: 6,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: rose700,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
          .toList(),
    );
  }
}

class ConversationScreen extends StatelessWidget {
  const ConversationScreen({
    super.key,
    required this.confirm,
    required this.manualInput,
  });

  final VoidCallback confirm;
  final VoidCallback manualInput;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '会話',
      subtitle: '候補を選んでください',
      child: ListView(
        children: [
          const StatusBanner(
            title: '聞き取りました',
            detail: '内容が違うときは修正できます',
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 14),
          const _HeardCard(),
          const SizedBox(height: 18),
          Text('伝えたい文章の候補', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 3),
          const Text(
            '候補は参考です。選んだあとに内容を確認できます。',
            style: TextStyle(color: mutedInk),
          ),
          const SizedBox(height: 14),
          _SuggestionCard(
            text: '昨日から頭が痛いです',
            reason: '直前の会話を参考',
            recommended: true,
            onSelect: confirm,
          ),
          const SizedBox(height: 14),
          _SuggestionCard(
            text: '前回より少し良くなりました',
            reason: '以前の会話を参考',
            onSelect: confirm,
          ),
          const SizedBox(height: 14),
          _SuggestionCard(
            text: '少し考える時間をください',
            reason: '過去によく使用',
            onSelect: confirm,
          ),
          const SizedBox(height: 18),
          Text('すぐに伝える', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                AssistPill('うまく話せません'),
                SizedBox(width: 8),
                AssistPill('少し待ってください'),
                SizedBox(width: 8),
                AssistPill('文字で伝えます'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const CompactAction(icon: Icons.refresh, label: '聞き直す'),
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
      ),
    );
  }
}

class _HeardCard extends StatelessWidget {
  const _HeardCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, size: 22, color: rose700),
                const SizedBox(width: 8),
                Text('相手の発言', style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                '「今日は体調はいかがですか？」',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () {}, child: const Text('聞き直す')),
                TextButton(onPressed: () {}, child: const Text('修正する')),
                TextButton(onPressed: () {}, child: const Text('無視する')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.text,
    required this.reason,
    required this.onSelect,
    this.recommended = false,
  });

  final String text;
  final String reason;
  final VoidCallback onSelect;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: warmWhite,
      elevation: recommended ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: recommended ? rose700 : outline,
          width: recommended ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recommended) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: rose050,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'おすすめ',
                    style: TextStyle(
                      color: rose700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(text, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(color: mutedInk),
                    ),
                  ),
                  SmallIconAction(
                    icon: Icons.volume_up_outlined,
                    label: '読む',
                    onTap: () => SpeechService.speak(text),
                  ),
                  const SmallIconAction(icon: Icons.edit_outlined, label: '編集'),
                  const SmallIconAction(icon: Icons.star_border, label: '保存'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
              onPressed: () => SpeechService.speak(controller.text),
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
