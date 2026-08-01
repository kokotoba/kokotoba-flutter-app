import 'package:flutter/material.dart';

class KeyInputScreen extends StatefulWidget {
  const KeyInputScreen({super.key});

  @override
  State<KeyInputScreen> createState() => _KeyInputScreenState();
}

class _KeyInputScreenState extends State<KeyInputScreen> {
  // ★追加：入力欄の文字を操作・管理するためのコントローラー
  final TextEditingController _textController = TextEditingController();

  // ダミーデータと状態管理
  int _selectedTabIndex = 0;
  final List<String> _tabs = ["よく使う単語", "過去の文章", "お気に入り"];
  final List<String> _dummyWords = ["はい", "いいえ", "お願いします", "大丈夫です", "痛いです", "分かりません"];

  // 色の定義
  final Color kokotobaRed = const Color(0xFFAD5E58);
  final Color kokotobaLightRed = const Color(0xFFF9EAE9);
  final Color bgColor = const Color(0xFFFAFAFA);

  @override
  void dispose() {
    // ★追加：画面が閉じられる時にコントローラーを破棄する（メモリ漏れを防ぐため）
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            // 戻る処理
          },
        ),
        title: const Text(
          "自分で文章を作る",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                "下から言葉を選ぶか、キーボードで入力してください",
                style: TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),

            // キーボード入力欄
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController, // ★追加：コントローラーを連携
                decoration: const InputDecoration(
                  hintText: "キーボードで入力",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // タブ部分
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTabIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kokotobaLightRed : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isSelected ? kokotobaRed : Colors.grey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // よく使う単語のボタン群
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: _dummyWords.map((word) {
                    // ★追加：ボタンを押せるように GestureDetector で囲む
                    return GestureDetector(
                      onTap: () {
                        // 現在の文字と、押された単語を合体させる
                        final currentText = _textController.text;
                        final newText = currentText + word;

                        // 入力欄に合体させた文字をセットし、カーソルを一番後ろに移動させる
                        _textController.value = TextEditingValue(
                          text: newText,
                          selection: TextSelection.collapsed(offset: newText.length),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          word,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 読み上げボタン
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // 読み上げ処理のダミー
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kokotobaRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "音声で読み上げる",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}