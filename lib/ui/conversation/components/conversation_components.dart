import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/util/speech_util.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

class SoundBars extends StatelessWidget {
  const SoundBars({super.key});

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

class HeardCard extends StatelessWidget {
  const HeardCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '「$text」',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    required this.text,
    required this.onSelect,
    this.recommended = false,
  });

  final String text;
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
                    child: _SuggestionAction(
                      icon: Icons.volume_up_outlined,
                      label: '読む',
                      onTap: () => SpeechUtil.speak(text),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: _SuggestionAction(
                      icon: Icons.edit_outlined,
                      label: '編集',
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: _SuggestionAction(
                      icon: Icons.star_border,
                      label: '保存',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionAction extends StatelessWidget {
  const _SuggestionAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextButton.icon(
        onPressed: onTap ?? () {},
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          foregroundColor: rose700,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
