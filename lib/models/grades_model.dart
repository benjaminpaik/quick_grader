import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart';

import 'my_client.dart';

final _sheetRange = 'Sheet1';
final _baseRow = 2;
final _baseColumn = 1;

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
  String _fileId;
  ValueRange _spreadSheet;
  List<File> _files = [];
  List<String> _assignmentList = [];
  int _assignmentSelectionIndex;
  SheetsApi _sheetsApi;

  SheetSelectorModel()
      : _currentUser = null,
        _spreadSheet = null,
        _assignmentList = null,
        _assignmentSelectionIndex = -1;

  UnmodifiableListView<File> get sheetList => UnmodifiableListView(_files);
  ValueRange get spreadSheet => _spreadSheet;
  List<String> get assignmentList => _assignmentList;
  String get selectedAssignment {
    if(_assignmentSelectionIndex >= 0) {
      return _assignmentList[_assignmentSelectionIndex];
    }
    else {
      return null;
    }
  }

  set selectedAssignment(String selection) {
    _assignmentSelectionIndex = _assignmentList.indexOf(selection);
    notifyListeners();
  }

  Future<void> signInSilently(BuildContext context) async {
    var account = await AuthManager.signInSilently();
    _currentUser = account;
    if (account != null) {
      _loadFiles();
      Navigator.pushReplacementNamed(context, '/sheets');
    }
  }

  Future<void> handleSignIn(BuildContext context) async {
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
    _files = files.items;
    notifyListeners();
  }

  Future<void> loadSpreadsheet(BuildContext context, String fileId) async {
    if (_currentUser == null) return;

    GoogleSignInAuthentication authentication =
        await _currentUser.authentication;
    print('authentication: $authentication');
    final client = MyClient(defaultHeaders: {
      'Authorization': 'Bearer ${authentication.accessToken}'
    });

    _fileId = fileId;
    _sheetsApi = SheetsApi(client);
    _spreadSheet =
        await _sheetsApi.spreadsheets.values.get(fileId, _sheetRange);
    _assignmentList = _spreadSheet.values.first
        .sublist(1)
        .map((val) => val.toString())
        .toList();

    Navigator.pushNamed(context, '/grades');
    notifyListeners();
  }

  Future<void> assignGrade(int studentIndex, int value) async {
    if (_currentUser == null) return;

    GoogleSignInAuthentication authentication =
        await _currentUser.authentication;
    print('authentication: $authentication');

    ValueRange vr = new ValueRange.fromJson({
      "values": [
        [value.toString()]
      ]
    });

    String range = _getRange(_assignmentSelectionIndex, studentIndex);
    if(range != null) {
      _sheetsApi.spreadsheets.values
          .update(vr, _fileId, range, valueInputOption: "USER_ENTERED");
    }
  }
}

String _getRange(int assignmentIndex, int studentIndex) {
  String rangeString;
  // make sure both indices are valid
  if(assignmentIndex >= 0 && studentIndex >= 0) {
    String columnLetter = _getColumnLetter(_baseColumn + assignmentIndex);
    int rowNumber = _baseRow + studentIndex;
    rangeString = columnLetter + rowNumber.toString();
  }
  return rangeString;
}

String _getColumnLetter(int value) {
  int charCode = value + 65;
  if(charCode < 65) charCode = 65;
  else if(charCode > 90) charCode = 90;
  String temp = String.fromCharCode(charCode);
  return temp;
}
