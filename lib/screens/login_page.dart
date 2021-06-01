import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_grader/models/grades_model.dart';

class LoginScreen extends StatelessWidget {
  final String title;

  const LoginScreen({this.title = ""});

  @override
  Widget build(BuildContext context) {
    final gradesModel = Provider.of<GradesModel>(context, listen: false);
    gradesModel.handleSignIn(context);
    return Scaffold(
      body: Container(
        color: Colors.black,
      ),
    );
  }
}
