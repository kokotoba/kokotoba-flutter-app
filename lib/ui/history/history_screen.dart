import 'package:flutter/material.dart';

import '../common/components/kokotoba_components.dart';
import 'components/history_components.dart';

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
          return HistoryCard(row: rows[index - 1]);
        },
      ),
    );
  }
}
