import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool emailValid = false;
  String _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              child: Image(
                image: AssetImage("assets/images/DrawerHeaderImage.jpg"),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(input);
                          if (input.isEmpty) {
                            return '  Enter Email';
                          } else if (emailValid == false) {
                            return '  Invalid email format';
                          } else {
                            _email = input;
                          }
                        },
                        decoration: InputDecoration(
                            labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      ),
                    ),
                    SizedBox(height: 20),
                    RaisedButton(
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          FirebaseAuth.instance
                              .sendPasswordResetEmail(email: _email)
                              .whenComplete(() {
                            Navigator.pushReplacementNamed(context, '/login');
                          });
                        }
                      },
                      child: Text('SUBMIT',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold)),
                      color: Theme.of(context).accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'A message will be sent to your email account',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

Future<AlertDialog> floatingMessage(String _email) async {
  return AlertDialog(
    title: Text("prova"),
    actions: <Widget>[
      MaterialButton(
        elevation: 5.0,
        child: Text("ok"),
        onPressed: () {},
      )
    ],
  );
}
