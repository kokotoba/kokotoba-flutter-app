import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kokotoba_flutter_app/core/controller/kokotoba_controllers.dart';
import 'package:kokotoba_flutter_app/main.dart';

void main() {
  testWidgets('ホームから主要画面へ移動できる', (tester) async {
    await tester.pumpWidget(
      KokotobaApplication(controllers: KokotobaControllers.mock()),
    );

    expect(find.text('ココトバ'), findsNothing);
    expect(find.text('あなたの言葉を、いっしょに。'), findsNothing);
    expect(find.text('会話を開始できます'), findsNothing);
    expect(find.text('プライバシーを大切にします'), findsNothing);
    expect(find.text('会話をはじめる'), findsOneWidget);

    await tester.tap(find.text('会話をはじめる'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('聞き取りを始める'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('聞き取りを始める'), findsOneWidget);

    await tester.tap(find.text('聞き取りを始める'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('聞き取りを停止'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('聞き取りを停止'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('文字で入力する'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('文字で入力する'));
    await tester.pumpAndSettle();
    expect(find.text('文字から伝える'), findsOneWidget);
  });

  testWidgets('ボトムナビゲーションで設定を開ける', (tester) async {
    await tester.pumpWidget(
      KokotobaApplication(controllers: KokotobaControllers.mock()),
    );

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
