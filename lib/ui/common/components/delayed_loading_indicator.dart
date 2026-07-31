import 'dart:async';

import 'package:flutter/material.dart';

/// 短時間で完了するデータ取得では表示せず、長引いた場合だけ表示する。
class DelayedLoadingIndicator extends StatefulWidget {
  const DelayedLoadingIndicator({
    super.key,
    this.delay = const Duration(milliseconds: 250),
  });

  final Duration delay;

  @override
  State<DelayedLoadingIndicator> createState() =>
      _DelayedLoadingIndicatorState();
}

class _DelayedLoadingIndicatorState extends State<DelayedLoadingIndicator> {
  Timer? timer;
  var visible = false;

  @override
  void initState() {
    super.initState();
    timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() => visible = true);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return const Center(child: CircularProgressIndicator());
  }
}
