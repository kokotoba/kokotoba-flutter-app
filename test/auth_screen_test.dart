import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kokotoba_flutter_app/core/auth/auth_service.dart';
import 'package:kokotoba_flutter_app/ui/auth/auth_gate.dart';
import 'package:kokotoba_flutter_app/ui/auth/login_screen.dart';
import 'package:kokotoba_flutter_app/ui/theme/theme.dart';

import 'support/fake_auth_service.dart';

void main() {
  Widget app(Widget home) {
    return MaterialApp(theme: kokotobaTheme(), home: home);
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  testWidgets('未ログインならログイン画面を表示して認証情報を送信する', (tester) async {
    final auth = FakeAuthService();
    addTearDown(auth.dispose);

    await tester.pumpWidget(app(AuthGate(authService: auth)));
    await tester.pumpAndSettle();

    expect(find.text('ココトバ'), findsOneWidget);
    expect(find.text('こ'), findsNothing);
    expect(find.text('アカウントにログインします'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'メールアドレス'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'パスワード'),
      'password',
    );
    await tapVisible(tester, find.widgetWithText(FilledButton, 'ログイン'));
    await tester.pump();

    expect(auth.signedInEmail, 'user@example.com');
    expect(auth.signedInPassword, 'password');
  });

  testWidgets('GoogleとAppleのSSOを開始できる', (tester) async {
    final auth = FakeAuthService();
    addTearDown(auth.dispose);

    await tester.pumpWidget(app(LoginScreen(authService: auth)));

    await tester.tap(find.widgetWithText(OutlinedButton, 'Googleで続ける'));
    await tester.pump();
    expect(auth.googleSignInCount, 1);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Appleで続ける'));
    await tester.pump();
    expect(auth.appleSignInCount, 1);
  });

  testWidgets('新規登録では表示名と確認用パスワードを検証する', (tester) async {
    final auth = FakeAuthService();
    addTearDown(auth.dispose);

    await tester.pumpWidget(app(LoginScreen(authService: auth)));
    await tester.tap(find.text('新規登録'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, '表示名'), '山田 花子');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'メールアドレス'),
      'hanako@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'パスワード'),
      'password',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'パスワード（確認）'),
      'password',
    );
    await tapVisible(tester, find.widgetWithText(FilledButton, 'アカウントを作成'));
    await tester.pump();

    expect(auth.createdDisplayName, '山田 花子');
    expect(auth.createdEmail, 'hanako@example.com');
    expect(auth.createdPassword, 'password');
  });

  testWidgets('Firebase認証エラーを日本語で表示する', (tester) async {
    final auth = FakeAuthService()
      ..failure = const AuthFailure('invalid-credential');
    addTearDown(auth.dispose);

    await tester.pumpWidget(app(LoginScreen(authService: auth)));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'メールアドレス'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'パスワード'),
      'incorrect',
    );
    await tapVisible(tester, find.widgetWithText(FilledButton, 'ログイン'));
    await tester.pump();

    expect(find.text('メールアドレスまたはパスワードが正しくありません。'), findsOneWidget);
  });

  testWidgets('パスワード再設定メールを送信する', (tester) async {
    final auth = FakeAuthService();
    addTearDown(auth.dispose);

    await tester.pumpWidget(app(LoginScreen(authService: auth)));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'メールアドレス'),
      'user@example.com',
    );
    await tapVisible(tester, find.text('パスワードを忘れた方'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '再設定メールを送信'));
    await tester.pumpAndSettle();

    expect(auth.resetEmail, 'user@example.com');
    expect(find.text('パスワード再設定メールを送信しました。'), findsOneWidget);
  });

  testWidgets('認証済みならホーム画面を表示する', (tester) async {
    final auth = FakeAuthService(
      user: const AuthUser(
        uid: 'firebase-uid',
        email: 'user@example.com',
        displayName: 'テストユーザー',
        emailVerified: true,
      ),
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(app(AuthGate(authService: auth)));
    await tester.pumpAndSettle();

    expect(find.text('会話をはじめる'), findsOneWidget);
    expect(find.text('アカウントにログインします'), findsNothing);
  });

  testWidgets('設定画面からログアウトしてログイン画面へ戻る', (tester) async {
    final auth = FakeAuthService(
      user: const AuthUser(
        uid: 'firebase-uid',
        email: 'user@example.com',
        displayName: 'テストユーザー',
        emailVerified: true,
      ),
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(app(AuthGate(authService: auth)));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined).last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'ログアウト'));
    await tester.pumpAndSettle();

    expect(auth.signOutCount, 1);
    expect(find.text('アカウントにログインします'), findsOneWidget);
  });
}
