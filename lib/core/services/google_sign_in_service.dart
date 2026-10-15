import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';

///* Result of a successful interactive Google sign-in.
// Holds the Google ID token the backend must exchange for app tokens,
// plus the basic profile fields for UI use.
class GoogleSignInResult {
  const GoogleSignInResult({
    required this.idToken,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String idToken;
  final String email;
  final String? displayName;
  final String? photoUrl;
}

///* High-level Google sign-in service wrapping `google_sign_in` + `firebase_auth`.
// The service only authenticates the user with Google/Firebase and returns
// the Google ID token. Exchanging that token for backend app tokens is the
// responsibility of the auth repository (see `AuthRepository.loginWithGoogle`).
class GoogleSignInService {
  GoogleSignInService({
    GoogleSignIn? googleSignIn,
    FirebaseAuth? firebaseAuth,
  }) {
    _googleSignIn = googleSignIn;
    _firebaseAuth = firebaseAuth;
  }

  GoogleSignIn? _googleSignIn;
  FirebaseAuth? _firebaseAuth;

  GoogleSignIn get _google => _googleSignIn ??= GoogleSignIn();
  FirebaseAuth get _auth => _firebaseAuth ??= FirebaseAuth.instance;

  //! ===== Interactive sign-in =====
  // --- Returns null when the user cancels; throws otherwise ---
  Future<GoogleSignInResult?> signInWithGoogle() async {
    late final GoogleSignInAccount? account;
    try {
      account = await _google.signIn().timeout(
        const Duration(seconds: 60),
      );
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      // --- User dismissal is a normal outcome, not an error ---
      if (code.contains('cancel')) return null;
      if (code.contains('network')) throw OfflineException();
      throw ServerException(
        errorModel: ErrorModel(
          statusCode: 0,
          errorMessage: e.message ?? 'Google sign-in failed',
        ),
      );
    }

    // --- Null account means the user dismissed the picker ---
    if (account == null) return null;

    final GoogleSignInAuthentication googleAuth;
    try {
      googleAuth = await account.authentication.timeout(
        const Duration(seconds: 30),
      );
    } on PlatformException catch (e) {
      await _google.signOut();
      throw ServerException(
        errorModel: ErrorModel(
          statusCode: 0,
          errorMessage: e.message ?? 'Google sign-in failed',
        ),
      );
    }

    final String? idToken = googleAuth.idToken;
    if (idToken == null || idToken.isEmpty) {
      await _google.signOut();
      throw ServerException(
        errorModel: const ErrorModel(
          statusCode: 0,
          errorMessage:
              'Google sign-in did not return an ID token. Please try again',
        ),
      );
    }

    try {
      await _auth
          .signInWithCredential(
            GoogleAuthProvider.credential(
              idToken: idToken,
              accessToken: googleAuth.accessToken,
            ),
          )
          .timeout(const Duration(seconds: 30));
    } on FirebaseAuthException catch (e) {
      await _google.signOut();
      if (e.code == 'network-request-failed') throw OfflineException();
      throw ServerException(
        errorModel: ErrorModel(
          statusCode: 0,
          errorMessage: e.message ?? 'Google sign-in failed',
        ),
      );
    }

    return GoogleSignInResult(
      idToken: idToken,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
    );
  }

  //! ===== Sign-out =====
  // --- Clears both the Google session and the Firebase session ---
  Future<void> signOut() async {
    try {
      await _google.signOut();
    } finally {
      await _auth.signOut();
    }
  }
}
