import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/core/auth/auth_service.dart';
import 'package:kokotoba_flutter_app/ui/theme/color.dart';

enum AuthMode { signIn, register }

enum _SocialProvider { google, apple }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  var mode = AuthMode.signIn;
  var obscurePassword = true;
  var submitting = false;
  _SocialProvider? activeSocialProvider;
  String? errorMessage;

  @override
  void dispose() {
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.dispose();
  }

  void changeMode(AuthMode value) {
    if (submitting || value == mode) return;
    setState(() {
      mode = value;
      errorMessage = null;
    });
    formKey.currentState?.reset();
  }

  Future<void> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() {
      submitting = true;
      activeSocialProvider = null;
      errorMessage = null;
    });

    try {
      if (mode == AuthMode.signIn) {
        await widget.authService.signIn(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        await widget.authService.createAccount(
          displayName: displayNameController.text,
          email: emailController.text,
          password: passwordController.text,
        );
      }
    } on AuthFailure catch (error) {
      if (mounted) setState(() => errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => errorMessage = const AuthFailure('unknown').message);
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  Future<void> submitSocial(_SocialProvider provider) async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      submitting = true;
      activeSocialProvider = provider;
      errorMessage = null;
    });

    try {
      switch (provider) {
        case _SocialProvider.google:
          await widget.authService.signInWithGoogle();
        case _SocialProvider.apple:
          await widget.authService.signInWithApple();
      }
    } on AuthCancelled {
      // Closing the provider's account picker is not an authentication error.
    } on AuthFailure catch (error) {
      if (mounted) setState(() => errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => errorMessage = const AuthFailure('unknown').message);
      }
    } finally {
      if (mounted) {
        setState(() {
          submitting = false;
          activeSocialProvider = null;
        });
      }
    }
  }

  Future<void> openPasswordReset() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _PasswordResetSheet(
        authService: widget.authService,
        initialEmail: emailController.text,
      ),
    );
    if (sent == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('パスワード再設定メールを送信しました。')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRegistering = mode == AuthMode.register;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ココトバ',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isRegistering ? 'アカウントを作成して始めます' : 'アカウントにログインします',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: mutedInk),
                      ),
                      const SizedBox(height: 28),
                      _SocialSignInButton(
                        label: 'Googleで続ける',
                        icon: const _GoogleMark(),
                        loading: activeSocialProvider == _SocialProvider.google,
                        onPressed: submitting
                            ? null
                            : () => submitSocial(_SocialProvider.google),
                      ),
                      const SizedBox(height: 12),
                      _SocialSignInButton(
                        label: 'Appleで続ける',
                        icon: const Icon(Icons.apple, size: 25),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        loading: activeSocialProvider == _SocialProvider.apple,
                        onPressed: submitting
                            ? null
                            : () => submitSocial(_SocialProvider.apple),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 14),
                        _AuthError(message: errorMessage!),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 22),
                        child: Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'またはメールアドレスで',
                                style: TextStyle(color: mutedInk, fontSize: 13),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                      ),
                      SegmentedButton<AuthMode>(
                        segments: const [
                          ButtonSegment(
                            value: AuthMode.signIn,
                            icon: Icon(Icons.login),
                            label: Text('ログイン'),
                          ),
                          ButtonSegment(
                            value: AuthMode.register,
                            icon: Icon(Icons.person_add_alt_1),
                            label: Text('新規登録'),
                          ),
                        ],
                        selected: {mode},
                        onSelectionChanged: (selection) =>
                            changeMode(selection.first),
                        showSelectedIcon: false,
                      ),
                      const SizedBox(height: 24),
                      if (isRegistering) ...[
                        TextFormField(
                          controller: displayNameController,
                          enabled: !submitting,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          decoration: const InputDecoration(
                            labelText: '表示名',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final name = value?.trim() ?? '';
                            if (name.isEmpty) return '表示名を入力してください。';
                            if (name.length > 50) return '表示名は50文字以内で入力してください。';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                      ],
                      TextFormField(
                        controller: emailController,
                        enabled: !submitting,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'メールアドレス',
                          prefixIcon: Icon(Icons.mail_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'メールアドレスを入力してください。';
                          if (!email.contains('@') || !email.contains('.')) {
                            return '正しいメールアドレスを入力してください。';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: passwordController,
                        enabled: !submitting,
                        obscureText: obscurePassword,
                        textInputAction: isRegistering
                            ? TextInputAction.next
                            : TextInputAction.done,
                        autofillHints: [
                          isRegistering
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        onFieldSubmitted: (_) {
                          if (!isRegistering) submit();
                        },
                        decoration: InputDecoration(
                          labelText: 'パスワード',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: obscurePassword ? 'パスワードを表示' : 'パスワードを隠す',
                            onPressed: submitting
                                ? null
                                : () => setState(
                                    () => obscurePassword = !obscurePassword,
                                  ),
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if ((value ?? '').isEmpty) return 'パスワードを入力してください。';
                          if (isRegistering && value!.length < 6) {
                            return 'パスワードは6文字以上で入力してください。';
                          }
                          return null;
                        },
                      ),
                      if (isRegistering) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: passwordConfirmationController,
                          enabled: !submitting,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onFieldSubmitted: (_) => submit(),
                          decoration: const InputDecoration(
                            labelText: 'パスワード（確認）',
                            prefixIcon: Icon(Icons.lock_reset),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value != passwordController.text) {
                              return 'パスワードが一致しません。';
                            }
                            return null;
                          },
                        ),
                      ],
                      if (!isRegistering)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: submitting ? null : openPasswordReset,
                            child: const Text('パスワードを忘れた方'),
                          ),
                        )
                      else
                        const SizedBox(height: 22),
                      SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: submitting ? null : submit,
                          icon: submitting
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  isRegistering
                                      ? Icons.person_add_alt_1
                                      : Icons.login,
                                ),
                          label: Text(isRegistering ? 'アカウントを作成' : 'ログイン'),
                        ),
                      ),
                      if (isRegistering) ...[
                        const SizedBox(height: 14),
                        const Text(
                          '登録後、確認メールを送信します。メール内のリンクから確認を完了してください。',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: mutedInk, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  const _SocialSignInButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
    this.foregroundColor = ink,
    this.backgroundColor = Colors.white,
  });

  final String label;
  final Widget icon;
  final bool loading;
  final VoidCallback? onPressed;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(
            color: backgroundColor == Colors.black ? Colors.black : outline,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: loading
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: foregroundColor,
                ),
              )
            : icon,
        label: Text(label),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 20,
      child: Image.asset(
        'assets/images/google_g_logo.png',
        key: const ValueKey('google-logo'),
        fit: BoxFit.contain,
        semanticLabel: 'Google',
      ),
    );
  }
}

