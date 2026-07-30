import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  var selected = 1;

  @override
  Widget build(BuildContext context) {
    const labels = ['標準', '大きい', 'とても大きい'];
    const sizes = [16.0, 20.0, 24.0];
    return PageLayout(
      title: 'はじめの設定',
      subtitle: '1 / 8',
      onBack: widget.onBack,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const LinearProgressIndicator(value: .125),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '文字の大きさを選ぶ',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 6, bottom: 22),
                    child: Text(
                      'あとから設定で変更できます。',
                      style: TextStyle(color: mutedInk),
                    ),
                  ),
                  for (var i = 0; i < labels.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        color: i == selected ? rose050 : warmWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: i == selected ? rose700 : outline,
                            width: i == selected ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => setState(() => selected = i),
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Text(
                                '伝えたい言葉  —  ${labels[i]}',
                                style: TextStyle(
                                  fontSize: sizes[i],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton(
                      onPressed: () {
                        showMessage(context, '「${labels[selected]}」に設定しました');
                        widget.onBack();
                      },
                      child: const Text('次へ'),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: widget.onBack,
                      child: const Text('あとで設定する'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
