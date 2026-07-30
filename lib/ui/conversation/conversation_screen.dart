import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/conversation/components/conversation_components.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

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
          const HeardCard(),
          const SizedBox(height: 18),
          Text('伝えたい文章の候補', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 3),
          const Text(
            '候補は参考です。選んだあとに内容を確認できます。',
            style: TextStyle(color: mutedInk),
          ),
          const SizedBox(height: 14),
          SuggestionCard(
            text: '昨日から頭が痛いです',
            reason: '直前の会話を参考',
            recommended: true,
            onSelect: confirm,
          ),
          const SizedBox(height: 14),
          SuggestionCard(
            text: '前回より少し良くなりました',
            reason: '以前の会話を参考',
            onSelect: confirm,
          ),
          const SizedBox(height: 14),
          SuggestionCard(
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
