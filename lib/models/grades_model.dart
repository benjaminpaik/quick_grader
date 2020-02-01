import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart';
import '../misc/authorization.dart';
import '../misc/my_client.dart';

final sheetsRoute = '/sheets';
final gradesRoute = '/grades';

final _baseRow = 2;
final _baseColumn = 1;

class SheetSelectorModel extends ChangeNotifier {
  SheetsApi _sheetsApi;
  GoogleSignInAccount _currentUser;
  List<File> _files = [];
  List<String> _filePath;
  String _fileId;
  ValueRange _spreadSheet;
  List<String> _tabNames;
  int _selectedTabIndex;
  List<String> _assignmentList;
  int _assignmentIndex;
  List<int> _gradesList;

  SheetSelectorModel()
      : _currentUser = null,
        _filePath = [],
        _spreadSheet = null,
        _tabNames = [],
        _assignmentList = [],
        _gradesList = [],
        _assignmentIndex = 0,
        _selectedTabIndex = 0;

  UnmodifiableListView<File> get fileList => UnmodifiableListView(_files);
  ValueRange get spreadSheet => _spreadSheet;
  List<String> get tabNames => _tabNames;
  List<String> get assignmentList => _assignmentList;
  String get selectedSheet {
    if (_selectedTabIndex >= 0)
      return _tabNames[_selectedTabIndex];
    else
      return null;
  }
  String get selectedAssignment {
    if (_assignmentIndex >= 0)
      return _assignmentList[_assignmentIndex];
    else
      return null;
  }

  void setSelectedTab(String selection) async {
    _selectedTabIndex = _tabNames.indexOf(selection);
    if (_selectedTabIndex >= 0) {
      _spreadSheet =
      await _sheetsApi.spreadsheets.values.get(_fileId, _tabNames[_selectedTabIndex]);
      _assignmentList = _spreadSheet.values.first
          .sublist(1)
          .map((val) => val.toString())
          .toList();
      setSelectedAssignment(_assignmentList.first);
      notifyListeners();
    }
  }

  void setSelectedAssignment(String selection) async {
    _assignmentIndex = _assignmentList.indexOf(selection);
    if (_assignmentIndex >= 0) {
      _spreadSheet = await _sheetsApi.spreadsheets.values
          .get(_fileId, _tabNames[_selectedTabIndex]);
      _assignmentList = _spreadSheet.values.first
          .sublist(1)
          .map((val) => val.toString())
          .toList();

      int rowIndex = _assignmentIndex + 1;
      _gradesList = _spreadSheet.values.sublist(1).map((row) {
        try {
          return int.parse(row[rowIndex].toString().trim());
        } catch (e) {
          return 0;
        }
      }).toList();
    }
    notifyListeners();
  }

  Future<void> signInSilently(BuildContext context) async {
    var account = await AuthManager.signInSilently();
    _currentUser = account;
    if (account != null) {
      _loadFiles('root', true);
      Navigator.pushReplacementNamed(context, sheetsRoute);
    }
  }

  Future<void> handleSignIn(BuildContext context) async {
    var account = await AuthManager.signIn();
    _currentUser = account;
    if (account != null) {
      _loadFiles('root', true);
      Navigator.pushReplacementNamed(context, sheetsRoute);
    }
  }

  Future<void> _loadFiles(String directory, bool addToPath) async {
    if (_currentUser == null) return;
    if (addToPath) {
      _filePath.add(directory);
    }

    GoogleSignInAuthentication authentication =
        await _currentUser.authentication;
    final client = MyClient(defaultHeaders: {
      'Authorization': 'Bearer ${authentication.accessToken}'
    });
    DriveApi driveApi = DriveApi(client);
    var response = await driveApi.files.list(
      q: "'" +
          directory +
          "' in parents and (mimeType=\'application/vnd.google-apps.folder\' or mimeType=\'application/vnd.google-apps.spreadsheet\')",
      $fields: "files(id, name, mimeType, createdTime, owners)",
      spaces: 'drive',
    );
    _files = response.files;
    notifyListeners();
  }

  Future<void> _loadSpreadsheet(BuildContext context, String fileId) async {
    if (_currentUser == null) return;

    GoogleSignInAuthentication authentication =
    await _currentUser.authentication;
    print('authentication: $authentication');
    final client = MyClient(defaultHeaders: {
      'Authorization': 'Bearer ${authentication.accessToken}'
    });

    _fileId = fileId;
    _sheetsApi = SheetsApi(client);

    final sheetInfo = await _sheetsApi.spreadsheets.get(_fileId);
    _tabNames =
        sheetInfo.sheets.map((sheet) => sheet.properties.title).toList();

    if (_tabNames.length > 0) {
      _spreadSheet =
      await _sheetsApi.spreadsheets.values.get(_fileId, _tabNames.first);
      _assignmentList = _spreadSheet.values.first
          .sublist(1)
          .map((val) => val.toString())
          .toList();
      setSelectedAssignment(_assignmentList.first);
      Navigator.pushNamed(context, gradesRoute);
      notifyListeners();
    }
  }

  Future<void> updateDirectory(BuildContext context, File file) async {
    String mimeType = file.mimeType.toString();
    if (mimeType.contains("spreadsheet")) {
      _loadSpreadsheet(context, file.id);
    } else if (mimeType.contains("folder")) {
      _loadFiles(file.id, true);
    }
  }

  Future<void> exitDirectory(BuildContext context) async {
    if (_filePath.length > 1) {
      _filePath.removeLast();
    }
    _loadFiles(_filePath.last, false);
  }

  Future<void> assignGrade(int studentIndex, int value) async {
    if (_currentUser == null || _assignmentIndex < 0) return;

    GoogleSignInAuthentication authentication =
        await _currentUser.authentication;
    print('authentication: $authentication');

    ValueRange vr = new ValueRange.fromJson({
      "values": [
        [value.toString()]
      ]
    });

    String writeRange = _getRange(_tabNames[_selectedTabIndex], _assignmentIndex, studentIndex);
    if (writeRange != null) {
      _sheetsApi.spreadsheets.values
          .update(vr, _fileId, writeRange, valueInputOption: "USER_ENTERED");
      _gradesList[studentIndex] = value;
      notifyListeners();
    }
  }

  void updateGrade(int studentIndex, int value) async {
    if (_assignmentIndex >= 0) {
      _gradesList[studentIndex] = value;
      notifyListeners();
    }
  }

  int getGrade(int studentIndex) {
    var assignmentGrade = 0;
    if (studentIndex < _gradesList.length) {
      assignmentGrade = _gradesList[studentIndex];
    }
    return assignmentGrade;
  }
}

String _getRange(String tabName, int assignmentIndex, int studentIndex) {
  String rangeString;
  // make sure both indices are valid
  if (assignmentIndex >= 0 && studentIndex >= 0) {
    String columnLetter = _getColumnLetter(_baseColumn + assignmentIndex);
    int rowNumber = _baseRow + studentIndex;
    rangeString = "$tabName!$columnLetter${rowNumber.toString()}";
  }
  return rangeString;
}

String _getColumnLetter(int value) {
  int charCode = value + 65;
  if (charCode < 65)
    charCode = 65;
  else if (charCode > 90) charCode = 90;
  String temp = String.fromCharCode(charCode);
  return temp;
}

bool isSpreadsheet(File file) {
  return file.mimeType.toString().contains('spreadsheet');
}

bool isFolder(File file) {
  return file.mimeType.toString().contains('folder');
}
