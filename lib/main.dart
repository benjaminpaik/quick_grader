import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_grader/screens/grades_page.dart';
import 'models/grades_model.dart';
import 'screens/login_page.dart';
import 'screens/sheet_selector_page.dart';

void main() => runApp(QuickGrade());

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
          appBarTheme: const AppBarTheme(color: Colors.black),
          primaryColor: Colors.black,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(title: 'LOGIN'),
          '/sheets': (context) => const SheetSelectorScreen(title: 'SHEETS'),
          '/grades': (context) => const GradesScreen(title: 'STUDENTS'),
        },
      ),
    );
  }
}
