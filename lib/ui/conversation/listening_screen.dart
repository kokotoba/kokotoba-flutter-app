import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/conversation/components/conversation_components.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

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
              const SoundBars(),
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
