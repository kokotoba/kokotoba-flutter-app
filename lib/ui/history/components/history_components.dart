import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/model/conversation_history.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.history});

  final ConversationHistory history;

  @override
  Widget build(BuildContext context) {
    final partner = history.latestPartnerUtterance;
    final user = history.latestUserUtterance;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDateTime(history.startedAt),
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: rose700),
            ),
            if (history.active)
              const Text(
                '進行中のセッション',
                style: TextStyle(color: mutedInk, fontSize: 13),
              ),
            const SizedBox(height: 8),
            _UtterancePreview(
              label: '相手',
              text: partner?.text ?? '相手の発言はまだありません',
              color: mutedInk,
            ),
            const SizedBox(height: 6),
            _UtterancePreview(
              label: '自分',
              text: user?.text ?? '自分の発言はまだありません',
              color: rose700,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showHistoryDetail(context, history),
                child: const Text('詳細を見る  ›'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UtterancePreview extends StatelessWidget {
  const _UtterancePreview({
    required this.label,
    required this.text,
    required this.color,
  });

  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 42,
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

Future<void> _showHistoryDetail(
  BuildContext context,
  ConversationHistory history,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.78,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('会話の詳細', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                _formatDateTime(history.startedAt),
                style: const TextStyle(color: mutedInk),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: history.utterances.isEmpty
                    ? const Center(child: Text('発言はまだありません'))
                    : ListView.separated(
                        itemCount: history.utterances.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _UtteranceBubble(
                          utterance: history.utterances[index],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _UtteranceBubble extends StatelessWidget {
  const _UtteranceBubble({required this.utterance});

  final ConversationUtterance utterance;

  @override
  Widget build(BuildContext context) {
    final isUser = utterance.speaker == ConversationSpeaker.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isUser ? rose050 : softSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUser ? '自分' : '相手',
                style: TextStyle(
                  color: isUser ? rose700 : mutedInk,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(utterance.text),
              const SizedBox(height: 4),
              Text(
                _formatTime(utterance.spokenAt),
                style: const TextStyle(color: mutedInk, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final now = DateTime.now();
  final sameDay =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  final date = sameDay ? '今日' : '${local.month}月${local.day}日';
  return '$date ${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}

String _formatTime(DateTime value) {
  final local = value.toLocal();
  return '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
