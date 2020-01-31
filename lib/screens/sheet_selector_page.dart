import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:provider/provider.dart';
import 'package:quick_grader/models/grades_model.dart';
import 'package:kt_dart/kt.dart';
import 'package:intl/intl.dart';

class SheetSelectorScreen extends StatelessWidget {
  final String title;

  const SheetSelectorScreen({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: _SheetSelectorWidget(),
      ),
    );
  }
}

class _SheetSelectorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<SheetSelectorModel, List<File>>(
      selector: (_, sheetSelectorModel) => sheetSelectorModel.fileList,
      builder: (_, fileList, child) {
        final sheetList = fileList;
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(0.0),
            itemCount: sheetList.length,
            itemBuilder: (BuildContext context, int index) {
              if (index < sheetList.length) {
                return GestureDetector(
                  key: ObjectKey(index),
                  child: FileWidget(sheetList[index]),
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
  final formatter = DateFormat('hh:mm EEE, MMM d, yyyy');
  final File file;

  FileWidget(this.file);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1.0, color: Colors.blue.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: Colors.white.withOpacity(0.8),
      child: RippleWidget(
        radius: 8.0,
        onTap: () {
            final sheetSelectorModel = Provider.of<SheetSelectorModel>(context, listen: false);
            sheetSelectorModel.updateDirectory(context, file);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                file.name,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 4.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      formatter.format(file.createdTime),
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    KtList.from(file.owners.map((element) => element.displayName)).joinToString(),
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RippleWidget extends StatelessWidget {
  final Color color;
  final Color highlightColor;
  final Color splashColor;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final BorderRadius borderRadius;
  final double radius;
  final Widget child;

  RippleWidget({
    this.color = Colors.blueAccent,
    this.splashColor,
    this.highlightColor,
    this.radius,
    this.borderRadius = BorderRadius.zero,
    this.onTap,
    this.onLongPress,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          splashColor: splashColor ?? color.withOpacity(0.3),
          highlightColor: highlightColor ?? color.withOpacity(0.2),
          borderRadius:
              radius != null ? BorderRadius.circular(radius) : borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          child: child,
        ),
      ),
    );
  }
}
