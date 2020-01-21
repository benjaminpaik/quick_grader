import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_grader/screens/students_page.dart';
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
        ChangeNotifierProvider<SheetSelectorModel>(create: (context) => SheetSelectorModel()),
      ],
      child: MaterialApp(
        title: 'Quick Grader',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(title: 'Login Screen'),
          '/sheets': (context) => SheetSelectorScreen(title: 'Sheets Screen',),
          '/grades': (context) => StudentsScreen(title: 'Students Screen',),
        },
      ),
    );
  }
}
