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
    return Selector<SheetSelectorModel, List<List<Object>>>(
      selector: (_, sheetSelectorModel) =>
          sheetSelectorModel.spreadSheet.values.sublist(1),
      builder: (context, students, child) {
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(0.0),
            itemCount: students.length,
            itemBuilder: (BuildContext context, int index) {
              if (index < students.length) {
                return GestureDetector(
                  key: ObjectKey(index),
                  child: _StudentWidget(index, students[index].first.toString().toUpperCase()),
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
      SizedBox(height: _buttonHeight, child: _GradeSliderWidget(studentIndex)),
      Divider(
        height: 20.0,
      ),
    ]);
  }
}

class _GradeSliderWidget extends StatelessWidget {
  final studentIndex;
  _GradeSliderWidget(this.studentIndex);

  @override
  Widget build(BuildContext context) {
    final sheetSelectorModel =
        Provider.of<SheetSelectorModel>(context, listen: false);

    return Selector<SheetSelectorModel, int>(
      selector: (_, sheetSelectorModel) =>
          sheetSelectorModel.getGrade(studentIndex),
      builder: (context, grade, child) {
        return Slider(
          onChanged: (value) {
            sheetSelectorModel.updateGrade(studentIndex, value.round());
          },
          onChangeEnd: (value) {
            sheetSelectorModel.assignGrade(studentIndex, value.round());
          },
          min: 0.0,
          max: 100.0,
          divisions: 100,
          value: grade.toDouble(),
          label: grade.toString(),
        );
      },
    );
  }
}

class _AssignmentSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sheetSelectorModel =
        Provider.of<SheetSelectorModel>(context, listen: false);
    return Selector<SheetSelectorModel, String>(
        selector: (_, sheetSelectorModel) =>
            sheetSelectorModel.selectedAssignment,
        builder: (context, selectedAssignment, child) {
          return DropdownButton<String>(
            value: selectedAssignment,
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
            items: sheetSelectorModel.assignmentList
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          );
        });
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
