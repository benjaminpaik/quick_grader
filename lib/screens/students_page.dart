import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_grader/models/grades_model.dart';

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
        final spreadSheetValues = sheetSelectorModel.spreadSheet.values.sublist(1);
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(0.0),
            itemCount: spreadSheetValues.length,
            itemBuilder: (BuildContext context, int index) {
              if (index < spreadSheetValues.length) {
                return GestureDetector(
                  key: ObjectKey(index),
                  child: _StudentWidget(
                      index, spreadSheetValues[index].first.toString()),
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
  static final _taskFont =
      const TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold);
  final String text;
  final int index;

  _StudentWidget(this.index, this.text);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Material(
        child: ListTile(
          title: Column(children: <Widget>[
            Text(
              text,
              style: _taskFont,
              textAlign: TextAlign.center,
            ),
          ]),
          onTap: () {},
        ),
      ),
      Divider(
        height: 0.0,
      ),
    ]);
  }
}

class _AssignmentSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sheetSelectorModel = Provider.of<SheetSelectorModel>(context);
    final assignments = sheetSelectorModel.assignmentList;

    return DropdownButton<String>(
      value: sheetSelectorModel.assignmentSelection,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        sheetSelectorModel.assignmentSelection = newValue;
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
