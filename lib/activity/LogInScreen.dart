import 'package:flutter/material.dart';
import 'package:wheelit/classes/AuthenticationManager.dart';

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: RaisedButton(
        child: Text('LOGIN'),
        onPressed: () => AuthenticationManager().login(),
      )),
    );
  }
}
