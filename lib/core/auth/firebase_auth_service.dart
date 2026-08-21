import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:kokotoba_flutter_app/core/auth/auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({firebase.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance;

  final firebase.FirebaseAuth _firebaseAuth;
  static Future<void>? _googleInitialization;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.userChanges().map(_toAuthUser);
  }

  @override
  AuthUser? get currentUser => _toAuthUser(_firebaseAuth.currentUser);

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(error.code);
    }
  }

  @override
  Future<void> createAccount({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthFailure('unknown');

      await user.updateDisplayName(displayName.trim());
      await user.sendEmailVerification();
      await user.getIdToken(true);
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(error.code);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuthentication = googleUser.authentication;
      final idToken = googleAuthentication.idToken;
      if (idToken == null) throw const AuthFailure('google-sign-in-failed');

      final credential = firebase.GoogleAuthProvider.credential(
        idToken: idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        throw const AuthCancelled();
      }
      if (error.code == GoogleSignInExceptionCode.clientConfigurationError ||
          error.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw const AuthFailure('google-configuration-error');
      }
      throw const AuthFailure('google-sign-in-failed');
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(error.code);
    }
  }

  @override
  Future<void> signInWithApple() async {
    try {
      final provider = firebase.AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      await _firebaseAuth.signInWithProvider(provider);
    } on firebase.FirebaseAuthException catch (error) {
      if (error.code == 'web-context-canceled' ||
          error.code == 'canceled' ||
          error.code == 'user-cancelled') {
        throw const AuthCancelled();
      }
      throw AuthFailure(
        error.code == 'unknown' ? 'apple-sign-in-failed' : error.code,
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(error.code);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthFailure('user-not-found');
      if (!user.emailVerified) await user.sendEmailVerification();
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(error.code);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (_googleInitialization != null) {
      try {
        await _googleInitialization;
        await GoogleSignIn.instance.signOut();
      } on GoogleSignInException {
        // Firebase sign-out already succeeded; stale Google state is non-fatal.
      }
    }
  }

  Future<void> _ensureGoogleInitialized() {
    return _googleInitialization ??= GoogleSignIn.instance.initialize();
  }

  AuthUser? _toAuthUser(firebase.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      emailVerified: user.emailVerified,
    );
  }
}
