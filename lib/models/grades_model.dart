import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'my_client.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive'
  ],
);

class AuthManager {
  static Future<GoogleSignInAccount> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      print('account: ${account?.toString()}');
      return account;
    } catch (error) {
      print(error);
      return null;
    }
  }

  static Future<GoogleSignInAccount> signInSilently() async {
    var account = await _googleSignIn.signInSilently();
    print('account: $account');
    return account;
  }

  static Future<void> signOut() async {
    try {
      _googleSignIn.disconnect();
    } catch (error) {
      print(error);
    }
  }
}

class SheetSelectorModel extends ChangeNotifier {
  GoogleSignInAccount _currentUser;
  List<File> _items = [];

  SheetSelectorModel() : _currentUser = null;

  UnmodifiableListView<File> get sheetList => UnmodifiableListView(_items);

  Future<void> signInSilently(BuildContext context) async {
    var account = await AuthManager.signInSilently();
    _currentUser = account;
    if (account != null) {
      _loadFiles();
      Navigator.pushReplacementNamed(context, '/sheets');
    }
  }

  Future<void> handleSignIn(BuildContext context) async {
    print("signing in");
    var account = await AuthManager.signIn();
    _currentUser = account;
    if (account != null) {
      _loadFiles();
      Navigator.pushReplacementNamed(context, '/sheets');
    }
  }

  Future<void> _loadFiles() async {
    if (_currentUser == null) return;

    GoogleSignInAuthentication authentication =
        await _currentUser.authentication;
    print('authentication: $authentication');
    final client = MyClient(defaultHeaders: {
      'Authorization': 'Bearer ${authentication.accessToken}'
    });
    DriveApi driveApi = DriveApi(client);
    var files = await driveApi.files
        .list(q: 'mimeType=\'application/vnd.google-apps.spreadsheet\'');
    _items = files.items;
    notifyListeners();
  }
}
