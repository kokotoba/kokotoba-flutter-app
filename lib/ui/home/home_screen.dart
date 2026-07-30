import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/home/components/home_components.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

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
              Expanded(
                child: Text(
                  'ホーム',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              RoundIconButton(
                icon: Icons.settings_outlined,
                tooltip: '初期設定',
                onPressed: openOnboarding,
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
                child: HomeAction(
                  icon: Icons.keyboard_alt_outlined,
                  title: '文字から伝える',
                  detail: '自分で入力',
                  onTap: manualInput,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HomeAction(
                  icon: Icons.copy_outlined,
                  title: 'よく使う文章',
                  detail: 'すぐに選ぶ',
                  onTap: openCards,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
