class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.emailVerified,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;

  String get label {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return email ?? 'ユーザー';
  }
}

abstract interface class AuthService {
  Stream<AuthUser?> authStateChanges();

  AuthUser? get currentUser;

  Future<void> signIn({required String email, required String password});

  Future<void> createAccount({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> signInWithApple();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<void> signOut();
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final String code;

  String get message {
    return switch (code) {
      'invalid-email' => 'メールアドレスの形式を確認してください。',
      'email-already-in-use' => 'このメールアドレスはすでに登録されています。',
      'weak-password' => 'もう少し安全なパスワードを設定してください。',
      'operation-not-allowed' => 'メールアドレスでの認証が現在利用できません。',
      'account-exists-with-different-credential' =>
        '同じメールアドレスのアカウントが別の方法で登録されています。',
      'credential-already-in-use' => 'このアカウントはすでに別のユーザーに登録されています。',
      'google-configuration-error' => 'Googleログインの設定を確認してください。',
      'google-sign-in-failed' => 'Googleアカウントでログインできませんでした。',
      'apple-sign-in-failed' => 'Apple Accountでログインできませんでした。',
      'user-disabled' => 'このアカウントは現在利用できません。',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'メールアドレスまたはパスワードが正しくありません。',
      'too-many-requests' => '試行回数が多すぎます。時間を置いてお試しください。',
      'network-request-failed' => '通信できませんでした。ネットワーク接続を確認してください。',
      'requires-recent-login' => '安全のため、もう一度ログインしてください。',
      _ => '処理を完了できませんでした。時間を置いてお試しください。',
    };
  }

  @override
  String toString() => message;
}

class AuthCancelled implements Exception {
  const AuthCancelled();
}
