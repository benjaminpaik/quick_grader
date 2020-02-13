import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_grader/screens/grades_page.dart';
import 'models/grades_model.dart';
import 'screens/login_page.dart';
import 'screens/sheet_selector_page.dart';

void main() => runApp(new QuickGrade());

class QuickGrade extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GradesModel>(
            create: (context) => GradesModel()),
      ],
      child: MaterialApp(
        title: 'Quick Grader',
        theme: ThemeData(
          primaryColor: Colors.black,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(title: 'LOGIN'),
          '/sheets': (context) => SheetSelectorScreen(title: 'SHEETS'),
          '/grades': (context) => GradesScreen(title: 'STUDENTS'),
        },
      ),
    );
  }
}
