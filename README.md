# kokotoba-flutter-app

ココトバは、会話で言葉を伝えることが難しい場面を支援するFlutterアプリです。
同階層の `kokotoba-android-app` にあるJetpack Compose実装を、AndroidとiOSで
動作するFlutterアプリへ移植しています。

## 実行

```shell
flutter pub get
flutter run
```

設定画面は `kokotoba-backend` のユーザーID `1` から取得します。先に
`kokotoba-infra` と `kokotoba-backend` を起動してください。
表示・音声設定の選択と各スイッチの変更は、バックエンドのPATCH APIを通じて
`user_settings` テーブルへ保存されます。
よく使う文章もユーザーID `1` に紐づけて取得・追加・削除し、
`frequent_phrases` テーブルへ保存されます。
カード左端のハンドルを長押ししてドラッグすると表示順を変更でき、
変更した順序はバックエンドに保存されます。

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

音声認識とLiteRT-LMによる候補生成は、移植元の画面からもまだ接続されていないため、
現在は移植元と同じサンプル内容を表示します。
