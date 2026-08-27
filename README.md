# kokotoba-flutter-app

ココトバは、会話で言葉を伝えることが難しい場面を支援するFlutterアプリです。
同階層の `kokotoba-android-app` にあるJetpack Compose実装を、AndroidとiOSで
動作するFlutterアプリへ移植しています。

## 実行

```shell
flutter pub get
flutter run
```

設定画面は `kokotoba-backend` の `/api/v1/me` APIから現在のユーザーの設定を取得します。先に
`kokotoba-infra` と `kokotoba-backend` を起動してください。
表示・音声設定の選択と各スイッチの変更は、バックエンドのPATCH APIを通じて
`user_settings` テーブルへ保存されます。
よく使う文章も現在のユーザーに紐づけて取得・追加・削除し、
`frequent_phrases` テーブルへ保存されます。
カード左端のハンドルを長押ししてドラッグすると表示順を変更でき、
変更した順序はバックエンドに保存されます。
バックエンドをDev認証モードで起動した場合は、`DEV_USER_ID`のユーザーとして
Authorizationヘッダーなしでアプリをテストできます。

Flutter側もログイン画面を表示しないDev認証モードで起動してください。
バックエンドの `DEV_USER_ID`（`.env.example`ではID `1`）がテストユーザーとして
使用されます。

```shell
flutter run --dart-define=AUTH_MODE=dev
```

iOS Simulator / macOSでは既定の接続先を利用できます。

```shell
flutter run
```

Android EmulatorではホストPCを `10.0.2.2` で参照します。

```shell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

実機の場合は、ホストPCのLAN内IPアドレスを指定してください。

## 検証

```shell
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator --debug
```

## 実装済み

- ホーム、会話、聞き取り、候補選択
- 文字入力、発話内容の確認・編集
- よく使う文章、会話履歴、設定、初期設定
- Android/iOSの端末標準音声による日本語読み上げ
- Android/iOSの端末標準音声認識による日本語の聞き取り

初回の聞き取り開始時に、マイクと音声認識の利用許可が求められます。
LiteRT-LMによる文章候補生成はまだ接続されていないため、現在はサンプル候補を表示します。
