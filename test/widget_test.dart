import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kokotoba_flutter_app/main.dart';

void main() {
  testWidgets('ホームから主要画面へ移動できる', (tester) async {
    await tester.pumpWidget(const KokotobaApplication());

    expect(find.text('ココトバ'), findsNothing);
    expect(find.text('あなたの言葉を、いっしょに。'), findsNothing);
    expect(find.text('会話を開始できます'), findsNothing);
    expect(find.text('プライバシーを大切にします'), findsNothing);
    expect(find.text('会話をはじめる'), findsOneWidget);

    await tester.tap(find.text('会話をはじめる'));
    await tester.pumpAndSettle();
    expect(find.text('聞き取り中'), findsOneWidget);

    await tester.tap(find.text('認識結果のUIを見る'));
    await tester.pumpAndSettle();
    expect(find.text('伝えたい文章の候補'), findsOneWidget);
  });

  testWidgets('ボトムナビゲーションで設定を開ける', (tester) async {
    await tester.pumpWidget(const KokotobaApplication());

    await tester.tap(find.byIcon(Icons.settings_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text('使いやすさを調整'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('プライバシー'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('プライバシー'), findsOneWidget);
  });
}
