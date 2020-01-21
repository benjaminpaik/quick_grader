import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_grader/models/grades_model.dart';

class SheetSelectorPage extends StatelessWidget {
  final String title;

  const SheetSelectorPage({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SheetSelectorWidget(),
      ),
    );
  }
}

class SheetSelectorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SheetSelectorModel>(
      builder: (context, sheetSelectorModel, child) {
        final sheetList = sheetSelectorModel.sheetList;
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(0.0),
            itemCount: sheetList.length,
            itemBuilder: (BuildContext context, int index) {
              if (index < sheetList.length) {
                return GestureDetector(
                  key: ObjectKey(index),
                  child: FileWidget(index, sheetList[index].title),
                );
              } else {
                return null;
              }
            });
      },
    );
  }
}

class FileWidget extends StatelessWidget {
  static final _taskFont =
      const TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold);
  final String text;
  final int index;

  FileWidget(this.index, this.text);

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
