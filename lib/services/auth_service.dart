import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Sign In with Google
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        // Save user info locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', account.displayName ?? '');
        await prefs.setString('user_email', account.email);
        await prefs.setString('user_photo', account.photoUrl ?? '');
        await prefs.setBool('is_logged_in', true);
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

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Get current user info
  Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
      'photo': prefs.getString('user_photo') ?? '',
    };
  }
}