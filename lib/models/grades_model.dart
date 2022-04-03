import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart';
import '../misc/authorization.dart';
import '../misc/my_client.dart';

const loginRoute = '/';
const sheetsRoute = '/sheets';
const gradesRoute = '/grades';

const _defaultMaxPoints = 100;
const _baseRow = 2;
const _baseColumn = 1;

class GradesModel extends ChangeNotifier {
  SheetsApi? _sheetsApi;
  GoogleSignInAccount? _currentUser;
  List<File> _files = [];
  final List<String> _filePath = [];
  String _fileId = "";
  ValueRange? _spreadSheet;
  List<String> _tabNames = [];
  int _selectedTabIndex = 0;
  List<String> _assignmentList = [];
  int _assignmentIndex = 0;
  int _maxPoints = _defaultMaxPoints;
  List<int> _gradesList = [];

  UnmodifiableListView<File> get fileList => UnmodifiableListView(_files);

  ValueRange? get spreadSheet => _spreadSheet;

  List<String> get tabNames => _tabNames;

  List<String> get assignmentList => _assignmentList;

  int get maxPoints => _maxPoints;

  String get selectedSheet {
    return _tabNames[_selectedTabIndex];
  }

  String get selectedAssignment {
    return _assignmentList[_assignmentIndex];
  }

  void setSelectedTab(String selection) async {
    final index = _tabNames.indexOf(selection);
    if (index >= 0) {
      _selectedTabIndex = index;
      _spreadSheet = await _sheetsApi?.spreadsheets.values
          .get(_fileId, _tabNames[_selectedTabIndex]);
      _assignmentList = _spreadSheet?.values?.first
              .sublist(1)
              .map((val) => val.toString())
              .toList() ??
          [];

      if (_assignmentList.isNotEmpty) {
        setSelectedAssignment(_assignmentList.first);
        notifyListeners();
      }
    }
  }

  void setSelectedAssignment(String selection) async {
    final index = _assignmentList.indexOf(selection);
    if (index >= 0) {
      _assignmentIndex = index;
      _spreadSheet = await _sheetsApi?.spreadsheets.values
          .get(_fileId, _tabNames[_selectedTabIndex]);
      _assignmentList = _spreadSheet?.values?.first
              .sublist(1)
              .map((val) => val.toString())
              .toList() ??
          [];
      _maxPoints = getAssignmentPoints(selection);
      if (_maxPoints == 0) _maxPoints = _defaultMaxPoints;
      int rowIndex = _assignmentIndex + 1;
      _gradesList = _spreadSheet!.values!.sublist(1).map((row) {
        try {
          return int.parse(row[rowIndex].toString().trim());
        } catch (e) {
          return 0;
        }
      }).toList();
    }
    notifyListeners();
  }

  Future<void> handleSignIn(BuildContext context) async {
    if (_currentUser == null) {
      _currentUser = await AuthManager.signInSilently();
    } else {
      _currentUser = await AuthManager.signIn();
    }
    if (_currentUser != null) {
      _loadFiles('root', true);
      Navigator.pushReplacementNamed(context, sheetsRoute);
    }
  }

  Future<void> handleSignOut(BuildContext context) async {
    _filePath.clear();
    AuthManager.signOut();
    Navigator.pushReplacementNamed(context, loginRoute);
  }

  Future<void> _loadFiles(String directory, bool addToPath) async {
    if (_currentUser == null) return;
    if (addToPath) {
      _filePath.add(directory);
    }

    GoogleSignInAuthentication authentication =
        await _currentUser!.authentication;
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

    if (response.files != null) {
      _files = response.files!;
    }
    notifyListeners();
  }

  Future<void> _loadSpreadsheet(BuildContext context, String fileId) async {
    if (_currentUser == null) return;

    GoogleSignInAuthentication authentication =
        await _currentUser!.authentication;
    final client = MyClient(defaultHeaders: {
      'Authorization': 'Bearer ${authentication.accessToken}'
    });

    _fileId = fileId;
    _sheetsApi = SheetsApi(client);

    final sheetInfo = await _sheetsApi?.spreadsheets.get(_fileId);
    _tabNames = sheetInfo?.sheets
            ?.map((sheet) => sheet.properties?.title ?? "")
            .toList() ??
        [];

    if (_tabNames.isNotEmpty) {
      _spreadSheet =
          await _sheetsApi!.spreadsheets.values.get(_fileId, _tabNames.first);
      _assignmentList = _spreadSheet?.values?.first
              .sublist(1)
              .map((val) => val.toString())
              .toList() ??
          [];

      if (_assignmentList.isNotEmpty) {
        setSelectedAssignment(_assignmentList.first);
        Navigator.pushNamed(context, gradesRoute);
        notifyListeners();
      }
    }
  }

  Future<void> updateDirectory(BuildContext context, File file) async {
    String mimeType = file.mimeType.toString();

    if (file.id != null) {
      if (mimeType.contains("spreadsheet")) {
        _loadSpreadsheet(context, file.id!);
      } else if (mimeType.contains("folder")) {
        _loadFiles(file.id!, true);
      }
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

    ValueRange vr = ValueRange.fromJson({
      "values": [
        [value.toString()]
      ]
    });

    String writeRange =
        _getRange(_tabNames[_selectedTabIndex], _assignmentIndex, studentIndex);
    if (writeRange.isNotEmpty) {
      _sheetsApi?.spreadsheets.values
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
      assignmentGrade = (_gradesList[studentIndex] > _maxPoints)
          ? _maxPoints
          : _gradesList[studentIndex];
    }
    return assignmentGrade;
  }
}

String _getRange(String tabName, int assignmentIndex, int studentIndex) {
  String rangeString = "";
  // make sure both indices are valid
  if (assignmentIndex >= 0 && studentIndex >= 0) {
    String columnLetter = _getColumnLetter(_baseColumn + assignmentIndex);
    int rowNumber = _baseRow + studentIndex;
    rangeString = "$tabName!$columnLetter${rowNumber.toString()}";
  }
  return rangeString;
}

String _getColumnLetter(int columnNumber) {
  int dividend = columnNumber + 1;
  String columnName = "";
  int modulo;

  while (dividend > 0) {
    modulo = (dividend - 1) % 26;
    columnName = String.fromCharCode(65 + modulo) + columnName;
    dividend = ((dividend - modulo) ~/ 26);
  }
  return columnName;
}

int getAssignmentPoints(String assignment) {
  int assignmentPoints = 0;
  int startIndex = assignment.indexOf("(");
  int endIndex = assignment.indexOf(")");
  // string contains parenthesis
  if (startIndex >= 0 && endIndex > startIndex) {
    String pointsString = assignment.substring(startIndex + 1, endIndex);
    assignmentPoints = int.tryParse(pointsString) ?? 0;
  }
  return assignmentPoints;
}

bool isSpreadsheet(File file) {
  return file.mimeType.toString().contains('spreadsheet');
}

bool isFolder(File file) {
  return file.mimeType.toString().contains('folder');
}
