# kokotoba-flutter-app

ココトバは、会話で言葉を伝えることが難しい場面を支援するFlutterアプリです。
同階層の `kokotoba-android-app` にあるJetpack Compose実装を、AndroidとiOSで
動作するFlutterアプリへ移植しています。

## 実行

```shell
flutter pub get
flutter run
```

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
