import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:provider/provider.dart';
import 'package:quick_grader/models/grades_model.dart';
import 'package:intl/intl.dart';

class SheetSelectorScreen extends StatelessWidget {
  final String title;
  final String ADD_SHEET_TIP = "create a new grades spreadsheet";

  const SheetSelectorScreen({this.title = ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final sheetSelectorModel =
                Provider.of<GradesModel>(context, listen: false);
            sheetSelectorModel.exitDirectory(context);
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'LOGOUT',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              final sheetSelectorModel =
                  Provider.of<GradesModel>(context, listen: false);
              sheetSelectorModel.handleSignOut(context);
            },
          )
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: _SheetSelectorWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: ADD_SHEET_TIP,
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}

class _SheetSelectorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<GradesModel, List<File>>(
      selector: (_, sheetSelectorModel) => sheetSelectorModel.fileList,
      builder: (_, fileList, child) {
        final sheetList = fileList;
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.all(0.0),
            itemCount: sheetList.length,
            itemBuilder: (BuildContext context, int index) {
              final file = (index < sheetList.length)
                  ? sheetList[index]
                  : sheetList.last;
              return GestureDetector(
                key: ObjectKey(index),
                child: FileWidget(file),
              );
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
    final fileColor = isSpreadsheet(file)
        ? Colors.green.withOpacity(0.8)
        : Colors.white.withOpacity(0.8);

    final owners =
        file.owners?.map((element) => element.displayName).join(" ") ?? "";
    final createdTime =
        file.createdTime != null ? formatter.format(file.createdTime!) : "";

    return Card(
      elevation: 0.0,
      margin: const EdgeInsets.all(2.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1.0, color: Colors.black.withOpacity(0.4)),
      ),
      color: fileColor,
      child: RippleWidget(
        onTap: () {
          final gradesModel = Provider.of<GradesModel>(context, listen: false);
          gradesModel.updateDirectory(context, file);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                file.name ?? "",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(1.0),
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      createdTime,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    owners,
                    style: const TextStyle(
                      fontSize: 14.0,
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
  final Color? highlightColor;
  final Color? splashColor;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final BorderRadius borderRadius;
  final double? radius;
  final Widget child;

  const RippleWidget({
    this.color = Colors.blueAccent,
    this.splashColor,
    this.highlightColor,
    this.radius,
    this.borderRadius = BorderRadius.zero,
    this.onTap,
    this.onLongPress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        splashColor: splashColor ?? color.withOpacity(0.3),
        highlightColor: highlightColor ?? color.withOpacity(0.2),
        borderRadius: borderRadius,
        onTap: onTap,
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}