class _AuthError extends StatelessWidget {
  const _AuthError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _PasswordResetSheet extends StatefulWidget {
  const _PasswordResetSheet({
    required this.authService,
    required this.initialEmail,
  });

  final AuthService authService;
  final String initialEmail;

  @override
  State<_PasswordResetSheet> createState() => _PasswordResetSheetState();
}

class _PasswordResetSheetState extends State<_PasswordResetSheet> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  var submitting = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() {
      submitting = true;
      errorMessage = null;
    });
    try {
      await widget.authService.sendPasswordResetEmail(emailController.text);
      if (mounted) Navigator.pop(context, true);
    } on AuthFailure catch (error) {
      if (mounted) setState(() => errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => errorMessage = const AuthFailure('unknown').message);
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        22,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'パスワードを再設定',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: '閉じる',
                  onPressed: submitting ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '登録済みのメールアドレスへ再設定用リンクを送ります。',
              style: TextStyle(color: mutedInk),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              autofocus: true,
              enabled: !submitting,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => submit(),
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                prefixIcon: Icon(Icons.mail_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty ||
                    !email.contains('@') ||
                    !email.contains('.')) {
                  return '正しいメールアドレスを入力してください。';
                }
                return null;
              },
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              _AuthError(message: errorMessage!),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: submitting ? null : submit,
                icon: const Icon(Icons.send_outlined),
                label: const Text('再設定メールを送信'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
