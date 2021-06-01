import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive'
  ],
);

class AuthManager {
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      print('account: ${account?.toString()}');
      return account;
    } catch (error) {
      print(error);
      return null;
    }
  }

  static Future<GoogleSignInAccount?> signInSilently() async {
    var account = await _googleSignIn.signInSilently();
    print("silent sign in");
    if(account == null) {
      print("silent sign in failed");
      account = await signIn();
    }
    return account;
  }

  static Future<void> signOut() async {
    try {
      _googleSignIn.signOut();
    } catch (error) {
      print(error);
    }
  }
}