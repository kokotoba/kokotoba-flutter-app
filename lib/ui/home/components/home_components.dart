import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/model/registered_card.dart';
import 'package:kokotoba_flutter_app/core/util/speech_util.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

class HomeQuickPhraseCard extends StatelessWidget {
  const HomeQuickPhraseCard({super.key, required this.card});

  final RegisteredCard card;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => SpeechUtil.speak(card.text),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: rose050,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up_outlined, color: rose700),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  card.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.play_arrow_rounded, color: rose700),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeQuickPhraseAddCard extends StatelessWidget {
  const HomeQuickPhraseAddCard({
    super.key,
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: rose050,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: rose100),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: const SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: rose700),
              SizedBox(width: 8),
              Text(
                '文章を登録',
                style: TextStyle(color: rose700, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeAction extends StatelessWidget {
  const HomeAction({
    super.key,
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
