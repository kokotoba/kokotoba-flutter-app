import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/auth/auth_service.dart';
import 'package:kokotoba_flutter_app/core/controller/settings_controller.dart';
import 'package:kokotoba_flutter_app/core/model/kokotoba_settings.dart';
import 'package:kokotoba_flutter_app/ui/common/components/delayed_loading_indicator.dart';
import 'package:kokotoba_flutter_app/ui/common/components/kokotoba_components.dart';
import 'package:kokotoba_flutter_app/ui/settings/components/settings_components.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    this.authUser,
    this.onSignOut,
    this.onSendEmailVerification,
  });

  final SettingsController controller;
  final AuthUser? authUser;
  final Future<void> Function()? onSignOut;
  final Future<void> Function()? onSendEmailVerification;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<KokotobaSettings> settingsFuture;
  final toggles = <String, bool>{};
  var signingOut = false;
  var sendingVerification = false;

  @override
  void initState() {
    super.initState();
    settingsFuture = widget.controller.fetchSettings();
  }

  void _setInitialToggles(KokotobaSettings settings) {
    if (toggles.isNotEmpty) return;
    for (final toggle in [
      ...settings.supportToggles,
      ...settings.privacyToggles,
    ]) {
      toggles[toggle.label] = toggle.enabled;
    }
  }

  Future<void> _signOut() async {
    if (widget.onSignOut == null || signingOut) return;
    setState(() => signingOut = true);
    try {
      await widget.onSignOut!();
    } catch (_) {
      if (mounted) showMessage(context, 'ログアウトできませんでした。');
    } finally {
      if (mounted) setState(() => signingOut = false);
    }
  }

  Future<void> _sendVerification() async {
    if (widget.onSendEmailVerification == null || sendingVerification) return;
    setState(() => sendingVerification = true);
    try {
      await widget.onSendEmailVerification!();
      if (mounted) showMessage(context, '確認メールを送信しました。');
    } on AuthFailure catch (error) {
      if (mounted) showMessage(context, error.message);
    } catch (_) {
      if (mounted) showMessage(context, '確認メールを送信できませんでした。');
    } finally {
      if (mounted) setState(() => sendingVerification = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '設定',
      subtitle: '使いやすさを調整',
      child: FutureBuilder<KokotobaSettings>(
        future: settingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const DelayedLoadingIndicator();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('設定を読み込めませんでした'));
          }

          final settings = snapshot.data!;
          _setInitialToggles(settings);
          return ListView(
            children: [
              if (widget.authUser != null) ...[
                _AccountSection(
                  user: widget.authUser!,
                  signingOut: signingOut,
                  sendingVerification: sendingVerification,
                  onSignOut: _signOut,
                  onSendVerification: _sendVerification,
                ),
                const SizedBox(height: 20),
              ],
              SettingsGroup(title: '表示', rows: settings.displayRows),
              const SizedBox(height: 20),
              SettingsGroup(title: '音声', rows: settings.voiceRows),
              const SizedBox(height: 20),
              ToggleGroup(
                title: '会話支援',
                labels: settings.supportToggles
                    .map((toggle) => toggle.label)
                    .toList(),
                values: toggles,
                onChanged: (key, value) => setState(() => toggles[key] = value),
              ),
              const SizedBox(height: 20),
              ToggleGroup(
                title: 'プライバシー',
                labels: settings.privacyToggles
                    .map((toggle) => toggle.label)
                    .toList(),
                values: toggles,
                onChanged: (key, value) => setState(() => toggles[key] = value),
              ),
              const SizedBox(height: 20),
              Card(
                color: rose050,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, color: rose700, size: 25),
                      SizedBox(width: 12),
                      Expanded(child: Text('音声認識と文章候補は、基本的に端末内で処理されます。')),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.user,
    required this.signingOut,
    required this.sendingVerification,
    required this.onSignOut,
    required this.onSendVerification,
  });

  final AuthUser user;
  final bool signingOut;
  final bool sendingVerification;
  final VoidCallback onSignOut;
  final VoidCallback onSendVerification;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('アカウント', style: Theme.of(context).textTheme.titleLarge),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: rose100,
                      foregroundColor: rose700,
                      child: Icon(Icons.person_outline),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (user.email != null)
                            Text(
                              user.email!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: mutedInk),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!user.emailVerified) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: rose050,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.mark_email_unread_outlined,
                          color: rose700,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(child: Text('メールアドレスが未確認です')),
                        TextButton(
                          onPressed: sendingVerification
                              ? null
                              : onSendVerification,
                          child: Text(sendingVerification ? '送信中' : '再送'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: signingOut ? null : onSignOut,
                  icon: signingOut
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout),
                  label: Text(signingOut ? 'ログアウト中' : 'ログアウト'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
