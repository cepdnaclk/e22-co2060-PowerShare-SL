import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ✅ FIX: Google Sign-In → Backend JWT save
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null;

      // Google ID token ලබා ගැනීම
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      // SharedPreferences-ට user info save
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', account.displayName ?? '');
      await prefs.setString('user_email', account.email);
      await prefs.setString('user_photo', account.photoUrl ?? '');
      await prefs.setBool('is_logged_in', true);

      // ✅ Backend-ට send කර JWT token ලබා ගැනීම
      final success = await ApiService.loginWithGoogle(
        googleId: account.id,
        name: account.displayName ?? '',
        email: account.email,
        photo: account.photoUrl,
        idToken: idToken ?? '',
      );

      if (!success) {
        // Backend fail වුනත් Google login continue කරන්න
        // (offline mode fallback)
        debugPrint('⚠️ Backend login failed, continuing with local session');
      }

      return account;
    } catch (e) {
      debugPrint('Sign In Error: $e');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Login state check
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // User info
  Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
      'photo': prefs.getString('user_photo') ?? '',
    };
  }
}
