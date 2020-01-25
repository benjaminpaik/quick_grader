import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_grader/models/grades_model.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentsScreen extends StatelessWidget {
  final String title;

  const StudentsScreen({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          _AssignmentSelector(),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: _StudentListWidget(),
      ),
    );
  }
}

class _StudentListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SheetSelectorModel>(
      builder: (context, sheetSelectorModel, child) {
        final spreadSheetValues =
            sheetSelectorModel.spreadSheet.values.sublist(1);
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(0.0),
            itemCount: spreadSheetValues.length,
            itemBuilder: (BuildContext context, int index) {
              if (index < spreadSheetValues.length) {
                return GestureDetector(
                  key: ObjectKey(index),
                  child: _StudentWidget(index,
                      spreadSheetValues[index].first.toString().toUpperCase()),
                );
              } else {
                return null;
              }
            });
      },
    );
  }
}

class _StudentWidget extends StatelessWidget {
  static final _studentFont =
      GoogleFonts.iBMPlexMono(fontWeight: FontWeight.w500);
  static final _buttonHeight = 75.0;
  final String text;
  final int studentIndex;

  _StudentWidget(this.studentIndex, this.text);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ListTile(
        title: Text(
          text,
          style: _studentFont,
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(height: _buttonHeight, child: _GradeButtonWidget(studentIndex)),
      Divider(
        height: 20.0,
      ),
    ]);
  }
}

class _GradeButtonWidget extends StatelessWidget {
  static final _buttonFont = GoogleFonts.iBMPlexMono();
  static final _defaultColor = const Color(0xFFF5F5F5);
  static final _selectedColor = const Color(0xFF9E9E9E);
  static final _buttonNames = const ["LOW", "MED", "HIGH"];
  final studentIndex;

  _GradeButtonWidget(this.studentIndex);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: _buttonNames.length,
        itemBuilder: (BuildContext context, int buttonIndex) {
          final sheetSelectorModel =
              Provider.of<SheetSelectorModel>(context, listen: true);
          final gradesList = sheetSelectorModel.gradesList;

          if (buttonIndex < _buttonNames.length) {
            var buttonColor = _defaultColor;
            if (studentIndex < gradesList.length &&
                gradesList[studentIndex] == buttonIndex.toString()) {
              buttonColor = _selectedColor;
            }

            return RaisedButton(
              padding: EdgeInsets.all(0.0),
              child: Text(
                _buttonNames[buttonIndex],
                style: _buttonFont,
              ),
              color: buttonColor,
              onPressed: () {
                sheetSelectorModel.assignGrade(studentIndex, buttonIndex);
              },
            );
          } else {
            return null;
          }
        },
      ),
    );
  }
}

/*
class _StudentRowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SheetSelectorModel>(
      builder: (context, sheetSelectorModel, child) {
        final sheetList = sheetSelectorModel.sheetList;
        return ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: EdgeInsets.all(0.0),
            itemCount: sheetList.length,
            itemBuilder: (BuildContext context, int index) {
              if (index < sheetList.length) {
                return GestureDetector(
                  key: ObjectKey(index),
                  child: FileWidget(
                      sheetList[index]),
                );
              } else {
                return null;
              }
            });
      },
    );
  }
}
 */

class _AssignmentSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sheetSelectorModel = Provider.of<SheetSelectorModel>(context);
    final assignments = sheetSelectorModel.assignmentList;

    return DropdownButton<String>(
      value: sheetSelectorModel.selectedAssignment,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.grey),
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      onChanged: (String newValue) {
        sheetSelectorModel.setSelectedAssignment(newValue);
      },
      items: assignments.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
