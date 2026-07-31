import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/controller/conversation_history_controller.dart';
import 'package:kokotoba_flutter_app/core/model/conversation_history.dart';
import 'package:kokotoba_flutter_app/ui/common/components/delayed_loading_indicator.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/history/components/history_components.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.controller});

  final ConversationHistoryController controller;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '会話の履歴',
      subtitle: '新しい順',
      child: FutureBuilder<List<ConversationHistory>>(
        future: controller.fetchConversationHistories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const DelayedLoadingIndicator();
          }
          if (snapshot.hasError) {
            return const Center(child: Text('会話履歴を読み込めませんでした'));
          }
          final histories = snapshot.data ?? const <ConversationHistory>[];
          return ListView.separated(
            itemCount: histories.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              if (index == 0) return const PrivacyNotice();
              return HistoryCard(history: histories[index - 1]);
            },
          );
        },
      ),
    );
  }
}
