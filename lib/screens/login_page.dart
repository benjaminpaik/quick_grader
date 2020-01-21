import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_grader/models/grades_model.dart';

class LoginScreen extends StatelessWidget {
  final String title;

  const LoginScreen({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.deepPurple,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              Text(
                'Log in using your Google account',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                child: Text('Log in'),
                onPressed: () {
                  final sheetSelectorModel =
                  Provider.of<SheetSelectorModel>(context, listen: false);
                  sheetSelectorModel.handleSignIn(context);
                },
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
