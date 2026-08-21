import 'dart:async';

import 'package:kokotoba_flutter_app/core/auth/auth_service.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.user});

  final controller = StreamController<AuthUser?>.broadcast();
  AuthUser? user;
  String? signedInEmail;
  String? signedInPassword;
  String? createdDisplayName;
  String? createdEmail;
  String? createdPassword;
  String? resetEmail;
  var signOutCount = 0;
  var verificationCount = 0;
  var googleSignInCount = 0;
  var appleSignInCount = 0;
  AuthFailure? failure;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield user;
    yield* controller.stream;
  }

  @override
  AuthUser? get currentUser => user;

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (failure case final error?) throw error;
    signedInEmail = email;
    signedInPassword = password;
  }

  @override
  Future<void> createAccount({
    required String displayName,
    required String email,
    required String password,
  }) async {
    if (failure case final error?) throw error;
    createdDisplayName = displayName;
    createdEmail = email;
    createdPassword = password;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (failure case final error?) throw error;
    resetEmail = email;
  }

  @override
  Future<void> signInWithGoogle() async {
    if (failure case final error?) throw error;
    googleSignInCount += 1;
  }

  @override
  Future<void> signInWithApple() async {
    if (failure case final error?) throw error;
    appleSignInCount += 1;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (failure case final error?) throw error;
    verificationCount += 1;
  }

  @override
  Future<void> signOut() async {
    if (failure case final error?) throw error;
    signOutCount += 1;
    user = null;
    controller.add(null);
  }

  Future<void> dispose() => controller.close();
}
