import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_grader/models/grades_model.dart';
import 'package:google_fonts/google_fonts.dart';

class GradesScreen extends StatelessWidget {
  final String title;

  const GradesScreen({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _TabSelector(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, sheetsRoute);
          },
        ),
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
    return Selector<GradesModel, List<List<Object>>>(
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
                  child: _StudentWidget(
                      index, students[index].first.toString().toUpperCase()),
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
  final String _studentName;
  final int studentIndex;

  _StudentWidget(this.studentIndex, this._studentName);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              _studentName,
              style: _studentFont,
              textAlign: TextAlign.left,
            ),
            _GradeDisplay(studentIndex),
          ],
        ),
      ),
      SizedBox(
          height: 75.0,
          child: Container(
            child: _GradeSliderWidget(studentIndex),
          )),
      Divider(
        height: 20.0,
      ),
    ]);
  }
}

class _GradeDisplay extends StatelessWidget {
  final studentIndex;
  _GradeDisplay(this.studentIndex);
  @override
  Widget build(BuildContext context) {
    return Selector<GradesModel, int>(
      selector: (_, sheetSelectorModel) =>
          sheetSelectorModel.getGrade(studentIndex),
      builder: (context, grade, child) {
        return Text(
          grade.toString(),
          style: GoogleFonts.b612Mono(),
          textAlign: TextAlign.right,
        );
      },
    );
  }
}

class _GradeSliderWidget extends StatelessWidget {
  final studentIndex;
  _GradeSliderWidget(this.studentIndex);

  @override
  Widget build(BuildContext context) {
    return Selector<GradesModel, int>(
      selector: (_, sheetSelectorModel) =>
          sheetSelectorModel.getGrade(studentIndex),
      builder: (context, grade, child) {
        final gradesModel = Provider.of<GradesModel>(context, listen: false);
        return Slider(
          onChanged: (value) {
            gradesModel.updateGrade(studentIndex, value.round());
          },
          onChangeEnd: (value) {
            gradesModel.assignGrade(studentIndex, value.round());
          },
          min: 0.0,
          max: gradesModel.maxPoints.toDouble(),
          divisions: gradesModel.maxPoints,
          value: grade.toDouble(),
          label: grade.toString(),
          activeColor: Colors.black,
          inactiveColor: Colors.grey,
        );
      },
    );
  }
}

class _TabSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gradesModel = Provider.of<GradesModel>(context, listen: false);
    return Selector<GradesModel, String>(
        selector: (_, sheetSelectorModel) => sheetSelectorModel.selectedSheet,
        builder: (context, selectedSheet, child) {
          return DropdownButton<String>(
            value: selectedSheet,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.grey),
            underline: Container(
              height: 2,
              color: Colors.black,
            ),
            onChanged: (String newValue) {
              gradesModel.setSelectedTab(newValue);
            },
            items: gradesModel.tabNames
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

class _AssignmentSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gradesModel = Provider.of<GradesModel>(context, listen: false);
    return Selector<GradesModel, String>(
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
              gradesModel.setSelectedAssignment(newValue);
            },
            items: gradesModel.assignmentList
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(_formatAssignmentText(value)),
              );
            }).toList(),
          );
        });
  }

  String _formatAssignmentText(String assignment) {
    int assignmentPoints = getAssignmentPoints(assignment);
    String pointsText = '($assignmentPoints)';
    if (assignmentPoints > 0) {
      return assignment.replaceFirst(pointsText, '');
    }
    return assignment;
  }
}
